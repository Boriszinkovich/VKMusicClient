//
//  CreatePlayListVC.m
//  VKMusicClient
//
//  Created by Boris on 4/4/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "CreatePlayListVC.h"

#import "MainTabBarController.h"
#import "CreatePlayListVCHeaderView.h"
#import "PlayList.h"
#import "Song.h"
#import "SongsCell.h"
#import "DetailPlayListVC.h"
#import "SongIndex.h"

@interface CreatePlayListVC () <UITextFieldDelegate, ODTableViewDelegate>

@property (nonatomic, strong, nonnull) UITextField *theSearchTextField;
@property (nonatomic, strong, nonnull) ODTableView *theMainTableView;
@property (nonatomic, strong, nonnull) NSMutableArray *theSearchedSongsArray;
@property (nonatomic, strong, nonnull) UIButton *theCancelButton;
@property (nonatomic, strong, nonnull) UIButton *theOkayButton;
@property (nonatomic, strong, nonnull) UIButton *theBackButton;
@property (nonatomic, strong, nonnull) BZSyncBackground *theSearchSyncBackground;

@end

@implementation CreatePlayListVC

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
                                             selector:@selector(receiveCellDeleteButtonNotification:)
                                                 name:keyCellDeleteButtonDidTouchedUpInside
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSongDidLoadNotification:)
                                                 name:keySongDidLoadNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDetailPlayListVCTextChangedNotification:)
                                                 name:keyDetailPlayListVCTextChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDetailPlayListBackPressedNotification:)
                                                 name:keyDetailPlayListBackPressedNotification
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

    ODTableView *theMainTableView = [ODTableView new];
    theMainTableView.theDelegate = self;
    self.theMainTableView = theMainTableView;
    [self.view addSubview:theMainTableView];
    theMainTableView.theWidth = theMainTableView.superview.theWidth;
    theMainTableView.theHeight = theMainTableView.superview.theHeight;
    theMainTableView.backgroundColor = [UIColor getColorWithHexString:keySongsTableBackgroundColor];
    [self methodSetMainTableViewDefaultOffset];
    self.theSearchSyncBackground = [BZSyncBackground new];
    self.theSearchSyncBackground.theDelayInSeconds = 0.5;
    
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
    theBackButton.theCenterY = (keyNavigationBarHeight.theDeviceValue + [BZExtensionsManager methodGetStatusBarHeight]) / 2 - theBackButton.superview.theMinY;
    theBackButton.imageView.tintColor = [UIColor getColorWithHexString:keyOrangeColor];
    [theBackButton addTarget:self
                      action:@selector(actionBackButtonDidTouchedUpInside:)
            forControlEvents:UIControlEventTouchUpInside];

    UIButton *theOkayButton = [UIButton new];
    self.theOkayButton = theOkayButton;
    [theVisualEffectView addSubview:theOkayButton];
    [theOkayButton setImage:[UIImage getImageNamed:keyCheckmarkImageName]
                     forState:UIControlStateNormal];
    theOkayButton.theWidth = keyOkayButtonWidthHeight.theDeviceValue;
    theOkayButton.theHeight = keyOkayButtonWidthHeight.theDeviceValue;
    theOkayButton.theMaxX = theOkayButton.superview.theWidth - keySearchButtonMaxXInset.theDeviceValue;
    theOkayButton.theCenterY = (keyNavigationBarHeight.theDeviceValue + [BZExtensionsManager methodGetStatusBarHeight]) / 2 - theOkayButton.superview.theMinY;
    [theOkayButton addTarget:self
                        action:@selector(actionOkayButtonDidTouchedUpInside:)
              forControlEvents:UIControlEventTouchUpInside];

    UITextField *theSearchTextField = [UITextField new];
    theSearchTextField.delegate = self;
    self.theSearchTextField = theSearchTextField;
    [theVisualEffectView addSubview:theSearchTextField];
    theSearchTextField.theHeight = keySearchTextFieldHeight.theDeviceValue;
    theSearchTextField.theMinX = theBackButton.theMaxX + keySearchButton_SearchFieldInset.theDeviceValue;
    theSearchTextField.theWidth = theOkayButton.theMinX - theBackButton.theMaxX - 2 * keySearchButton_SearchFieldInset.theDeviceValue;
    theSearchTextField.theCenterY = (theSearchTextField.superview.theHeight + [BZExtensionsManager methodGetStatusBarHeight]) / 2 ;
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
        theCancelButton.theCenterY = theCancelButton.superview.theHeight / 2;
        [theCancelButton addTarget:self
                            action:@selector(actionClearButtonTouchUpInside:)
                  forControlEvents:UIControlEventTouchUpInside];
        theCancelButton.hidden = YES;
    }
    
    self.theSearchedSongsArray = [NSMutableArray new];
    if (!self.theChosedSongsArray)
    {
        self.theChosedSongsArray = [NSMutableArray new];
    }
    [self methodChangeSongs];
    [self methodCheckPlayListSongsCount];
}

