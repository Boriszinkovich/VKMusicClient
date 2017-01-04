//
//  SongsCell.m
//  VKMusicClient
//
//  Created by Boris on 3/14/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "SongsCell.h"

#import "Song.h"
#import "MainTabBarController.h"

@interface SongsCell ()

@property (nonatomic, strong, nonnull) UILabel *theTitleLabel;
@property (nonatomic, strong, nonnull) UILabel *theDescriptionLabel;
@property (nonatomic, strong, nonnull) UILabel *theListenCounterLabel;
@property (nonatomic, strong, nonnull) UIButton *theLeftLoadButton;
@property (nonatomic, strong, nonnull) UIView *theProgressView;
@property (nonatomic, strong, nonnull) UIView *theRightSeparatorView;
@property (nonatomic, strong, nonnull) UIImageView *theRightImageView;
@property (nonatomic, strong, nullable) UITapGestureRecognizer *theTapGestureRecognizer;

@end

NSString * const keyContentTopInset = @"17 15 13 13";
NSString * const keyArtistLeftInset = @"7 6 5 5";
NSString * const keyArtistMaxYValue = @"45 38 35 35";
NSString * const keyListenCounterMaxYValue = @"70 62 62 55";
NSString * const keySongMaxYValue = @"60 52 52 43";
NSString * const keyLeftRightSeparatorWidth = @"6 5 4 4";
NSString * const keyLeftViewWidth = @"10 9 8 8";
NSString * const keyRightLoadViewWidth = @"60 50 45 45";
NSString * const keyRightImageViewInset = @"30 25 20 20";
NSString * const keyRightImageViewMetrics = @"30 30 30 30";

@implementation SongsCell

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self methodInitSongsCell];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self methodInitSongsCell];
    }
    return self;
}

- (void)methodInitSongsCell
{
    _theSongsCellStyle = SongsCellStyleNone;
    self.userInteractionEnabled = YES;
}

#pragma mark - Setters (Public)

- (void)setTheSongsCellStyle:(SongsCellStyle)theSongsCellStyle
{
    BZAssert((BOOL)(theSongsCellStyle <= SongsCellStyleEnumCount));
    if (theSongsCellStyle == _theSongsCellStyle)
    {
        return;
    }
    _theSongsCellStyle = theSongsCellStyle;
    [self createAllViews];
    [self methodAdjustRightImageView];
}

- (void)setIsEditing:(BOOL)isEditing
{
    if (_isEditing == isEditing)
    {
        return;
    }
    _isEditing = isEditing;
    [self createAllViews];
    if (self.isAbstractCell)
    {
        return;
    }
    self.theRightSeparatorView.hidden = isEditing;
}

#pragma mark - Getters (Public)

#pragma mark - Setters (Private)

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.theRightSeparatorView.theMaxX = self
    .theRightSeparatorView.superview.theWidth;
    [self methodAdjustTitleLabel];
    [self methodAdjustDescriptionLabel];
    if (self.editing)
    {
        self.theRightSeparatorView.hidden = YES;
    }
    else
    {
        self.theRightSeparatorView.hidden = NO;
        self.theRightSeparatorView.theMaxX = self.theWidth;
    }
    [self setNeedsDisplay];
}

#pragma mark - Create Views & Variables

