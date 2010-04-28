//
//  MusicPlayerAUGraphWithQueueOutput.h
//  RetroPlayer
//
//  Created by Dave Dribin on 4/19/10.
//  Copyright 2010 Bit Maki, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioQueue.h>
#import "MusicPlayerOutput.h"
#import "DDAudioQueueDelegate.h"

@class DDAudioUnitGraph;
@class DDAudioUnitNode;
@class DDAudioQueue;
@class DDAudioQueueReader;

@interface MusicPlayerAUGraphWithQueueOutput : NSObject <MusicPlayerOutput, DDAudioQueueDelegate>
{
    NSObject<MusicPlayerOutputDelegate> * _delegate;
    
    MusicEmu * _emu;
    GmeMusicFile * _musicFile;
    
    DDAudioUnitGraph * _graph;
    DDAudioUnitNode * _outputNode;
    DDAudioUnitNode * _effectNode;
    DDAudioUnitNode * _converterNode;
    BOOL _shouldBufferDataInCallback;
    

    DDAudioQueue * _queue;
    DDAudioQueueBuffer * _buffers[5];
    DDAudioQueueReader * _queueReader;
    AudioStreamBasicDescription _dataFormat;
    UInt32 _bufferByteSize;
    
    NSTimer * _oneSecondTimer;
    NSTimeInterval _timeOfLastOneSecondTimer;
    NSTimeInterval _timeInMusicFilePlay;
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
