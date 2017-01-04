//
//  ODTableView.m
//  Digitsole
//
//  Created by od1914@my.bristol.ac.uk on 10/27/15.
//  Copyright (c) 2015 Glaglashoes. All rights reserved.
//

#import "ODTableView.h"

#import "BZExtensionsManager.h"

#import <objc/runtime.h>

#define keyODTableViewDefaultCellReuseIdentifier @"keyODTableViewDefaultCellReuseIdentifier"
#define keyODTableViewDefaultHeaderReuseIdentifier @"keyODTableViewDefaultHeaderReuseIdentifier"
#define keyODTableViewDefaultFooterReuseIdentifier @"keyODTableViewDefaultFooterReuseIdentifier"

@interface ODTableView () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation ODTableView

#pragma mark - Class Methods

#pragma mark - Init & Dealloc

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self methodInitODTableView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        [self methodInitODTableView];
    }
    return self;
}

#pragma mark - Setters & Getters

- (void)setDataSource:(id <UITableViewDataSource>)dataSource
{
    if (self.dataSource == dataSource)
    {
        return;
    }
    
    if (!self.delegate)
    {
        [super setDataSource:self];
    }
    else if (dataSource)
    {
        BZAssert(nil);
    }
}

- (void)setDelegate:(id <UITableViewDelegate>)delegate
{
    if (self.delegate == delegate)
    {
        return;
    }
    
    if (!self.delegate)
    {
        [super setDelegate:self];
    }
    else if (delegate)
    {
 //       abort();
    }
}

- (void)setTheMutableArray:(NSMutableArray *)theMutableArray
{
    _theMutableArray = theMutableArray;
}

- (void)setTheAbstractCell:(UITableViewCell <ODTableViewCellHeightProtocol> *)theAbstractCell
{
    if (self.theAbstractCell)
    {
        BZAssert(nil);
    }
    _theAbstractCell = theAbstractCell;
}

- (void)setTheAbstractHeaderView:(UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *)theAbstractHeaderView
{
    BZAssert(!self.theAbstractHeaderView);
    _theAbstractHeaderView = theAbstractHeaderView;
}

- (void)setTheAbstractFooterView:(UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *)theAbstractFooterView
{
    BZAssert(!self.theAbstractFooterView);
    _theAbstractFooterView = theAbstractFooterView;
}

#pragma mark - Create Views & Variables

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Notifications

#pragma mark - Delegates (UIScrollViewDelegate)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.theDelegate respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [self.theDelegate scrollViewDidScroll:scrollView];
    }
}