#pragma mark - Actions

- (void)actionClearButtonTouchUpInside:(UIButton *)theButton
{
    if (isEqual(self.theSearchTextField.text, @""))
    {
        return;
    }
    self.theSearchTextField.text = @"";
    self.theCancelButton.hidden = YES;
    [self methodChangeSongs];
}

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
    [self methodChangeSongs];
}

- (void)actionOkayButtonDidTouchedUpInside:(UIButton *)theButton
{
    if (!self.theChosedSongsArray.count)
    {
        return;
    }
    if (!self.thePlayList)
    {
        DetailPlayListVC *theDetailPlayListVC = [DetailPlayListVC new];
        theDetailPlayListVC.theSongsMutableArray = self.theChosedSongsArray;
        theDetailPlayListVC.thePlayListVC = self;
        if (self.thePlayListNameString)
        {
            theDetailPlayListVC.thePlayListNameString = self.thePlayListNameString;
        }
        [self.navigationController pushViewController:theDetailPlayListVC animated:YES];
    }
    else
    {
        NSArray *theCoreDataSongs = self.thePlayList.theSongSet.allObjects;
        for (int i = 0; i < theCoreDataSongs.count; i++)
        {
            if (![self.theChosedSongsArray containsObject:theCoreDataSongs[i]])
            {
                [self.thePlayList removeTheSongSetObject:theCoreDataSongs[i]];
            }
        }
        [self.thePlayList addTheSongSet:[NSSet setWithArray:self.theChosedSongsArray]];
        [SongIndex methodDeleteSongIndexesWithArray:self.theIndexesMutableArray];
        [SongIndex methodCreateIndexesWithSongArray:self.theChosedSongsArray
                                       withPlayList:self.thePlayList];
        if ([self.thePlayList.managedObjectContext hasChanges])
        {
            [self.thePlayList.managedObjectContext save:nil];
        }
        [[NSNotificationCenter defaultCenter]
         postNotificationName:keyPlayListSongsChangedNotification
         object:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)actionBackButtonDidTouchedUpInside:(UIButton *)theButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Gestures

#pragma mark - Notifications

- (void)receiveCellDeleteButtonNotification:(NSNotification *)theNotification
{
    typeof(SongsCell *) theCell = theNotification.object;
    theCell.theSongsCellStyle = SongsCellStyleNone;
    [self.theChosedSongsArray removeObject:theCell.theSong];
    NSInteger theRow = [self.theSearchedSongsArray indexOfObject:theCell.theSong];
    if (theRow != NSNotFound)
    {
        SongsCell *theSearchedCell = [self.theMainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:theRow inSection:1]];
        theSearchedCell.theSongsCellStyle = SongsCellStyleNone;
    }
    NSRange theRange = NSMakeRange(0, 1);
    NSIndexSet *theSectionIndexSet = [NSIndexSet indexSetWithIndexesInRange:theRange];
    [self.theMainTableView reloadSections:theSectionIndexSet
                         withRowAnimation:UITableViewRowAnimationNone];
    [self methodCheckPlayListSongsCount];
}

- (void)receiveSongDidLoadNotification:(NSNotification *)theNotification
{
    Song *theSong = ((Song *)theNotification.object);
    NSInteger theIndex = [self.theChosedSongsArray indexOfObject:theSong];
    if (theIndex != NSNotFound)
    {
        SongsCell *theSongCell = [self.theMainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:theIndex inSection:0]];
        [theSongCell methodAdjustProgressView];
    }
    [self methodChangeSongs];
}

