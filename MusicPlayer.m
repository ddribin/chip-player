//
//  MusicPlayer.m
//  RetroPlayer
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import "MusicPlayer.h"
#import "MusicEmu.h"
#import "TrackInfo.h"
#import "GmeErrors.h"
#import "MusicPlayerStateMachine.h"
#import "MusicPlayerAudioQueueOutput.h"

#define kNumberBuffers (sizeof(_buffers)/sizeof(_buffers[0]))

enum State {
    RRStateUninitialized,
    RRStateStopped,
    RRStatePlaying,
    RRStatePaused,
};

@implementation MusicPlayer

- (id)initWithDelegate:(id<MusicPlayerDelegate>)delegate sampleRate:(long)sampleRate;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _sampleRate = sampleRate;
    _playerOutput = [[MusicPlayerAudioQueueOutput alloc] initWithDelegate:self sampleRate:sampleRate];
    _stateMachine = [[MusicPlayerStateMachine alloc] initWithActions:self];
    _delegate = delegate;
    
    return self;
}

- (id)initWithDelegate:(id<MusicPlayerDelegate>)delegate;
{
    return [self initWithDelegate:delegate sampleRate:44100];
}

- (id)init;
{
    return [self initWithDelegate:nil sampleRate:44100];
}

- (void)dealloc {
    [_emu release];
    [_stateMachine release];
    [_playerOutput release];
    
    [super dealloc];
}

- (void)setup;
{
    [_stateMachine setup];
}

- (void)teardown;
{
    [_stateMachine teardown];
}

- (void)stop;
{
    [_stateMachine stop];
}

- (void)togglePause;
{
    [_stateMachine togglePause];
}

- (BOOL)isPlaying;
{
    return [_stateMachine isPlaying];
}

- (BOOL)loadFileAtPath:(NSString *)path error:(NSError **)error;
{
    [self stop];
    
    MusicEmu * emu = [MusicEmu musicEmuWithFile:path sampleRate:_sampleRate error:error];
    if (emu == nil) {
        return NO;
    }
    
    [_emu release];
    _emu = [emu retain];
    _playerOutput.emu = emu;
    
    return YES;
}

- (int)numberOfTracks;
{
    return [_emu track_count];
}

- (TrackInfo *)trackInfoForTrack:(int)track;
{
    track_info_t gmeTrackInfo;
    gme_err_t gmeError = [_emu track_info:&gmeTrackInfo track:track];
    if (gmeError != 0) {
        NSLog(@"error: %s", gmeError);
    }
    
    TrackInfo * trackInfo = [[TrackInfo alloc] initWithTrackInfo:&gmeTrackInfo trackNumber:track];
    return [trackInfo autorelease];
}

- (BOOL)playTrack:(int)track error:(NSError **)error;
{
    [_stateMachine stop];
    
    gme_err_t gme_error = [_emu start_track:track];
    if (gme_error != 0) {
        if (error != NULL) {
            *error = [NSError gme_error:gme_error];
        }
        return NO;
    }
    
    track_info_t track_info_;
    gme_error = [_emu track_info:&track_info_];
    if (gme_error == 0) {
        if ( track_info_.length <= 0 ) {
            track_info_.length = track_info_.intro_length +
            track_info_.loop_length * 2;
        }
    }
    if ( track_info_.length <= 0 )
        track_info_.length = (long) (2.5 * 60 * 1000);
    [_emu set_fade:track_info_.length];
    
    [_stateMachine play];
    return YES;
}

#pragma mark -
#pragma mark MusicPlayerActions API

- (void)handleError:(NSError *)error;
{
    [_delegate musicPlayer:self didFailWithError:error];
}

- (void)clearError;
{
}

- (BOOL)setupAudio:(NSError **)error;
{
    return [_playerOutput setupAudio:error];
}

- (void)teardownAudio;
{
    [_playerOutput teardownAudio];
}

- (BOOL)startAudio:(NSError **)error;
{
    return [_playerOutput startAudio:error];
}

- (void)stopAudio;
{
    [_playerOutput stopAudio];
}

- (BOOL)pauseAudio:(NSError **)error;
{
    return [_playerOutput pauseAudio:error];
}

- (BOOL)unpauseAudio:(NSError **)error;
{
    return [_playerOutput unpauseAudio:error];
}

- (void)didStop;
{
    if (_delegate != nil) {
        [_delegate musicPlayerDidStop:self];
    }
}

- (void)didPlay;
{
    if (_delegate != nil) {
        [_delegate musicPlayerDidStart:self];
    }
}

- (void)didPause;
{
    if (_delegate != nil) {
        [_delegate musicPlayerDidPause:self];
    }
}

#pragma mark -

- (void)musicPlayerOutputDidFinishTrack:(MusicPlayerAudioQueueOutput *)output;
{
    [_delegate musicPlayerDidFinishTrack:self];
}

@end
