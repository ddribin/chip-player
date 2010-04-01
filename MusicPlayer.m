//
//  MusicPlayer.m
//  RetroPlayer
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import "MusicPlayer.h"
#import "MusicEmu.h"
#import "TrackInfo.h"
#import "GmeErrors.h"

#define kNumberBuffers (sizeof(_buffers)/sizeof(_buffers[0]))

enum State {
    RRStateUninitialized,
    RRStateStopped,
    RRStatePlaying,
    RRStatePaused,
};

@implementation MusicPlayer

static void HandleOutputBuffer(void * inUserData,
                               AudioQueueRef inAQ,
                               AudioQueueBufferRef inBuffer)
{
    MusicPlayer * player = (MusicPlayer *) inUserData;
    if (player->_state != RRStatePlaying) {
        return;
    }
    
    MusicEmu * emu = player->_emu;
    if (emu == nil) {
        NSLog(@"No emu");
        return;
    }
    
    gme_err_t error = GmeMusicEmuPlay(emu, inBuffer->mAudioDataBytesCapacity/2, inBuffer->mAudioData);
    if (error == 0) {
        inBuffer->mAudioDataByteSize = inBuffer->mAudioDataBytesCapacity;
        OSStatus result = AudioQueueEnqueueBuffer(player->_queue, inBuffer, 0, NULL);
        if (result != noErr) {
            NSLog(@"AudioQueueEnqueueBuffer error: %d %s %s", result, GetMacOSStatusErrorString(result), GetMacOSStatusCommentString(result));
        }
        player->_currentPacket += player->_numPacketsToRead;
    } else {
        NSLog(@"GmeMusicEmuPlay error: %s", error);
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

- (id)initWithSampleRate:(long)sampleRate;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _sampleRate = sampleRate;
    _state = RRStateUninitialized;
    
    return self;
}

- (id)init;
{
    return [self initWithSampleRate:44100];
}

- (BOOL)setup:(NSError **)error;
{
    if (_state != RRStateUninitialized) {
        return YES;
    }
    
    UInt32 formatFlags = (0
                          | kLinearPCMFormatFlagIsPacked 
                          | kLinearPCMFormatFlagIsSignedInteger 
#if __BIG_ENDIAN__
                          | kLinearPCMFormatFlagIsBigEndian
#endif
                          );
    
    _dataFormat.mFormatID = kAudioFormatLinearPCM;
    _dataFormat.mSampleRate = _sampleRate;
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

    Float32 gain = 0.25;
    result = AudioQueueSetParameter(_queue, kAudioQueueParam_Volume, gain);
    if (result != noErr) {
        goto failed;
    }
    
    for (int i = 0; i < kNumberBuffers; ++i) {
        AudioQueueAllocateBuffer(_queue, _bufferByteSize, &_buffers[i]);
    }

    _state = RRStateStopped;
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

- (void)teardown;
{
    if (_state == RRStateUninitialized) {
        return;
    }
    
    [self stop];
    
    AudioQueueDispose(_queue, YES);
    
    for (int i = 0; i < kNumberBuffers; ++i) {
        AudioQueueFreeBuffer(_queue, _buffers[i]);
    }
    
    _state = RRStateUninitialized;
}

#if 0
- (BOOL)setupSound:(NSError **)error;
{
    UInt32 formatFlags = (0
                          | kLinearPCMFormatFlagIsPacked 
                          | kLinearPCMFormatFlagIsSignedInteger 
#if __BIG_ENDIAN__
                          | kLinearPCMFormatFlagIsBigEndian
#endif
                          );
    
    _dataFormat.mFormatID = kAudioFormatLinearPCM;
    _dataFormat.mSampleRate = _sampleRate;
    _dataFormat.mChannelsPerFrame = 2;
    _dataFormat.mFormatFlags = formatFlags;
    _dataFormat.mBitsPerChannel = 16;
    _dataFormat.mFramesPerPacket = 1;
    _dataFormat.mBytesPerFrame = _dataFormat.mBitsPerChannel * _dataFormat.mChannelsPerFrame / 8;
    _dataFormat.mBytesPerPacket = _dataFormat.mBytesPerFrame * _dataFormat.mFramesPerPacket;
    
    OSStatus result;
    result = AudioQueueNewOutput(&_dataFormat, HandleOutputBuffer, self, CFRunLoopGetCurrent(),
                                 kCFRunLoopCommonModes, 0, &_queue);
    
    if (result != noErr)
    {
        if (error != NULL) {
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:result userInfo:nil];
        }
        return NO;
    }
    
    _isRunning = YES;
    
    CalculateBytesForTime(&_dataFormat, 1, 2.0, &_bufferByteSize, &_numPacketsToRead);
    
    _currentPacket = 0;
    
    for (int i = 0; i < kNumberBuffers; ++i)
    {
        AudioQueueAllocateBuffer(_queue, _bufferByteSize, &_buffers[i]);
        HandleOutputBuffer(self, _queue, _buffers[i]);
    }
    
    Float32 gain = 0.25;
    AudioQueueSetParameter(_queue, kAudioQueueParam_Volume, gain);
    
    result = AudioQueueStart(_queue, NULL);
    NSLog(@"result: %d", result);
    
    return YES;
}
#endif

- (BOOL)isPlaying;
{
    return ((_state == RRStatePlaying) || (_state == RRStatePaused));
}

- (BOOL)playTrack:(int)track error:(NSError **)error;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");
    [self stop];
    
    gme_err_t gme_error = [_emu start_track:track];
    if (gme_error != 0) {
        if (error != NULL) {
            *error = [NSError gme_error:gme_error];
        }
        return NO;
    }
    
    track_info_t track_info_;
    gme_error = [_emu track_info:&track_info_];
    if (gme_error == 0) {
        if ( track_info_.length <= 0 ) {
            track_info_.length = track_info_.intro_length +
            track_info_.loop_length * 2;
        }
    }
    if ( track_info_.length <= 0 )
        track_info_.length = (long) (2.5 * 60 * 1000);
    [_emu set_fade:track_info_.length];
    
    if (![self play:error]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)play:(NSError **)error;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");
    NSAssert(_state == RRStateStopped, @"Invalid state");
    
    _state = RRStatePlaying;
    // Prime buffers
    for (int i = 0; i < kNumberBuffers; ++i) {
        HandleOutputBuffer(self, _queue, _buffers[i]);
    }
    
    OSStatus status = AudioQueueStart(_queue, NULL);
    if (status != noErr) {
        goto failed;
    }
    
    return YES;
    
failed:
    _state = RRStateStopped;
    if (error != NULL) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    }
    return NO;
}

