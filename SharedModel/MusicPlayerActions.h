//
//  MusicPlayerActions.h
//  RetroPlayer
//
//  Created by Dave Dribin on 4/1/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MusicEmu;

@protocol MusicPlayerActions <NSObject>

- (void)handleError:(NSError *)error;

- (void)setButtonToPlay;
- (void)setButtonToPause;
- (void)enableOrDisablePreviousAndNext;

- (BOOL)setupAudio:(NSError **)error;
- (void)teardownAudio;
- (BOOL)startAudio:(NSError **)error;
- (void)stopAudio;
- (BOOL)pauseAudio:(NSError **)error;
- (BOOL)unpauseAudio:(NSError **)error;

- (void)setCurrentTrackToSelectedTrack;
- (void)nextTrack;
- (void)previousTrack;

#pragma mark -

- (BOOL)isCurrentTrackTheLastTrack;
- (BOOL)isCurrentTrackTheFirstTrack;

@end
