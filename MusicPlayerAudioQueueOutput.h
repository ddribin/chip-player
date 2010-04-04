//
//  MusicPlayerAudioQueueOutput.h
//  RetroPlayer
//
//  Created by Dave Dribin on 4/1/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioQueue.h>

@class MusicEmu;
@class GmeMusicFile;
@class MusicPlayerAudioQueueOutput;


@protocol MusicPlayerOutputDelegate <NSObject>

- (void)musicPlayerOutputDidFinishTrack:(MusicPlayerAudioQueueOutput *)output;

@end


@interface MusicPlayerAudioQueueOutput : NSObject
{
    NSObject<MusicPlayerOutputDelegate> * _delegate;
    
    MusicEmu * _emu;
    GmeMusicFile * _musicFile;
    long _sampleRate;
    
    AudioStreamBasicDescription _dataFormat;
    AudioQueueRef _queue;
    AudioQueueBufferRef _buffers[3];
    UInt32 _bufferByteSize;
    UInt32 _numPacketsToRead;
    AudioStreamPacketDescription * _packetDescs;
    BOOL _shouldBufferDataInCallback;
}

@property (retain) MusicEmu * emu;
@property (retain) GmeMusicFile * musicFile;

- (id)initWithDelegate:(id<MusicPlayerOutputDelegate>)delegate sampleRate:(long)sampleRate;
- (id)initWithDelegate:(id<MusicPlayerOutputDelegate>)delegate;

- (BOOL)setupAudio:(NSError **)error;
- (BOOL)setupWithSampleRate:(long)sampleRate error:(NSError **)error;
- (void)teardownAudio;
- (BOOL)startAudio:(NSError **)error;
- (void)stopAudio;
- (BOOL)pauseAudio:(NSError **)error;
- (BOOL)unpauseAudio:(NSError **)error;

@end
