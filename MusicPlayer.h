//
//  MusicPlayer.h
//  RetroPlayer
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MusicPlayerActions.h"
#import "MusicPlayerAudioQueueOutput.h"

@class MusicEmu;
@class TrackInfo;
@class MusicPlayer;
@class MusicPlayerStateMachine;
@class MusicPlayerAudioQueueOutput;

@protocol MusicPlayerDelegate <NSObject>

- (void)musicPlayerDidStop:(MusicPlayer *)player;
- (void)musicPlayerDidStart:(MusicPlayer *)player;
- (void)musicPlayerDidPause:(MusicPlayer *)player;
- (void)musicPlayerDidFinishTrack:(MusicPlayer *)player;
- (void)musicPlayer:(MusicPlayer *)player didFailWithError:(NSError *)error;

@end


@interface MusicPlayer : NSObject <MusicPlayerActions, MusicPlayerOutputDelegate>
{
    id<MusicPlayerDelegate> _delegate;
    
    MusicPlayerStateMachine * _stateMachine;
    MusicPlayerAudioQueueOutput * _playerOutput;
    MusicEmu * _emu;
    long _sampleRate;
}

- (id)initWithDelegate:(id<MusicPlayerDelegate>)delegate sampleRate:(long)sampleRate;

- (id)initWithDelegate:(id<MusicPlayerDelegate>)delegate;

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
