//
//  TrackTable.h
//  RetroPlayer
//
//  Created by Dave Dribin on 3/31/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MusicPlayer;

@interface TrackTableDataSource : NSObject <NSTableViewDataSource>
{
    // Non-retained
    NSTableView * _table;
    
    MusicPlayer * _player;
    NSInteger _currentTrack;
}

@property (assign) IBOutlet NSTableView * table;
@property (nonatomic, retain) MusicPlayer * player;
@property (nonatomic) NSInteger currentTrack;

@end