- (void)createAllViews
{
    if (!self.isFirstLoad)
    {
        return;
    }
    self.isFirstLoad = NO;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UILabel *theTitleLabel = [UILabel new];
    self.theTitleLabel = theTitleLabel;
    UIImageView *theSongImageView = [UIImageView new];
    UILabel *theDescriptionLabel = [UILabel new];
    self.theDescriptionLabel = theDescriptionLabel;
    UIButton *theLeftLoadButton = [UIButton new];
    self.theLeftLoadButton = theLeftLoadButton;
    UIView *theProgressView = [UIView new];
    self.theProgressView  = theProgressView;
    UIImageView *theRightSeparatorView = [UIImageView new];
    self.theRightSeparatorView = theRightSeparatorView;
    UIImageView *theRightImageView = [UIImageView new];
    self.theRightImageView = theRightImageView;
    UILabel *theListenCounterLabel = [UILabel new];
    self.theListenCounterLabel = theListenCounterLabel;
    if (!self.isAbstractCell)
    {
        UIImageView *theLeftSeparatorView = [UIImageView new];
        [self.contentView addSubview:theLeftSeparatorView];
        theLeftSeparatorView.backgroundColor = [UIColor getColorWithHexString:keySongsTableBackgroundColor];;
        theLeftSeparatorView.theHeight = theLeftSeparatorView.superview.theHeight;
        theLeftSeparatorView.theWidth = keyLeftRightSeparatorWidth.theDeviceValue;
        
        [self.contentView addSubview:theRightSeparatorView];
        theRightSeparatorView.backgroundColor = [UIColor getColorWithHexString:keySongsTableBackgroundColor];;
        theRightSeparatorView.theHeight = theRightSeparatorView.superview.theHeight;
        theRightSeparatorView.theWidth = keyLeftRightSeparatorWidth.theDeviceValue;
        theRightSeparatorView.theMaxX = theRightSeparatorView.superview.theWidth;
        
        UIImageView *theBottomSeparatorView = [UIImageView new];
        [self.contentView addSubview:theBottomSeparatorView];
        theBottomSeparatorView.backgroundColor = [UIColor getColorWithHexString:keySongsTableBackgroundColor];;
        theBottomSeparatorView.theHeight = keyBottomSeparatorHeight.theDeviceValue;
        theBottomSeparatorView.theWidth = theBottomSeparatorView.superview.theWidth;
        theBottomSeparatorView.theMaxY = theBottomSeparatorView.superview.theHeight;
        
        [self.contentView addSubview:theLeftLoadButton];
        theLeftLoadButton.theMinY = 0;
        theLeftLoadButton.theWidth = keyRightLoadViewWidth.theDeviceValue;
        theLeftLoadButton.theHeight = theLeftLoadButton.superview.theHeight - keyBottomSeparatorHeight.theDeviceValue;
        theLeftLoadButton.theMinX = theLeftSeparatorView.theMaxX;
        theLeftLoadButton.backgroundColor = [UIColor redColor];
        [theLeftLoadButton addTarget:self
                              action:@selector(actionRightLoadButtonDidTouchedUpInside)
                    forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:theProgressView];
        theProgressView.theWidth =  keyRightLoadViewWidth.theDeviceValue;
        theProgressView.theHeight = 0;
        theProgressView.theMinX = theLeftLoadButton.theMinX;
        theProgressView.theMaxY = theProgressView.superview.theHeight - keyBottomSeparatorHeight.theDeviceValue;
        theProgressView.backgroundColor = [UIColor greenColor];
        
        [self.contentView addSubview:theSongImageView];
        theSongImageView.image = [UIImage getImageNamed:@"icon_musictone"];
        [theSongImageView sizeToFit];
        theSongImageView.theMinX = keyContentLeftInset.theDeviceValue + theLeftLoadButton.theMaxX;
        theSongImageView.theMinY = keyContentTopInset.theDeviceValue;
        
        [self.contentView addSubview:theTitleLabel];
        theTitleLabel.theMinX = theSongImageView.theMaxX + keyArtistLeftInset.theDeviceValue;
        theTitleLabel.theMinY = keyContentTopInset.theDeviceValue;
        theTitleLabel.numberOfLines = 0;
        theTitleLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Light
                                             size:@"15 14 12 12".theDeviceValue];
        
        [self.contentView addSubview:theDescriptionLabel];
        theDescriptionLabel.theMinX = keyContentLeftInset.theDeviceValue + theLeftLoadButton.theMaxX;
        theDescriptionLabel.theMinY = keyArtistMaxYValue.theDeviceValue;
        theDescriptionLabel.theWidth = self.contentView.theWidth - theDescriptionLabel.theMinX - 15;
        theDescriptionLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Light
                                                   size:@"12 11 9 9".theDeviceValue];
        
        [self.contentView addSubview:theListenCounterLabel];
        theListenCounterLabel.theMinX = theDescriptionLabel.theMinX;
        theListenCounterLabel.theMinY = keyListenCounterMaxYValue.theDeviceValue;
        theListenCounterLabel.theWidth = self.contentView.theWidth - theListenCounterLabel.theMinX - 15;
        theListenCounterLabel.theHeight = 15;
        theListenCounterLabel.text = @"Listen counter:";
        theListenCounterLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Light
                                                   size:@"12 11 9 9".theDeviceValue];
        theListenCounterLabel.numberOfLines = 1;
        
        [self.contentView addSubview:theRightImageView];
        theRightImageView.hidden = YES;
        theRightImageView.userInteractionEnabled = YES;
    }
}

#pragma mark - Actions

- (void)actionRightLoadButtonDidTouchedUpInside
{
    [self.theSong methodLoadSong];
}

#pragma mark - Gestures

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)theTapGestureRecognizer
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:keyCellDeleteButtonDidTouchedUpInside
     object:self];
}

#pragma mark - Delegates (ODTableViewCellHeightProtocol)

- (double)getCalculatedHeight
{
    return keyCellHeight.theDeviceValue + keyBottomSeparatorHeight.theDeviceValue;
}

