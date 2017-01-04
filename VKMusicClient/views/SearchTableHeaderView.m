//
//  SearchTableHeaderView.m
//  VKMusicClient
//
//  Created by Boris on 3/17/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "SearchTableHeaderView.h"

@interface SearchTableHeaderView ()

@property (nonatomic, strong, nonnull) UILabel *theTitleLabel;

@end

@implementation SearchTableHeaderView

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

#pragma mark - Setters (Public)

- (void)setTheTitleString:(NSString *)theTitleString
{
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
    self.theTitleLabel.text = theTitleString;
    [self.theTitleLabel sizeToFit];
    self.theTitleLabel.theWidth = self.contentView.theWidth - 15 - keyContentLeftInset.theDeviceValue;
    self.theTitleLabel.theCenterY = self.theTitleLabel.superview.theHeight/2;
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
        theTitleLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Light
                                             size:@"20 18 16 16".theDeviceValue];
        theTitleLabel.theMinX = keyContentLeftInset.theDeviceValue;
    }
}

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Delegates (ODTableViewHeaderFooterHeightProtocol)

- (double)getCalculatedHeight
{
    return 40;
}

- (void)adjustToAbstractHeaderFooterView:(UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *)abstractHeaderFooterView
{
    typeof(self) theAbstractHeaderFooterView = (id)abstractHeaderFooterView;
    self.theTitleString = theAbstractHeaderFooterView.theTitleString;
}

#pragma mark - Methods (Public)

#pragma mark - Methods (Private)

#pragma mark - Standard Methods

@end






























