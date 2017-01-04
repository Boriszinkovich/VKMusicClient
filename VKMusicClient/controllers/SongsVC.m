//
//  SongsVC.m
//  VKMusicClient
//
//  Created by User on 12.03.16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "SongsVC.h"

#import "SongsCell.h"
#import "UserService.h"
#import "Song.h"
#import "UserDefaults.h"
#import "AppDelegate.h"
#import "SearchTableHeaderView.h"
#import "MainTabBarController.h"
#import "AudioPlayer.h"
#import "PlayerVC.h"
#import "FavouritesVC.h"

@interface SongsVC () <UITextFieldDelegate, ODTableViewDelegate, AppDelegateLoadDelegate, FavouiteVCDeleteSongDelegate>

@property (nonatomic, strong, nonnull) UITextField *theSearchTextField;
@property (nonatomic, strong, nonnull) ODTableView *theMainTableView;
@property (nonatomic, strong, nonnull) NSMutableArray<Song *> *theAllSongMutableArray;
@property (nonatomic, strong, nonnull) NSMutableArray<Song *> *theSearchSongMutableArray;
@property (nonatomic, assign) NSInteger theCurrentOffset;
@property (nonatomic, assign) NSInteger theTotalSearchCount;
@property (nonatomic, strong) Reachability *theInternetReachability;
@property (nonatomic, strong) UIRefreshControl *theMainRefreshControl;
@property (nonatomic, strong, nonnull) UIActivityIndicatorView *theFooterIndicatorView;
@property (nonatomic, strong, nonnull) UIButton *theCancelButton;
@property (nonatomic, strong, nonnull) UIView *theSortButtonsContainerView;
@property (nonatomic, assign) BOOL isDataLoading;
@property (nonatomic, assign) BOOL isCanBeLoadedMore;
@property (nonatomic, strong, nonnull) NSDate *theLastSearchedDate;
@property (nonatomic, strong, nonnull) BZSyncBackground *theSearchSyncBackground;

@end

NSString * const keySongsVCLoad = @"keySongsVCLoad";
NSInteger const keyLoadCount = 50;

