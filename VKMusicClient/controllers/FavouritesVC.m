//
//  FavouritesVC.m
//  VKMusicClient
//
//  Created by User on 12.03.16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "FavouritesVC.h"

#import "SongsVC.h"
#import "MainTabBarController.h"
#import "SongsCell.h"
#import "PlayerVC.h"
#import "Song.h"
#import "UserDefaults.h"

typedef enum : NSUInteger
{
    FavouritesVCSortButtonDate = 1,
    FavouritesVCSortButtonPopularity,
    FavouritesVCSortButtonEnumCount = FavouritesVCSortButtonPopularity
} FavouritesVCSortButton;

@interface FavouritesVC () <UITextFieldDelegate, ODTableViewDelegate>

@property (nonatomic, strong, nonnull) UITextField *theSearchTextField;
@property (nonatomic, strong, nonnull) ODTableView *theMainTableView;
@property (nonatomic, strong, nonnull) NSMutableArray<Song *> *theAllSongMutableArray;
@property (nonatomic, strong) UIRefreshControl *theMainRefreshControl;
@property (nonatomic, strong, nonnull) UIActivityIndicatorView *theFooterIndicatorView;
@property (nonatomic, strong, nonnull) UIButton *theCancelButton;
@property (nonatomic, strong, nonnull) UIButton *theEditButton;
@property (nonatomic, strong, nonnull) UIButton *theCurrentSelectedButton;
@property (nonatomic, strong, nonnull) UIButton *theSortButton;
@property (nonatomic, strong, nonnull) UIView *theSortButtonsContainerView;
@property (nonatomic, strong, nonnull) UIView *theVisualEffectView;
@property (nonatomic, strong, nonnull) NSMutableArray<UIButton *> *theSortButtonArray;
@property (nonatomic, strong, nonnull) UIView *theBlackBackgroundView;
@property (nonatomic, assign) SongsSortType theSongsSortType;

@end

NSString * const keySortNavigationBarHeight = @"135 121 101 101";
NSString * const keySortButtonTitleColor = @"4b4b4c";

