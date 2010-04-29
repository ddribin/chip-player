//
//  MockMusicPlayerActions.h
//  RetroPlayer
//
//  Created by Dave Dribin on 4/3/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MusicPlayerActions.h"


@interface MockMusicPlayerActions : NSObject <MusicPlayerActions>
{
    int currentTrack;
    int selectedTrack;
    int numberOfTracks;

@public
    // Expectations
    BOOL enableOrDisablePreviousAndNextWasCalled;
    BOOL startAudioWasCalled;
    BOOL stopAudioWasCalled;
    BOOL activateAudioSessionWasCalled;
    BOOL setButtonToPlayWasCalled;
    BOOL setButtonToPausedWasCalled;
}

@property int currentTrack;
@property int selectedTrack;
@property (readonly) int numberOfTracks;

+ (id)mockActions;

- (void)clearExpectations;

- (void)setCurrentTrackToFirstTrack;
- (void)setCurrentTrackToMiddleTrack;
- (void)setCurrentTrackToLastTrack;

@end
