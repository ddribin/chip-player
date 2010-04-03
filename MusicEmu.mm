//
//  MusicEmu.m
//  RetroPlayer
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

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

+ (id)musicEmuWithFile:(NSString *)path sampleRate:(long)sampleRate error:(NSError **)error;
{
    Music_Emu * emu;
    gme_err_t gme_error = gme_open_file([path fileSystemRepresentation], &emu, sampleRate);
    if (gme_error != 0) {
        if (error != NULL) {
            *error = [NSError gme_error:gme_error];
        }
        return nil;
    }
    
    id o = [[self alloc] initWithMusicEmu:emu];
    return [o autorelease];
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
