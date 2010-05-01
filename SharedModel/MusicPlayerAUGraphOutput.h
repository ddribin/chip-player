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
#import "MusicPlayerOutput.h"

@class DDAudioUnitGraph;
@class DDAudioUnitNode;

@interface MusicPlayerAUGraphOutput : NSObject <MusicPlayerOutput>
{
    NSObject<MusicPlayerOutputDelegate> * _delegate;
    
    MusicEmu * _emu;
    GmeMusicFile * _musicFile;
    
    DDAudioUnitGraph * _graph;
    DDAudioUnitNode * _outputNode;
    DDAudioUnitNode * _effectNode;
    DDAudioUnitNode * _converterNode;
    BOOL _shouldBufferDataInCallback;
}

@property (retain) MusicEmu * emu;
@property (retain) GmeMusicFile * musicFile;

- (id)initWithDelegate:(id<MusicPlayerOutputDelegate>)delegate;

- (BOOL)setupWithSampleRate:(long)sampleRate error:(NSError **)error;
- (void)teardownAudio;
- (BOOL)startAudio:(NSError **)error;
- (void)stopAudio;
- (BOOL)pauseAudio:(NSError **)error;
- (BOOL)unpauseAudio:(NSError **)error;

@end
