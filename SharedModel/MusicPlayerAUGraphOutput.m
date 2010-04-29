//
//  MusicPlayerAUGraphOutput.m
//  RetroPlayer
//
//  Created by Dave Dribin on 4/17/10.
//  Copyright 2010 Bit Maki, Inc. All rights reserved.
//

#import "MusicPlayerAUGraphOutput.h"
#import "GmeMusicFile.h"
#import "MusicEmu.h"
#import "DDCoreAudio.h"


@interface MusicPlayerAUGraphOutput ()
@end

@implementation MusicPlayerAUGraphOutput

@synthesize emu = _emu;
@synthesize musicFile = _musicFile;

- (id)initWithDelegate:(id<MusicPlayerOutputDelegate>)delegate;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _delegate = delegate;
    
    return self;
}

- (void)dealloc
{
    [_emu release];
    [_musicFile release];
    
    [super dealloc];
}

// render some silence
static void SilenceData(AudioBufferList *inData)
{
	for (UInt32 i=0; i < inData->mNumberBuffers; i++)
		memset(inData->mBuffers[i].mData, 0, inData->mBuffers[i].mDataByteSize);
}

static OSStatus MyRenderer(void *							inRefCon,
                           AudioUnitRenderActionFlags *	ioActionFlags,
                           const AudioTimeStamp *			inTimeStamp,
                           UInt32							inBusNumber,
                           UInt32							inNumberFrames,
                           AudioBufferList *				ioData)
{
    MusicPlayerAUGraphOutput * player = (MusicPlayerAUGraphOutput *)inRefCon;

    if (!player->_shouldBufferDataInCallback) {
        SilenceData(ioData);
        return noErr;
    }
    
    GmeMusicFile * musicFile = player->_musicFile;
    if (musicFile == nil) {
        NSLog(@"No music file");
        SilenceData(ioData);
        return noErr;
    }

    NSError * error = nil;
    if (!GmeMusicFilePlay(musicFile, ioData->mBuffers[0].mDataByteSize/2, ioData->mBuffers[0].mData, &error)) {
        NSLog(@"GmeMusicFilePlay error: %@ %@", error, [error userInfo]);
        return noErr;
    }

    // Peform after delay to get us out of the callback as some resulting actions
    // that act on the queue may not work when called from the callback
    // [player performSelector:@selector(checkTrackDidEnd) withObject:nil afterDelay:0.0];
    if ([musicFile trackEnded]) {
        NSLog(@"%s:%d trackEnded", __PRETTY_FUNCTION__, __LINE__);
        player->_shouldBufferDataInCallback = NO;
        [player performSelectorOnMainThread:@selector(trackEnded) withObject:nil waitUntilDone:NO];
    }
    
    return noErr;
}


- (BOOL)setupWithSampleRate:(long)sampleRate error:(NSError **)error;
{
    _graph = [[DDAudioUnitGraph alloc] init];
    
    _outputNode = [_graph addNodeWithType:kAudioUnitType_Output
                                  subType:kAudioUnitSubType_DDDefaultOutput];
    [_outputNode retain];
    
#if 0
    _effectNode = [_graph addNodeWithType:kAudioUnitType_Effect
                                  subType:kAudioUnitSubType_MatrixReverb];
#endif
    
    _converterNode = [_graph addNodeWithType:kAudioUnitType_FormatConverter
                                     subType:kAudioUnitSubType_AUConverter];
    [_converterNode retain];
    
    if (_effectNode == nil) {
        [_graph connectNode:_converterNode output:0
                     toNode:_outputNode input:0];
    } else {
        [_graph connectNode:_converterNode output:0
                     toNode:_effectNode input:0];
        [_graph connectNode:_effectNode output:0
                     toNode:_outputNode input:0];
    }
    
    [_graph open];
    
    // 16-bit signed integer, stereo
    AudioStreamBasicDescription streamFormat = {0};
    UInt32 formatFlags = (0
                          | kAudioFormatFlagIsPacked 
                          | kAudioFormatFlagIsSignedInteger 
                          | kAudioFormatFlagsNativeEndian
                          );
    
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mSampleRate = 44100;
    streamFormat.mChannelsPerFrame = 2;
    streamFormat.mFormatFlags = formatFlags;
    streamFormat.mBitsPerChannel = 16;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = streamFormat.mBitsPerChannel * streamFormat.mChannelsPerFrame / 8;
    streamFormat.mBytesPerPacket = streamFormat.mBytesPerFrame * streamFormat.mFramesPerPacket;
    DDAudioUnit * converterUnit = [_converterNode audioUnit];
    [converterUnit setStreamFormatWithDescription:&streamFormat];

#if TARGET_OS_IPHONE
    /*
     * See Technical Q&A QA1606 Audio Unit Processing Graph -
     *   Ensuring audio playback continues when screen is locked
     *
     * http://developer.apple.com/iphone/library/qa/qa2009/qa1606.html
     *
     * Need to set kAudioUnitProperty_MaximumFramesPerSlice to 4096 on all
     * non-output audio units.  In this case, that's only the converter unit.
     */
    [converterUnit setUnsignedInt32Value:4096 forProperty:kAudioUnitProperty_MaximumFramesPerSlice];
#endif
    
    [_converterNode setInputCallback:MyRenderer context:self forInput:0];
    
    NSLog(@"graph: %@", _graph);
    
    [_graph update];
    [_graph initialize];
    return YES;
}

- (void)teardownAudio;
{
    [_graph stop];
    [_graph uninitialize];
    [_graph close];
    
    [_outputNode release]; _outputNode = nil;
    [_effectNode release]; _effectNode = nil;
    [_converterNode release]; _converterNode = nil;
    [_graph release]; _graph = nil;
}

- (BOOL)startAudio:(NSError **)error;
{
    _shouldBufferDataInCallback = YES;
    [_graph start];
    return YES;
}

- (void)stopAudio;
{
    _shouldBufferDataInCallback = NO;
    [_graph stop];
}

- (BOOL)pauseAudio:(NSError **)error;
{
    [_graph stop];
    return YES;
}

- (BOOL)unpauseAudio:(NSError **)error;
{
    [_graph start];
    return YES;
}

- (void)trackEnded
{
    [_delegate musicPlayerOutputDidFinishTrack:(id)self];
}

@end
