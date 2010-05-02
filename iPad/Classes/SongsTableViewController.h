//
//  SongsTableViewController.h
//  ChipPlayer
//
//  Created by Dave Dribin on 5/2/10.
//  Copyright 2010 Bit Maki, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@class GmeMusicFile;

@protocol SongsTableViewControllerDelegate <NSObject>

- (void)didSelectTrack:(NSInteger)track;

@end


@interface SongsTableViewController : UIViewController
    <UITableViewDataSource, UITableViewDelegate>
{
    id<SongsTableViewControllerDelegate> _delegate;
    GmeMusicFile * _musicFile;
}

@property (nonatomic, assign) id<SongsTableViewControllerDelegate> delegate;
@property (nonatomic, retain) GmeMusicFile * musicFile;
@property (nonatomic) NSInteger selectedTrack;

@end
