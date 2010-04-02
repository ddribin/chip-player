//
//  MyDocument.h
//  Retro Player
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "MUsicPlayer.h"

@class MusicPlayer;
@class TrackTableDataSource;

@interface MyDocument : NSDocument <MusicPlayerDelegate>
{
    MusicPlayer * _player;
    NSInteger _currentTrack;

    TrackTableDataSource * _trackTableDataSource;
    NSTableView * _trackTable;
    NSButton * _playPauseButton;
}

@property (assign) IBOutlet TrackTableDataSource * trackTableDataSource;
@property (assign) IBOutlet NSTableView * trackTable;
@property (assign) IBOutlet NSButton * playPauseButton;

- (IBAction)play:(id)sender;
- (IBAction)playSelectedTrack:(id)sender;

@end
