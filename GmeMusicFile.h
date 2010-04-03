//
//  GmeMusicFile.h
//  RetroPlayer
//
//  Created by Dave Dribin on 4/2/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MusicEmu;
@class TrackInfo;

@interface GmeMusicFile : NSObject
{
    MusicEmu * _emu;
}

+ (id)musicFileAtPath:(NSString *)path sampleRate:(long)sampleRate error:(NSError **)error;
+ (id)musicFileAtPath:(NSString *)path error:(NSError **)error;

- (long)sampleRate;
- (int)numberOfTracks;
- (TrackInfo *)infoForTrack:(int)track;

- (BOOL)playTrack:(int)track error:(NSError **)error;
- (BOOL)trackEnded;

BOOL GmeMusicFilePlay(GmeMusicFile * file, long count, short * samples, NSError ** error);

@end
