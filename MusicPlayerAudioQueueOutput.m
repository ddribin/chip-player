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

#define FAIL_ON_ERR(_X_) if ((status = (_X_)) != noErr) { goto failed; }

@interface MusicPlayerAudioQueueOutput ()
- (void)setupDataFormatWithSampleRate:(long)sampleRate;
- (void)calculateBufferSizeForSeconds:(Float64)seconds;
- (OSStatus)allocateBuffers;
- (void)checkTrackDidEnd;
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
    
    // Peform after delay to get us out of the callback as some resulting actions
    // that act on the queue may not work when called from the callback
    // [player performSelector:@selector(checkTrackDidEnd) withObject:nil afterDelay:0.0];
    if ([musicFile trackEnded]) {
        NSLog(@"%s:%d trackEnded", __PRETTY_FUNCTION__, __LINE__);
        player->_shouldBufferDataInCallback = NO;
        player->_stoppedDueToTrackEnding = YES;
        AudioQueueStop(player->_queue, NO);
    }
}

static void HandleIsRunningChanged(void * userData,
                                   AudioQueueRef queue,
                                   AudioQueuePropertyID property)
{
    MusicPlayerAudioQueueOutput * player = (MusicPlayerAudioQueueOutput *)userData;

    UInt32 isRunning = 0;
    UInt32 isRunningSize = sizeof(isRunning);
    OSStatus status = AudioQueueGetProperty(queue, property, &isRunning, &isRunningSize);
    if (status != noErr) {
        NSLog(@"AudioQueueGetProperty failed: %d", status);
    }
    else {
        NSLog(@"isRunning: %d", isRunning);
        static NSTimeInterval __start;
        if (isRunning) {
            __start = [NSDate timeIntervalSinceReferenceDate];
        } else {
            NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
            NSLog(@"duration: %.3f", (end - __start));
        }

        if (!isRunning && player->_stoppedDueToTrackEnding) {
            // [player performSelector:@selector(checkTrackDidEnd) withObject:nil afterDelay:0.0];
            [player checkTrackDidEnd];
        }
    }
}

- (id)initWithDelegate:(id<MusicPlayerOutputDelegate>)delegate;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _delegate = delegate;
    _shouldBufferDataInCallback = NO;
    
    return self;
}

- (void)dealloc
{
    [_emu release];
    [_musicFile release];
    
    [super dealloc];
}

- (BOOL)setupWithSampleRate:(long)sampleRate error:(NSError **)error;
{
    AudioQueueRef newQueue = NULL;
    OSStatus status;
    
    [self setupDataFormatWithSampleRate:sampleRate];
    FAIL_ON_ERR(AudioQueueNewOutput(&_dataFormat, HandleOutputBuffer, self, CFRunLoopGetCurrent(),
                                    kCFRunLoopCommonModes, 0, &newQueue));
    _queue = newQueue;
    
    [self calculateBufferSizeForSeconds:0.1];
    
    FAIL_ON_ERR(AudioQueueAddPropertyListener(_queue, kAudioQueueProperty_IsRunning, HandleIsRunningChanged, self));
    FAIL_ON_ERR(AudioQueueSetParameter(_queue, kAudioQueueParam_Volume, 1.00))
    FAIL_ON_ERR([self allocateBuffers]);
    
    return YES;
    
failed:
    if (newQueue != NULL) {
        AudioQueueDispose(newQueue, YES);
        newQueue = NULL;
    }
    
    if (error != NULL) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    }
    return NO;
}

- (void)setupDataFormatWithSampleRate:(long)sampleRate;
{
    // 16-bit signed integer, stereo
    UInt32 formatFlags = (0
                          | kAudioFormatFlagIsPacked 
                          | kAudioFormatFlagIsSignedInteger 
                          | kAudioFormatFlagsNativeEndian
                          );
    
    _dataFormat.mFormatID = kAudioFormatLinearPCM;
    _dataFormat.mSampleRate = sampleRate;
    _dataFormat.mChannelsPerFrame = 2;
    _dataFormat.mFormatFlags = formatFlags;
    _dataFormat.mBitsPerChannel = 16;
    _dataFormat.mFramesPerPacket = 1;
    _dataFormat.mBytesPerFrame = _dataFormat.mBitsPerChannel * _dataFormat.mChannelsPerFrame / 8;
    _dataFormat.mBytesPerPacket = _dataFormat.mBytesPerFrame * _dataFormat.mFramesPerPacket;
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

- (OSStatus)allocateBuffers;
{
    OSStatus status;
    for (int i = 0; i < kNumberBuffers; ++i) {
        FAIL_ON_ERR(AudioQueueAllocateBuffer(_queue, _bufferByteSize, &_buffers[i]));
    }
    return noErr;
    
failed:
    return status;
}

- (void)teardownAudio;
{
    AudioQueueDispose(_queue, YES);
}

- (BOOL)startAudio:(NSError **)error;
{
    // Prime buffers
    _shouldBufferDataInCallback = YES;
    _stoppedDueToTrackEnding = NO;
    for (int i = 0; i < kNumberBuffers; ++i) {
        HandleOutputBuffer(self, _queue, _buffers[i]);
    }
    
    NSLog(@"AudioQueueStart:%d", __LINE__);
    OSStatus status;
    FAIL_ON_ERR(AudioQueueStart(_queue, NULL));
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
    NSLog(@"AudioQueueStop:%d", __LINE__);
    AudioQueueStop(_queue, YES);
}

- (BOOL)pauseAudio:(NSError **)error;
{
    _shouldBufferDataInCallback = NO;
    NSLog(@"AudioQueuePause:%d", __LINE__);
    OSStatus status;
    FAIL_ON_ERR(AudioQueuePause(_queue));
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
    NSLog(@"AudioQueueStart:%d", __LINE__);
    OSStatus status;
    FAIL_ON_ERR(AudioQueueStart(_queue, NULL));
    return YES;
    
failed:
    if (error != NULL) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    }
    return NO;
}

- (void)checkTrackDidEnd;
{
    if ([_musicFile trackEnded]) {
        [_delegate musicPlayerOutputDidFinishTrack:self];
    }
}

@end
