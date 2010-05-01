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