- (void)stop;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");
    if (_state == RRStateStopped) {
        return;
    }
    
    _state = RRStateStopped;
    AudioQueueStop(_queue, YES);
}

- (BOOL)pause:(NSError **)error;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");
    NSAssert(_state == RRStatePlaying, @"Invalid state");
    
    _state = RRStatePaused;
    AudioQueuePause(_queue);
    return YES;
}

- (BOOL)unpause:(NSError **)error;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");
    NSAssert(_state == RRStatePaused, @"Invalid state");
    
    _state = RRStatePlaying;
    AudioQueueStart(_queue, NULL);
    return YES;
}

- (BOOL)togglePause:(NSError **)error;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");
    NSAssert(_state != RRStateStopped, @"Invalid state");
    
    if (_state == RRStatePlaying) {
        return [self pause:error];
    } else {
        return [self unpause:error];
    }
}

- (BOOL)playPause:(NSError **)error;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");
    
    if (_state == RRStateStopped) {
        return [self play:error];
    }
    
    if (_state == RRStatePlaying) {
        return [self pause:error];
    }
    
    if (_state == RRStatePaused) {
        return [self unpause:error];
    }
    
    return YES;
}

- (BOOL)loadFileAtPath:(NSString *)path error:(NSError **)error;
{
    [self stop];
    
    MusicEmu * emu = [MusicEmu musicEmuWithFile:path sampleRate:_sampleRate error:error];
    if (emu == nil) {
        return NO;
    }
    
    _emu = [emu retain];
    return YES;
}

- (int)numberOfTracks;
{
    return [_emu track_count];
}

- (TrackInfo *)trackInfoForTrack:(int)track;
{
    track_info_t gmeTrackInfo;
    gme_err_t gmeError = [_emu track_info:&gmeTrackInfo track:track];
    if (gmeError != 0) {
        NSLog(@"error: %s", gmeError);
    }
    
    TrackInfo * trackInfo = [[TrackInfo alloc] initWithTrackInfo:&gmeTrackInfo trackNumber:track];
    return [trackInfo autorelease];
}

@end
