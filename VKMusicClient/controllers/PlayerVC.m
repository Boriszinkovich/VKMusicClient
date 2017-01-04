//
//  PlayerVC.m
//  VKMusicClient
//
//  Created by Boris on 3/22/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "PlayerVC.h"

#import "SongsVC.h"
#import "AudioPlayer.h"
#import "Song.h"
#import "UserDefaults.h"

@interface PlayerVC () <AudioPlayerDelegate>

@property (nonatomic, strong, nonnull) UIView *theNavigationBarView;
@property (nonatomic, strong, nonnull) UIButton *theCloseButton;
@property (nonatomic, strong, nonnull) UIButton *theMixButton;
@property (nonatomic, strong, nonnull) UILabel *theLeftTimeLabel;
@property (nonatomic, strong, nonnull) UILabel *theRightTimeLabel;
@property (nonatomic, strong, nonnull) UISlider *theSlider;
@property (nonatomic, strong, nonnull) UIButton *thePlayButton;
@property (nonatomic, strong, nonnull) UIButton *theNextButton;
@property (nonatomic, strong, nonnull) UIButton *thePreviousButton;
@property (nonatomic, strong, nonnull) UILabel *theTitleLabel;
@property (nonatomic, strong, nonnull) UILabel *theSongNameLabel;
@property (nonatomic, strong, nullable) NSArray<Song *> *theSongArray;
@property (nonatomic, assign) NSUInteger theCurentSelectedSongIndex;
@property (nonatomic, strong, nonnull) UIButton *theMixSongsButton;
@property (nonatomic, strong, nonnull) UIButton *theRepeatSongButton;
@property (nonatomic, assign) BOOL isNeedToReload;
@property (nonatomic, assign) BOOL isNeedToAdjustSlider;
@property (nonatomic, assign) NSUInteger theCurrentSongDuration;

@end

NSString * const keyCloseButtonLeftInset = @"14 12 11 11";
NSString * const keyCloseButtonFontSize = @"22 20 19 19";
NSString * const keyTitleLabelFontSize = @"24 22 20 20";
NSString * const keyTitleLabelWidth = @"210 190 180 180";
NSString * const keySongNameLabelTopInset = @"20 18 15 15";
NSString * const keySongNameLabelFontSize = @"18 16 14 14";
NSString * const keySongNameLabelMaxWidth =  @"260 245 235 235";
NSString * const keyTimeLabelsTopInset = @"90 80 70 70";
NSString * const keyTimeLabelsLeftRightInsets = @"8 7 6 6";
NSString * const keySliderWidth = @"230 200 170 170";
NSString * const keyBottomViewHeight = @"60 56 54 54";
NSString * const keyNextPreviousButtonsInsets = @"14 12 11 11";
NSString * const keyPreviousNextButtonsFontSize = @"21 19 18 18";
NSString * const keyPlayButtonFontSize = @"25 23 22 22";
NSString * const keyRepeatCurrentSongButtonTopInset = @"35 30 27 27";
NSString * const keyMixButtonTopInset = @"45 38 33 33";
NSString * const keyButtonsFontSize = @"22 20 19 19";
NSString * const keyMixRepeatButtonInsets = @"15 13 12 12";

@implementation PlayerVC

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (instancetype _Nonnull)initWithSongArray:(NSArray * _Nonnull)theSongArray
              withCurrentSelectedSongIndex:(NSInteger)theCurrentSelectedSongIndex
{
    self =  [super init];
    if (self)
    {
        [self methodInitPlayerVCWithSongArray:theSongArray
                 withCurrentSelectedSongIndex:theCurrentSelectedSongIndex
                           withIsNeedToReload:YES];
    }
    return self;
}

- (void)methodInitPlayerVCWithSongArray:(NSArray *)theSongArray
           withCurrentSelectedSongIndex:(NSInteger)theCurrentSelectedSongIndex
                     withIsNeedToReload:(BOOL)isNeedToReload;
{
    BZAssert(theSongArray && theCurrentSelectedSongIndex >= 0 && (theCurrentSelectedSongIndex < theSongArray.count));
    self.theSongArray = theSongArray;
    self.theCurentSelectedSongIndex = theCurrentSelectedSongIndex;
    self.isNeedToReload = isNeedToReload;
    self.theCurrentSongDuration = [[AudioPlayer sharedInstance] methodGetCurrentSongDuration];
}

