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


@interface TrackTableDataSource ()
- (NSString *)objectValueForCurrentTrackColumnAtRow:(NSInteger)row;
- (NSString *)trackInfo:(TrackInfo *)info valueForKey:(NSString *)trackInfoKey row:(NSInteger)row;
@end

@implementation TrackTableDataSource

@synthesize musicFile = _musicFile;
@synthesize table = _table;
@synthesize currentTrack = _currentTrack;


- (void)dealloc
{
    [_musicFile release];
    
    [super dealloc];
}

- (GmeMusicFile *)musicFile
{
    return [[_musicFile retain] autorelease]; 
}

- (void)setMusicFile:(GmeMusicFile *)musicFile
{
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
    
    NSString * identifier = [tableColumn identifier];
    TrackInfo * info = [_musicFile infoForTrack:row];
    NSString * value;

    if (info == nil) {
        value = nil;
    }
    else if ([@"currentTrack" isEqualToString:identifier]) {
        value = [self objectValueForCurrentTrackColumnAtRow:row];
    }
    else {
        value = [self trackInfo:info valueForKey:identifier row:row];
    }

    return value;
}

- (NSString *)objectValueForCurrentTrackColumnAtRow:(NSInteger)row;
{
    NSString * value = @"";
    if (row == _currentTrack) {
        value = @">";
    }
    return value;
}

- (NSString *)trackInfo:(TrackInfo *)info valueForKey:(NSString *)trackInfoKey row:(NSInteger)row;
{
    NSString * value = [info valueForKey:trackInfoKey];
    if ([trackInfoKey isEqualToString:@"song"] && [@"" isEqualToString:value]) {
        value = [NSString stringWithFormat:@"Track %d", row+1];
    }
    return value;
}

@end
