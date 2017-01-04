//
//  DetailPlayListVC.m
//  VKMusicClient
//
//  Created by Boris on 4/5/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "DetailPlayListVC.h"

#import "MainTabBarController.h"
#import "SongsCell.h"
#import "PlayList.h"
#import "CreatePlayListVC.h"
#import "SongIndex.h"
#import "Song.h"
#import "PlayerVC.h"
#import "UserService.h"

@interface DetailPlayListVC () <UITextFieldDelegate, ODTableViewDelegate>

@property (nonatomic, strong, nonnull) UITextField *thePlayListNameTextField;
@property (nonatomic, strong, nonnull) ODTableView *theMainTableView;
@property (nonatomic, strong, nonnull) UIButton *theCancelButton;
@property (nonatomic, strong, nonnull) UIButton *theOkayButton;
@property (nonatomic, strong, nonnull) UIButton *theBackButton;
@property (nonatomic, strong) Reachability *theInternetReachability;

@end

double const keyNonActiveAlpha = 0.3;

@implementation DetailPlayListVC

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setters (Public)

- (void)setThePlayList:(PlayList *)thePlayList
{
    BZAssert(thePlayList);
    _thePlayList = thePlayList;
}

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePlayListSongsChangedNotification:)
                                                 name:keyPlayListSongsChangedNotification
                                               object:nil];
    
    Reachability *theInternerReachability = [Reachability reachabilityForInternetConnection];
    self.theInternetReachability = theInternerReachability;
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

    ODTableView *theMainTableView = [ODTableView new];
    theMainTableView.theDelegate = self;
    self.theMainTableView = theMainTableView;
    [self.view addSubview:theMainTableView];
    theMainTableView.theWidth = theMainTableView.superview.theWidth;
    theMainTableView.theHeight = theMainTableView.superview.theHeight;
    theMainTableView.backgroundColor = [UIColor getColorWithHexString:keySongsTableBackgroundColor];
    theMainTableView.editing = YES;
    theMainTableView.allowsSelectionDuringEditing = YES;
    [self methodSetMainTableViewDefaultOffset];
    
    UIBlurEffect *theBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *theVisualEffectView = [[UIVisualEffectView alloc] initWithEffect:theBlurEffect];
    [self.view addSubview:theVisualEffectView];
    theVisualEffectView.theHeight = keyNavigationBarHeight.theDeviceValue;
    theVisualEffectView.theWidth = theVisualEffectView.superview.theWidth;
    
    UIButton *theBackButton = [UIButton new];
    self.theBackButton = theBackButton;
    [theVisualEffectView addSubview:theBackButton];
    [theBackButton setImage:[[UIImage getImageNamed:keyBackButtonImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                   forState:UIControlStateNormal];
    [theBackButton sizeToFit];
    theBackButton.theMinX = keySearchButtonMaxXInset.theDeviceValue;
    theBackButton.theCenterY = (keyNavigationBarHeight.theDeviceValue + [UIApplication sharedApplication].statusBarFrame.size.height) / 2 - theBackButton.superview.theMinY;
    theBackButton.imageView.tintColor = [UIColor getColorWithHexString:keyOrangeColor];
    [theBackButton addTarget:self
                      action:@selector(actionBackButtonDidTouchedUpInside:)
            forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *theOkayButton = [UIButton new];
    self.theOkayButton = theOkayButton;
    [theVisualEffectView addSubview:theOkayButton];
    if (!self.thePlayList)
    {
        [theOkayButton setImage:[UIImage getImageNamed:keyCheckmarkImageName]
                       forState:UIControlStateNormal];
        theOkayButton.theWidth = keyOkayButtonWidthHeight.theDeviceValue;
        theOkayButton.theHeight = keyOkayButtonWidthHeight.theDeviceValue;
    }
    else
    {
        [theOkayButton setTitle:@"Edit" forState:UIControlStateNormal];
        [theOkayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        theOkayButton.titleLabel.font = [UIFont fontWithName:keyHeveticaNeueCyr_Light size:@"20 18 16 16".theDeviceValue];
        [theOkayButton sizeToFit];
    }
    theOkayButton.theMaxX = theOkayButton.superview.theWidth - keySearchButtonMaxXInset.theDeviceValue;
    theOkayButton.theCenterY = (keyNavigationBarHeight.theDeviceValue + [UIApplication sharedApplication].statusBarFrame.size.height) / 2 - theOkayButton.superview.theMinY;
    [theOkayButton addTarget:self
                      action:@selector(actionOkayButtonDidTouchedUpInside:)
            forControlEvents:UIControlEventTouchUpInside];
    
    UITextField *thePlayListNameTextField = [UITextField new];
    thePlayListNameTextField.delegate = self;
    self.thePlayListNameTextField = thePlayListNameTextField;
    [theVisualEffectView addSubview:thePlayListNameTextField];
    thePlayListNameTextField.theHeight = keySearchTextFieldHeight.theDeviceValue;
    thePlayListNameTextField.theMinX = theBackButton.theMaxX + keySearchButton_SearchFieldInset.theDeviceValue;
    thePlayListNameTextField.theWidth = theOkayButton.theMinX - theBackButton.theMaxX - 2 * keySearchButton_SearchFieldInset.theDeviceValue;
    thePlayListNameTextField.theCenterY = (thePlayListNameTextField.superview.theHeight + [UIApplication sharedApplication].statusBarFrame.size.height) / 2 ;
    thePlayListNameTextField.backgroundColor = [UIColor getColorWithHexString:keySongsTableBackgroundColor];
    thePlayListNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    thePlayListNameTextField.layer.cornerRadius = 5;
    thePlayListNameTextField.returnKeyType = UIReturnKeySearch;
    thePlayListNameTextField.leftViewMode = UITextFieldViewModeAlways;
    thePlayListNameTextField.rightViewMode = UITextFieldViewModeAlways;
    thePlayListNameTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light"
                                              size:@"18 16 14 14".theDeviceValue];
    [thePlayListNameTextField addTarget:self
                           action:@selector(actionTextFieldDidChange:)
                 forControlEvents:UIControlEventEditingChanged];
    {
        UIView *theLeftView = [UIView new];
        thePlayListNameTextField.leftView = theLeftView;
        theLeftView.theWidth = @"12 11 9 9".theDeviceValue;
        theLeftView.theHeight = theLeftView.superview.theHeight;
        theLeftView.backgroundColor = thePlayListNameTextField.backgroundColor;
        
        UIButton *theCancelButton = [UIButton new];
        self.theCancelButton = theCancelButton;
        thePlayListNameTextField.rightView = theCancelButton;
        [theCancelButton setImage:[UIImage getImageNamed:@"icon-clearbutton"]
                         forState:UIControlStateNormal];
        [theCancelButton sizeToFit];
        theCancelButton.theWidth = theCancelButton.theWidth + keySearchImageLeftInset.theDeviceValue;
        theCancelButton.theCenterY = theCancelButton.superview.theHeight/2;
        [theCancelButton addTarget:self
                            action:@selector(actionClearButtonDidTouchedUpInside:)
                  forControlEvents:UIControlEventTouchUpInside];
        theCancelButton.hidden = YES;
    }
    if (!self.thePlayList)
    {
        thePlayListNameTextField.placeholder = @"Enter new song name";
    }
    else
    {
        thePlayListNameTextField.text = self.thePlayList.thePlayListName;
        self.theSongsMutableArray = [self.thePlayList methodGetPlayListSongArray].mutableCopy;
        self.theIndexesMutableArray = [self.thePlayList methodGetPlayListIndexesArray].mutableCopy;
    }
    if (!self.thePlayList && self.thePlayListNameString)
    {
        self.thePlayListNameTextField.text = self.thePlayListNameString;
    }
    [self methodCheckPlayListNameForUnique];
}

#pragma mark - Actions

- (void)actionOkayButtonDidTouchedUpInside:(UIButton *)theButton
{
    if (!self.thePlayList)
    {
        if (self.theOkayButton.alpha != 1)
        {
            return;
        }
        self.thePlayList = [PlayList methodInit];
        self.thePlayList.theCreationDate = [NSDate new];
        [self.thePlayList addTheSongSet:[NSSet setWithArray:self.theSongsMutableArray]];
        self.thePlayList.thePlayListName = self.thePlayListNameTextField.text;
        if ([self.thePlayList.managedObjectContext hasChanges])
        {
            [self.thePlayList.managedObjectContext save:nil];
        }
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:keyNewPlayListWasCreated
         object:self];
        [SongIndex methodCreateIndexesWithSongArray:self.theSongsMutableArray
                                       withPlayList:self.thePlayList];
        [self.navigationController popToViewController:self.navigationController.viewControllers.firstObject animated:YES];
    }
    else
    {
        CreatePlayListVC *theCreatePlayListVC = [CreatePlayListVC new];
        theCreatePlayListVC.thePlayList = self.thePlayList;
        theCreatePlayListVC.theIndexesMutableArray = self.theIndexesMutableArray;
        theCreatePlayListVC.theChosedSongsArray = self.theSongsMutableArray.mutableCopy;
        [self.navigationController pushViewController:theCreatePlayListVC animated:YES];
    }
}

- (void)actionClearButtonDidTouchedUpInside:(UIButton *)theButton
{
    if (isEqual(self.thePlayListNameTextField.text, @""))
    {
        return;
    }
    self.thePlayListNameTextField.text = @"";
    self.theCancelButton.hidden = YES;
    [self methodCheckPlayListNameForUnique];
}

- (void)actionTextFieldDidChange:(UITextField *)theTextField
{
    if (isEqual(self.thePlayListNameTextField.text, @""))
    {
        self.theCancelButton.hidden = YES;
    }
    else
    {
        self.theCancelButton.hidden = NO;
    }
    if (!self.thePlayList)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:keyDetailPlayListVCTextChangedNotification
         object:theTextField.text];
    }
    [self methodCheckPlayListNameForUnique];
}