@implementation FavouritesVC

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

    }
    [self methodChangeSongs];
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
    self.theSongsSortType = [UserDefaults sharedInstance].theSongsSortType;
    self.theAllSongMutableArray = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSongDidLoadNotification:)
                                                 name:keySongDidLoadNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSongPopularityChangedNotification:)
                                                 name:keyPopularityChangedNotification
                                               object:nil];

    ODTableView *theMainTableView = [ODTableView new];
    theMainTableView.theDelegate = self;
    self.theMainTableView = theMainTableView;
    [self.view addSubview:theMainTableView];
    theMainTableView.theWidth = theMainTableView.superview.theWidth;
    theMainTableView.theHeight = theMainTableView.superview.theHeight;
    theMainTableView.backgroundColor = [UIColor getColorWithHexString:keySongsTableBackgroundColor];
    [self methodSetMainTableViewDefaultOffset];
    theMainTableView.allowsSelectionDuringEditing = YES;
    
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
    self.theVisualEffectView =  theVisualEffectView;
    [self.view addSubview:theVisualEffectView];
    theVisualEffectView.theHeight = keySortNavigationBarHeight.theDeviceValue;
    theVisualEffectView.theWidth = theVisualEffectView.superview.theWidth;
    theVisualEffectView.theMinY = keyNavigationBarHeight.theDeviceValue - theVisualEffectView.theHeight;
    
    UIButton *theSearchButton = [UIButton new];
    self.theSortButton = theSearchButton;
    [theVisualEffectView addSubview:theSearchButton];
    [theSearchButton setImage:[UIImage getImageNamed:keySearchButtonImageName]
                     forState:UIControlStateNormal];
    [theSearchButton setImage:[UIImage getImageNamed:@"icon-filter"]
                     forState:UIControlStateSelected];
    [theSearchButton sizeToFit];
    theSearchButton.theMinX = keySearchButtonMaxXInset.theDeviceValue;
    theSearchButton.theCenterY = (keyNavigationBarHeight.theDeviceValue + [BZExtensionsManager methodGetStatusBarHeight]) / 2 - theSearchButton.superview.theMinY;
    [theSearchButton addTarget:self
                        action:@selector(actionSearchButtonDidTouchedUpInside:)
              forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *theEditButton = [UIButton new];
    self.theEditButton = theEditButton;
    [theVisualEffectView addSubview:theEditButton];
    [theEditButton setTitle:@"Edit" forState:UIControlStateNormal];
    [theEditButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [theEditButton setTitleColor:[UIColor getColorWithHexString:keyOrangeColor] forState:UIControlStateSelected];
    theEditButton.titleLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Light size:@"20 18 16 16".theDeviceValue];
    [theEditButton sizeToFit];
    theEditButton.theMinY = theSearchButton.theMinY;
    theEditButton.theMaxX = theEditButton.superview.theWidth - keySearchButtonMaxXInset.theDeviceValue;
    [theEditButton addTarget:self
                      action:@selector(actionEditButtonDidTouchedUpInside:)
            forControlEvents:UIControlEventTouchUpInside];
    
    UITextField *theSearchTextField = [UITextField new];
    theSearchTextField.delegate = self;
    self.theSearchTextField = theSearchTextField;
    [theVisualEffectView addSubview:theSearchTextField];
    theSearchTextField.theHeight = @"36 33 28 28".theDeviceValue;
    theSearchTextField.theMinX = theSearchButton.theMaxX + keySearchButton_SearchFieldInset.theDeviceValue;
    theSearchTextField.theWidth = theEditButton.theMinX - theSearchButton.theMaxX - keySearchButton_SearchFieldInset.theDeviceValue * 2;
    theSearchTextField.theCenterY = theSearchButton.theCenterY;
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
    
    UIView *theSortButtonsContainerView = [UIView new];
    self.theSortButtonsContainerView = theSortButtonsContainerView;
    [theVisualEffectView addSubview:theSortButtonsContainerView];
    theSortButtonsContainerView.theWidth = @"393 357 305 305".theDeviceValue;
    theSortButtonsContainerView.theHeight = keySearchTextFieldHeight.theDeviceValue;
    theSortButtonsContainerView.theMinY = 0 - theSortButtonsContainerView.theHeight;
    theSortButtonsContainerView.theCenterX = theSortButtonsContainerView.superview.theWidth / 2;
    theSortButtonsContainerView.layer.cornerRadius = 15.0;
    theSortButtonsContainerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    theSortButtonsContainerView.layer.borderWidth = 0.3f;
    theSortButtonsContainerView.layer.masksToBounds = YES;
    
    NSMutableArray<UIButton *> *theSortButtonArray = [NSMutableArray new];
    for (int i = 0; i < FavouritesVCSortButtonEnumCount; i++)
    {
        UIButton *theSortButton = [UIButton new];
        [theSortButtonsContainerView addSubview:theSortButton];
        theSortButton.theWidth  = theSortButton.superview.theWidth / 2;
        theSortButton.theHeight = theSortButton.superview.theHeight;
        theSortButton.theMinX = theSortButton.theWidth * i;
        NSString *theButtonTitleString;
        switch (i + 1)
        {
            case FavouritesVCSortButtonDate:
            {
                theButtonTitleString = @"Date";
            }
                break;
            case FavouritesVCSortButtonPopularity:
            {
                theButtonTitleString = @"Popularity";
            }
                break;
        }
        [theSortButton setTitle:theButtonTitleString
                       forState:UIControlStateNormal];
        [theSortButton setTitleColor:[UIColor getColorWithHexString:keySortButtonTitleColor] forState:UIControlStateNormal];
        theSortButton.titleLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Roman size:@"15 14 12 12".theDeviceValue];
        [theSortButton setBackgroundImage:[UIImage getImageFromColor:[UIColor getColorWithHexString:keyOrangeColor]]
                                 forState:UIControlStateSelected];
        theSortButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        theSortButton.layer.borderWidth = 0.5f;
        theSortButton.tag = i + 1;
        [theSortButton addTarget:self
                          action:@selector(actionSortButtonDidTouchedUpInside:)
                forControlEvents:UIControlEventTouchUpInside];
        [theSortButtonArray addObject:theSortButton];
    }
    theSortButtonArray[0].selected = YES;
    self.theCurrentSelectedButton = theSortButtonArray[0];
    
    UIView *theBlackBackgroundView = [UIView new];
    [self.view addSubview:theBlackBackgroundView];
    self.theBlackBackgroundView = theBlackBackgroundView;
    theBlackBackgroundView.theWidth = theBlackBackgroundView.superview.theWidth;
    theBlackBackgroundView.theHeight = theBlackBackgroundView.superview.theHeight - theVisualEffectView.theHeight;
    theBlackBackgroundView.theMinY = theVisualEffectView.theMaxY;
    theBlackBackgroundView.backgroundColor = [UIColor blackColor];
    theBlackBackgroundView.alpha = 0;
    UITapGestureRecognizer *theTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(handleBlackViewGesture:)];
    [theBlackBackgroundView addGestureRecognizer:theTapGestureRecognizer];
}


