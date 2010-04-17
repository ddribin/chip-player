//
//  MusicPlayerAUGraphOutput.h
//  RetroPlayer
//
//  Created by Dave Dribin on 4/17/10.
//  Copyright 2010 Bit Maki, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
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