- (void)actionBackButtonDidTouchedUpInside:(UIButton *)theButton
{
    if (theButton.alpha < 1)
    {
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
    if (self.thePlayList)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:keyNewPlayListWasCreated
         object:self];
    }
    else
    {
        self.thePlayListVC.theChosedSongsArray = self.theSongsMutableArray;
        self.thePlayListVC.theIndexesMutableArray = self.theIndexesMutableArray;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:keyDetailPlayListBackPressedNotification
         object:self];
    }
}

#pragma mark - Gestures

#pragma mark - Notifications

- (void)receivePlayListSongsChangedNotification:(NSNotification *)theNotification
{
    self.theSongsMutableArray = [self.thePlayList methodGetPlayListSongArray].mutableCopy;
    self.theIndexesMutableArray = [self.thePlayList methodGetPlayListIndexesArray].mutableCopy;
    [self.theMainTableView reloadData];
}

- (void)receiveSongDidLoadNotification:(NSNotification *)theNotification
{
    Song *theSong = ((Song *)theNotification.object);
    NSInteger theIndex = [self.theSongsMutableArray indexOfObject:theSong];
    NSInteger theSection;
    NSInteger theRow;
    if (theIndex == NSNotFound)
    {
        return;
    }
    else
    {
        theSection = 0;
        theRow = [self.theSongsMutableArray indexOfObject:theSong];
    }
    SongsCell *theSongCell = [self.theMainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:theRow inSection:theSection]];
    [theSongCell methodAdjustProgressView];
}