- (void)adjustToAbstractCell:(UITableViewCell <ODTableViewCellHeightProtocol> *)abstractCell
{
    typeof(self) theCell = (id)abstractCell;
    self.theSong = theCell.theSong;
    self.isEditing = theCell.isEditing;
    self.theSongsCellStyle = theCell.theSongsCellStyle;
    [self methodAdjustProgressView];
    [self methodAdjustTitleLabel];
    [self methodAdjustDescriptionLabel];
    [self methodAdjustCounterLabel];
}

#pragma mark - Methods (Public)

- (void)methodAdjustProgressView
{
    [self createAllViews];
    if (self.isAbstractCell)
    {
        return;
    }
    double theNewHeight = self.theLeftLoadButton.theHeight * (double)self.theSong.theLoadedProgress.integerValue / 100;
    self.theProgressView.theHeight = theNewHeight;
    self.theProgressView.theMaxY = self.theProgressView.superview.theHeight - keyBottomSeparatorHeight.theDeviceValue;
}

#pragma mark - Methods (Private)

- (void)methodAdjustTitleLabel
{
    [self createAllViews];
    if (self.isAbstractCell)
    {
        return;
    }
    self.theTitleLabel.text = self.theSong.theTitle;
    self.theTitleLabel.theWidth = self.contentView.theWidth - self.theTitleLabel.theMinX - 15 - self.theLeftLoadButton.theWidth;
    double theTitleLabelHeight = keyArtistMaxYValue.theDeviceValue - keyContentTopInset.theDeviceValue;
    CGSize theSize = CGSizeMake(self.theTitleLabel.theWidth, theTitleLabelHeight);
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.theTitleLabel.font, NSFontAttributeName,nil];
    CGRect textRect = [self.theSong.theTitle boundingRectWithSize:theSize
                                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                       attributes:attributes
                                                          context:nil];
    
    self.theTitleLabel.theHeight = textRect.size.height;
}

- (void)methodAdjustCounterLabel
{
    self.theListenCounterLabel.text = [NSString stringWithFormat:@"Listen count: %ld", (NSInteger)self.theSong.thePopularity.doubleValue];
    [self.theListenCounterLabel sizeToFit];
}

- (void)methodAdjustDescriptionLabel
{
    [self createAllViews];
    if (self.isAbstractCell)
    {
        return;
    }
    self.theDescriptionLabel.text = self.theSong.theArtist;
    [self.theDescriptionLabel sizeToFit];
    self.theDescriptionLabel.theWidth = self.contentView.theWidth - self.theDescriptionLabel.theMinX - 15 - self.theLeftLoadButton.theWidth;
}

- (void)methodAdjustRightImageView
{
    switch (self.theSongsCellStyle)
    {
        case SongsCellStyleNone:
        {
            self.theRightImageView.hidden = YES;
            if (self.theTapGestureRecognizer)
            {
                [self.theRightImageView removeGestureRecognizer:self.theTapGestureRecognizer];
                self.theTapGestureRecognizer = nil;
            }
        }
            break;
        case SongsCellStyleCheckmark:
        {
            self.theRightImageView.image = [UIImage getImageNamed:@"checkmark-xxl"];
            self.theRightImageView.theWidth = keyRightImageViewMetrics.theDeviceValue;
            self.theRightImageView.theHeight = keyRightImageViewMetrics.theDeviceValue;
            self.theRightImageView.theCenterY = self.theRightImageView.superview.theHeight / 2;
            self.theRightImageView.theMaxX = self.theRightImageView.superview.theWidth - keyRightImageViewInset.theDeviceValue;
            self.theRightImageView.hidden = NO;
            if (self.theTapGestureRecognizer)
            {
                [self.theRightImageView removeGestureRecognizer:self.theTapGestureRecognizer];
                self.theTapGestureRecognizer = nil;
            }
        }
            break;
        case SongsCellStyleDelete:
        {
            UIImage *theImage = [UIImage getImageNamed:@"deleteRed"];
            self.theRightImageView.image = theImage;
            self.theRightImageView.theWidth = keyRightImageViewMetrics.theDeviceValue;
            self.theRightImageView.theHeight = keyRightImageViewMetrics.theDeviceValue;
            self.theRightImageView.theCenterY = self.theRightImageView.superview.theHeight / 2;
            self.theRightImageView.theMaxX = self.theRightImageView.superview.theWidth - keyRightImageViewInset.theDeviceValue;
            self.theRightImageView.hidden = NO;
            if (!self.theTapGestureRecognizer)
            {
                UITapGestureRecognizer *theTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                          action:@selector(handleTapGestureRecognizer:)];
                self.theTapGestureRecognizer = theTapGestureRecognizer;
                [self.theRightImageView addGestureRecognizer:theTapGestureRecognizer];
            }
        }
            break;
    }
}

#pragma mark - Standard Methods

@end






