@implementation SongsVC

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        if (![UserDefaults sharedInstance].theAccessToken)
        {
            return;
        }
        [self methodLoadAllUserSongs];
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
    self.theSearchSyncBackground = [BZSyncBackground new];
    self.theSearchSyncBackground.theDelayInSeconds = 0.5;
    
    Reachability *theInternerReachability = [Reachability reachabilityForInternetConnection];
    self.theInternetReachability = theInternerReachability;
    {
        weakify(self);
        theInternerReachability.reachableBlock = ^(Reachability *theReachability)
        {
            [BZExtensionsManager methodAsyncMainWithBlock:^
             {
                 strongify(self);
                 if (!isEqual(self.theSearchTextField.text, @""))
                 {
                     [self methodChangeSongs];
                 }
             }];
        };
    }
    [theInternerReachability startNotifier];

    AppDelegate *theAppDelegate = (id)[UIApplication sharedApplication].delegate;
    theAppDelegate.theLoadedDelegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(actionDidReceiveAutorizedNotification:)
                                                 name:keyLoginVCLoadNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSongDidLoadNotification:)
                                                 name:keySongDidLoadNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSongLoadProgressNotification:)
                                                 name:keySongLoadProgressNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSongPopularityChangedNotification:)
                                                 name:keyPopularityChangedNotification
                                               object:nil];

    self.theAllSongMutableArray = [NSMutableArray new];
    self.theSearchSongMutableArray = [NSMutableArray new];
    self.isCanBeLoadedMore = YES;
    
    ODTableView *theMainTableView = [ODTableView new];
    theMainTableView.theDelegate = self;
    self.theMainTableView = theMainTableView;
    [self.view addSubview:theMainTableView];
    theMainTableView.theWidth = theMainTableView.superview.theWidth;
    theMainTableView.theHeight = theMainTableView.superview.theHeight;
    theMainTableView.backgroundColor = [UIColor getColorWithHexString:keySongsTableBackgroundColor];
    [self methodSetMainTableViewDefaultOffset];
    
    UIRefreshControl *theMainRefreshControl = [UIRefreshControl new];
    self.theMainRefreshControl = theMainRefreshControl;
    [self.theMainTableView addSubview:theMainRefreshControl];
    theMainRefreshControl.theMinY = 10;
    [theMainRefreshControl addTarget:self action:@selector(actionRefreshDidChange:) forControlEvents:UIControlEventValueChanged];
    
    UIActivityIndicatorView *theFooterIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.theFooterIndicatorView = theFooterIndicator;
    theFooterIndicator.theHeight = 0;
    theMainTableView.tableFooterView = theFooterIndicator;
    theFooterIndicator.theWidth = self.view.theWidth;
    
    UIBlurEffect *theBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *theVisualEffectView = [[UIVisualEffectView alloc] initWithEffect:theBlurEffect];
    [self.view addSubview:theVisualEffectView];
    theVisualEffectView.theHeight = keyNavigationBarHeight.theDeviceValue;
    theVisualEffectView.theWidth = theVisualEffectView.superview.theWidth;
    
    UITextField *theSearchTextField = [UITextField new];
    theSearchTextField.delegate = self;
    self.theSearchTextField = theSearchTextField;
    [theVisualEffectView addSubview:theSearchTextField];
    theSearchTextField.theHeight = keySearchTextFieldHeight.theDeviceValue;
    theSearchTextField.theWidth = @"346 314 268 268".theDeviceValue;
    theSearchTextField.theMaxX = theSearchTextField.superview.theWidth - keySearchButton_SearchFieldInset.theDeviceValue
    - keySearchButtonMaxXInset.theDeviceValue - [UIImage getImageNamed:keySearchButtonImageName].size.width;
    theSearchTextField.theCenterY = (theSearchTextField.superview.theHeight + [UIApplication sharedApplication].statusBarFrame.size.height) / 2 ;
    theSearchTextField.backgroundColor = [UIColor getColorWithHexString:keySongsTableBackgroundColor];
    theSearchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    theSearchTextField.layer.cornerRadius = 5;
    theSearchTextField.returnKeyType = UIReturnKeySearch;
    theSearchTextField.leftViewMode = UITextFieldViewModeAlways;
    theSearchTextField.rightViewMode = UITextFieldViewModeAlways;
    theSearchTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light"
                                          size:@"18 16 14 14".theDeviceValue];
    [theSearchTextField addTarget:self
                       action:@selector(actionSearchTextDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    {
        UIView *theLeftView = [UIView new];
        double theSearchImageViewWidth;
        {
            UIImageView *theSearchImageView = [UIImageView new];
            [theLeftView addSubview:theSearchImageView];
            theSearchImageView.image = [UIImage getImageNamed:@"search-icon"];
            [theSearchImageView sizeToFit];
            theSearchImageView.theCenterY = theLeftView.superview.theHeight/2;
            theSearchImageView.theMinX = keySearchImageLeftInset.theDeviceValue;
            theSearchImageViewWidth = theSearchImageView.theWidth;
        }
        theSearchTextField.leftView = theLeftView;
        theLeftView.theWidth = theSearchImageViewWidth + keySearchImageLeftInset.theDeviceValue + @"12 11 9 9".theDeviceValue;
        theLeftView.theHeight = theLeftView.superview.theHeight;
        theLeftView.backgroundColor = theSearchTextField.backgroundColor;
        
        UIButton *theCancelButton = [UIButton new];
        self.theCancelButton = theCancelButton;
        theSearchTextField.rightView = theCancelButton;
        [theCancelButton setImage:[UIImage getImageNamed:@"icon-clearbutton"]
                         forState:UIControlStateNormal];
        [theCancelButton sizeToFit];
        theCancelButton.theWidth = theCancelButton.theWidth + keySearchImageLeftInset.theDeviceValue;
        theCancelButton.theCenterY = theCancelButton.superview.theHeight/2;
        [theCancelButton addTarget:self
                            action:@selector(actionClearButtonTouchUpInside:)
                  forControlEvents:UIControlEventTouchUpInside];
        theCancelButton.hidden = YES;
    }
}

#pragma mark - Actions

- (void)actionSearchTextDidChange:(UITextField *)theTextField
{
    if (isEqual(self.theSearchTextField.text, @""))
    {
        self.theCancelButton.hidden = YES;
    }
    else
    {
        self.theCancelButton.hidden = NO;
    }
    self.theLastSearchedDate = [NSDate new];
    [self methodChangeSongs];
}

- (void)actionClearButtonTouchUpInside:(UIButton *)theClearButton
{
    if (isEqual(self.theSearchTextField.text, @""))
    {
        return;
    }
    self.theSearchTextField.text = @"";
    self.theCancelButton.hidden = YES;
    [self methodChangeSongs];
}

- (void)actionRefreshDidChange:(UIRefreshControl *)refreshControl
{
    if ([self.theFooterIndicatorView isAnimating])
    {
        [self.theFooterIndicatorView stopAnimating];
    }
    if (!self.theInternetReachability.isReachable)
    {
        [BZExtensionsManager methodDispatchAfterSeconds:2
                                              withBlock:^
         {
             [self.theMainRefreshControl endRefreshing];
         }];
    }
    UserService *theUserService = [UserService sharedInstance];
    if (isEqual(self.theSearchTextField.text, @""))
    {
        self.isDataLoading = YES;
        {
            weakify(self);
            [theUserService methodLoadAllSongsToCoreDataWithCompletion:^(NSError * _Nullable error)
             {
                 strongify(self);
                 self.isDataLoading = NO;
                 [self methodLoadAllUserSongs];
             }];
        }
        return;
    }
    [self methodChangeSongs];
}

- (void)actionDidReceiveAutorizedNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:keyLoginVCLoadNotification])
    {
        if (!self.theAllSongMutableArray.count)
        {
            [self.theMainRefreshControl beginRefreshing];
            [[UserService sharedInstance] methodLoadAllSongsToCoreDataWithCompletion:^(NSError * _Nullable error)
             {
                 [self methodLoadAllUserSongs];
             }];
        }
    }
}

