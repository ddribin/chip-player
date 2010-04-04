//
//  MusicPlayerStateMachineTest.h
//  RetroPlayer
//
//  Created by Dave Dribin on 4/3/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class MusicPlayerStateMachine;
@protocol MusicPlayerActions;
@class MockMusicPlayerActions;

@protocol OCMockObject
- (id)stub;
- (id)expect;
- (void)verify;
@end

@interface MusicPlayerStateMachineTest : SenTestCase
{
    MockMusicPlayerActions * mockActions;
    MusicPlayerStateMachine * stateMachine;
}

@end