- (instancetype _Nonnull)initWithAudioPlayer:(AudioPlayer * _Nonnull)theAudioPlayer
{
    BZAssert(theAudioPlayer);
    if (!theAudioPlayer.theSongArray.count)
    {
        theAudioPlayer.theSongArray  = [Song methodGetAllNonUserSongs];
    }
    self =  [super init];
    if (self)
    {
        [self methodInitPlayerVCWithSongArray:theAudioPlayer.theSongArray
                 withCurrentSelectedSongIndex:theAudioPlayer.theCurentSelectedSongIndex
                           withIsNeedToReload:NO];
    }
    return self;
}

#pragma mark - Setters (Public)

#pragma mark - Getters (Public)

#pragma mark - Setters (Private)

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isFirstLoad)
    {
        [self createAllViews];
    }
}

#pragma mark - Create Views & Variables

- (void)createAllViews
{
    if (!self.isFirstLoad)
    {
        return;
    }
    self.isFirstLoad = NO;
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    AudioPlayer *theAudioPlayer = [AudioPlayer sharedInstance];
    Song *theCurrentAudioSong = theAudioPlayer.theSongArray[theAudioPlayer.theCurentSelectedSongIndex];
    theAudioPlayer.theSongArray = self.theSongArray;
    theAudioPlayer.theCurentSelectedSongIndex = self.theCurentSelectedSongIndex;
    theAudioPlayer.thePlayerDelegate = self;
    if (isEqual(theCurrentAudioSong.theSongID,self.theSongArray[self.theCurentSelectedSongIndex].theSongID))
    {
        self.isNeedToReload = NO;
    }
    
    UIView *theNavigationBarView = [UIView new];
    self.theNavigationBarView = theNavigationBarView;
    [self.view addSubview:theNavigationBarView];
    theNavigationBarView.theWidth = theNavigationBarView.superview.theWidth;
    theNavigationBarView.theHeight = keyNavigationBarHeight.theDeviceValue;
    theNavigationBarView.backgroundColor = [UIColor getColorWithHexString:keyOrangeColor];
    Song *theSong = self.theSongArray[self.theCurentSelectedSongIndex];
    {
        UIButton *theCloseButton = [UIButton new];
        self.theCloseButton = theCloseButton;
        [theNavigationBarView addSubview:theCloseButton];
        theCloseButton.theMinX = keyCloseButtonLeftInset.theDeviceValue;
        [theCloseButton setTitle:@"Close" forState:UIControlStateNormal];
        theCloseButton.titleLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Light
                                                         size:keyCloseButtonFontSize.theDeviceValue];
        [theCloseButton sizeToFit];
        theCloseButton.theCenterY = (theCloseButton.superview.theHeight + [UIApplication sharedApplication].statusBarFrame.size.height) / 2 ;
        [theCloseButton addTarget:self
                           action:@selector(actionCloseButtonDidTouchedUpInside)
                 forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *theTitleLabel = [UILabel new];
        self.theTitleLabel = theTitleLabel;
        [theNavigationBarView addSubview:theTitleLabel];
        theTitleLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Light
                                             size:keyTitleLabelFontSize.theDeviceValue];
        theTitleLabel.text = theSong.theArtist;
        theTitleLabel.textAlignment = NSTextAlignmentCenter;
        [theTitleLabel sizeToFit];
        theTitleLabel.theWidth = keyTitleLabelWidth.theDeviceValue;
        theTitleLabel.theCenterX = theTitleLabel.superview.theWidth / 2;
        theTitleLabel.theCenterY = (theTitleLabel.superview.theHeight + [UIApplication sharedApplication].statusBarFrame.size.height) / 2;
    }
    UILabel *theSongNameLabel = [UILabel new];
    self.theSongNameLabel = theSongNameLabel;
    [self.view addSubview:theSongNameLabel];
    theSongNameLabel.theMinY = self.theNavigationBarView.theMaxY + keySongNameLabelTopInset.theDeviceValue;
    theSongNameLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Light
                                            size:keySongNameLabelFontSize.theDeviceValue];
    
    theSongNameLabel.textAlignment = NSTextAlignmentCenter;
    theSongNameLabel.numberOfLines = 2;
    [theSongNameLabel sizeToFit];
    [self methodAdjustSongNameLabelWithSong:theSong];

    UILabel *theLeftTimeLabel = [UILabel new];
    self.theLeftTimeLabel = theLeftTimeLabel;
    [self.view addSubview:theLeftTimeLabel];
    theLeftTimeLabel.text = @"00:00";
    [theLeftTimeLabel sizeToFit];
    theLeftTimeLabel.theMinY = self.theNavigationBarView.theMaxY + keyTimeLabelsTopInset.theDeviceValue;
    theLeftTimeLabel.theMinX = keyTimeLabelsLeftRightInsets.theDeviceValue;
    
    UILabel *theRightTimeLabel = [UILabel new];
    self.theRightTimeLabel = theRightTimeLabel;
    [self.view addSubview:theRightTimeLabel];
    theRightTimeLabel.theMinY = self.theNavigationBarView.theMaxY + keyTimeLabelsTopInset.theDeviceValue;
    [self methodAdjustRightTimeLabelWithString:[self methodGetFormattedStringWithSecond:theSong.theDuration.integerValue]];
    
    UISlider *theSlider = [UISlider new];
    self.theSlider = theSlider;
    [self.view addSubview:theSlider];
    theSlider.theHeight = 100;
    theSlider.theWidth = keySliderWidth.theDeviceValue;
    theSlider.theCenterY = theLeftTimeLabel.theCenterY;
    theSlider.theCenterX = theSlider.superview.theWidth / 2;
    theSlider.isPanGestureEnabled = YES;
    theSlider.minimumTrackTintColor = [UIColor getColorWithHexString:keyOrangeColor];
    theSlider.maximumValue = theSong.theDuration.integerValue;
    [theSlider addTarget:self
                  action:@selector(actionTheSliderValueDidChange:)
        forControlEvents:UIControlEventValueChanged];
    [theSlider addTarget:self
                  action:@selector(actionTheSliderDidFinishSliding:)
        forControlEvents:(UIControlEventTouchUpInside)];
    [theSlider addTarget:self
                  action:@selector(actionTheSliderDidStartSliding:)
        forControlEvents:(UIControlEventTouchDown)];
