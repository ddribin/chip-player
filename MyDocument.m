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
    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
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
    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    MusicPlayer * player = [[[MusicPlayer alloc] init] autorelease];
    NSError * error = nil;
#if 0
    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    if (![player setupSound:&error]) {
        if (outError != NULL) {
            *outError = error;
        }
        return NO;
    }
#endif
    
    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    [player setup];

    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    if (![player loadFileAtPath:[absoluteURL path] error:&error]) {
        [player teardown];
        if (outError != NULL) {
            *outError = error;
        }
        return NO;
    }
    
    NSLog(@"%s:%d", __PRETTY_FUNCTION__, __LINE__);
    _player = [player retain];
    _currentTrack = 0;
    
    return YES;
}

- (IBAction)play:(id)sender;
{
    if ([_player isPlaying]) {
        [_player togglePause];
    } else {
        [self playSelectedTrack:nil];
    }
}

- (IBAction)playSelectedTrack:(id)sender;
{
    _currentTrack = [_trackTable selectedRow];
    NSError * error = nil;
    if (![_player playTrack:_currentTrack error:&error]) {
        NSLog(@"Could not play: %@ %@", error, [error userInfo]);
    }
}

- (IBAction)pauseOrResume:(id)sender;
{
}

@end