#pragma mark - Gestures

#pragma mark - Notifications

- (void)receiveSongDidLoadNotification:(NSNotification *)theNotification
{
    Song *theSong = ((Song *)theNotification.object);
    NSInteger theIndex = [self.theAllSongMutableArray indexOfObject:theSong];
    NSInteger theSection;
    NSInteger theRow;
    if (theIndex == NSNotFound)
    {
        theIndex = [self.theSearchSongMutableArray indexOfObject:theSong];
        if (theIndex == NSNotFound)
        {
            return;
        }
        theRow = [self.theSearchSongMutableArray indexOfObject:theSong];
        if (self.theAllSongMutableArray.count)
        {
            theSection = 1;
        }
        else
        {
            theSection = 0;
        }
    }
    else
    {
        theSection = 0;
        theRow = [self.theAllSongMutableArray indexOfObject:theSong];
    }
    SongsCell *theSongCell = [self.theMainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:theRow inSection:theSection]];
    [theSongCell methodAdjustProgressView];
}

- (void)receiveSongLoadProgressNotification:(NSNotification *)theNotification
{
    Song *theSong = ((Song *)theNotification.object);
    NSInteger theIndex = [self.theAllSongMutableArray indexOfObject:theSong];
    NSInteger theSection;
    NSInteger theRow;
    if (theIndex == NSNotFound)
    {
        theIndex = [self.theSearchSongMutableArray indexOfObject:theSong];
        if (theIndex == NSNotFound)
        {

            return;
        }
        theRow = [self.theSearchSongMutableArray indexOfObject:theSong];
        if (self.theAllSongMutableArray.count)
        {
            theSection = 1;
        }
        else
        {
            theSection = 0;
        }
    }
    else
    {
        theSection = 0;
        theRow = [self.theAllSongMutableArray indexOfObject:theSong];
    }
    SongsCell *theSongCell = [self.theMainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:theRow inSection:theSection]];
    [theSongCell methodAdjustProgressView];
}

