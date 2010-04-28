//
//  DetailViewController.h
//  ChipPlayer
//
//  Created by Dave Dribin on 4/27/10.
//  Copyright Bit Maki, Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GmeMusicFile;

@interface DetailViewController : UIViewController
    <UIPopoverControllerDelegate, UISplitViewControllerDelegate,
    UITableViewDataSource, UITableViewDelegate>
{
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    
    GmeMusicFile * _detailItem;
    UITableView * _songTable;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) GmeMusicFile * detailItem;

@property (nonatomic, retain) IBOutlet UITableView * songTable;

@end
