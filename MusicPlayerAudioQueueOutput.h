//
//  MusicPlayerAudioQueueOutput.h
//  RetroPlayer
//
//  Created by Dave Dribin on 4/1/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioQueue.h>

@class MusicEmu;


@interface MusicPlayerAudioQueueOutput : NSObject
{
    MusicEmu * _emu;
    long _sampleRate;
    
    AudioStreamBasicDescription _dataFormat;
    AudioQueueRef _queue;
    AudioQueueBufferRef _buffers[3];
    UInt32 _bufferByteSize;
    SInt64 _currentPacket;
    UInt32 _numPacketsToRead;
    AudioStreamPacketDescription * _packetDescs;
    BOOL _shouldBufferDataInCallback;
}

@property (retain) MusicEmu * emu;

- (id)initWithSampleRate:(long)sampleRate;

- (BOOL)setupAudio:(NSError **)error;
- (void)teardownAudio;
- (BOOL)startAudio:(NSError **)error;
- (void)stopAudio;
- (BOOL)pauseAudio:(NSError **)error;
- (BOOL)unpauseAudio:(NSError **)error;

@end
