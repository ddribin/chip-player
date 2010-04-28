//
//  TrackInfo.h
//  RetroPlayer
//
//  Created by Dave Dribin on 3/31/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "gme/gme.h"


@interface TrackInfo : NSObject
{
    NSUInteger _trackNumber;
    NSUInteger _trackCount;
    NSInteger _length;
    NSInteger _introLength;
    NSInteger _loopLength;
    NSString * _system;
    NSString * _game;
    NSString * _song;
    NSString * _author;
    NSString * _copyright;
}

@property (readonly) NSUInteger trackNumber;
@property (readonly) NSUInteger trackCount;
@property (readonly) NSInteger length;
@property (readonly) NSInteger introLength;
@property (readonly) NSInteger loopLength;
@property (readonly, copy) NSString * system;
@property (readonly, copy) NSString * game;
@property (readonly, copy) NSString * song;
@property (readonly, copy) NSString * author;
@property (readonly, copy) NSString * copyright;

- (id)initWithTrackInfo:(track_info_t *)trackInfo trackNumber:(NSUInteger)trackNumber;

@end
