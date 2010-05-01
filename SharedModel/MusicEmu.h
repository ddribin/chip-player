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

/**
 * A very thin wrapper around the C++ Music_Emu class to localize all C++ to a single file.
 */
@interface MusicEmu : NSObject {
    Music_Emu * _emu;
}

+ (gme_err_t)gme_open_file:(const char *)path emu:(MusicEmu **)emu sampleRate:(long)sampleRate;

- (gme_err_t)set_sample_rate:(long)sample_rate;
- (long)sample_rate;

- (int)track_count;

- (gme_err_t)track_info:(track_info_t*)track_info;
- (gme_err_t)track_info:(track_info_t*)track_info track:(int)track;

- (gme_err_t)start_track:(int)track;

- (void)set_fade:(long)start_msec length:(long)length_msec;
- (void)set_fade:(long)start_msec;

- (bool)track_ended;

@end

#ifdef __cplusplus
extern "C" {
#endif

gme_err_t GmeMusicEmuPlay(MusicEmu * emu, long count, short * samples);

#ifdef __cplusplus
}
#endif
