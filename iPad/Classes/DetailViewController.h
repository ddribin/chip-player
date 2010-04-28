//
//  DetailViewController.h
//  ChipPlayer
//
//  Created by Dave Dribin on 4/27/10.
//  Copyright Bit Maki, Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GmeMusicFile;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    
    id detailItem;
    UILabel *detailDescriptionLabel;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) IBOutlet UILabel *detailDescriptionLabel;

@end