- (void)receiveSongPopularityChangedNotification:(NSNotification *)theNotification
{
    Song *theSong = ((Song *)theNotification.object);
    NSInteger theIndex = [self.theAllSongMutableArray indexOfObject:theSong];
    NSInteger theSection;
    NSInteger theRow;
    if (theIndex == NSNotFound)
    {
        theIndex = [self.theSearchSongMutableArray indexOfObject:theSong];
        if (theIndex == NSNotFound)
        {
            return;
        }
        theRow = [self.theSearchSongMutableArray indexOfObject:theSong];
        if (self.theAllSongMutableArray.count)
        {
            theSection = 1;
        }
        else
        {
            theSection = 0;
        }
    }
    else
    {
        theSection = 0;
        theRow = [self.theAllSongMutableArray indexOfObject:theSong];
    }
    SongsCell *theSongCell = [self.theMainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:theRow inSection:theSection]];
    [theSongCell methodAdjustCounterLabel];
}

#pragma mark - Delegates (FavouiteVCDeleteSongDelegate)

- (void)favouriteVC:(FavouritesVC * _Nonnull)theFavouriteVC
      didDeleteSong:(Song * _Nonnull)theSong
{
    [self.theMainTableView reloadData];
}

#pragma mark - Delegates (UIScrollViewDelegate)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.theSearchTextField)
    {
        return;
    }
    if (!self.isCanBeLoadedMore)
    {
        return;
    }
    if (self.theSearchSongMutableArray.count == self.theTotalSearchCount)
    {
        return;
    }
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - self.view.theHeight * 3)
    {
        if (!isEqual(self.theSearchTextField.text, @""))
        {
            if (!self.theFooterIndicatorView.isAnimating)
            {
                self.theFooterIndicatorView.theHeight = 40;
                self.theMainTableView.tableFooterView = self.theFooterIndicatorView;
                [self.theFooterIndicatorView startAnimating];
                [self methodLoadWithScroll];
            }
        }
    }
}

#pragma mark - Delegates (UITextFieldDelegate)

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.textAlignment = NSTextAlignmentLeft;
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Delegates (AppDelegateLoadDelegate)

- (void)methodAllSongsDidLoad
{
    if (!self.theAllSongMutableArray.count)
    {
        [self methodLoadAllUserSongs];
    }
    if (self.isDataLoading)
    {
        self.isDataLoading = NO;
        [self methodLoadAllUserSongs];
    }
}

#pragma mark - Delegates (ODTableViewDelegate)

- (NSUInteger)tableViewNumberOfSections:(ODTableView *)tableView
{
    if (isEqual(self.theSearchTextField.text, @""))
    {
        return 1;
    }
    NSInteger theCounter = 0;
    if (self.theAllSongMutableArray.count)
    {
        theCounter++;
    }
    if (self.theSearchSongMutableArray.count)
    {
        theCounter++;
    }
    return theCounter;
}

- (NSInteger)tableView:(ODTableView *)tableView numberOfCellsInSection:(NSInteger)section
{
    if (!section)
    {
        if (self.theAllSongMutableArray.count)
        {
            return self.theAllSongMutableArray.count;
        }
        return self.theSearchSongMutableArray.count;
    }
    return self.theSearchSongMutableArray.count;
}

- (UITableViewCell <ODTableViewCellHeightProtocol> *)tableViewAbstractCell:(ODTableView *)tableView
{
    return [SongsCell new];
}

- (void)tableView:(ODTableView *)tableView setupAbstractCell:(UITableViewCell <ODTableViewCellHeightProtocol> *)cell
{
    typeof(SongsCell *) theCell = (id)cell;
    if (!cell.theIndexPath.section)
    {
        if (self.theAllSongMutableArray.count)
        {
            theCell.theSong = self.theAllSongMutableArray[cell.theIndexPath.row];
            return;
        }
        theCell.theSong = self.theSearchSongMutableArray[cell.theIndexPath.row];
        return;
    }
    theCell.theSong = self.theSearchSongMutableArray[cell.theIndexPath.row];
}

