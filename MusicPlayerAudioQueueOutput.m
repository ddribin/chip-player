//
//  MusicPlayerAudioQueueOutput.m
//  RetroPlayer
//
//  Created by Dave Dribin on 4/1/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import "MusicPlayerAudioQueueOutput.h"
#import "GmeMusicFile.h"
#import "MusicEmu.h"


@interface MusicPlayerAudioQueueOutput ()
- (void)trackDidEnd;
@end

@implementation MusicPlayerAudioQueueOutput

@synthesize emu = _emu;
@synthesize musicFile = _musicFile;

#define kNumberBuffers (sizeof(_buffers)/sizeof(_buffers[0]))

static void HandleOutputBuffer(void * inUserData,
                               AudioQueueRef inAQ,
                               AudioQueueBufferRef inBuffer)
{
    MusicPlayerAudioQueueOutput * player = (MusicPlayerAudioQueueOutput *) inUserData;
    if (!player->_shouldBufferDataInCallback) {
        return;
    }
    
    GmeMusicFile * musicFile = player->_musicFile;
    if (musicFile == nil) {
        NSLog(@"No music file");
        return;
    }
    
    NSError * error = nil;
    if (!GmeMusicFilePlay(musicFile, inBuffer->mAudioDataBytesCapacity/2, inBuffer->mAudioData, &error)) {
        NSLog(@"GmeMusicFilePlay error: %@ %@", error, [error userInfo]);
        return;
    }
    
    inBuffer->mAudioDataByteSize = inBuffer->mAudioDataBytesCapacity;
    OSStatus result = AudioQueueEnqueueBuffer(player->_queue, inBuffer, 0, NULL);
    if (result != noErr) {
        NSLog(@"AudioQueueEnqueueBuffer error: %d %s %s", result, GetMacOSStatusErrorString(result), GetMacOSStatusCommentString(result));
    }
    if ([musicFile trackEnded]) {
        [player trackDidEnd];
    }
}

// we only use time here as a guideline
// we're really trying to get somewhere between 16K and 64K buffers, but not allocate too much if we don't need it
static void CalculateBytesForTime (const AudioStreamBasicDescription * inDesc, UInt32 inMaxPacketSize, Float64 inSeconds, UInt32 *outBufferSize, UInt32 *outNumPackets)
{
	static const int maxBufferSize = 0x10000; // limit size to 64K
	static const int minBufferSize = 0x4000; // limit size to 16K
    
	if (inDesc->mFramesPerPacket) {
		Float64 numPacketsForTime = inDesc->mSampleRate / inDesc->mFramesPerPacket * inSeconds;
		*outBufferSize = numPacketsForTime * inMaxPacketSize;
	} else {
		// if frames per packet is zero, then the codec has no predictable packet == time
		// so we can't tailor this (we don't know how many Packets represent a time period
		// we'll just return a default buffer size
		*outBufferSize = maxBufferSize > inMaxPacketSize ? maxBufferSize : inMaxPacketSize;
	}
	
    // we're going to limit our size to our default
	if (*outBufferSize > maxBufferSize && *outBufferSize > inMaxPacketSize)
		*outBufferSize = maxBufferSize;
	else {
		// also make sure we're not too small - we don't want to go the disk for too small chunks
		if (*outBufferSize < minBufferSize)
			*outBufferSize = minBufferSize;
	}
	*outNumPackets = *outBufferSize / inMaxPacketSize;
}

- (id)initWithDelegate:(id<MusicPlayerOutputDelegate>)delegate sampleRate:(long)sampleRate;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _delegate = delegate;
    _sampleRate = sampleRate;
    _shouldBufferDataInCallback = NO;
    
    return self;
}

- (id)initWithDelegate:(id<MusicPlayerOutputDelegate>)delegate;
{
    return [self initWithDelegate:delegate sampleRate:44100];
}

- (void)dealloc
{
    [_emu release];
    
    [super dealloc];
}

