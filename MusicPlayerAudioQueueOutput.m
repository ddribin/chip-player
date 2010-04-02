//
//  MusicPlayerAudioQueueOutput.m
//  RetroPlayer
//
//  Created by Dave Dribin on 4/1/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import "MusicPlayerAudioQueueOutput.h"
#import "MusicEmu.h"


@implementation MusicPlayerAudioQueueOutput

@synthesize emu = _emu;

#define kNumberBuffers (sizeof(_buffers)/sizeof(_buffers[0]))

static void HandleOutputBuffer(void * inUserData,
                               AudioQueueRef inAQ,
                               AudioQueueBufferRef inBuffer)
{
    MusicPlayerAudioQueueOutput * player = (MusicPlayerAudioQueueOutput *) inUserData;
    if (!player->_shouldBufferDataInCallback) {
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
    _shouldBufferDataInCallback = NO;
    
    return self;
}

- (void)dealloc
{
    [_emu release];
    
    [super dealloc];
}

- (BOOL)setupAudio:(NSError **)error;
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

@end