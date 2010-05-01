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

#import "TrackInfo.h"


@implementation TrackInfo

@synthesize trackNumber = _trackNumber;
@synthesize trackCount = _trackCount;
@synthesize length = _length;
@synthesize introLength = _introLength;
@synthesize loopLength = _loopLength;
@synthesize system = _system;
@synthesize game = _game;
@synthesize song = _song;
@synthesize author = _author;
@synthesize copyright = _copyright;

- (id)initWithTrackInfo:(track_info_t *)trackInfo trackNumber:(NSUInteger)trackNumber;
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _trackNumber = trackNumber;
    _trackCount = trackInfo->track_count;
    _length = trackInfo->length;
    _introLength = trackInfo->intro_length;
    _loopLength = trackInfo->loop_length;
    _system = [[NSString alloc] initWithUTF8String:trackInfo->system];
    _game = [[NSString alloc] initWithUTF8String:trackInfo->game];
    _song = [[NSString alloc] initWithUTF8String:trackInfo->song];
    _author = [[NSString alloc] initWithUTF8String:trackInfo->author];
    _copyright = [[NSString alloc] initWithUTF8String:trackInfo->copyright];
    
    if ([@"" isEqualToString:_song]) {
        [_song release];
        _song = [[NSString alloc] initWithFormat:@"Track %u", _trackNumber+1];
    }
    
    return self;
}

- (void)dealloc
{
    [_system release];
    [_game release];
    [_song release];
    [_author release];
    [_copyright release];
    
    [super dealloc];
}

@end
