/*
 * Copyright (c) 2010 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "MusicPlayerStateMachine.h"

@interface MusicPlayerStateMachine ()
@property (nonatomic) int state;
@end

enum State {
    RRStateUninitialized,
    RRStateStopped,
    RRStatePlaying,
    RRStatePaused,
    RRStateInterrupted,
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
    NSAssert((_state == RRStatePaused) || (_state == RRStateInterrupted), @"Invalid state");
    
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

- (void)beginInterruption;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");

    if (_state == RRStatePlaying) {
        [self pause];
        self.state = RRStateInterrupted;
    }
}

- (void)endInterruption;
{
    NSAssert(_state != RRStateUninitialized, @"Invalid state");

    [_actions activateAudioSession];
    if (_state == RRStateInterrupted) {
        [self unpause];
    }
}

@end
