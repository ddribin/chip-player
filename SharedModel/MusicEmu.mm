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

#import "MusicEmu.h"
#import "GmeErrors.h"
#import "gme/Music_Emu.h"


@interface MusicEmu ()
- (id)initWithMusicEmu:(Music_Emu *)emu;
@end

@implementation MusicEmu

gme_err_t GmeMusicEmuPlay(MusicEmu * emu, long count, short * samples)
{
    return emu->_emu->play(count, samples);
}

+ (gme_err_t)gme_open_file:(const char *)path emu:(MusicEmu **)emu sampleRate:(long)sampleRate;
{
    Music_Emu * gmeEmu = NULL;
    gme_err_t gmeError = gme_open_file(path, &gmeEmu, sampleRate);
    if (gmeEmu != NULL) {
        *emu = [[[self alloc] initWithMusicEmu:gmeEmu] autorelease];
    }
    return gmeError;
}

- (id)initWithMusicEmu:(Music_Emu *)emu;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _emu = emu;
    
    return self;
}

- (void)dealloc
{
    delete _emu;
    [super dealloc];
}

- (gme_err_t)set_sample_rate:(long)sample_rate;
{
    return _emu->set_sample_rate(sample_rate);
}

- (long)sample_rate;
{
    return _emu->sample_rate();
}

- (int)track_count;
{
    return _emu->track_count();
}

- (gme_err_t)track_info:(track_info_t*)track_info;
{
    return _emu->track_info(track_info);
}

- (gme_err_t)track_info:(track_info_t*)track_info track:(int)track;
{
    return _emu->track_info(track_info, track);
}

- (gme_err_t)start_track:(int)track;
{
    return _emu->start_track(track);
}

- (void)set_fade:(long)start_msec length:(long)length_msec;
{
    _emu->set_fade(start_msec, length_msec);
}

- (void)set_fade:(long)start_msec;
{
    [self set_fade:start_msec length:8000];
}

- (bool)track_ended;
{
    return _emu->track_ended();
}

@end