//    {
//        theSlider.theLeftSeparatorView.theWidth = 20;
//        theSlider.theLeftSeparatorView.theHeight = 10;
//        theSlider.theLeftSeparatorView.backgroundColor = [UIColor greenColor];
//    }
    
    UIButton *theRepeatSongButton = [UIButton new];
    self.theRepeatSongButton = theRepeatSongButton;
    [self.view addSubview:theRepeatSongButton];
    [theRepeatSongButton setTitle:@"Repeat Song" forState:UIControlStateNormal];
    theRepeatSongButton.titleLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Light size:keyButtonsFontSize.theDeviceValue];
    [theRepeatSongButton sizeToFit];
    theRepeatSongButton.theMinY = theLeftTimeLabel.theMaxY + keyRepeatCurrentSongButtonTopInset.theDeviceValue;
    theRepeatSongButton.theMinX = keyMixRepeatButtonInsets.theDeviceValue;
    [theRepeatSongButton setTitleColor:[UIColor redColor]
                              forState:UIControlStateNormal];
    [theRepeatSongButton setTitleColor:[UIColor greenColor]
                              forState:UIControlStateSelected];
    [theRepeatSongButton addTarget:self
                            action:@selector(actionRepeatButtonDidTouchedUpInside:)
                  forControlEvents:UIControlEventTouchUpInside];
    BOOL isSongRepeated = [UserDefaults sharedInstance].theRepeatSongChosedString.boolValue;
    theRepeatSongButton.selected = isSongRepeated;
    
    UIButton *theMixButton = [UIButton new];
    self.theMixButton = theMixButton;
    [self.view addSubview:theMixButton];
    [theMixButton setTitle:@"Mix" forState:UIControlStateNormal];
    theMixButton.titleLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Light size:keyButtonsFontSize.theDeviceValue];
    [theMixButton sizeToFit];
    theMixButton.theMinY = theLeftTimeLabel.theMaxY + keyMixButtonTopInset.theDeviceValue;
    theMixButton.theMaxX = theMixButton.superview.theWidth -   keyMixRepeatButtonInsets.theDeviceValue;
    [theMixButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [theMixButton setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
    [theMixButton addTarget:self
                     action:@selector(actionMixButtonDidTouchedUpInside:)
           forControlEvents:UIControlEventTouchUpInside];
    BOOL isSongMixed = [UserDefaults sharedInstance].theMixChosedString.boolValue;
    theMixButton.selected = isSongMixed;
    
    UIView *theBottomView = [UIView new];
    [self.view addSubview:theBottomView];
    theBottomView.theWidth = theBottomView.superview.theWidth;
    theBottomView.theHeight = keyBottomViewHeight.theDeviceValue;
    theBottomView.theMaxY = theBottomView.superview.theHeight;
    theBottomView.backgroundColor = [UIColor getColorWithHexString:keyOrangeColor];
    {
        UIButton *thePreviousButton = [UIButton new];
        self.thePreviousButton = thePreviousButton;
        [theBottomView addSubview:thePreviousButton];
        [thePreviousButton setTitle:@"Previous" forState:UIControlStateNormal];
        thePreviousButton.titleLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Light
                                                         size:keyPreviousNextButtonsFontSize.theDeviceValue];
        [thePreviousButton sizeToFit];
        thePreviousButton.theMinX = keyNextPreviousButtonsInsets.theDeviceValue;
        thePreviousButton.theCenterY = thePreviousButton.superview.theHeight / 2;
        [thePreviousButton addTarget:self
                              action:@selector(actionPreviousSongButtonDidTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *theNextButton = [UIButton new];
        self.theNextButton = theNextButton;
        [theBottomView addSubview:theNextButton];
        [theNextButton setTitle:@"Next" forState:UIControlStateNormal];
        theNextButton.titleLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Light
                                                            size:keyPreviousNextButtonsFontSize.theDeviceValue];
        [theNextButton sizeToFit];
        theNextButton.theMaxX = theNextButton.superview.theWidth - keyNextPreviousButtonsInsets.theDeviceValue;
        theNextButton.theCenterY = theNextButton.superview.theHeight / 2;
        [theNextButton addTarget:self
                          action:@selector(actionNextSongButtonDidTouchedUpInside:)
                forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *thePlayButton = [UIButton new];
        self.thePlayButton = thePlayButton;
        [theBottomView addSubview:thePlayButton];
        [thePlayButton setTitle:@"Play" forState:UIControlStateNormal];
        [thePlayButton setTitle:@"Pause" forState:UIControlStateSelected];
        thePlayButton.titleLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Light
                                                        size:keyPlayButtonFontSize.theDeviceValue];
        [thePlayButton sizeToFit];
        thePlayButton.theCenterX = thePlayButton.superview.theWidth / 2;
        thePlayButton.theCenterY = thePlayButton.superview.theHeight / 2;
        [thePlayButton addTarget:self
                          action:@selector(actionPlayButtonDidTouchedUpInside:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    if (self.isNeedToReload)
    {
        NSUInteger theCurrentSecond = 0;
        [self methodAdjustLabelAndSliderWithSecond:theCurrentSecond];
        self.theCurrentSongDuration = [[AudioPlayer sharedInstance] methodGetCurrentSongDuration];
    }
    weakify(self)
    [BZExtensionsManager methodAsyncMainWithBlock:^
     {
         strongify(self)
         if (!self.isNeedToReload)
         {
             [theAudioPlayer methodPlay];
             NSUInteger theCurrentPlayedSecond = [theAudioPlayer methodGetCurrentPlayedSecond];
             [self methodAdjustLabelAndSliderWithSecond:theCurrentPlayedSecond];
         }
         else
         {
             [theAudioPlayer methodStartPlay];
         }
         self.thePlayButton.selected = YES;
         self.isNeedToAdjustSlider = YES;
         self.theCurrentSongDuration = [[AudioPlayer sharedInstance] methodGetCurrentSongDuration];
         [self.thePlayButton sizeToFit];
     }];
}

#pragma mark - Actions

- (void)actionCloseButtonDidTouchedUpInside
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionPlayButtonDidTouchedUpInside:(UIButton *)theButton
{
    if (theButton.isSelected)
    {
        [[AudioPlayer sharedInstance] methodPause];
        theButton.selected = NO;
    }
    else
    {
        theButton.selected = YES;
        [[AudioPlayer sharedInstance] methodPlay];
    }
}

- (void)actionNextSongButtonDidTouchedUpInside:(UIButton *)theButton
{
    [[AudioPlayer sharedInstance] methodPlayNext];
    self.thePlayButton.selected = YES;
    [self methodAdjustLabelAndSliderWithSecond:0];
}

- (void)actionPreviousSongButtonDidTouchedUpInside:(UIButton *)theButton
{
    [[AudioPlayer sharedInstance] methodPlayPrevious];
    self.thePlayButton.selected = YES;
    [self methodAdjustLabelAndSliderWithSecond:0];
}

- (void)actionTheSliderValueDidChange:(UISlider *)theSlider
{
    [[AudioPlayer sharedInstance] methodSeekToSecond:theSlider.value];
    [self methodAdjustLabelAndSliderWithSecond:theSlider.value];
}

- (void)actionTheSliderDidFinishSliding:(UISlider *)theSlider
{
    if (self.thePlayButton.selected)
    {
        [[AudioPlayer sharedInstance] methodPlay];
    }
    else
    {
        [[AudioPlayer sharedInstance] methodPause];
    }
}

- (void)actionTheSliderDidStartSliding:(UISlider *)theSlider
{
    [[AudioPlayer sharedInstance] methodPause];
}

- (void)actionMixButtonDidTouchedUpInside:(UIButton *)theButton
{
    theButton.selected = !theButton.selected;
    [UserDefaults sharedInstance].theMixChosedString = [NSString stringWithFormat:@"%zd", theButton.isSelected];
}

- (void)actionRepeatButtonDidTouchedUpInside:(UIButton *)theButton
{
    theButton.selected = !theButton.selected;
    [UserDefaults sharedInstance].theRepeatSongChosedString = [NSString stringWithFormat:@"%zd", theButton.isSelected];
}

#pragma mark - Gestures

#pragma mark - Notifications

#pragma mark - Delegates (AudioPlayerDelegate)

- (void)audioPlayer:(AudioPlayer * _Nonnull) theAudioPlayer
didStartPlayingTheSong:(Song * _Nonnull)theSong
{
    self.thePlayButton.selected = YES;
    [self methodAdjustTitleLabelWithSong:theSong];
    [self methodAdjustSongNameLabelWithSong:theSong];
    self.theCurrentSongDuration = [[AudioPlayer sharedInstance] methodGetCurrentSongDuration];
    [self methodAdjustRightTimeLabelWithString:[self methodGetFormattedStringWithSecond: self.theCurrentSongDuration]];
    self.theSlider.maximumValue = self.theCurrentSongDuration;
    [self methodAdjustLabelAndSliderWithSecond:0];
}

- (void)audioPlayer:(AudioPlayer *)theAudioPlayer
    didPlayAtSecond:(NSUInteger)theSecond
{
        [self methodAdjustLabelAndSliderWithSecond:theSecond];
        [self methodAdjustRightTimeLabelWithString:[self methodGetFormattedStringWithSecond: self.theCurrentSongDuration - theSecond]];
}

- (void)audioPlayerWasPaused:(AudioPlayer * _Nonnull) theAudioPlayer
{
    self.thePlayButton.selected = NO;
}

- (void)audioPlayerWasStarted:(AudioPlayer * _Nonnull) theAudioPlayer
{
    self.thePlayButton.selected = YES;
}

#pragma mark - Methods (Public)

#pragma mark - Methods (Private)

- (void)methodAdjustTitleLabelWithSong:(Song * _Nonnull)theSong
{
    BZAssert(theSong);
    self.theTitleLabel.text = theSong.theArtist;
    [self.theTitleLabel sizeToFit];
    self.theTitleLabel.theWidth = keyTitleLabelWidth.theDeviceValue;
    self.theTitleLabel.theCenterX = self.theTitleLabel.superview.theWidth / 2;
}

- (void)methodAdjustSongNameLabelWithSong:(Song * _Nonnull)theSong
{
    self.theSongNameLabel.text = theSong.theTitle;
    [self.theSongNameLabel sizeToFit];
    self.theSongNameLabel.theWidth = keySongNameLabelMaxWidth.theDeviceValue;
    self.theSongNameLabel.theCenterX = self.theSongNameLabel.superview.theWidth / 2;
    self.theSongNameLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)methodAdjustRightTimeLabelWithString:(NSString *)theString
{
    self.theRightTimeLabel.text = [NSString stringWithFormat:@"-%@", theString];
    [self.theRightTimeLabel sizeToFit];
    self.theRightTimeLabel.theMaxX = self.theRightTimeLabel.superview.theWidth - keyTimeLabelsLeftRightInsets.theDeviceValue;
}

- (void)methodAdjustLabelAndSliderWithSecond:(NSInteger)theSecond
{
    if (theSecond < 0)
    {
        theSecond = 0;
    }
    NSString *theFormattedTimeString = [self methodGetFormattedStringWithSecond:theSecond];
    self.theLeftTimeLabel.text = theFormattedTimeString;
    [self.theLeftTimeLabel sizeToFit];
    
    self.theSlider.value = theSecond;
}

- (NSString *)methodGetFormattedStringWithSecond:(NSUInteger)theSecond
{
    NSUInteger theHours = theSecond / 3600;
    NSUInteger theMinutes = (theSecond / 60) % 60;
    NSUInteger theOnlySeconds = theSecond % 60;
    NSString *theFormattedTimeString;
    if (!theHours)
    {
        theFormattedTimeString = [NSString stringWithFormat:@"%02zd:%02zd", theMinutes, theOnlySeconds];
    }
    else
    {
        theFormattedTimeString = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", theHours, theMinutes, theOnlySeconds];
    }
    return theFormattedTimeString;
}

#pragma mark - Standard Methods

@end






























