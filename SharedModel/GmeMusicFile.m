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

#import "GmeMusicFile.h"
#import "TrackInfo.h"
#import "MusicEmu.h"
#import "GmeErrors.h"


@interface GmeMusicFile ()
- (id)initWithMusicEmu:(MusicEmu *)emu;
@end

@implementation GmeMusicFile

BOOL GmeMusicFilePlay(GmeMusicFile * file, long count, short * samples, NSError ** error)
{
    MusicEmu * emu = file->_emu;
    gme_err_t gmeError = GmeMusicEmuPlay(emu, count, samples);
    if (gmeError != 0) {
        if (error != NULL) {
            *error = [NSError gme_error:gmeError];
        }
        return NO;
    }
    return YES;
}

+ (id)musicFileAtPath:(NSString *)path sampleRate:(long)sampleRate error:(NSError **)error;
{
    MusicEmu * emu = nil;
    gme_err_t gmeError = [MusicEmu gme_open_file:[path fileSystemRepresentation] emu:&emu sampleRate:sampleRate];
    if (gmeError != 0) {
        if (error != NULL) {
            *error = [NSError gme_error:gmeError];
        }
        return nil;
    }
    
    id o = [[self alloc] initWithMusicEmu:emu];
    return [o autorelease];
}

+ (id)musicFileAtPath:(NSString *)path error:(NSError **)error;
{
    return [self musicFileAtPath:path sampleRate:44100 error:error];
}

- (id)initWithMusicEmu:(MusicEmu *)emu;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _emu = [emu retain];
    
    return self;
}

- (void)dealloc
{
    [_emu release];
    [super dealloc];
}


- (long)sampleRate;
{
    return [_emu sample_rate];
}

- (int)numberOfTracks;
{
    return [_emu track_count];
}

- (TrackInfo *)infoForTrack:(int)track;
{
    track_info_t gmeTrackInfo;
    gme_err_t gmeError = [_emu track_info:&gmeTrackInfo track:track];
    if (gmeError != 0) {
        NSLog(@"error: %s", gmeError);
    }
    
    TrackInfo * trackInfo = [[TrackInfo alloc] initWithTrackInfo:&gmeTrackInfo trackNumber:track];
    return [trackInfo autorelease];
}

- (BOOL)playTrack:(int)track error:(NSError **)error;
{
    gme_err_t gme_error = [_emu start_track:track];
    if (gme_error != 0) {
        if (error != NULL) {
            *error = [NSError gme_error:gme_error];
        }
        return NO;
    }
    
    track_info_t track_info_;
    gme_error = [_emu track_info:&track_info_];
    if (gme_error == 0) {
        if ( track_info_.length <= 0 ) {
            track_info_.length = track_info_.intro_length +
            track_info_.loop_length * 2;
        }
    }
    if ( track_info_.length <= 0 )
        track_info_.length = (long) (4.0 * 60 * 1000);
    [_emu set_fade:track_info_.length];
    
    return YES;
}

- (BOOL)trackEnded;
{
    return [_emu track_ended];
}

@end