- (void)receiveSongLoadProgressNotification:(NSNotification *)theNotification
{
    Song *theSong = ((Song *)theNotification.object);
    NSInteger theIndex = [self.theSongsMutableArray indexOfObject:theSong];
    NSInteger theSection;
    NSInteger theRow;
    if (theIndex == NSNotFound)
    {
        return;
    }
    else
    {
        theSection = 0;
        theRow = [self.theSongsMutableArray indexOfObject:theSong];
    }
    SongsCell *theSongCell = [self.theMainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:theRow inSection:theSection]];
    [theSongCell methodAdjustProgressView];
}

- (void)receiveSongPopularityChangedNotification:(NSNotification *)theNotification
{
    Song *theSong = ((Song *)theNotification.object);
    NSInteger theIndex = [self.theSongsMutableArray indexOfObject:theSong];
    if (theIndex != NSNotFound)
    {
        SongsCell *theSongCell = [self.theMainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:theIndex inSection:0]];
        [theSongCell methodAdjustCounterLabel];
    }
}

#pragma mark - Delegates (UITextFieldDelegate)

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.theCancelButton.hidden = NO;
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

- (NSInteger)tableView:(ODTableView *)tableView numberOfCellsInSection:(NSInteger)section
{
    return self.theSongsMutableArray.count;
}