- (void)receiveSongLoadProgressNotification:(NSNotification *)theNotification
{
    Song *theSong = ((Song *)theNotification.object);
    NSInteger theIndex = [self.theChosedSongsArray indexOfObject:theSong];
    if (theIndex != NSNotFound)
    {
        SongsCell *theSongCell = [self.theMainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:theIndex inSection:0]];
        [theSongCell methodAdjustProgressView];
    }
}

- (void)receiveDetailPlayListVCTextChangedNotification:(NSNotification *)theNotification
{
    self.thePlayListNameString = theNotification.object;
}

- (void)receiveDetailPlayListBackPressedNotification:(NSNotification *)theNotification
{
    [self.theMainTableView reloadData];
}

- (void)receiveSongPopularityChangedNotification:(NSNotification *)theNotification
{
    Song *theSong = ((Song *)theNotification.object);
    NSInteger theIndex = [self.theSearchedSongsArray indexOfObject:theSong];
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
    return 2;
}

- (NSInteger)tableView:(ODTableView *)tableView numberOfCellsInSection:(NSInteger)section
{
    if (!section)
    {
        return self.theChosedSongsArray.count;
    }
    else
    {
        return self.theSearchedSongsArray.count;
    }
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
        theCell.theSong = self.theChosedSongsArray[theCell.theIndexPath.row];
        theCell.theSongsCellStyle = SongsCellStyleDelete;
        return;
    }
    theCell.theSong = self.theSearchedSongsArray[theCell.theIndexPath.row];
    if ([self.theChosedSongsArray containsObject:theCell.theSong])
    {
        theCell.theSongsCellStyle = SongsCellStyleCheckmark;
    }
    else
    {
        theCell.theSongsCellStyle = SongsCellStyleNone;
    }
}

- (UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *)tableViewAbstractHeaderView:(ODTableView *)tableView
{
    return [CreatePlayListVCHeaderView new];
}

- (void)tableView:(ODTableView *)tableView setupAbstractHeaderView:(UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *)abstractHeaderView
{
    typeof(CreatePlayListVCHeaderView *) theHeaderView = (id)abstractHeaderView;
    if (!theHeaderView.theSection)
    {
        NSInteger theCount = self.theChosedSongsArray.count;
        theHeaderView.theTitleString = [NSString stringWithFormat:@"Chosed(%zd)", (long)theCount];
    }
    else
    {
        theHeaderView.theTitleString = [NSString stringWithFormat:@"Search(%zd)", (long)self.theSearchedSongsArray.count];
    }
}

- (void)tableView:(ODTableView *)tableView didSelectCell:(UITableViewCell<ODTableViewCellHeightProtocol> *)cell
{
    if (cell.theIndexPath.section)
    {
        typeof(SongsCell *) theCell = (id)cell;
        if ([self.theChosedSongsArray containsObject:theCell.theSong])
        {
            theCell.theSongsCellStyle = SongsCellStyleNone;
            [self.theChosedSongsArray removeObject:theCell.theSong];
        }
        else
        {
            theCell.theSongsCellStyle = SongsCellStyleCheckmark;
            [self.theChosedSongsArray insertObject:theCell.theSong atIndex:0];
        }
        NSRange theRange = NSMakeRange(0, 1);
        NSIndexSet *theSectionIndexSet = [NSIndexSet indexSetWithIndexesInRange:theRange];
        [self.theMainTableView reloadSections:theSectionIndexSet
                             withRowAnimation:UITableViewRowAnimationNone];
        [self methodCheckPlayListSongsCount];
    }
}

#pragma mark - Methods (Public)

#pragma mark - Methods (Private)

- (void)methodSetMainTableViewDefaultOffset
{
    self.theMainTableView.contentInset = UIEdgeInsetsMake(keyNavigationBarHeight.theDeviceValue, 0, 0, 0);
}

- (void)methodChangeSongs
{
    NSArray *theLoadedSongs = [Song methodGetLoadedSongsWithSongsSortType:SongsSortTypeDate
                                                         withSearchString:self.theSearchTextField.text];
    [self.theSearchedSongsArray removeAllObjects];
    [self.theSearchedSongsArray addObjectsFromArray:theLoadedSongs];
    [self.theMainTableView reloadData];
}

- (void)methodCheckPlayListSongsCount
{
    if (!self.theChosedSongsArray.count)
    {
        self.theOkayButton.alpha = 0.3;
    }
    else
    {
        self.theOkayButton.alpha = 1;
    }
}

#pragma mark - Standard Methods

@end






























