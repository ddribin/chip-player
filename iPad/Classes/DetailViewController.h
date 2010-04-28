//
//  DetailViewController.h
//  ChipPlayer
//
//  Created by Dave Dribin on 4/27/10.
//  Copyright Bit Maki, Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicPlayerActions.h"
#import "MusicPlayerOutput.h"

@class GmeMusicFile;
@class MusicPlayerStateMachine;

@interface DetailViewController : UIViewController
    <UIPopoverControllerDelegate, UISplitViewControllerDelegate,
    UITableViewDataSource, UITableViewDelegate,
    MusicPlayerActions, MusicPlayerOutputDelegate>
{
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    UITableView * _songTable;
    
    GmeMusicFile * _detailItem;
    MusicPlayerStateMachine * _stateMachine;
    id<MusicPlayerOutput> _playerOutput;
    
    UIBarButtonItem * _previousButton;
    UIBarButtonItem * _playPauseButton;
    UIBarButtonItem * _nextButton;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UITableView * songTable;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * previousButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * playPauseButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * nextButton;

@property (nonatomic, retain) GmeMusicFile * detailItem;

- (IBAction)playPause:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)previous:(id)sender;

@end
