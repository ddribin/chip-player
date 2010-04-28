//
//  TrackTable.h
//  RetroPlayer
//
//  Created by Dave Dribin on 3/31/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GmeMusicFile;

@interface TrackTableDataSource : NSObject <NSTableViewDataSource>
{
    // Non-retained
    NSTableView * _table;
    
    GmeMusicFile * _musicFile;
    NSInteger _currentTrack;
}

@property (assign) IBOutlet NSTableView * table;
@property (nonatomic, retain) GmeMusicFile * musicFile;
@property (nonatomic) NSInteger currentTrack;

@end
