//
//  SongTableViewCell.h
//  ChipPlayer
//
//  Created by Dave Dribin on 5/2/10.
//  Copyright 2010 Bit Maki, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SongTableViewCell : UITableViewCell
{
    UILabel * _songLabel;
    UILabel * _artistLabel;
    UILabel * _gameLabel;
    UILabel * _copyrightLabel;
    UIInterfaceOrientation _interfaceOrientation;
}

@property (nonatomic, retain) IBOutlet UILabel * songLabel;
@property (nonatomic, retain) IBOutlet UILabel * artistLabel;
@property (nonatomic, retain) IBOutlet UILabel * gameLabel;
@property (nonatomic, retain) IBOutlet UILabel * copyrightLabel;

@property (nonatomic) UIInterfaceOrientation interfaceOrientation;

@end
