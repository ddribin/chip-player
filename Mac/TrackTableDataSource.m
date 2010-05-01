/*
 * Copyright (c) 2010 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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
