//
//  PlayListVC.m
//  VKMusicClient
//
//  Created by Boris on 4/4/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "PlayListVC.h"

#import "MainTabBarController.h"
#import "PlayList.h"
#import "PlayListCell.h"
#import "CreatePlayListVC.h"
#import "DetailPlayListVC.h"
#import "DataManager.h"

@interface PlayListVC () <ODTableViewDelegate>

@property (nonatomic, strong, nonnull) UITextField *theSearchTextField;
@property (nonatomic, strong, nonnull) UIButton *theCancelButton;
@property (nonatomic, strong, nonnull) ODTableView *theMainTableView;
@property (nonatomic, strong, nonnull) NSMutableArray *thePlayListArray;

@end

NSString * const keyHeaderHeight = @"60 55 50 50";

@implementation PlayListVC

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
    self.thePlayListArray = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNewPlayListWasCreatedNotification:)
                                                 name:keyNewPlayListWasCreated
                                               object:nil];
    
    ODTableView *theMainTableView = [ODTableView new];
    theMainTableView.theDelegate = self;
    self.theMainTableView = theMainTableView;
    [self.view addSubview:theMainTableView];
    theMainTableView.theWidth = theMainTableView.superview.theWidth;
    theMainTableView.theHeight = theMainTableView.superview.theHeight;
    theMainTableView.backgroundColor = [UIColor getColorWithHexString:keySongsTableBackgroundColor];
    [self methodSetMainTableViewDefaultOffset];
    theMainTableView.editing = YES;
    theMainTableView.allowsSelectionDuringEditing = YES;
    
    UIBlurEffect *theBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *theVisualEffectView = [[UIVisualEffectView alloc] initWithEffect:theBlurEffect];
    [self.view addSubview:theVisualEffectView];
    theVisualEffectView.theHeight = keyNavigationBarHeight.theDeviceValue;
    theVisualEffectView.theWidth = theVisualEffectView.superview.theWidth;
    
    UIView *theTableViewHeaderView = [UIView new];
    theTableViewHeaderView.theWidth = self.theMainTableView.theWidth;
    theTableViewHeaderView.theHeight = keyHeaderHeight.theDeviceValue;
    self.theMainTableView.tableHeaderView = theTableViewHeaderView;
    theTableViewHeaderView.backgroundColor = [UIColor getColorWithHexString:keyOrangeColor];
    UITapGestureRecognizer *theTapGestuteRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(handleHeaderTapGesture:)];
    
    [theTableViewHeaderView addGestureRecognizer:theTapGestuteRecognizer];
    {
        UILabel *theLabel = [UILabel new];
        [theTableViewHeaderView addSubview:theLabel];
        theLabel.text = @"Create";
        theLabel.font = [UIFont fontWithName:@"HelveticaNeueCyr-Light" size:@"26 24 22 22".theDeviceValue];
        [theLabel sizeToFit];
        theLabel.theCenterX = theLabel.superview.theWidth / 2;
        theLabel.theCenterY = theLabel.superview.theHeight / 2;
    }
    [self methodGetPlayLists];
}

#pragma mark - Actions

#pragma mark - Gestures

- (void)handleHeaderTapGesture:(UITapGestureRecognizer *)theTapGestureRecognizer
{
    CreatePlayListVC *theCreatePlayListVC = [CreatePlayListVC new];
    [self.navigationController pushViewController:theCreatePlayListVC animated:YES];
}

#pragma mark - Notifications

- (void)receiveNewPlayListWasCreatedNotification:(NSNotification *)theNotification
{
    [self methodGetPlayLists];
}

#pragma mark - Delegates (ODTableViewDelegate)

- (NSInteger)tableView:(ODTableView *)tableView numberOfCellsInSection:(NSInteger)section
{
    return self.thePlayListArray.count;
}

- (UITableViewCell <ODTableViewCellHeightProtocol> *)tableViewAbstractCell:(ODTableView *)tableView
{
    return [PlayListCell new];
}