#pragma mark - Actions

- (void)actionRefreshDidChange:(UIRefreshControl * _Nonnull)refreshControl
{
    BZAssert(refreshControl);
    [self methodChangeSongs];
}

- (void)actionSearchTextDidChange:(UITextField * _Nonnull)theTextField
{
    BZAssert(theTextField);
    if (isEqual(self.theSearchTextField.text, @""))
    {
        self.theCancelButton.hidden = YES;
    }
    else
    {
        self.theCancelButton.hidden = NO;
    }
    [self methodChangeSongs];
}

- (void)actionClearButtonTouchUpInside:(UIButton * _Nonnull)theClearButton
{
    BZAssert(theClearButton);
    if (isEqual(self.theSearchTextField.text, @""))
    {
        return;
    }
    self.theSearchTextField.text = @"";
    self.theCancelButton.hidden = YES;
    [self methodChangeSongs];
}

- (void)actionSearchButtonDidTouchedUpInside:(UIButton * _Nonnull)theButton
{
    BZAssert(theButton);
    if (!theButton.isSelected)
    {
        theButton.selected = YES;
        BZAnimation *theBZAnimation = [BZAnimation new];
        theBZAnimation.theDuration = 1;
        theBZAnimation.theOptions = UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction;
        weakify(self);
        [theBZAnimation methodSetAnimationBlock:^
         {
             strongify(self);
             self.theVisualEffectView.theMinY = 0;
             self.theBlackBackgroundView.theMinY = self.theVisualEffectView.theMaxY;
             self.theBlackBackgroundView.alpha = 0.8;
             self.theEditButton.alpha = 0;
             self.theSortButtonsContainerView.theMaxY = self.theSearchTextField.theMinY - @"10 9 8 8".theDeviceValue;
         }];
        [theBZAnimation methodStart];
        self.theSearchTextField.enabled = NO;
        [self.theSearchTextField resignFirstResponder];
    }
    else
    {
        [self methodDissmisSortMenu];
    }
}

- (void)actionSortButtonDidTouchedUpInside:(UIButton * _Nonnull)theButton
{
    BZAssert(theButton);
    if (theButton.tag == self.theCurrentSelectedButton.tag)
    {
        return;
    }
    theButton.selected  = YES;
    self.theCurrentSelectedButton.selected = NO;
    self.theCurrentSelectedButton = theButton;
    switch (theButton.tag)
    {
        case FavouritesVCSortButtonDate:
        {
            self.theSongsSortType = SongsSortTypeDate;
        }
            break;
        case FavouritesVCSortButtonPopularity:
        {
            self.theSongsSortType = SongsSortTypePopularity;
        }
            break;
    }
    [UserDefaults sharedInstance].theSongsSortType = self.theSongsSortType;
    [self methodChangeSongs];
}

- (void)actionEditButtonDidTouchedUpInside:(UIButton * _Nonnull)theButton
{
    BZAssert(theButton);
    theButton.selected = !theButton.selected;
    if (theButton.isSelected)
    {
        [self.theMainTableView setEditing:theButton.selected animated:YES];
    }
    else
    {
        [self.theMainTableView setEditing:theButton.selected animated:YES];
    }
    [BZExtensionsManager methodDispatchAfterSeconds:0.5 withBlock:^
     {
         [self.theMainTableView reloadData];
     }];
}

#pragma mark - Gestures

- (void)handleBlackViewGesture:(UITapGestureRecognizer * _Nonnull)theGestureRecognizer
{
    BZAssert(theGestureRecognizer);
    [self methodDissmisSortMenu];
}

#pragma mark - Notifications

- (void)receiveSongDidLoadNotification:(NSNotification * _Nonnull)theNotification
{
    BZAssert(theNotification);
    [self methodChangeSongs];
}