- (void)tableView:(ODTableView *)tableView didSelectCell:(UITableViewCell<ODTableViewCellHeightProtocol> *)cell
{
    NSIndexPath *theCellIndexPath = cell.theIndexPath;
    Song *theSong;
    NSInteger theCurrentSelectedSongIndex = 0;
    if (theCellIndexPath.section == 0)
    {
        if (self.theAllSongMutableArray.count)
        {
            theSong = self.theAllSongMutableArray[theCellIndexPath.row];
        }
        else
        {
            theSong = self.theSearchSongMutableArray[theCellIndexPath.row];
        }
        theCurrentSelectedSongIndex =  theCellIndexPath.row;
    }
    else
    {
        theSong = self.theSearchSongMutableArray[theCellIndexPath.row];
        theCurrentSelectedSongIndex = self.theAllSongMutableArray.count + theCellIndexPath.row;
    }
    NSMutableArray *theSongsArray = [NSMutableArray new];
    [theSongsArray addObjectsFromArray:self.theAllSongMutableArray];
    [theSongsArray addObjectsFromArray:self.theSearchSongMutableArray];
    
    PlayerVC *thePlayerVC = [[PlayerVC alloc] initWithSongArray:theSongsArray
                                   withCurrentSelectedSongIndex:theCurrentSelectedSongIndex];
    
    UINavigationController *thePlayerNavigationController = [[UINavigationController alloc]initWithRootViewController:thePlayerVC];
    [self.navigationController presentViewController:thePlayerNavigationController
                                            animated:YES
                                          completion:nil];
}

- (UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *)tableViewAbstractHeaderView:(ODTableView *)tableView
{
    if (!self.theSearchTextField)
    {
        return nil;
    }
    return [SearchTableHeaderView new];
}

- (void)tableView:(ODTableView *)tableView setupAbstractHeaderView:(UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *)abstractHeaderView
{
    typeof(SearchTableHeaderView *) theHeaderView = (id)abstractHeaderView;
    if (!theHeaderView.theSection)
    {
        if (self.theAllSongMutableArray.count)
        {
            theHeaderView.theTitleString = @"My songs";
        }
        else if (self.theSearchSongMutableArray.count)
        {
            theHeaderView.theTitleString = @"Global search";
        }
    }
    else
    {
        theHeaderView.theTitleString = @"Global search";
    }
}

#pragma mark - Methods (Public)

#pragma mark - Methods (Private)

