//
//  MusicPlayerAudioQueueOutput.h
//  RetroPlayer
//
//  Created by Dave Dribin on 4/1/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#import "MusicPlayerOutput.h"


@interface MusicPlayerAudioQueueOutput : NSObject <MusicPlayerOutput>
{
    NSObject<MusicPlayerOutputDelegate> * _delegate;
    
    MusicEmu * _emu;
    GmeMusicFile * _musicFile;
    
    AudioStreamBasicDescription _dataFormat;
    AudioQueueRef _queue;
    AudioQueueBufferRef _buffers[3];
    UInt32 _bufferByteSize;
    UInt32 _numPacketsToRead;
    BOOL _shouldBufferDataInCallback;
    BOOL _stoppedDueToTrackEnding;
}

@property (retain) MusicEmu * emu;
@property (retain) GmeMusicFile * musicFile;

- (id)initWithDelegate:(id<MusicPlayerOutputDelegate>)delegate;

- (BOOL)setupWithSampleRate:(long)sampleRate error:(NSError **)error;
- (void)teardownAudio;
- (BOOL)startAudio:(NSError **)error;
- (void)stopAudio;
- (BOOL)pauseAudio:(NSError **)error;
- (BOOL)unpauseAudio:(NSError **)error;

@end
