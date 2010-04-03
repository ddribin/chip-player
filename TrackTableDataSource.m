//
//  TrackTable.m
//  RetroPlayer
//
//  Created by Dave Dribin on 3/31/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import "TrackTableDataSource.h"
#import "GmeMusicFile.h"
#import "TrackInfo.h"


@implementation TrackTableDataSource

@synthesize musicFile = _musicFile;
@synthesize table = _table;
@synthesize currentTrack = _currentTrack;


- (void)dealloc {
    [_musicFile release];
    
    [super dealloc];
}

- (GmeMusicFile *)musicFile {
    return [[_musicFile retain] autorelease]; 
}

- (void)setMusicFile:(GmeMusicFile *)musicFile {
    if (_musicFile != musicFile) {
        [_musicFile release];
        _musicFile = [musicFile retain];
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
    NSInteger tracks = [_musicFile numberOfTracks];
    return tracks;
}

- (int)trackForRow:(NSInteger)row
{
    return row-1;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    TrackInfo * info = [_musicFile infoForTrack:row];
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
