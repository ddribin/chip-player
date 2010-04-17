//
//  MusicPlayerAUGraphOutput.m
//  RetroPlayer
//
//  Created by Dave Dribin on 4/17/10.
//  Copyright 2010 Bit Maki, Inc. All rights reserved.
//

#import "MusicPlayerAUGraphOutput.h"
#import "GmeMusicFile.h"
#import "MusicEmu.h"
#import "DDCoreAudio.h"


@interface MusicPlayerAUGraphOutput ()
@end

@implementation MusicPlayerAUGraphOutput

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

static OSStatus MyRenderer(void *							inRefCon,
                           AudioUnitRenderActionFlags *	ioActionFlags,
                           const AudioTimeStamp *			inTimeStamp,
                           UInt32							inBusNumber,
                           UInt32							inNumberFrames,
                           AudioBufferList *				ioData)
{
#if 0
    bzero(ioData->mBuffers[0].mData,
          ioData->mBuffers[0].mDataByteSize);
#else
    MusicPlayerAUGraphOutput * player = (MusicPlayerAUGraphOutput *)inRefCon;

    if (!player->_shouldBufferDataInCallback) {
        bzero(ioData->mBuffers[0].mData, ioData->mBuffers[0].mDataByteSize);
        return noErr;
    }
    
    GmeMusicFile * musicFile = player->_musicFile;
    if (musicFile == nil) {
        NSLog(@"No music file");
        bzero(ioData->mBuffers[0].mData, ioData->mBuffers[0].mDataByteSize);
        return noErr;
    }

    NSError * error = nil;
    if (!GmeMusicFilePlay(musicFile, ioData->mBuffers[0].mDataByteSize/2, ioData->mBuffers[0].mData, &error)) {
        NSLog(@"GmeMusicFilePlay error: %@ %@", error, [error userInfo]);
        return noErr;
    }

    // Peform after delay to get us out of the callback as some resulting actions
    // that act on the queue may not work when called from the callback
    // [player performSelector:@selector(checkTrackDidEnd) withObject:nil afterDelay:0.0];
    if ([musicFile trackEnded]) {
        NSLog(@"%s:%d trackEnded", __PRETTY_FUNCTION__, __LINE__);
        player->_shouldBufferDataInCallback = NO;
        [player performSelectorOnMainThread:@selector(trackEnded) withObject:nil waitUntilDone:NO];
    }
    
#endif
    return noErr;
}


- (BOOL)setupWithSampleRate:(long)sampleRate error:(NSError **)error;
{
    _graph = [[DDAudioUnitGraph alloc] init];
    
    _outputNode = [_graph addNodeWithType:kAudioUnitType_Output
                                  subType:kAudioUnitSubType_DefaultOutput];
    [_outputNode retain];
    
    
    _converterNode = [_graph addNodeWithType:kAudioUnitType_FormatConverter
                                     subType:kAudioUnitSubType_AUConverter];
    [_converterNode retain];
    
    [_graph connectNode:_converterNode output:0
                 toNode:_outputNode input:0];
    
    [_graph open];
    
    // 16-bit signed integer, stereo
    AudioStreamBasicDescription streamFormat = {0};
    UInt32 formatFlags = (0
                          | kAudioFormatFlagIsPacked 
                          | kAudioFormatFlagIsSignedInteger 
                          | kAudioFormatFlagsNativeEndian
                          );
    
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mSampleRate = 44100;
    streamFormat.mChannelsPerFrame = 2;
    streamFormat.mFormatFlags = formatFlags;
    streamFormat.mBitsPerChannel = 16;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = streamFormat.mBitsPerChannel * streamFormat.mChannelsPerFrame / 8;
    streamFormat.mBytesPerPacket = streamFormat.mBytesPerFrame * streamFormat.mFramesPerPacket;
    DDAudioUnit * converterUnit = [_converterNode audioUnit];
    [converterUnit setStreamFormatWithDescription:&streamFormat];
    
    [_converterNode setInputCallback:MyRenderer context:self forInput:0];
    
    NSLog(@"graph: %@", _graph);
    
    [_graph update];
    [_graph initialize];
    return YES;
}

- (void)teardownAudio;
{
}

- (BOOL)startAudio:(NSError **)error;
{
    _shouldBufferDataInCallback = YES;
    [_graph start];
    return YES;
}

- (void)stopAudio;
{
    _shouldBufferDataInCallback = NO;
    [_graph stop];
}

- (BOOL)pauseAudio:(NSError **)error;
{
    [_graph stop];
    return YES;
}

- (BOOL)unpauseAudio:(NSError **)error;
{
    [_graph start];
    return YES;
}

- (void)trackEnded
{
    [_delegate musicPlayerOutputDidFinishTrack:(id)self];
}

@end
