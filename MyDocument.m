//
//  MyDocument.m
//  Retro Player
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import "MyDocument.h"
#import "MusicPlayer.h"
#import "TrackTableDataSource.h"

@implementation MyDocument

@synthesize trackTableDataSource = _trackTableDataSource;
@synthesize trackTable = _trackTable;
@synthesize playPauseButton = _playPauseButton;

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    
    }
    return self;
}

- (void)dealloc
{
    [_player teardown];
    [_player release];
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
    MusicPlayer * player = [[[MusicPlayer alloc] initWithDelegate:self] autorelease];
    [player setup];

    NSError * error = nil;
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
    NSInteger currentTrack = [_trackTableDataSource currentTrack];
    NSError * error = nil;
    if (![_player playTrack:currentTrack error:&error]) {
        NSLog(@"Could not play: %@ %@", error, [error userInfo]);
    }
}

- (IBAction)play:(id)sender;
{
    if ([_player isPlaying]) {
        [_player togglePause];
    } else {
        [self playCurrentTrack];
    }
}

- (IBAction)playSelectedTrack:(id)sender;
{
    NSInteger track = [_trackTable selectedRow];
    [_trackTableDataSource setCurrentTrack:track];
    [self playCurrentTrack];
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

- (void)musicPlayer:(MusicPlayer *)player didFailWithError:(NSError *)error;
{
    [NSApp presentError:error];
}

@end
