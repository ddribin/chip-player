//
//  RootViewController.h
//  ChipPlayer
//
//  Created by Dave Dribin on 4/27/10.
//  Copyright Bit Maki, Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface RootViewController : UITableViewController {
    DetailViewController *detailViewController;
    NSArray * _files;
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, copy) NSArray * files;

@end
