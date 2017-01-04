//
//  CreatePlayListVCHeaderView.m
//  VKMusicClient
//
//  Created by Boris on 4/4/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "CreatePlayListVCHeaderView.h"

@interface CreatePlayListVCHeaderView ()

@property (nonatomic, strong, nonnull) UILabel *theTitleLabel;

@end

NSString * const keyTitleLabelLeftInset = @"15 12 10 10";
NSString * const keyLabelFontSize = @"22 20 19 19";

@implementation CreatePlayListVCHeaderView

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

#pragma mark - Setters (Public)

- (void)setTheTitleString:(NSString *)theTitleString
{
    BZAssert(theTitleString);
    if (isEqual(_theTitleString, theTitleString))
    {
        return;
    }
    _theTitleString = theTitleString;
    [self createAllViews];
    if (self.isAbstractHeaderFooterView)
    {
        return;
    }
    [self methodAdjustTitleLabel];
}

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
    self.contentView.backgroundColor = [UIColor getColorWithHexString:keyOrangeColor];
    
    UILabel *theTitleLabel = [UILabel new];
    self.theTitleLabel = theTitleLabel;
    if (!self.isAbstractHeaderFooterView)
    {
        [self.contentView addSubview:theTitleLabel];
        theTitleLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Light size:keyLabelFontSize.theDeviceValue];
        theTitleLabel.theMinX = keyTitleLabelLeftInset.theDeviceValue;
    }
}

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Notifications

#pragma mark - Delegates (ODTableViewHeaderFooterHeightProtocol)

- (double)getCalculatedHeight
{
    return 50;
}

- (void)adjustToAbstractHeaderFooterView:(UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *)abstractHeaderFooterView
{
    typeof(self) theAbstractHeaderFooterView = (id)abstractHeaderFooterView;
    self.theTitleString = theAbstractHeaderFooterView.theTitleString;
}

#pragma mark - Methods (Public)

#pragma mark - Methods (Private)

- (void)methodAdjustTitleLabel
{
    if (!self.theTitleString)
    {
        return;
    }
    self.theTitleLabel.text = self.theTitleString;
    [self.theTitleLabel sizeToFit];
    self.theTitleLabel.theCenterY = 50 / 2;
}

#pragma mark - Standard Methods

@end






























