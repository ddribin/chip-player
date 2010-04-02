//
//  TrackTable.m
//  RetroPlayer
//
//  Created by Dave Dribin on 3/31/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import "TrackTableDataSource.h"
#import "MusicPlayer.h"
#import "TrackInfo.h"


@implementation TrackTableDataSource

@synthesize player = _player;
@synthesize table = _table;
@synthesize currentTrack = _currentTrack;


- (void)dealloc {
    [_player release];
    
    [super dealloc];
}

- (MusicPlayer *)player {
    return [[_player retain] autorelease]; 
}

- (void)setPlayer:(MusicPlayer *)player {
    if (_player != player) {
        [_player release];
        _player = [player retain];
        [_table reloadData];
    }
}

- (void)setCurrentTrack:(NSInteger)track
{
    NSMutableIndexSet * dirtyRows = [NSMutableIndexSet indexSet];
    [dirtyRows addIndex:_currentTrack];
    [dirtyRows addIndex:track];
    
    _currentTrack = track;
    [_table reloadDataForRowIndexes:dirtyRows columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    NSInteger tracks = [_player numberOfTracks];
    return tracks;
}

- (int)trackForRow:(NSInteger)row
{
    return row-1;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    TrackInfo * info = [_player trackInfoForTrack:row];
    if (info == nil) {
        return nil;
    }
    
    NSString * identifier = [tableColumn identifier];
    id value;
    if ([@"currentTrack" isEqualToString:identifier]) {
        value = (row == _currentTrack)? @"P" : @"";
    }
    else {
        NSString * trackInfoKey = identifier;
        value = [info valueForKey:trackInfoKey];
        if ([trackInfoKey isEqualToString:@"song"] && [@"" isEqualToString:value]) {
            value = [NSString stringWithFormat:@"Track %d", row+1];
        }
    }

    return value;
}

@end
