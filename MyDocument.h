//
//  MyDocument.h
//  Retro Player
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "MusicPlayer.h"
#import "MusicPlayerActions.h"

@class MusicPlayer;
@class TrackTableDataSource;
@class GmeMusicFile;

@interface MyDocument : NSDocument <MusicPlayerActions, MusicPlayerOutputDelegate, MusicPlayerDelegate>
{
    MusicPlayer * _player;
    GmeMusicFile * _musicFile;
    MusicPlayerStateMachine * _stateMachine;
    MusicPlayerAudioQueueOutput * _playerOutput;

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
