//
//  MyDocument.h
//  Retro Player
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class MusicPlayer;
@class TrackTable;

@interface MyDocument : NSDocument
{
    MusicPlayer * _player;
    int _currentTrack;
    TrackTable * _trackTable;
}

@property (assign) IBOutlet TrackTable * trackTable;

- (IBAction)play:(id)sender;
- (IBAction)pauseOrResume:(id)sender;

@end