- (void)receiveSongPopularityChangedNotification:(NSNotification *)theNotification
{
    Song *theSong = ((Song *)theNotification.object);
    NSInteger theIndex = [self.theAllSongMutableArray indexOfObject:theSong];
    if (theIndex != NSNotFound)
    {
        SongsCell *theSongCell = [self.theMainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:theIndex inSection:0]];
        [theSongCell methodAdjustCounterLabel];
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

#pragma mark - Delegates (ODTableViewDelegate)

- (NSUInteger)tableViewNumberOfSections:(ODTableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(ODTableView *)tableView numberOfCellsInSection:(NSInteger)section
{
    return self.theAllSongMutableArray.count;
}

- (UITableViewCell <ODTableViewCellHeightProtocol> *)tableViewAbstractCell:(ODTableView *)tableView
{
    return [SongsCell new];
}

- (void)tableView:(ODTableView *)tableView setupAbstractCell:(UITableViewCell <ODTableViewCellHeightProtocol> *)cell
{
    typeof(SongsCell *) theCell = (id)cell;
    theCell.theSong = self.theAllSongMutableArray[cell.theIndexPath.row];
    theCell.isEditing = self.theEditButton.selected;
}

- (void)tableView:(ODTableView *)tableView didSelectCell:(UITableViewCell<ODTableViewCellHeightProtocol> *)cell
{
    NSIndexPath *theCellIndexPath = cell.theIndexPath;
    NSInteger theCurrentSelectedSongIndex = theCellIndexPath.row;
    NSMutableArray *theSongsArray = [NSMutableArray new];
    [theSongsArray addObjectsFromArray:self.theAllSongMutableArray];
    
    PlayerVC *thePlayerVC = [[PlayerVC alloc] initWithSongArray:theSongsArray
                                   withCurrentSelectedSongIndex:theCurrentSelectedSongIndex];
    
    UINavigationController *thePlayerNavigationController = [[UINavigationController alloc]initWithRootViewController:thePlayerVC];
    [self.navigationController presentViewController:thePlayerNavigationController
                                            animated:YES
                                          completion:nil];
}

- (UITableViewCellEditingStyle)tableView:(ODTableView *)tableView setupEditingStyleForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView setupEditActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    weakify(self);
    UITableViewRowAction *theTableViewRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        strongify(self);
                                        Song *theSong = self.theAllSongMutableArray[indexPath.row];
                                        [theSong methodDeleteFile];
                                        [tableView beginUpdates];
                                        [self.theAllSongMutableArray removeObjectAtIndex:indexPath.row];
                                        if ([self.theDeleteSongDelegate respondsToSelector:@selector(favouriteVC:didDeleteSong:)])
                                        {
                                            [self.theDeleteSongDelegate favouriteVC:self didDeleteSong:theSong];
                                        }
                                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                                        [tableView endUpdates];
                                    }];
    theTableViewRowAction.backgroundColor = [UIColor clearColor];
    [BZExtensionsManager methodAsyncBackgroundWithBlock:^
     {
         [BZExtensionsManager methodAsyncMainWithBlock:^
          {
              [BZExtensionsManager methodDispatchAfterSeconds:0.001 withBlock:^
               {
                   UIButton *theRealButton = [theTableViewRowAction valueForKey:@"_button"];
                   theRealButton.theHeight = keyCellHeight.theDeviceValue;
                   theRealButton.backgroundColor = [UIColor redColor];
               }];
          }];
     }];
    return @[theTableViewRowAction];
}

- (BOOL)tableView:(ODTableView *)tableView canEditCellAtIndexPath:(NSIndexPath *)theIndexPath
{
    return YES;
}

- (BOOL)tableView:(ODTableView *)tableView canMoveCellAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromCellAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return proposedDestinationIndexPath;
}

