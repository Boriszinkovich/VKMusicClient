//
//  BZPageView.h
//  ScrollViewTask
//
//  Created by BZ on 2/18/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger
{
    BZPageViewOrientationHorizontal = 1,
    BZPageViewOrientationVertical,
    BZPageViewOrientationEnumCount = BZPageViewOrientationVertical
} BZPageViewOrientation;

@protocol BZPageViewDelegate;

@interface BZPageView : UIView

@property (nonatomic, weak, nullable) id <BZPageViewDelegate> theDelegate;
@property (nonatomic, assign) BZPageViewOrientation theViewPagingOrientation;
/// default is 0.7
@property (nonatomic, assign) double theAnimationDuration;
/// defaults to 1
@property (nonatomic, assign) double theSpringDamping;
/// default UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction
@property (nonatomic, assign) UIViewAnimationOptions theAnimationOptions;
/// default to NO
@property (nonatomic, assign) BOOL isInfinite;
@property (nonatomic, assign, readonly) NSInteger theCurrentPageIndex;
@property (nonatomic, assign, readonly) NSInteger theCountOfPages;

/// add only afterSetting theWidth and theHeight
- (void)methodAddPage:(UIView * _Nonnull)thePage;
/// works correctly only when isInfinitive set to NO
- (void)methodScrollToViewWithIndex:(NSInteger)theIndex;
- (void)methodScrollToNextPage;
- (void)methodScrollToPreviousPage;

@end

@protocol BZPageViewDelegate<NSObject>

@optional

- (void)pageView:(BZPageView * _Nonnull)theBZPageView
 didScrollToView:(UIView * _Nonnull)theView
         atIndex:(NSInteger)theIndex;

@end































