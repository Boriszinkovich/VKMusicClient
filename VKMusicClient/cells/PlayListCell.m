//
//  PlayListCell.m
//  VKMusicClient
//
//  Created by Boris on 4/4/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "PlayListCell.h"

#import "PlayList.h"

@interface PlayListCell ()

@property (nonatomic, strong, nonnull) UILabel *theTitleLabel;

@end

NSString * const keyTitleLabelLeftRightInsets = @"20 15 15 13";

@implementation PlayListCell

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self methodInitPlayListCell];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self methodInitPlayListCell];
    }
    return self;
}

- (void)methodInitPlayListCell
{
    
}

#pragma mark - Setters (Public)

#pragma mark - Getters (Public)

#pragma mark - Setters (Private)

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

#pragma mark - Create Views & Variables

- (void)createAllViews
{
    if (!self.isFirstLoad)
    {
        return;
    }
    self.isFirstLoad = NO;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.theBottomSeparatorView.theHeight = 1;
    self.theBottomSeparatorView.backgroundColor = [UIColor getColorWithHexString:keySongsTableBackgroundColor];
    UILabel *theTitleLabel = [UILabel new];
    self.theTitleLabel = theTitleLabel;
    
    if (!self.isAbstractCell)
    {
        [self.contentView addSubview:theTitleLabel];
        theTitleLabel.theMinX = keyTitleLabelLeftRightInsets.theDeviceValue;
        theTitleLabel.numberOfLines = 1;
        theTitleLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Light
                                             size:@"20 18 16 16".theDeviceValue];

    }
}

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Notifications

#pragma mark - Delegates (ODTableViewCellHeightProtocol)

- (double)getCalculatedHeight
{
    return keyPlayListCellHeight.theDeviceValue;
}

- (void)adjustToAbstractCell:(UITableViewCell <ODTableViewCellHeightProtocol> *)abstractCell
{
    typeof(self) theCell = (id)abstractCell;
    self.thePlayList = theCell.thePlayList;
    [self methodAdjustTitleLabel];
}

#pragma mark - Methods (Public)

#pragma mark - Methods (Private)

- (void)methodAdjustTitleLabel
{
    [self createAllViews];
    if (self.isAbstractCell)
    {
        return;
    }
    self.theTitleLabel.text = self.thePlayList.thePlayListName;
    [self.theTitleLabel sizeToFit];
    self.theTitleLabel.theWidth = self.contentView.theWidth - 2 * keyTitleLabelLeftRightInsets.theDeviceValue;
    self.theTitleLabel.theCenterY = self.theTitleLabel.superview.theHeight / 2;
}

#pragma mark - Standard Methods

@end






