- (void)tableView:(ODTableView *)tableView setupAbstractCell:(UITableViewCell <ODTableViewCellHeightProtocol> *)cell
{
    typeof(PlayListCell *) theCell = (id)cell;
    theCell.thePlayList = self.thePlayListArray[theCell.theIndexPath.row];
}

- (void)tableView:(ODTableView *)tableView didSelectCell:(UITableViewCell<ODTableViewCellHeightProtocol> *)cell
{
    typeof(PlayListCell *) theCell = (id)cell;
    PlayList *theSelectedPlayList = self.thePlayListArray[theCell.theIndexPath.row];
    DetailPlayListVC *theDetailVC = [DetailPlayListVC new];
    theDetailVC.thePlayList = theSelectedPlayList;
    [self.navigationController pushViewController:theDetailVC animated:YES];
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
                                                       PlayList *thePlayList = self.thePlayListArray[indexPath.row];
                                                       [tableView beginUpdates];
                                                       [self.thePlayListArray removeObjectAtIndex:indexPath.row];
                                                       [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                                                       [tableView endUpdates];
                                                       [thePlayList.managedObjectContext deleteObject:thePlayList];
                                                       [[DataManager sharedInstance] saveContext];
                                                       
                                                   }];
    theTableViewRowAction.backgroundColor = [UIColor clearColor];
    
    [BZExtensionsManager methodAsyncBackgroundWithBlock:^
     {
         [BZExtensionsManager methodAsyncMainWithBlock:^
          {
              [BZExtensionsManager methodDispatchAfterSeconds:0.001 withBlock:^
               {
                   UIButton *theRealButton = [theTableViewRowAction valueForKey:@"_button"];
                   theRealButton.theHeight = keyPlayListCellHeight.theDeviceValue;
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
    PlayList *theMovedPlayList = self.thePlayListArray[sourceIndexPath.row];
    [self.thePlayListArray removeObjectAtIndex:sourceIndexPath.row];
    [self.thePlayListArray insertObject:theMovedPlayList atIndex:destinationIndexPath.row];
    if (destinationIndexPath.row == self.thePlayListArray.count - 1)
    {
        PlayList *theTopPlayList = self.thePlayListArray[destinationIndexPath.row - 1];
        NSDate *theNewDate = [NSDate dateWithTimeInterval:-1 sinceDate:theTopPlayList.theCreationDate];
        theMovedPlayList.theCreationDate = theNewDate;
    }
    else if (!destinationIndexPath.row)
    {
        PlayList *theBottomPlayList = self.thePlayListArray[destinationIndexPath.row + 1];
        NSDate *theNewDate = [NSDate dateWithTimeInterval:1 sinceDate:theBottomPlayList.theCreationDate];
        theMovedPlayList.theCreationDate = theNewDate;
    }
    else
    {
        PlayList *theTopPlayList = self.thePlayListArray[destinationIndexPath.row - 1];
        PlayList *theBottomPlayList = self.thePlayListArray[destinationIndexPath.row + 1];
        NSTimeInterval theTimaInterval = [theTopPlayList.theCreationDate timeIntervalSinceDate:theBottomPlayList.theCreationDate] / 2;
        NSDate *theNewDate = [NSDate dateWithTimeInterval:theTimaInterval sinceDate:theBottomPlayList.theCreationDate];
        theMovedPlayList.theCreationDate = theNewDate;
    }
    if ([theMovedPlayList.managedObjectContext hasChanges])
    {
        [theMovedPlayList.managedObjectContext save:nil];
    }
}

#pragma mark - Methods (Public)

#pragma mark - Methods (Private)

- (void)methodSetMainTableViewDefaultOffset
{
    self.theMainTableView.contentInset = UIEdgeInsetsMake(keyNavigationBarHeight.theDeviceValue, 0, [MainTabBarController sharedInstance].theTabBarHeight, 0);
}

- (void)methodGetPlayLists
{
    self.thePlayListArray = [PlayList methodGetPlayListArray].mutableCopy;
    [self.theMainTableView reloadData];
}

#pragma mark - Standard Methods

@end






