- (void)methodAlertWithNoInternet
{
    UIAlertController *theAlert = [UIAlertController alertControllerWithTitle:@"No internet connection"
                                                                      message:@"Please, check you internet connection and continue searching"
                                                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *theDefaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
    
    [theAlert addAction:theDefaultAction];
    [self presentViewController:theAlert animated:YES completion:nil];
}

- (void)methodLoadAllUserSongs
{
    [self.theMainRefreshControl beginRefreshing];
    NSArray *theSongsArray = [Song methodGetAllUserSongs];
    if (theSongsArray.count)
    {
        [self.theAllSongMutableArray removeAllObjects];
        [self.theAllSongMutableArray addObjectsFromArray:theSongsArray];
        [self.theMainTableView reloadData];
        [self.theMainRefreshControl endRefreshing];
    }
}

- (void)methodLoadWithScroll
{
    [[UserService sharedInstance] methodLoadSongsWithSearchString:self.theSearchTextField.text
                                                       withOffset:self.theCurrentOffset
                                                            count:keyLoadCount
                                                          taskKey:keySongsVCLoad
                                                       completion:^(NSArray<Song *> * _Nullable theSongsArray, NSUInteger theSongsCount, NSError * _Nullable error)
     {
         [self.theSearchSongMutableArray addObjectsFromArray:theSongsArray];
         self.theCurrentOffset += keyLoadCount;
         [self.theMainTableView reloadData];
         [self.theMainRefreshControl endRefreshing];
         [self.theFooterIndicatorView stopAnimating];
         self.theFooterIndicatorView.theHeight = 0;
         self.theMainTableView.tableFooterView = self.theFooterIndicatorView;
         if (!theSongsArray.count)
         {
             self.isCanBeLoadedMore = NO;
         }
     }];
}

- (void)methodChangeSongs
{
    [self.theSearchSyncBackground methodSyncBackgroundWithBlock:^
     {
         [BZExtensionsManager methodAsyncMainWithBlock:^
          {
              self.isCanBeLoadedMore = YES;
              [Song methodDeleteAllNonUserSongs];
              self.theCurrentOffset = 0;
              if (isEqual(self.theSearchTextField.text, @""))
              {
                  self.theFooterIndicatorView.theHeight = 0;
                  self.theMainTableView.tableFooterView = self.theFooterIndicatorView;
                  [self.theMainRefreshControl beginRefreshing];
                  [self methodLoadAllUserSongs];
                  [self.theMainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
                  return;
              }
              [self.theFooterIndicatorView stopAnimating];
              UserService *theUserService = [UserService sharedInstance];
              [theUserService methodLoadSongsWithSearchString:self.theSearchTextField.text
                                                   withOffset:self.theCurrentOffset
                                                        count:keyLoadCount
                                                      taskKey:keyLoadSongsToCoreData
                                                   completion:^(NSArray<Song *> * _Nullable theSongsArray, NSUInteger theSongsCount, NSError * _Nullable error)
               {
                   if (error)
                   {
                       [self.theSearchSongMutableArray removeAllObjects];
                       [self.theMainTableView reloadData];
                       self.isCanBeLoadedMore = NO;
                       [BZExtensionsManager methodDispatchAfterSeconds:0.5
                                                             withBlock:^
                        {//because of damping
                            self.theFooterIndicatorView.theHeight = 0;
                            self.theMainTableView.tableFooterView = self.theFooterIndicatorView;
                            [self.theFooterIndicatorView stopAnimating];
                        }];
                       return;
                   }
                   self.theTotalSearchCount = theSongsCount;
                   if (!theSongsArray.count)
                   {
                       [BZExtensionsManager methodDispatchAfterSeconds:0.5
                                                             withBlock:^
                        {
                            self.theFooterIndicatorView.theHeight = 0;
                            self.theMainTableView.tableFooterView = self.theFooterIndicatorView;
                            [self.theFooterIndicatorView stopAnimating];
                        }];
                       self.isCanBeLoadedMore = NO;
                       [self.theSearchSongMutableArray removeAllObjects];
                       [self.theMainTableView reloadData];
                       return;
                   }
                   [self.theSearchSongMutableArray removeAllObjects];
                   [self.theSearchSongMutableArray addObjectsFromArray:theSongsArray];
                   self.theCurrentOffset += keyLoadCount;
                   [self.theMainTableView reloadData];
                   [BZExtensionsManager methodDispatchAfterSeconds:0.5
                                                         withBlock:^
                    {//because of damping
                        self.theFooterIndicatorView.theHeight = 0;
                        self.theMainTableView.tableFooterView = self.theFooterIndicatorView;
                        [self.theFooterIndicatorView stopAnimating];
                    }];
               }];
              
              self.theFooterIndicatorView.theHeight = 40;
              self.theMainTableView.tableFooterView = self.theFooterIndicatorView;
              NSArray *theNewAllSongArray =  [Song methodGetSongsWithSearchString:self.theSearchTextField.text];
              if  (self.theMainTableView.contentOffset.y > self.theMainTableView.theHeight)
              {
                  [self.theMainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
              }
              if (theNewAllSongArray.count)
              {
                  [self.theAllSongMutableArray removeAllObjects];
                  [self.theAllSongMutableArray addObjectsFromArray:theNewAllSongArray];
                  [self.theMainTableView reloadData];
              }
              else
              {
                  [self.theAllSongMutableArray removeAllObjects];
                  [self.theMainTableView reloadData];
              }
              [self.theMainRefreshControl endRefreshing];
              [self.theFooterIndicatorView startAnimating];
          }];
     }];
}

- (void)methodSetMainTableViewRefreshingOffset
{
   self.theMainTableView.contentInset = UIEdgeInsetsMake(keyNavigationBarHeight.theDeviceValue + self.theMainRefreshControl.theHeight, 0, [MainTabBarController sharedInstance].theTabBarHeight, 0);
}

- (void)methodSetMainTableViewDefaultOffset
{
    self.theMainTableView.contentInset = UIEdgeInsetsMake(keyNavigationBarHeight.theDeviceValue, 0, [MainTabBarController sharedInstance].theTabBarHeight, 0);
}

#pragma mark - Standard Methods

@end






























