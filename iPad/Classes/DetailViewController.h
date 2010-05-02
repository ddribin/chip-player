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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MusicPlayerActions.h"
#import "MusicPlayerOutput.h"
#import "SongsTableViewController.h"

@class GmeMusicFile;
@class MusicPlayerStateMachine;
@class SongsTableViewController;

@interface DetailViewController : UIViewController
    <UIPopoverControllerDelegate, UISplitViewControllerDelegate,
    SongsTableViewControllerDelegate,
    MusicPlayerActions, MusicPlayerOutputDelegate, AVAudioSessionDelegate>
{
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    UITableView * _songTable;
    NSInteger _currentTrack;
    SongsTableViewController * _songsTableViewController;
    
    GmeMusicFile * _musicFile;
    MusicPlayerStateMachine * _stateMachine;
    id<MusicPlayerOutput> _playerOutput;
    
    UIBarButtonItem * _previousButton;
    UIBarButtonItem * _playPauseButton;
    UIBarButtonItem * _nextButton;
}

@property (nonatomic, retain) IBOutlet SongsTableViewController * songsTableViewController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UITableView * songTable;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * previousButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * playPauseButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * nextButton;

@property (nonatomic, retain) GmeMusicFile * musicFile;
@property (nonatomic, readonly) NSInteger currentTrack;

- (IBAction)playPause:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)previous:(id)sender;

@end
