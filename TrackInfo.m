//
//  TrackInfo.m
//  RetroPlayer
//
//  Created by Dave Dribin on 3/31/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import "TrackInfo.h"


@implementation TrackInfo

@synthesize trackCount = _trackCount;
@synthesize length = _length;
@synthesize introLength = _introLength;
@synthesize loopLength = _loopLength;
@synthesize system = _system;
@synthesize game = _game;
@synthesize song = _song;
@synthesize author = _author;
@synthesize copyright = _copyright;

- (id)initWithTrackInfo:(track_info_t *)trackInfo;
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _trackCount = trackInfo->track_count;
    _length = trackInfo->length;
    _introLength = trackInfo->intro_length;
    _loopLength = trackInfo->loop_length;
    _system = [[NSString alloc] initWithUTF8String:trackInfo->system];
    _game = [[NSString alloc] initWithUTF8String:trackInfo->game];
    _song = [[NSString alloc] initWithUTF8String:trackInfo->song];
    _author = [[NSString alloc] initWithUTF8String:trackInfo->author];
    _copyright = [[NSString alloc] initWithUTF8String:trackInfo->copyright];
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc {
    [_system release];
    [_game release];
    [_song release];
    [_author release];
    [_copyright release];
    
    [super dealloc];
}

@end
