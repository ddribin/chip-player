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

#import "MyDocument.h"
#import "GmeMusicFile.h"
#import "MusicPlayerStateMachine.h"
#import "TrackTableDataSource.h"
#import "MusicPlayerAudioQueueOutput.h"
#import "MusicPlayerAUGraphOutput.h"
#import "MusicPlayerAUGraphWithQueueOutput.h"
#import "DDAudioComponent.h"

#define USE_AUDIO_QUEUE 0

@implementation MyDocument

@synthesize trackTableDataSource = _trackTableDataSource;
@synthesize trackTable = _trackTable;
@synthesize previousButton = _previousButton;
@synthesize playPauseButton = _playPauseButton;
@synthesize nextButton = _nextButton;

- (id)init
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
#if USE_AUDIO_QUEUE
    Class MusicPlayerOutputClass = [MusicPlayerAudioQueueOutput class];
#elif 0
    Class MusicPlayerOutputClass = [MusicPlayerAUGraphOutput class];
#else
    Class MusicPlayerOutputClass = [MusicPlayerAUGraphWithQueueOutput class];
#endif
    NSLog(@"MusicPlayerOutputClass: %@", MusicPlayerOutputClass);
    _playerOutput = [[MusicPlayerOutputClass alloc] initWithDelegate:self];
    _stateMachine = [[MusicPlayerStateMachine alloc] initWithActions:self];
    
    return self;
}

- (void)dealloc
{
    [_stateMachine teardown];
    
    [_stateMachine release];
    [_musicFile release];
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
    
    _trackTableDataSource.musicFile = _musicFile;
    [_trackTable setDoubleAction:@selector(playSelectedTrack:)];
    [_stateMachine setup];
    // [DDAudioComponent printComponents];
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
        goto failed;
    }
    
    if (![_playerOutput setupWithSampleRate:[musicFile sampleRate] error:&error]) {
        goto failed;
    }
    
    [_musicFile release];
    _musicFile = [musicFile retain];
    [_playerOutput setMusicFile:_musicFile];
    
    return YES;
    
failed:
    if (outError != NULL) {
        *outError = error;
    }
    return NO;
}

#pragma mark External Actions

- (IBAction)play:(id)sender;
{
    [_stateMachine togglePause];
}

- (IBAction)playSelectedTrack:(id)sender;
{
    [_stateMachine play];
}

- (IBAction)next:(id)sender;
{
    [_stateMachine next];
}

- (IBAction)previous:(id)sender;
{
    [_stateMachine previous];
}

- (void)musicPlayerOutputDidFinishTrack:(id<MusicPlayerOutput>)output;
{
    [_stateMachine trackDidFinish];
}

#pragma mark -

- (void)playCurrentTrack;
{
    NSInteger currentTrack = [_trackTableDataSource currentTrack];
    NSError * error = nil;
    if (![_musicFile playTrack:currentTrack error:&error]) {
        NSLog(@"Could not play: %@ %@", error, [error userInfo]);
    }
}

#pragma mark -
#pragma mark MusicPlayerActions API

- (void)handleError:(NSError *)error;
{
    [NSApp presentError:error];
}

- (void)setButtonToPlay;
{
    [_playPauseButton setTitle:@"Play"];
}

- (void)setButtonToPause;
{
    [_playPauseButton setTitle:@"Pause"];
}

- (void)enableOrDisablePreviousAndNext;
{
    BOOL previousEnabled = ![self isCurrentTrackTheFirstTrack];
    [_previousButton setEnabled:previousEnabled];
    
    BOOL nextEnabled = ![self isCurrentTrackTheLastTrack];
    [_nextButton setEnabled:nextEnabled];
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

- (void)previousTrack;
{
    NSInteger currentTrack = [_trackTableDataSource currentTrack];
    currentTrack--;
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

- (void)activateAudioSession;
{
}

- (BOOL)isCurrentTrackTheLastTrack;
{
    NSInteger currentTrack = [_trackTableDataSource currentTrack];
    BOOL isLast = ((currentTrack+1) == [_musicFile numberOfTracks]);
    return isLast;
}


- (BOOL)isCurrentTrackTheFirstTrack;
{
    NSInteger currentTrack = [_trackTableDataSource currentTrack];
    BOOL isFirst = (currentTrack == 0);
    return isFirst;
}

@end
