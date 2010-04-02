//
//  MusicPlayerStateMachine.h
//  RetroPlayer
//
//  Created by Dave Dribin on 4/1/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MusicPlayerActions.h"


@interface MusicPlayerStateMachine : NSObject
{
    id<MusicPlayerActions> _actions;
    int _state;
}

- (id)initWithActions:(id<MusicPlayerActions>)actions;

- (BOOL)isPlaying;

- (void)setup;
- (void)teardown;
- (void)play;
- (void)stop;
- (void)pause;
- (void)unpause;
- (void)togglePause;

@end