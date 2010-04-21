//
//  MusicPlayerAUGraphWithQueueOutput.m
//  RetroPlayer
//
//  Created by Dave Dribin on 4/19/10.
//  Copyright 2010 Bit Maki, Inc. All rights reserved.
//

#import "MusicPlayerAUGraphWithQueueOutput.h"

#import "GmeMusicFile.h"
#import "MusicEmu.h"
#import "DDCoreAudio.h"
#import "DDAudioQueue.h"
#import "DDAudioQueueBuffer.h"
#import "DDAudioQueueReader.h"

#define NUM_BUFFERS (sizeof(_buffers)/sizeof(*_buffers))


@interface MusicPlayerAUGraphWithQueueOutput ()
@end

@implementation MusicPlayerAUGraphWithQueueOutput

@synthesize emu = _emu;
@synthesize musicFile = _musicFile;

- (id)initWithDelegate:(id<MusicPlayerOutputDelegate>)delegate;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _delegate = delegate;
    
    return self;
}

- (void)dealloc
{
    [_emu release];
    [_musicFile release];
    
    [super dealloc];
}

// render some silence
static void SilenceData(AudioBufferList *inData)
{
	for (UInt32 i=0; i < inData->mNumberBuffers; i++)
		memset(inData->mBuffers[i].mData, 0, inData->mBuffers[i].mDataByteSize);
}

- (void)audioQueue:(DDAudioQueue *)queue bufferIsAvailable:(DDAudioQueueBuffer *)buffer;
{
    MusicPlayerAUGraphWithQueueOutput * player = self;
    
    if (!player->_shouldBufferDataInCallback) {
        return;
    }
    
    GmeMusicFile * musicFile = player->_musicFile;
    if (musicFile == nil) {
        NSLog(@"No music file");
        return;
    }
    
    NSError * error = nil;
    if (!GmeMusicFilePlay(musicFile, buffer->capacity/2, buffer->bytes, &error)) {
        NSLog(@"GmeMusicFilePlay error: %@ %@", error, [error userInfo]);
        return;
    }
    
    buffer->length = buffer->capacity;
    [_queue enqueueBuffer:buffer];
    
    // Peform after delay to get us out of the callback as some resulting actions
    // that act on the queue may not work when called from the callback
    // [player performSelector:@selector(checkTrackDidEnd) withObject:nil afterDelay:0.0];
    if ([musicFile trackEnded]) {
        NSLog(@"%s:%d trackEnded", __PRETTY_FUNCTION__, __LINE__);
        player->_shouldBufferDataInCallback = NO;
        [_queue enqueueFenceBuffer];
    }
}

- (void)audioQueueDidReceiveFence:(DDAudioQueue *)queue;
{
    [_delegate musicPlayerOutputDidFinishTrack:self];
}

// audio render procedure, don't allocate memory, don't take any locks, don't waste time
static OSStatus MyRenderer(void *							inRefCon,
                           AudioUnitRenderActionFlags *	ioActionFlags,
                           const AudioTimeStamp *			inTimeStamp,
                           UInt32							inBusNumber,
                           UInt32							inNumberFrames,
                           AudioBufferList *				ioData)
{
    MusicPlayerAUGraphWithQueueOutput * player = (MusicPlayerAUGraphWithQueueOutput *)inRefCon;
    
    UInt32 bytesRead = DDAudioQueueReaderRead(player->_queueReader, ioData->mBuffers[0].mData, inNumberFrames*player->_dataFormat.mBytesPerFrame);
    ioData->mBuffers[0].mDataByteSize = bytesRead;
    return noErr;
}

- (void)calculateBufferSizeForSeconds:(Float64)seconds;
{
    _bufferByteSize = _dataFormat.mSampleRate * _dataFormat.mBytesPerPacket * seconds;
    if ((_bufferByteSize % 4) != 0) {
        _bufferByteSize += 4 - (_bufferByteSize % 4);
    }
    NSLog(@"Buffer size: %u (%.3f)", _bufferByteSize,
          ((float)_bufferByteSize) / ((float)_dataFormat.mSampleRate) / ((float)_dataFormat.mBytesPerFrame));
}

