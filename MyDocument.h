//
//  MyDocument.h
//  Retro Player
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class MusicPlayer;
@class TrackTableDataSource;

@interface MyDocument : NSDocument
{
    MusicPlayer * _player;
    NSInteger _currentTrack;
    TrackTableDataSource * _trackTableDataSource;
    NSTableView * _trackTable;
}

@property (assign) IBOutlet TrackTableDataSource * trackTableDataSource;
@property (assign) IBOutlet NSTableView * trackTable;

- (IBAction)play:(id)sender;
- (IBAction)pauseOrResume:(id)sender;
- (IBAction)playSelectedTrack:(id)sender;

@end
