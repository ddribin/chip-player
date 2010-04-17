//
//  MusicPlayerOutput.h
//  RetroPlayer
//
//  Created by Dave Dribin on 4/17/10.
//  Copyright 2010 Bit Maki, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MusicPlayerOutput;
@class MusicEmu;
@class GmeMusicFile;
@class MusicPlayerAudioQueueOutput;


@protocol MusicPlayerOutputDelegate <NSObject>

- (void)musicPlayerOutputDidFinishTrack:(id<MusicPlayerOutput>)output;

@end

@protocol MusicPlayerOutput <NSObject>

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