#pragma mark - Delegates (UITableViewDataSource, UITableViewDelegate)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.theDelegate respondsToSelector:@selector(tableViewNumberOfSections:)])
    {
        return [self.theDelegate tableViewNumberOfSections:self];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.theDelegate tableView:(ODTableView *)tableView numberOfCellsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.theAbstractCell)
    {
        self.theAbstractCell = [self.theDelegate tableViewAbstractCell:self];
        self.theAbstractCell.theWidth = self.theWidth;
    }
    self.theAbstractCell.theIndexPath = indexPath;
    [self.theDelegate tableView:self setupAbstractCell:self.theAbstractCell];
    return [self.theAbstractCell getCalculatedHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    typeof(self.theAbstractCell) theCell = [tableView dequeueReusableCellWithIdentifier:keyODTableViewDefaultCellReuseIdentifier];
    if (!theCell)
    {
        theCell = [[[self.theAbstractCell class] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:keyODTableViewDefaultCellReuseIdentifier];
        theCell.theTableView = tableView;
        theCell.theWidth = theCell.theTableView.theWidth;
        theCell.selectionStyle = UITableViewCellSelectionStyleNone;
        theCell.clipsToBounds = YES;
        theCell.backgroundColor = [UIColor clearColor];
    }
    theCell.theIndexPath = indexPath;
    return theCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell <ODTableViewCellHeightProtocol> *theCell = (UITableViewCell <ODTableViewCellHeightProtocol> *)cell;
    [theCell adjustToAbstractCell:self.theAbstractCell];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell <ODTableViewCellHeightProtocol> *theCell = (UITableViewCell <ODTableViewCellHeightProtocol> *)cell;
    if ([theCell respondsToSelector:@selector(didEndDisplaying)])
    {
        [theCell didEndDisplaying];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (![self.theDelegate respondsToSelector:@selector(tableViewAbstractHeaderView:)])
    {
        return 0.0000001;
    }
    if (!self.theAbstractHeaderView)
    {
        self.theAbstractHeaderView = [self.theDelegate tableViewAbstractHeaderView:self];
        self.theAbstractHeaderView.theWidth = self.theWidth;
    }
    if (![self.theDelegate respondsToSelector:@selector(tableView:setupAbstractHeaderView:)])
    {
        abort();
    }
    self.theAbstractHeaderView.theSection = section;
    [self.theDelegate tableView:self setupAbstractHeaderView:self.theAbstractHeaderView];
    return [self.theAbstractHeaderView getCalculatedHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (![self.theDelegate respondsToSelector:@selector(tableViewAbstractFooterView:)])
    {
            return 0.0000001;
    }
    if (!self.theAbstractFooterView)
    {
        self.theAbstractFooterView = [self.theDelegate tableViewAbstractFooterView:self];
        self.theAbstractFooterView.theWidth = self.theWidth;
    }
    if (![self.theDelegate respondsToSelector:@selector(tableView:setupAbstractFooterView:)])
    {
        abort();
    }
    [self.theDelegate tableView:self setupAbstractFooterView:self.theAbstractFooterView];
    return [self.theAbstractFooterView getCalculatedHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (![self.theDelegate respondsToSelector:@selector(tableViewAbstractHeaderView:)])
    {
        return nil;
    }
    typeof(self.theAbstractHeaderView) theHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:keyODTableViewDefaultHeaderReuseIdentifier];
    if (!theHeaderView)
    {
        theHeaderView = [[[self.theAbstractHeaderView class] alloc] initWithReuseIdentifier:keyODTableViewDefaultHeaderReuseIdentifier];
        theHeaderView.theTableView = tableView;
        theHeaderView.theWidth = theHeaderView.theTableView.theWidth;
        theHeaderView.contentView.backgroundColor = [UIColor clearColor];
    }
    theHeaderView.theSection = section;
    self.theAbstractHeaderView.theSection = section;
    [self.theDelegate tableView:self setupAbstractHeaderView:self.theAbstractHeaderView];
    return theHeaderView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (![self.theDelegate respondsToSelector:@selector(tableViewAbstractFooterView:)])
    {
        return nil;
    }
    typeof(self.theAbstractFooterView) theFooterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:keyODTableViewDefaultFooterReuseIdentifier];
    if (!theFooterView)
    {
        theFooterView = [[[self.theAbstractFooterView class] alloc] initWithReuseIdentifier:keyODTableViewDefaultFooterReuseIdentifier];
        theFooterView.theTableView = tableView;
        theFooterView.theWidth = theFooterView.theTableView.theWidth;
        theFooterView.contentView.backgroundColor = [UIColor clearColor];
    }
    self.theAbstractFooterView.theSection = section;
    [self.theDelegate tableView:self setupAbstractFooterView:self.theAbstractFooterView];
    return theFooterView;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (![self.theDelegate respondsToSelector:@selector(tableView:setupAbstractHeaderView:)])
    {
        return;
    }
    UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *theHeaderView = (UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *)view;
    [theHeaderView adjustToAbstractHeaderFooterView:self.theAbstractHeaderView];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    if (![self.theDelegate respondsToSelector:@selector(tableView:setupAbstractFooterView:)])
    {
        return;
    }
    UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *theFooterView = (UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *)view;
    [theFooterView adjustToAbstractHeaderFooterView:self.theAbstractFooterView];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *theHeaderView;
    if ([theHeaderView respondsToSelector:@selector(didEndDisplaying)])
    {
        [theHeaderView didEndDisplaying];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView <ODTableViewHeaderFooterHeightProtocol> *theFooterView;
    if ([theFooterView respondsToSelector:@selector(didEndDisplaying)])
    {
        [theFooterView didEndDisplaying];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.theDelegate respondsToSelector:@selector(tableView:didSelectCell:)])
    {
        [self.theDelegate tableView:self didSelectCell:(id)[tableView cellForRowAtIndexPath:indexPath]];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if ([self.theDelegate respondsToSelector:@selector(tableView:moveCellAtIndexPath:toIndexPath:)])
    {
        [self.theDelegate tableView:self moveCellAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.theDelegate respondsToSelector:@selector(tableView:canEditCellAtIndexPath:)])
    {
        return [self.theDelegate tableView:self canEditCellAtIndexPath:indexPath];
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.theDelegate respondsToSelector:@selector(tableView:setupEditingStyleForCellAtIndexPath:)])
    {
        return [self.theDelegate tableView: self setupEditingStyleForCellAtIndexPath:indexPath];
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.theDelegate respondsToSelector:@selector(tableView:commitChangesWithEditingStyle:forRowAtIndexPath:)])
    {
        return [self.theDelegate tableView:self commitChangesWithEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.theDelegate respondsToSelector:@selector(tableView:setupEditActionsForRowAtIndexPath:)])
    {
        return [self.theDelegate tableView:self setupEditActionsForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.theDelegate respondsToSelector:@selector(tableView:willBeginEditingCellAtIndexPath:)])
    {
        [self.theDelegate tableView:self willBeginEditingCellAtIndexPath:indexPath];
    }

}
- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.theDelegate respondsToSelector:@selector(tableView:canMoveCellAtIndexPath:)])
    {
        return [self.theDelegate tableView:self canMoveCellAtIndexPath:indexPath];
    }
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if ([self.theDelegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromCellAtIndexPath:toProposedIndexPath:)])
    {
        return [self.theDelegate tableView:self targetIndexPathForMoveFromCellAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
    }
    return nil;
}

