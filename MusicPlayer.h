//
//  MusicPlayer.h
//  RetroPlayer
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MusicPlayerActions.h"

@class MusicEmu;
@class TrackInfo;
@class MusicPlayerStateMachine;
@class MusicPlayerAudioQueueOutput;

@interface MusicPlayer : NSObject <MusicPlayerActions>
{
    MusicPlayerStateMachine * _stateMachine;
    MusicPlayerAudioQueueOutput * _playerOutput;
    MusicEmu * _emu;
    long _sampleRate;
    BOOL _shouldBufferDataInCallback;
}

- (id)initWithSampleRate:(long)sampleRate;

- (id)init;

- (BOOL)loadFileAtPath:(NSString *)path error:(NSError **)error;

- (int)numberOfTracks;
- (TrackInfo *)trackInfoForTrack:(int)track;

- (BOOL)playTrack:(int)track error:(NSError **)error;

- (BOOL)isPlaying;

- (void)setup;
- (void)teardown;
- (void)stop;
- (void)togglePause;

@end
