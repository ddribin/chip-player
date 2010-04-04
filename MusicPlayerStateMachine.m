//
//  MusicPlayerStateMachine.m
//  RetroPlayer
//
//  Created by Dave Dribin on 4/1/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import "MusicPlayerStateMachine.h"

@interface MusicPlayerStateMachine ()
@property (nonatomic) int state;
@end

enum State {
    RRStateUninitialized,
    RRStateStopped,
    RRStatePlaying,
    RRStatePaused,
};

@implementation MusicPlayerStateMachine

@synthesize state = _state;

- (id)initWithActions:(id<MusicPlayerActions>)actions;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _actions = actions;
    _state = RRStateUninitialized;
    
    return self;
}

- (void)setState:(int)state
{
    // NSLog(@"state %d -> %d", _state, state);
    _state = state;
}

- (void)setup;
{
    NSAssert(_state == RRStateUninitialized, @"Invalid state");

    [_actions setButtonToPlay];
    [_actions enableOrDisablePreviousAndNext];
    self.state = RRStateStopped;
}

- (void)teardown;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");
    
    [_actions stopAudio];
    [_actions teardownAudio];
    self.state = RRStateUninitialized;
}

- (void)play;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");

    if ((_state == RRStatePlaying) || (_state == RRStatePaused)) {
        [_actions stopAudio];
    }

    [_actions setCurrentTrackToSelectedTrack];
    [_actions enableOrDisablePreviousAndNext];
    NSError * error = nil;;
    if (![_actions startAudio:&error]) {
        [_actions handleError:error];
        return;
    }
    
    [_actions setButtonToPause];
    self.state = RRStatePlaying;
}

- (void)stop;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");
    if (_state == RRStateStopped) {
        return;
    }
    
    [_actions stopAudio];
    [_actions setButtonToPlay];
    self.state = RRStateStopped;
}

- (void)pause;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");
    NSAssert(_state == RRStatePlaying, @"Invalid state");

    NSError * error = nil;
    if (![_actions pauseAudio:&error]) {
        [_actions handleError:error];
        return;
    }
    
    [_actions setButtonToPlay];
    self.state = RRStatePaused;
}

- (void)unpause;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");
    NSAssert(_state == RRStatePaused, @"Invalid state");
    
    NSError * error = nil;
    if (![_actions unpauseAudio:&error]) {
        [_actions handleError:error];
        return;
    }
    
    [_actions setButtonToPause];
    self.state = RRStatePlaying;
}

- (void)togglePause;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");
    
    if (_state == RRStateStopped) {
        NSError * error = nil;
        if (![_actions startAudio:&error]) {
            [_actions handleError:error];
        }
        [_actions setButtonToPause];
        
        self.state = RRStatePlaying;
    }
    else if (_state == RRStatePlaying) {
        [self pause];
    }
    else if (_state == RRStatePaused) {
        [self unpause];
    }
}

- (void)next;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");
    
    if ([_actions isCurrentTrackTheLastTrack]) {
        return;
    }
    
    if (_state == RRStateStopped) {
        [_actions nextTrack];
        [_actions enableOrDisablePreviousAndNext];
    }
    else if (_state == RRStatePlaying) {
        [_actions stopAudio];
        [_actions nextTrack];
        [_actions startAudio:NULL];
        [_actions enableOrDisablePreviousAndNext];
    }
    else if (_state == RRStatePaused) {
        [_actions stopAudio];
        [_actions nextTrack];
        [_actions enableOrDisablePreviousAndNext];

        self.state = RRStateStopped;
    }
}

- (void)previous;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");

    if ([_actions isCurrentTrackTheFirstTrack]) {
        return;
    }
    
    if (_state == RRStateStopped) {
        [_actions previousTrack];
        [_actions enableOrDisablePreviousAndNext];
    }
    else if (_state == RRStatePlaying) {
        [_actions stopAudio];
        [_actions previousTrack];
        [_actions enableOrDisablePreviousAndNext];
        [_actions startAudio:NULL];
    }
    else if (_state == RRStatePaused) {
        [_actions stopAudio];
        [_actions previousTrack];
        [_actions enableOrDisablePreviousAndNext];
        
        self.state = RRStateStopped;
    }
}

- (void)trackDidFinish;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");
    
    if (_state == RRStatePlaying) {
        [_actions stopAudio];
    }
    
    if ([_actions isCurrentTrackTheLastTrack]) {
        [_actions setButtonToPlay];
        
        self.state = RRStateStopped;
    } else {
        [_actions nextTrack];
        [_actions enableOrDisablePreviousAndNext];
        [_actions startAudio:NULL];
        
        self.state = RRStatePlaying;
    }
}

@end
