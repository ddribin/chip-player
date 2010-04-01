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
    MusicPlayer * _player;
    NSTableView * _table;
}

@property (nonatomic, retain) MusicPlayer * player;
@property (assign) IBOutlet NSTableView * table;

@end