- (UITableViewCell <ODTableViewCellHeightProtocol> *)tableViewAbstractCell:(ODTableView *)tableView
{
    return [SongsCell new];
}

- (void)tableView:(ODTableView *)tableView
setupAbstractCell:(UITableViewCell <ODTableViewCellHeightProtocol> *)cell
{
    typeof(SongsCell *) theCell = (id)cell;
    theCell.theSongsCellStyle = SongsCellStyleNone;
    theCell.theSong = self.theSongsMutableArray[theCell.theIndexPath.row];
    theCell.isEditing = YES;
}

- (void)tableView:(ODTableView *)tableView
    didSelectCell:(UITableViewCell<ODTableViewCellHeightProtocol> *)cell
{
    if (self.thePlayList)
    {
        PlayerVC *thePlayerVC = [[PlayerVC alloc] initWithSongArray:self.theSongsMutableArray
                                       withCurrentSelectedSongIndex:cell.theIndexPath.row];
        UINavigationController *thePlayerNavigationController = [[UINavigationController alloc]initWithRootViewController:thePlayerVC];
        [self.navigationController presentViewController:thePlayerNavigationController
                                                animated:YES
                                              completion:nil];
    }
}

- (UITableViewCellEditingStyle)tableView:(ODTableView *)tableView
     setupEditingStyleForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(ODTableView *)tableView commitChangesWithEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView setupEditActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    weakify(self);
    UITableViewRowAction *theTableViewRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                                   {
                                                       strongify(self);
                                                       Song *theDeletedSong =  self.theSongsMutableArray[indexPath.row];
                                                       [tableView beginUpdates];
                                                       [self.theSongsMutableArray removeObjectAtIndex:indexPath.row];
                                                       [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                                                       [tableView endUpdates];
                                                       if (self.thePlayList)
                                                       {
                                                           SongIndex *theDeleteSongIndex = self.theIndexesMutableArray[indexPath.row];
                                                           [self.theIndexesMutableArray removeObjectAtIndex:indexPath.row];
                                                           [theDeleteSongIndex.managedObjectContext deleteObject:theDeleteSongIndex];
                                                           [self.thePlayList removeTheSongSetObject:theDeletedSong];
                                                           if ([self.thePlayList.managedObjectContext hasChanges])
                                                           {
                                                               [self.thePlayList.managedObjectContext save:nil];
                                                           }
                                                       }
                                                   }];
    theTableViewRowAction.backgroundColor = [UIColor clearColor];
    [BZExtensionsManager methodDispatchAfterSeconds:0.001 withBlock:^
     {
         UIButton *theRealButton = [theTableViewRowAction valueForKey:@"_button"];
         theRealButton.theHeight = keyCellHeight.theDeviceValue;
         theRealButton.backgroundColor = [UIColor redColor];
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
    if (!self.thePlayList)
    {
        Song *theMovedSong = self.theSongsMutableArray[sourceIndexPath.row];
        [self.theSongsMutableArray removeObjectAtIndex:sourceIndexPath.row];
        [self.theSongsMutableArray insertObject:theMovedSong atIndex:destinationIndexPath.row];
        return;
    }
    SongIndex *theMovedIndex = self.theIndexesMutableArray[sourceIndexPath.row];
    [self.theSongsMutableArray removeObjectAtIndex:sourceIndexPath.row];
    [self.theSongsMutableArray insertObject:theMovedIndex.theSong atIndex:destinationIndexPath.row];
    [self.theIndexesMutableArray removeObjectAtIndex:sourceIndexPath.row];
    [self.theIndexesMutableArray insertObject:theMovedIndex atIndex:destinationIndexPath.row];
    if (destinationIndexPath.row == self.theSongsMutableArray.count - 1)
    {
        SongIndex *theTopIndex = self.theIndexesMutableArray[destinationIndexPath.row - 1];
        double theNewSongIndex = theTopIndex.theIndexValue.doubleValue + 1;
        theMovedIndex.theIndexValue = [NSString stringWithFormat:@"%.03f", theNewSongIndex];
    }
    else if (!destinationIndexPath.row)
    {
        SongIndex *theBottomIndex = self.theIndexesMutableArray[destinationIndexPath.row + 1];
        double theNewSongIndex = theBottomIndex.theIndexValue.doubleValue - 1;
        theMovedIndex.theIndexValue = [NSString stringWithFormat:@"%.03f", theNewSongIndex];
    }
    else
    {
        SongIndex *theTopIndex = self.theIndexesMutableArray[destinationIndexPath.row - 1];
        SongIndex *theBottomIndex = self.theIndexesMutableArray[destinationIndexPath.row + 1];
        double theNewSongIndex = (theBottomIndex.theIndexValue.doubleValue + theTopIndex.theIndexValue.doubleValue) / 2;
        theMovedIndex.theIndexValue = [NSString stringWithFormat:@"%.03f", theNewSongIndex];
    }
    if ([theMovedIndex.managedObjectContext hasChanges])
    {
        [theMovedIndex.managedObjectContext save:nil];
    }
}

#pragma mark - Methods (Public)

#pragma mark - Methods (Private)

- (void)methodSetMainTableViewDefaultOffset
{
    self.theMainTableView.contentInset = UIEdgeInsetsMake(keyNavigationBarHeight.theDeviceValue, 0, 0, 0);
}

- (void)methodCheckPlayListNameForUnique
{
    if(self.thePlayList)
    {
        BOOL isPlayListNameUnique = ![PlayList isPlayListExistsWithName:self.thePlayListNameTextField.text]
        || isEqual(self.thePlayList.thePlayListName, self.thePlayListNameTextField.text);
        if (!isEqual(self.thePlayListNameTextField.text, @"") && isPlayListNameUnique)
        {
            self.thePlayList.thePlayListName = self.thePlayListNameTextField.text;
            if ([self.thePlayList.managedObjectContext hasChanges])
            {
                [self.thePlayList.managedObjectContext save:nil];
            }
            self.theBackButton.alpha = 1;
        }
        else
        {
            self.theBackButton.alpha = keyNonActiveAlpha;
        }
    }
    else
    {
        BOOL isPlayListNameUnique = ![PlayList isPlayListExistsWithName:self.thePlayListNameTextField.text];
        if (!isEqual(self.thePlayListNameTextField.text, @"") && isPlayListNameUnique)
        {
            self.theOkayButton.alpha = 1;
        }
        else
        {
            self.theOkayButton.alpha = keyNonActiveAlpha;
        }
    }
}

#pragma mark - Standard Methods

@end






