- (void)tableView:(ODTableView *)tableView moveCellAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (sourceIndexPath.row == destinationIndexPath.row)
    {
        return;
    }
    Song *theMovedSong = self.theAllSongMutableArray[sourceIndexPath.row];
    [self.theAllSongMutableArray removeObjectAtIndex:sourceIndexPath.row];
    [self.theAllSongMutableArray insertObject:theMovedSong atIndex:destinationIndexPath.row];
    if (destinationIndexPath.row == self.theAllSongMutableArray.count - 1)
    {
        Song *theTopSong = self.theAllSongMutableArray[destinationIndexPath.row - 1];
        switch (self.theSongsSortType)
        {
            case SongsSortTypeDate:
            {
                NSDate *theNewDate = [NSDate dateWithTimeInterval:-1 sinceDate:theTopSong.theLoadDate];
                theMovedSong.theLoadDate = theNewDate;
            }
                break;
            case SongsSortTypePopularity:
            {
                double theNewPopularity = theTopSong.thePopularity.doubleValue - 0.01;
                theMovedSong.thePopularity = [NSString stringWithFormat:@"%.02f", theNewPopularity];
            }
                break;
        }
    }
    else if (!destinationIndexPath.row)
    {
        Song *theBottomSong = self.theAllSongMutableArray[destinationIndexPath.row + 1];
        switch (self.theSongsSortType)
        {
            case SongsSortTypeDate:
            {
                NSDate *theNewDate = [NSDate dateWithTimeInterval:1 sinceDate:theBottomSong.theLoadDate];
                theMovedSong.theLoadDate = theNewDate;
            }
                break;
            case SongsSortTypePopularity:
            {
                double theNewPopularity = theBottomSong.thePopularity.doubleValue + 0.01;
                theMovedSong.thePopularity = [NSString stringWithFormat:@"%.02f", theNewPopularity];
            }
                break;
        }
    }
    else
    {
        Song *theTopSong = self.theAllSongMutableArray[destinationIndexPath.row - 1];
        Song *theBottomSong = self.theAllSongMutableArray[destinationIndexPath.row + 1];
        switch (self.theSongsSortType)
        {
            case SongsSortTypeDate:
            {
                NSTimeInterval theTimaInterval = [theTopSong.theLoadDate timeIntervalSinceDate:theBottomSong.theLoadDate] / 2;
                NSDate *theNewDate = [NSDate dateWithTimeInterval:theTimaInterval sinceDate:theBottomSong.theLoadDate];
                theMovedSong.theLoadDate = theNewDate;
            }
                break;
            case SongsSortTypePopularity:
            {
                double theNewPopularity = (theBottomSong.thePopularity.doubleValue + theTopSong.thePopularity.doubleValue) / 2;
                theMovedSong.thePopularity = [NSString stringWithFormat:@"%.02f", theNewPopularity];
            }
                break;
        }
    }
    if ([theMovedSong.managedObjectContext hasChanges])
    {
        [theMovedSong.managedObjectContext save:nil];
    }
}

#pragma mark - Methods (Public)

#pragma mark - Methods (Private)

- (void)methodSetMainTableViewRefreshingOffset
{
    self.theMainTableView.contentInset = UIEdgeInsetsMake(keyNavigationBarHeight.theDeviceValue + self.theMainRefreshControl.theHeight, 0, [MainTabBarController sharedInstance].theTabBarHeight, 0);
}

- (void)methodSetMainTableViewDefaultOffset
{
    self.theMainTableView.contentInset = UIEdgeInsetsMake(keyNavigationBarHeight.theDeviceValue, 0, [MainTabBarController sharedInstance].theTabBarHeight, 0);
}

- (void)methodChangeSongs
{
    if (!self.theSongsSortType || !self.theSearchTextField)
    {
        return;
    }
    NSArray *theLoadedSongs = [Song methodGetLoadedSongsWithSongsSortType:self.theSongsSortType
                                                         withSearchString:self.theSearchTextField.text];
    [self.theAllSongMutableArray removeAllObjects];
    [self.theAllSongMutableArray addObjectsFromArray:theLoadedSongs];
    [self.theMainTableView reloadData];
    [self.theMainRefreshControl endRefreshing];
}

- (void)methodDissmisSortMenu
{
    self.theSortButton.selected = NO;
    BZAnimation *theBZAnimation = [BZAnimation new];
    theBZAnimation.theDuration = 1;
    theBZAnimation.theOptions = UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction;
    weakify(self);
    [theBZAnimation methodSetAnimationBlock:^
     {
         strongify(self);
         self.theVisualEffectView.theMinY = keyNavigationBarHeight.theDeviceValue - self.theVisualEffectView.theHeight;
         self.theBlackBackgroundView.theMinY = self.theVisualEffectView.theMaxY;
         self.theBlackBackgroundView.alpha = 0;
         self.theEditButton.alpha = 1;
         self.theSortButtonsContainerView.theMinY = 0 - self.theSortButtonsContainerView.theHeight;
     }];
    [theBZAnimation methodStart];
    self.theSearchTextField.enabled = YES;
}

#pragma mark - Standard Methods

@end






























