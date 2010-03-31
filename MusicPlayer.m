//
//  MusicPlayer.m
//  RetroPlayer
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import "MusicPlayer.h"
#import "MusicEmu.h"
#import "GmeErrors.h"

#define kNumberBuffers (sizeof(_buffers)/sizeof(_buffers[0]))

@implementation MusicPlayer

static void HandleOutputBuffer(void * inUserData,
                               AudioQueueRef inAQ,
                               AudioQueueBufferRef inBuffer)
{
    MusicPlayer * player = (MusicPlayer *) inUserData;
    if (!player->_isRunning) {
        return;
    }
    
    MusicEmu * emu = player->_emu;
    if (emu == nil) {
        return;
    }
    
    gme_err_t error = GmeMusicEmuPlay(emu, inBuffer->mAudioDataBytesCapacity/2, inBuffer->mAudioData);
    if (error == 0) {
        inBuffer->mAudioDataByteSize = inBuffer->mAudioDataBytesCapacity;
        OSStatus result = AudioQueueEnqueueBuffer(player->_queue, inBuffer, 0, NULL);
        if (result != noErr) {
            NSLog(@"Error: %d %s %s", result, GetMacOSStatusErrorString(result), GetMacOSStatusCommentString(result));
        }
        player->_currentPacket += player->_numPacketsToRead;
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
    
    return self;
}

- (id)init;
{
    return [self initWithSampleRate:44100];
}

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

- (void)stop;
{
    if (!_isRunning) {
        return;
    }
    
    _isRunning = NO;
    AudioQueueStop(_queue, YES);
    AudioQueueDispose(_queue, YES);
    _queue = NULL;
    int i;
    for (i = 0; i < kNumberBuffers; ++i)
    {
        AudioQueueFreeBuffer(_queue, _buffers[i]);
    }
}

- (BOOL)loadFileAtPath:(NSString *)path error:(NSError **)error;
{
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

- (BOOL)playTrack:(int)track error:(NSError **)error;
{
    [self stop];

    gme_err_t gme_error = [_emu start_track:track];
    if (gme_error != 0) {
        if (error != NULL) {
            *error = [NSError gme_error:gme_error];
        }
        return NO;
    }
    
    track_info_t track_info_;
    if ([_emu track_info:&track_info_]) {
        if ( track_info_.length <= 0 ) {
            track_info_.length = track_info_.intro_length +
            track_info_.loop_length * 2;
        }
    }
    if ( track_info_.length <= 0 )
        track_info_.length = (long) (2.5 * 60 * 1000);
    [_emu set_fade:track_info_.length];
    
    if (![self setupSound:error]) {
        return NO;
    }
    
    return YES;
}

@end
