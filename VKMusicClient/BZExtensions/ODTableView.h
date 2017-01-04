//
//  ODTableView.h
//  Digitsole
//
//  Created by od1914@my.bristol.ac.uk on 10/27/15.
//  Copyright (c) 2015 Glaglashoes. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ODTableViewCellHeightProtocol <NSObject>

- (double)getCalculatedHeight;
- (void)adjustToAbstractCell:(UITableViewCell <ODTableViewCellHeightProtocol> * _Nullable)abstractCell;

@optional

- (void)didEndDisplaying;

@end

@protocol ODTableViewHeaderFooterHeightProtocol <NSObject>

- (double)getCalculatedHeight;
- (void)adjustToAbstractHeaderFooterView:(UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> * )abstractHeaderFooterView;

@optional

- (void)didEndDisplaying;

@end

@class ODTableView;

@protocol ODTableViewDelegate <NSObject>

- (NSInteger)tableView:(ODTableView *)tableView numberOfCellsInSection:(NSInteger)section;
- (UITableViewCell <ODTableViewCellHeightProtocol> *)tableViewAbstractCell:(ODTableView *)tableView;
- (void)tableView:(ODTableView *)tableView setupAbstractCell:(UITableViewCell <ODTableViewCellHeightProtocol> *)cell;

@optional

- (NSUInteger)tableViewNumberOfSections:(ODTableView *)tableView;
- (UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *)tableViewAbstractHeaderView:(ODTableView *)tableView;
- (UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *)tableViewAbstractFooterView:(ODTableView *)tableView;
- (void)tableView:(ODTableView *)tableView setupAbstractHeaderView:(UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *)abstractHeaderView;
- (void)tableView:(ODTableView *)tableView setupAbstractFooterView:(UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *)abstractFooterView;
- (void)tableView:(ODTableView *)tableView didSelectCell:(UITableViewCell <ODTableViewCellHeightProtocol> *)cell;

- (UITableViewCellEditingStyle)tableView:(ODTableView *)tableView setupEditingStyleForCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(ODTableView *)tableView commitChangesWithEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath;
- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView setupEditActionsForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(ODTableView *)tableView moveCellAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
- (BOOL)tableView:(ODTableView *)tableView canMoveCellAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(ODTableView *)tableView canEditCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(ODTableView *)tableView willBeginEditingCellAtIndexPath:(nonnull NSIndexPath *)indexPath;
- (void)tableView:(ODTableView *)tableView willEndEditingCellAtIndexPath:(nonnull NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(ODTableView *)tableView targetIndexPathForMoveFromCellAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end

@interface ODTableView : UITableView

@property (nonatomic, weak) id <ODTableViewDelegate> theDelegate;
@property (nonatomic, strong, readonly) NSMutableArray *theMutableArray;
@property (nonatomic, strong, readonly) UITableViewCell <ODTableViewCellHeightProtocol> *theAbstractCell;
@property (nonatomic, strong, readonly) UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *theAbstractHeaderView;
@property (nonatomic, strong, readonly) UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *theAbstractFooterView;

@end

@interface UITableViewCell (ODTableViewExtensions)

@property (nonatomic, readonly, assign) BOOL isAbstractCell;
@property (nonatomic, weak) UITableView *theTableView;
@property (nonatomic, strong) NSIndexPath *theIndexPath;

@end

@interface UITableViewHeaderFooterView (ODTableViewExtensions)

@property (nonatomic, readonly, assign) BOOL isAbstractHeaderFooterView;
@property (nonatomic, weak) UITableView *theTableView;
@property (nonatomic, assign) NSInteger theSection;

@end

NS_ASSUME_NONNULL_END




























