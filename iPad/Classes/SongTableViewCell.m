//
//  SongTableViewCell.m
//  ChipPlayer
//
//  Created by Dave Dribin on 5/2/10.
//  Copyright 2010 Bit Maki, Inc. All rights reserved.
//

#import "SongTableViewCell.h"


@implementation SongTableViewCell

@synthesize songLabel = _songLabel;
@synthesize artistLabel = _artistLabel;
@synthesize gameLabel = _gameLabel;
@synthesize copyrightLabel = _copyrightLabel;
@synthesize interfaceOrientation = _interfaceOrientation;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#if 0
    NSLog(@"%@: interfaceOrientation: %d", self, interfaceOrientation);
    _interfaceOrientation = interfaceOrientation;
    if (UIInterfaceOrientationIsPortrait(_interfaceOrientation)) {
        [_gameLabel setHidden:YES];
        [_copyrightLabel setHidden:YES];
    } else {
        [_gameLabel setHidden:NO];
        [_copyrightLabel setHidden:NO];
    }
#endif
}

- (void)dealloc
{
    [_songLabel release];
    [_artistLabel release];
    [_gameLabel release];
    [_copyrightLabel release];
    [super dealloc];
}


@end