- (BOOL)setupAudio:(NSError **)error;
{
    return [self setupWithSampleRate:_sampleRate error:error];
}

- (BOOL)setupWithSampleRate:(long)sampleRate error:(NSError **)error;
{
    UInt32 formatFlags = (0
                          | kLinearPCMFormatFlagIsPacked 
                          | kLinearPCMFormatFlagIsSignedInteger 
#if __BIG_ENDIAN__
                          | kLinearPCMFormatFlagIsBigEndian
#endif
                          );
    
    _dataFormat.mFormatID = kAudioFormatLinearPCM;
    _dataFormat.mSampleRate = sampleRate;
    _dataFormat.mChannelsPerFrame = 2;
    _dataFormat.mFormatFlags = formatFlags;
    _dataFormat.mBitsPerChannel = 16;
    _dataFormat.mFramesPerPacket = 1;
    _dataFormat.mBytesPerFrame = _dataFormat.mBitsPerChannel * _dataFormat.mChannelsPerFrame / 8;
    _dataFormat.mBytesPerPacket = _dataFormat.mBytesPerFrame * _dataFormat.mFramesPerPacket;
    
    OSStatus result;
    result = AudioQueueNewOutput(&_dataFormat, HandleOutputBuffer, self, CFRunLoopGetCurrent(),
                                 kCFRunLoopCommonModes, 0, &_queue);
    
    if (result != noErr) {
        _queue = NULL;
        goto failed;
    }
    
    CalculateBytesForTime(&_dataFormat, 1, 2.0, &_bufferByteSize, &_numPacketsToRead);
    
    Float32 gain = 1.00;
    result = AudioQueueSetParameter(_queue, kAudioQueueParam_Volume, gain);
    if (result != noErr) {
        goto failed;
    }
    
    for (int i = 0; i < kNumberBuffers; ++i) {
        AudioQueueAllocateBuffer(_queue, _bufferByteSize, &_buffers[i]);
    }
    
    return YES;
    
failed:
    if (_queue != NULL) {
        AudioQueueDispose(_queue, YES);
        _queue = NULL;
    }
    
    if (error != NULL) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:result userInfo:nil];
    }
    return NO;
}

- (void)teardownAudio;
{
    AudioQueueDispose(_queue, YES);
}

- (BOOL)startAudio:(NSError **)error;
{
    // Prime buffers
    _shouldBufferDataInCallback = YES;
    _shouldNotifyOnTrackFinished = YES;
    for (int i = 0; i < kNumberBuffers; ++i) {
        HandleOutputBuffer(self, _queue, _buffers[i]);
    }
    
    OSStatus status = AudioQueueStart(_queue, NULL);
    if (status != noErr) {
        goto failed;
    }
    
    return YES;
    
failed:
    if (error != NULL) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    }
    return NO;
}

- (void)stopAudio;
{
    _shouldBufferDataInCallback = NO;
    AudioQueueStop(_queue, YES);
}

- (BOOL)pauseAudio:(NSError **)error;
{
    _shouldBufferDataInCallback = NO;
    OSStatus status = AudioQueuePause(_queue);
    
    if (status != noErr) {
        goto failed;
    }
    
    return YES;
    
failed:
    if (error != NULL) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    }
    return NO;
}

- (BOOL)unpauseAudio:(NSError **)error;
{
    _shouldBufferDataInCallback = YES;
    OSStatus status = AudioQueueStart(_queue, NULL);
    
    if (status != noErr) {
        goto failed;
    }
    
    return YES;
    
failed:
    if (error != NULL) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    }
    return NO;
}

- (void)trackDidEnd;
{
    if (_shouldNotifyOnTrackFinished && (_delegate != nil)) {
        // We're called in the callback. Things don't work quite right (like stopping and starting), so this causes it to be called the next time;
        [_delegate performSelector:@selector(musicPlayerOutputDidFinishTrack:) withObject:self afterDelay:0];
    }
    _shouldNotifyOnTrackFinished = NO;
}

@end
