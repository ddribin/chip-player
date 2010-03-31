//
//  MusicPlayer.h
//  RetroPlayer
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <AudioToolbox/AudioQueue.h>

@class MusicEmu;
@class TrackInfo;

@interface MusicPlayer : NSObject
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
    BOOL _isRunning;
}

- (id)initWithSampleRate:(long)sampleRate;

- (id)init;

- (BOOL)setupSound:(NSError **)error;

- (BOOL)loadFileAtPath:(NSString *)path error:(NSError **)error;

- (int)numberOfTracks;

- (TrackInfo *)trackInfoForTrack:(int)track;

- (BOOL)playTrack:(int)track error:(NSError **)error;

- (void)stop;

@end
