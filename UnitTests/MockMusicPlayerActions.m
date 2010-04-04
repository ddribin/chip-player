//
//  MockMusicPlayerActions.m
//  RetroPlayer
//
//  Created by Dave Dribin on 4/3/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import "MockMusicPlayerActions.h"


@implementation MockMusicPlayerActions

@synthesize currentTrack, selectedTrack, numberOfTracks;

+ (id)mockActions;
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    currentTrack = 1;
    selectedTrack = 1;
    numberOfTracks = 3;
    
    return self;
}


- (void)clearExpectations;
{
    enableOrDisablePreviousAndNextWasCalled = NO;
    startAudioWasCalled = NO;
    stopAudioWasCalled = NO;
    setButtonToPlayWasCalled = NO;
    setButtonToPausedWasCalled = NO;
}

- (void)setCurrentTrackToFirstTrack;
{
    currentTrack = 1;
}

- (void)setCurrentTrackToMiddleTrack;
{
    currentTrack = 2;
}

- (void)setCurrentTrackToLastTrack;
{
    currentTrack = 3;
}

#pragma mark -

- (void)handleError:(NSError *)error;
{
}

- (void)setButtonToPlay;
{
    setButtonToPlayWasCalled = YES;
}

- (void)setButtonToPause;
{
    setButtonToPausedWasCalled = YES;
}

- (void)enableOrDisablePreviousAndNext;
{
    enableOrDisablePreviousAndNextWasCalled = YES;
}

- (BOOL)setupAudio:(NSError **)error;
{
    return YES;
}
    
- (void)teardownAudio;
{
}

- (BOOL)startAudio:(NSError **)error;
{
    startAudioWasCalled = YES;
    return YES;
}    
    
- (void)stopAudio;
{
    stopAudioWasCalled = YES;
}

- (BOOL)pauseAudio:(NSError **)error;
{
    return YES;
}

- (BOOL)unpauseAudio:(NSError **)error;
{
    return YES;
}

- (void)setCurrentTrackToSelectedTrack;
{
    currentTrack = selectedTrack;
}

- (void)nextTrack;
{
    currentTrack++;
}

- (void)previousTrack;
{
    currentTrack--;
}

#pragma mark -

- (BOOL)isCurrentTrackTheFirstTrack;
{
    return (currentTrack == 1);
}

- (BOOL)isCurrentTrackTheLastTrack;
{
    return (currentTrack == numberOfTracks);
}

@end