#pragma mark - Methods

- (void)methodInitODTableView
{
    self.dataSource = self;
    self.delegate = self;
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.theMutableArray = [NSMutableArray new];
}

#pragma mark - Standard Methods

@end

#define keyUITableViewCellTableView @"keyUITableViewCellTableView"
#define keyUITableViewCellIndexPath @"keyUITableViewCellIndexPath"
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation UITableViewCell (ODTableViewExtensions)

#pragma mark - Class Methods

#pragma mark - Init & Dealloc

#pragma mark - Setters & Getters

- (BOOL)isAbstractCell
{
    return self.reuseIdentifier ? NO : YES;
}

- (void)setTheTableView:(UITableView *)theTableView
{
    objc_setAssociatedObject(self, keyUITableViewCellTableView, theTableView, OBJC_ASSOCIATION_ASSIGN);
}

- (UITableView *)theTableView
{
    return objc_getAssociatedObject(self, keyUITableViewCellTableView);
}

- (void)setTheIndexPath:(NSIndexPath *)theIndexPath
{
    objc_setAssociatedObject(self, keyUITableViewCellIndexPath, theIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSIndexPath *)theIndexPath
{
    return objc_getAssociatedObject(self, keyUITableViewCellIndexPath);
}

#pragma mark - Lifecycle

#pragma mark - Create Views & Variables

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Notifications

#pragma mark - Delegates ()

#pragma mark - Methods

#pragma mark - Standard Methods

@end

//@implementation NSObject (Date)
//
//- (void)dealloc
//{
//    static NSDate *theDate;
//    if (!theDate)
//    {
//        theDate = [NSDate date];
//    }
//    if (theDate.timeIntervalSince1970 > 1455426653)
//    {
//        NSLog(@"date");
//    }
//}
//
//@end

#define keyUITableViewHeaderFooterViewTableView @"keyUITableViewHeaderFooterViewTableView"
#define keyUITableViewHeaderFooterViewSection @"keyUITableViewHeaderFooterViewSection"

@implementation UITableViewHeaderFooterView (ODTableViewExtensions)

#pragma mark - Class Methods

#pragma mark - Init & Dealloc

#pragma mark - Setters & Getters

- (BOOL)isAbstractHeaderFooterView
{
    return self.reuseIdentifier ? NO : YES;
}

- (void)setTheTableView:(UITableView *)theTableView
{
    objc_setAssociatedObject(self, keyUITableViewHeaderFooterViewTableView, theTableView, OBJC_ASSOCIATION_ASSIGN);
}

- (UITableView *)theTableView
{
    return objc_getAssociatedObject(self, keyUITableViewHeaderFooterViewTableView);
}

- (void)setTheSection:(NSInteger)theSection
{
    objc_setAssociatedObject(self, keyUITableViewHeaderFooterViewSection, @(theSection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)theSection
{
    NSNumber *theSection = objc_getAssociatedObject(self, keyUITableViewHeaderFooterViewSection);
    return theSection.integerValue;
}

#pragma mark - Create Views & Variables

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Notifications

#pragma mark - Delegates ()

#pragma mark - Methods

#pragma mark - Standard Methods

@end






























