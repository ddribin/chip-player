//
//  TrackInfo.h
//  RetroPlayer
//
//  Created by Dave Dribin on 3/31/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "gme/gme.h"


@interface TrackInfo : NSObject
{
    NSUInteger _trackCount;
    NSString * _system;
    NSString * _game;
    NSString * _song;
    NSString * _author;
    NSString * _copyright;
}

@property (readonly) NSUInteger trackCount;
@property (readonly, copy) NSString * system;
@property (readonly, copy) NSString * game;
@property (readonly, copy) NSString * song;
@property (readonly, copy) NSString * author;
@property (readonly, copy) NSString * copyright;

- (id)initWithTrackInfo:(track_info_t *)trackInfo;

@end
