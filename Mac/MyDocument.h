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


#import <Cocoa/Cocoa.h>
#import "MusicPlayerActions.h"
#import "MusicPlayerOutput.h"

@class TrackTableDataSource;
@class GmeMusicFile;
@class MusicPlayerStateMachine;

@interface MyDocument : NSDocument <MusicPlayerActions, MusicPlayerOutputDelegate>
{
    GmeMusicFile * _musicFile;
    MusicPlayerStateMachine * _stateMachine;
    id<MusicPlayerOutput> _playerOutput;

    TrackTableDataSource * _trackTableDataSource;
    NSTableView * _trackTable;
    NSButton * _previousButton;
    NSButton * _playPauseButton;
    NSButton * _nextButton;
}

@property (assign) IBOutlet TrackTableDataSource * trackTableDataSource;
@property (assign) IBOutlet NSTableView * trackTable;
@property (assign) IBOutlet NSButton * previousButton;
@property (assign) IBOutlet NSButton * playPauseButton;
@property (assign) IBOutlet NSButton * nextButton;

- (IBAction)play:(id)sender;
- (IBAction)playSelectedTrack:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)previous:(id)sender;

@end
