//
//  MyDocument.h
//  Retro Player
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "MusicPlayerActions.h"
#import "MusicPlayerOutput.h"

@class TrackTableDataSource;
@class GmeMusicFile;
@class MusicPlayerStateMachine;
@class MusicPlayerAUGraphOutput;

@interface MyDocument : NSDocument <MusicPlayerActions, MusicPlayerOutputDelegate>
{
    GmeMusicFile * _musicFile;
    MusicPlayerStateMachine * _stateMachine;
    id<MusicPlayerOutput> _playerOutput;

    TrackTableDataSource * _trackTableDataSource;
    NSTableView * _trackTable;
    NSButton * _previousButton;
    NSButton * _playPauseButton;
    NSButton * _nextButton;
}

@property (assign) IBOutlet TrackTableDataSource * trackTableDataSource;
@property (assign) IBOutlet NSTableView * trackTable;
@property (assign) IBOutlet NSButton * previousButton;
@property (assign) IBOutlet NSButton * playPauseButton;
@property (assign) IBOutlet NSButton * nextButton;

- (IBAction)play:(id)sender;
- (IBAction)playSelectedTrack:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)previous:(id)sender;

@end
