/*
 * Copyright (c) 2010 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "MusicPlayerAudioQueueOutput.h"
#import "GmeMusicFile.h"
#import "MusicEmu.h"

#define FAIL_ON_ERR(_X_) if ((status = (_X_)) != noErr) { goto failed; }

@interface MusicPlayerAudioQueueOutput ()
- (void)setupDataFormatWithSampleRate:(long)sampleRate;
- (void)calculateBufferSizeForSeconds:(Float64)seconds;
- (OSStatus)allocateBuffers;
- (void)primeBuffers;
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
    MusicPlayerAudioQueueOutput * self =
        (MusicPlayerAudioQueueOutput *) inUserData;
    
    if (!self->_shouldBufferDataInCallback) {
        return;
    }
    
    GmeMusicFile * musicFile = self->_musicFile;
    if (musicFile == nil) {
        NSLog(@"No music file");
        return;
    }
    
    NSError * error = nil;
    if (!GmeMusicFilePlay(musicFile, inBuffer->mAudioDataBytesCapacity/2,
                          inBuffer->mAudioData, &error))
    {
        NSLog(@"GmeMusicFilePlay error: %@ %@", error, [error userInfo]);
        return;
    }
    
    inBuffer->mAudioDataByteSize = inBuffer->mAudioDataBytesCapacity;
    OSStatus result = AudioQueueEnqueueBuffer(self->_queue, inBuffer, 0, NULL);
    if (result != noErr) {
        NSLog(@"AudioQueueEnqueueBuffer error: %d", result);
    }
    
    // Asynchronous stop means all queued buffers still get played.
    if ([musicFile trackEnded]) {
        self->_shouldBufferDataInCallback = NO;
        self->_stoppedDueToTrackEnding = YES;
        AudioQueueStop(self->_queue, NO);
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
        if (!isRunning && player->_stoppedDueToTrackEnding) {
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
    _queue = NULL;
}

- (BOOL)startAudio:(NSError **)error;
{
    [self primeBuffers];
    
    OSStatus status;
    FAIL_ON_ERR(AudioQueueStart(_queue, NULL));
    return YES;
    
failed:
    if (error != NULL) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                     code:status userInfo:nil];
    }
    return NO;
}

- (void)primeBuffers;
{
    _shouldBufferDataInCallback = YES;
    _stoppedDueToTrackEnding = NO;
    for (int i = 0; i < kNumberBuffers; ++i) {
        HandleOutputBuffer(self, _queue, _buffers[i]);
    }
}

- (void)stopAudio;
{
    _shouldBufferDataInCallback = NO;
    AudioQueueStop(_queue, YES);
}

- (BOOL)pauseAudio:(NSError **)error;
{
    _shouldBufferDataInCallback = NO;
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
