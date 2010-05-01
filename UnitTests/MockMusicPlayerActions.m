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
    activateAudioSessionWasCalled = NO;
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

- (void)activateAudioSession;
{
    activateAudioSessionWasCalled = YES;
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
