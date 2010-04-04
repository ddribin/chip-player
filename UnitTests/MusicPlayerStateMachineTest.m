//
//  MusicPlayerStateMachineTest.m
//  RetroPlayer
//
//  Created by Dave Dribin on 4/3/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import "MusicPlayerStateMachineTest.h"
#import "MusicPlayerStateMachine.h"
#import "MockMusicPlayerActions.h"

enum State {
    RRStateUninitialized,
    RRStateStopped,
    RRStatePlaying,
    RRStatePaused,
};


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
    STAssertTrue([stateMachine state] == RRStateUninitialized, nil);
}

- (void)assertStateIsStopped
{
    STAssertTrue([stateMachine state] == RRStateStopped, nil);
}

- (void)assertStateIsPlaying
{
    STAssertTrue([stateMachine state] == RRStatePlaying, nil);
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

@end
