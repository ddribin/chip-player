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

#import "MusicPlayerStateMachineTest.h"
#import "MusicPlayerStateMachine.h"
#import "MockMusicPlayerActions.h"

enum State {
    RRStateUninitialized,
    RRStateStopped,
    RRStatePlaying,
    RRStatePaused,
    RRStateInterrupted,
};

#define TOKEN_STRING(_X_) [NSString stringWithUTF8String:#_X_]

@implementation MusicPlayerStateMachineTest

- (void)setup
{
}

- (void)tearDown
{
}

#pragma mark -

- (void)makeStateMachine
{
    mockActions = [MockMusicPlayerActions mockActions];
    stateMachine = [[MusicPlayerStateMachine alloc] initWithActions:mockActions];
    [stateMachine autorelease];
    
    mockActions.selectedTrack = 1;
}

- (void)makeSetupStateMachine
{
    [self makeStateMachine];
    [stateMachine setup];
}

- (BOOL)isStateUninitialized
{
    return ([stateMachine state] == RRStateUninitialized);
}

- (BOOL)isStateStopped
{
    return ([stateMachine state] == RRStateStopped);
}

- (BOOL)isStatePlaying
{
    return ([stateMachine state] == RRStateStopped);
}

- (void)assertStateIsUninitialized
{
    STAssertEquals([stateMachine state], RRStateUninitialized, nil);
}

- (void)assertStateIsStopped
{
    STAssertEquals([stateMachine state], RRStateStopped, nil);
}

- (void)assertStateIsPlaying
{
    STAssertEquals([stateMachine state], RRStatePlaying, nil);
}

- (void)assertStateIsPaused
{
    STAssertEquals([stateMachine state], RRStatePaused, nil);
}

- (void)assertStateIsInterrupted
{
    STAssertEquals([stateMachine state], RRStateInterrupted, nil);
}


#pragma mark -
#pragma mark Tests

- (void)testUninitializedAtStart
{
    [self makeStateMachine];
    
    [self assertStateIsUninitialized];
}

- (void)testSetupUpdatesButtons
{
    [self makeStateMachine];
    
    [stateMachine setup];
    
    [self assertStateIsStopped];
    STAssertTrue(mockActions->setButtonToPlayWasCalled, nil);
    STAssertTrue(mockActions->enableOrDisablePreviousAndNextWasCalled, nil);
}

- (void)testPlayingSelectedWhenStoppedOnADifferentTrack
{
    [self makeSetupStateMachine];
    mockActions.selectedTrack = 2;
    [mockActions clearExpectations];
    
    [stateMachine play];
    
    [self assertStateIsPlaying];
    STAssertEquals(mockActions.currentTrack, 2, nil);
    STAssertFalse(mockActions->stopAudioWasCalled, nil);
    STAssertTrue(mockActions->startAudioWasCalled, nil);
    STAssertTrue(mockActions->setButtonToPausedWasCalled, nil);
    STAssertTrue(mockActions->enableOrDisablePreviousAndNextWasCalled, nil);
}

- (void)testPlayingSelectedWhenPlayingADifferentTrack
{
    [self makeSetupStateMachine];
    [stateMachine play];
    mockActions.selectedTrack = 2;
    [mockActions clearExpectations];
    
    [stateMachine play];
    
    [self assertStateIsPlaying];
    STAssertEquals(mockActions.currentTrack, 2, nil);
    STAssertTrue(mockActions->stopAudioWasCalled, nil);
    STAssertTrue(mockActions->startAudioWasCalled, nil);
    STAssertTrue(mockActions->setButtonToPausedWasCalled, nil);
    STAssertTrue(mockActions->enableOrDisablePreviousAndNextWasCalled, nil);
}

- (void)testPlayingSelectedWhenPausedOnADifferentTrack
{
    [self makeSetupStateMachine];
    [stateMachine play];
    [stateMachine togglePause];
    mockActions.selectedTrack = 2;
    [mockActions clearExpectations];
    
    [stateMachine play];
    
    [self assertStateIsPlaying];
    STAssertEquals(mockActions.currentTrack, 2, nil);
    STAssertTrue(mockActions->stopAudioWasCalled, nil);
    STAssertTrue(mockActions->startAudioWasCalled, nil);
    STAssertTrue(mockActions->setButtonToPausedWasCalled, nil);
    STAssertTrue(mockActions->enableOrDisablePreviousAndNextWasCalled, nil);
}

- (void)testTogglingPauseWhenStoppedStartsCurrentTrack
{
    [self makeSetupStateMachine];
    mockActions.selectedTrack = 2;
    [mockActions clearExpectations];
    
    [stateMachine togglePause];
    
    [self assertStateIsPlaying];
    STAssertEquals(mockActions.currentTrack, 1, nil);
    STAssertFalse(mockActions->stopAudioWasCalled, nil);
    STAssertTrue(mockActions->startAudioWasCalled, nil);
    STAssertTrue(mockActions->setButtonToPausedWasCalled, nil);
    STAssertFalse(mockActions->enableOrDisablePreviousAndNextWasCalled, nil);
}

- (void)testFinishingLastTrackStopsPlayer
{
    [self makeSetupStateMachine];
    [stateMachine play];
    [mockActions setCurrentTrackToLastTrack];
    [mockActions clearExpectations];
    
    [stateMachine trackDidFinish];
    
    [self assertStateIsStopped];
    STAssertTrue(mockActions->stopAudioWasCalled, nil);
    STAssertFalse(mockActions->startAudioWasCalled, nil);
    STAssertTrue(mockActions->setButtonToPlayWasCalled, nil);
}

- (void)testBeginInterruptionWhilePlayingTransitionsToInterrupted
{
    [self makeSetupStateMachine];
    [stateMachine play];
    
    [stateMachine beginInterruption];
    
    [self assertStateIsInterrupted];
}

- (void)testStartsForEndInterruptionWhilePlaying
{
    [self makeSetupStateMachine];
    [stateMachine play];
    [stateMachine beginInterruption];
    
    [stateMachine endInterruption];
    
    [self assertStateIsPlaying];
    STAssertTrue(mockActions->activateAudioSessionWasCalled, nil);
}

- (void)testStillPausedAfterBeginInterruptionWhilePaused
{
    [self makeSetupStateMachine];
    [stateMachine play];
    [stateMachine togglePause];

    [stateMachine beginInterruption];
    
    [self assertStateIsPaused];
}

- (void)testStillPausedAfterEndInterruptionWhilePaused
{
    [self makeSetupStateMachine];
    [stateMachine play];
    [stateMachine togglePause];
    [stateMachine beginInterruption];
    
    [stateMachine endInterruption];
    
    [self assertStateIsPaused];
    STAssertTrue(mockActions->activateAudioSessionWasCalled, nil);
}

@end