- (BOOL)setupWithSampleRate:(long)sampleRate error:(NSError **)error;
{
    _graph = [[DDAudioUnitGraph alloc] init];
    
    _outputNode = [_graph addNodeWithType:kAudioUnitType_Output
                                  subType:kAudioUnitSubType_DefaultOutput];
    [_outputNode retain];
    
#if 0
    _effectNode = [_graph addNodeWithType:kAudioUnitType_Effect
                                  subType:kAudioUnitSubType_MatrixReverb];
#endif
    
    _converterNode = [_graph addNodeWithType:kAudioUnitType_FormatConverter
                                     subType:kAudioUnitSubType_AUConverter];
    [_converterNode retain];
    
    if (_effectNode == nil) {
        [_graph connectNode:_converterNode output:0
                     toNode:_outputNode input:0];
    } else {
        [_graph connectNode:_converterNode output:0
                     toNode:_effectNode input:0];
        [_graph connectNode:_effectNode output:0
                     toNode:_outputNode input:0];
    }
    
    [_graph open];
    
    // 16-bit signed integer, stereo
    memset(&_dataFormat, 0, sizeof(_dataFormat));
    UInt32 formatFlags = (0
                          | kAudioFormatFlagIsPacked 
                          | kAudioFormatFlagIsSignedInteger 
                          | kAudioFormatFlagsNativeEndian
                          );
    
    _dataFormat.mFormatID = kAudioFormatLinearPCM;
    _dataFormat.mSampleRate = 44100;
    _dataFormat.mChannelsPerFrame = 2;
    _dataFormat.mFormatFlags = formatFlags;
    _dataFormat.mBitsPerChannel = 16;
    _dataFormat.mFramesPerPacket = 1;
    _dataFormat.mBytesPerFrame = _dataFormat.mBitsPerChannel * _dataFormat.mChannelsPerFrame / 8;
    _dataFormat.mBytesPerPacket = _dataFormat.mBytesPerFrame * _dataFormat.mFramesPerPacket;
    DDAudioUnit * converterUnit = [_converterNode audioUnit];
    [converterUnit setStreamFormatWithDescription:&_dataFormat];
    
    [_converterNode setInputCallback:MyRenderer context:self forInput:0];
    
    NSLog(@"graph: %@", _graph);
    
    [_graph update];
    [_graph initialize];
    
    _queue = [(DDAudioQueue *)[DDAudioQueue alloc] initWithDelegate:self];
    [_queue scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self calculateBufferSizeForSeconds:0.1];
    for (int i = 0; i < NUM_BUFFERS; i++) {
        _buffers[i] = [_queue allocateBufferWithCapacity:_bufferByteSize error:NULL];
    }
    
    _queueReader = [[DDAudioQueueReader alloc] initWithAudioQueue:_queue];
    
    return YES;
}

- (void)teardownAudio;
{
    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    [_graph stop];
    [_graph uninitialize];
    [_graph close];
    
    [_outputNode release]; _outputNode = nil;
    [_effectNode release]; _effectNode = nil;
    [_converterNode release]; _converterNode = nil;
    [_graph release]; _graph = nil;
    
    [_queue removeFromRunLoop];
    [_queueReader release]; _queueReader = nil;
    [_queue release]; _queue = nil;
}

- (BOOL)startAudio:(NSError **)error;
{
    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    _shouldBufferDataInCallback = YES;

    for (int i = 0; i < NUM_BUFFERS; i++) {
        [self audioQueue:_queue bufferIsAvailable:_buffers[i]];
    }

    [_graph start];
    
    return YES;
}

- (void)stopAudio;
{
    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    _shouldBufferDataInCallback = NO;
    [_graph stop];
    [_queue reset];
    [_queueReader reset];
}

- (BOOL)pauseAudio:(NSError **)error;
{
    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    [_graph stop];
    return YES;
}

- (BOOL)unpauseAudio:(NSError **)error;
{
    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    [_graph start];
    return YES;
}

@end
