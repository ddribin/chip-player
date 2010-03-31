//
//  MusicEmu.h
//  RetroPlayer
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "gme/gme.h"

@interface MusicEmu : NSObject {
    Music_Emu * _emu;
}

+ (id)musicEmuWithFile:(NSString *)path sampleRate:(long)sampleRate error:(NSError **)error;

- (Music_Emu *)emu;

- (gme_err_t)set_sample_rate:(long)sample_rate;

- (int)track_count;

- (gme_err_t)track_info:(track_info_t*)track_info;
- (gme_err_t)track_info:(track_info_t*)track_info track:(int)track;

- (gme_err_t)start_track:(int)track;

- (void)set_fade:(long)start_msec length:(long)length_msec;
- (void)set_fade:(long)start_msec;

@end

#ifdef __cplusplus
extern "C" {
#endif

gme_err_t GmeMusicEmuPlay(MusicEmu * emu, long count, short * samples);

#ifdef __cplusplus
}
#endif
