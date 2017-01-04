//
//  MainVC.m
//  VKMusicClient
//
//  Created by User on 11.03.16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "MainTabBarController.h"

#import "UserDefaults.h"
#import "LoginVC.h"
#import "SongsVC.h"
#import "FavouritesVC.h"
#import "PlayerVC.h"
#import "AudioPlayer.h"
#import "PlayListVC.h"

typedef enum : NSUInteger
{
    TabBarButtonSong = 1,
    TabBarButtonFavourite,
    TabBarButtonPlayer,
    TabBarButtonPlayList,
    TabBarButtonFifth,
    TabBarButtonEnumCount = TabBarButtonFifth
} TabBarButton;

@interface MainTabBarController () <UITabBarControllerDelegate>

@property (nonatomic, strong, nonnull) UIButton *theSelectedBarButton;
@property (nonatomic, strong, nonnull) NSMutableArray<UIButton *> *theBarButtonArray;

@end

NSString * const keyPlayerTabBarButtonInset = @"23 20 18 18";

@implementation MainTabBarController

#pragma mark - Class Methods (Public)

+ (MainTabBarController * _Nonnull)sharedInstance
{
    static MainTabBarController *theMainTabBarController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      theMainTabBarController = [[MainTabBarController alloc] initSharedInstance];
                  });
    return theMainTabBarController;
}

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (instancetype _Nonnull)initSharedInstance
{
    self = [super init];
    if (self)
    {
        [self methodInitTabBarController];
    }
    return self;
}

- (void)methodInitTabBarController
{
    self.theTabBarHeight = [UIImage getImageNamed:@"gradient-tab-bar"].size.height;
}

- (instancetype)init
{
    BZAssert(nil);
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
    if (![UserDefaults sharedInstance].theAccessToken)
    {
        LoginVC *theLoginVC = [LoginVC new];
        UINavigationController *theLoginNavigationController = [[UINavigationController alloc]initWithRootViewController:theLoginVC];
        [self.navigationController presentViewController:theLoginNavigationController
                                                animated:YES
                                              completion:nil];
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
    self.tabBar.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    self.delegate = self;
    
    UIImageView *theTabBarImageView = [UIImageView new];
    [self.view addSubview:theTabBarImageView];
    theTabBarImageView.image = [UIImage getImageNamed:@"gradient-tab-bar"];
    [theTabBarImageView sizeToFit];
    theTabBarImageView.theWidth = theTabBarImageView.superview.theWidth;
    theTabBarImageView.theMaxY = theTabBarImageView.superview.theMaxY;
    theTabBarImageView.userInteractionEnabled = YES;
    
    NSMutableArray<UIButton *> *theBarButtonArray = [NSMutableArray new];
    self.theBarButtonArray = theBarButtonArray;
    UIViewController *theVC;
    NSMutableArray *theViewControllersMutableArray = [NSMutableArray new];
    for (TabBarButton i = 0; i < TabBarButtonEnumCount; i++)
    {
        UIButton *theCurrentButton = [UIButton new];
        theCurrentButton.tag = i + 1;
        [theBarButtonArray addObject:theCurrentButton];
        [theTabBarImageView addSubview:theCurrentButton];
        [theCurrentButton addTarget:self
                             action:@selector(actionBarButtonPressed:)
                   forControlEvents:UIControlEventTouchDown];
        NSString *theNonActiveImageNameString;
        NSString *theActiveImageNameString;
        switch (theBarButtonArray[i].tag)
        {
            case TabBarButtonSong:
            {
                theNonActiveImageNameString = @"tabbar-home-page";
                theActiveImageNameString = @"tabbar-home-page-active";
                theVC = [SongsVC new];
            }
                break;
            case TabBarButtonFavourite:
            {
                theNonActiveImageNameString = @"tabbar-search";
                theActiveImageNameString = @"tabbar-search-active";
                theVC = [FavouritesVC new];
            }
                break;
            case TabBarButtonPlayer:
            {
                theNonActiveImageNameString = @"tabbar-add-file";
                theActiveImageNameString = @"tabbar-add-file-active";
            }
                break;
            case TabBarButtonPlayList:
            {
                theNonActiveImageNameString = @"tabbar-notification";
                theActiveImageNameString = @"tabbar-notification-active";
                theVC = [PlayListVC new];
            }
                break;
            case TabBarButtonFifth:
            {
                theNonActiveImageNameString = @"tabbar-profile";
                theActiveImageNameString = @"tabbar-profile-active";
            }
                break;
        }
        [theViewControllersMutableArray addObject:theVC];
        [theCurrentButton setImage:[UIImage getImageNamed:theNonActiveImageNameString]
                              forState:UIControlStateNormal];
        [theCurrentButton setImage:[UIImage getImageNamed:theActiveImageNameString]
                              forState:UIControlStateSelected];
        [theCurrentButton sizeToFit];
        theCurrentButton.theCenterY = theCurrentButton.superview.theHeight / 2;
    }
    self.viewControllers = theViewControllersMutableArray.copy;
    theBarButtonArray.firstObject.theMinX = keyPlayerTabBarButtonInset.theDeviceValue;
    theBarButtonArray.lastObject.theMaxX = theBarButtonArray.lastObject.superview.theWidth - keyPlayerTabBarButtonInset.theDeviceValue;
    double theCenterXDistance = (theBarButtonArray.lastObject.theCenterX - theBarButtonArray.firstObject.theCenterX)/4;
    for (int i = 1; i < 4; i++)
    {
        theBarButtonArray[i].theCenterX = theBarButtonArray.firstObject.theCenterX + theCenterXDistance * i;
    }
    
    theBarButtonArray.firstObject.selected = YES;
    self.theSelectedBarButton = theBarButtonArray.firstObject;
    
    FavouritesVC *theFavouriteVC = self.viewControllers[TabBarButtonFavourite - 1];
    theFavouriteVC.theDeleteSongDelegate = self.viewControllers[TabBarButtonSong - 1];
}

#pragma mark - Actions

- (void)actionBarButtonPressed:(UIButton *)theButton
{
    if (theButton.isSelected)
    {
        return;
    }
    BZAssert(theButton >= TabBarButtonSong && theButton.tag <= TabBarButtonEnumCount);
    if (theButton.tag > 4)
    {//because we haven't created uiviewcontrollers for last buttons
        return;
    }
    if (theButton.tag != TabBarButtonPlayer)
    {
        theButton.selected = YES;
        self.theSelectedBarButton.selected = NO;
        self.theSelectedBarButton = theButton;
        switch (theButton.tag)
        {
            case 1:
            {
                self.selectedIndex = 0;
            }
                break;
            case 2:
            {
                self.selectedIndex = 1;
            }
                break;
            case 4:
            {
                self.selectedIndex = 2;
            }
                break;
        }
    }
    else
    {
        PlayerVC *thePlayerVC = [[PlayerVC alloc] initWithAudioPlayer:[AudioPlayer sharedInstance]];
        UINavigationController *thePlayerNavigationController = [[UINavigationController alloc]initWithRootViewController:thePlayerVC];
        [self.navigationController presentViewController:thePlayerNavigationController
                                                animated:YES
                                              completion:nil];
    }
}

#pragma mark - Gestures

#pragma mark - Delegates ()

#pragma mark - Methods (Public)

- (UIViewController *)methodGetViewControllerWithIndex:(NSUInteger)theIndex
{
    BZAssert(theIndex <= self.viewControllers.count - 1);
    return self.viewControllers[theIndex];
}

#pragma mark - Methods (Private)

#pragma mark - Standard Methods

@end






























