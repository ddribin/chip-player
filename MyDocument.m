//
//  MyDocument.m
//  Retro Player
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import "MyDocument.h"
#import "GmeMusicFile.h"
#import "MusicPlayerStateMachine.h"
#import "MusicPlayer.h"
#import "TrackTableDataSource.h"

@implementation MyDocument

@synthesize trackTableDataSource = _trackTableDataSource;
@synthesize trackTable = _trackTable;
@synthesize playPauseButton = _playPauseButton;

- (id)init
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _playerOutput = [(MusicPlayerAudioQueueOutput *)[MusicPlayerAudioQueueOutput alloc] initWithDelegate:self];
    _stateMachine = [[MusicPlayerStateMachine alloc] initWithActions:self];
    
    return self;
}

- (void)dealloc
{
    [_player teardown];
    [_player release];
    
    [_stateMachine teardown];
    [_stateMachine release];
    [_playerOutput release];
    [super dealloc];
}


- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    _trackTableDataSource.player = _player;
    [_trackTable setDoubleAction:@selector(playSelectedTrack:)];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

#if 0
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}
#endif



- (BOOL)readFromURL:(NSURL *)absoluteURL
             ofType:(NSString *)typeName
              error:(NSError **)outError
{
    NSError * error = nil;
    GmeMusicFile * musicFile = [GmeMusicFile musicFileAtPath:[absoluteURL path] error:&error];
    if (musicFile == nil) {
        if (outError != NULL) {
            *outError = error;
        }
        return NO;
    }
    
    if (![_playerOutput setupWithSampleRate:[musicFile sampleRate] error:&error]) {
        if (outError != NULL) {
            *outError = error;
        }
        return NO;
    }
    
    [_musicFile release];
    _musicFile = [musicFile retain];
    
    [_playerOutput setMusicFile:_musicFile];
    
    [_stateMachine setup];
    
    MusicPlayer * player = [[(MusicPlayer *)[MusicPlayer alloc] initWithDelegate:self] autorelease];
    [player setup];

    error = nil;
    if (![player loadFileAtPath:[absoluteURL path] error:&error]) {
        [player teardown];
        if (outError != NULL) {
            *outError = error;
        }
        return NO;
    }
    
    _player = [player retain];
    
    return YES;
}

- (void)playCurrentTrack;
{
#if 0
    NSInteger currentTrack = [_trackTableDataSource currentTrack];
    NSError * error = nil;
    if (![_player playTrack:currentTrack error:&error]) {
        NSLog(@"Could not play: %@ %@", error, [error userInfo]);
    }
#else
    NSInteger currentTrack = [_trackTableDataSource currentTrack];
    NSError * error = nil;
    if (![_musicFile playTrack:currentTrack error:&error]) {
        NSLog(@"Could not play: %@ %@", error, [error userInfo]);
    }
#endif
}

- (IBAction)play:(id)sender;
{
#if 0
    if ([_player isPlaying]) {
        [_player togglePause];
    } else {
        [self playCurrentTrack];
    }
#else
    [_stateMachine togglePause];
#endif
}

- (IBAction)playSelectedTrack:(id)sender;
{
#if 0
    NSInteger track = [_trackTable selectedRow];
    [_trackTableDataSource setCurrentTrack:track];
    [self playCurrentTrack];
#else
    [_stateMachine play];
#endif
}

- (void)musicPlayerDidStop:(MusicPlayer *)player;
{
    [_playPauseButton setTitle:@"Play"];
}

- (void)musicPlayerDidStart:(MusicPlayer *)player;
{
    [_playPauseButton setTitle:@"Pause"];
}

- (void)musicPlayerDidPause:(MusicPlayer *)player;
{
    [_playPauseButton setTitle:@"Play"];
}

- (void)musicPlayerDidFinishTrack:(MusicPlayer *)player;
{
    NSInteger currentTrack = [_trackTableDataSource currentTrack];
    if ((currentTrack+1) < [_player numberOfTracks]) {
        currentTrack++;
        [_trackTableDataSource setCurrentTrack:currentTrack];
        [self playCurrentTrack];
    } else {
        [_player stop];
    }
}

- (void)musicPlayerOutputDidFinishTrack:(MusicPlayerAudioQueueOutput *)output;
{
    [_stateMachine trackDidFinish];
}

- (void)musicPlayer:(MusicPlayer *)player didFailWithError:(NSError *)error;
{
    [NSApp presentError:error];
}

#pragma mark -
#pragma mark MusicPlayerActions API

- (void)handleError:(NSError *)error;
{
}

- (void)clearError;
{
}

- (void)didStop;
{
    [_playPauseButton setTitle:@"Play"];
}
    
- (void)didPlay;
{
    [_playPauseButton setTitle:@"Pause"];
}

- (void)didPause;
{
    [_playPauseButton setTitle:@"Play"];
}

- (BOOL)setupAudio:(NSError **)error;
{
    return YES;
}

- (void)teardownAudio;
{
    [_playerOutput teardownAudio];
}

- (BOOL)startAudio:(NSError **)error;
{
    [self playCurrentTrack];
    return [_playerOutput startAudio:error];
}

- (void)setCurrentTrackToSelectedTrack;
{
    NSInteger track = [_trackTable selectedRow];
    [_trackTableDataSource setCurrentTrack:track];
}

- (void)nextTrack;
{
    NSInteger currentTrack = [_trackTableDataSource currentTrack];
    currentTrack++;
    [_trackTableDataSource setCurrentTrack:currentTrack];
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

- (BOOL)isCurrentTrackTheLastTrack;
{
    NSInteger currentTrack = [_trackTableDataSource currentTrack];
    BOOL isLast = ((currentTrack+1) == [_player numberOfTracks]);
    return isLast;
}

@end
