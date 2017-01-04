//
//  BZPageView.m
//  ScrollViewTask
//
//  Created by BZ on 2/18/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "BZPageView.h"

#import "BZExtensionsManager.h"

typedef enum : NSUInteger
{
    BZPageViewScrollDirectionLeading = 1,
    BZPageViewScrollDirectionTrailing = 2,
    BZViewSeparatorTypeEnumCount = BZPageViewScrollDirectionTrailing
} BZPageViewScrollDirection;

@interface BZPageView ()

@property (nonatomic, strong, nonnull) NSMutableArray<UIView *> *theViewsArray;
@property (nonatomic, strong, nonnull) NSMutableArray<UIView *> *theHolderViewArray;
@property (nonatomic, strong, nonnull) UIView *theHolderView;
@property (nonatomic, assign) BOOL theIsMoving;
@property (nonatomic, assign) double theStartMovingCenterX;
@property (nonatomic, assign) double theStartMovingCenterY;
@property (nonatomic, assign) NSInteger theCurrentPageIndex;
@property (nonatomic, assign) NSInteger theCountOfPages;

@end

@implementation BZPageView

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self methodInitBZPageView];
    }
    return self;
}

- (void)methodInitBZPageView
{
    self.clipsToBounds = YES;
    _theViewsArray = [NSMutableArray new];
    _theHolderViewArray = [NSMutableArray new];
    _theViewPagingOrientation = BZPageViewOrientationVertical;
    
    UIView *theHolderView = [UIView new];
    _theHolderView = theHolderView;
    [self addSubview:theHolderView];
    theHolderView.clipsToBounds = YES;
    theHolderView.opaque = 0;
    
    _theAnimationDuration = 0.7;
    _theSpringDamping = 1;
    _theAnimationOptions = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction;
    _isInfinite = NO;
    _theCountOfPages = 0;
    
    UIPanGestureRecognizer *thePanGestureRecognizer = [UIPanGestureRecognizer new];
    [thePanGestureRecognizer addTarget:self action:@selector(handleHolderViewPanGestureRecognizer:)];
    thePanGestureRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:thePanGestureRecognizer];
}

#pragma mark - Setters (Public)

- (void)setTheCurrentPageIndex:(NSInteger)theCurrentPageIndex
{
    BZAssert((BOOL)(theCurrentPageIndex >= 0 && theCurrentPageIndex < self.theViewsArray.count))
    if (_theCurrentPageIndex == theCurrentPageIndex)
    {
        return;
    }
    _theCurrentPageIndex = theCurrentPageIndex;
}

- (void)setTheViewPagingOrientation:(BZPageViewOrientation)theViewPagingOrientation
{
    if (_theViewPagingOrientation == theViewPagingOrientation)
    {
        return;
    }
    _theViewPagingOrientation = theViewPagingOrientation;
    BZAssert(theViewPagingOrientation && theViewPagingOrientation <= BZPageViewOrientationEnumCount);
    if (self.theViewsArray.count < 2)
    {
        return;
    }
    [self methodAdjustPageView];
}


- (void)setTheAnimationDuration:(double)theAnimationDuration
{
    BZAssert((BOOL)(theAnimationDuration >= 0));
    if (theAnimationDuration == _theAnimationDuration)
    {
        return;
    }
    _theAnimationDuration = theAnimationDuration;
}

- (void)setTheSpringDamping:(double)theSpringDamping
{
    if (theSpringDamping == _theSpringDamping)
    {
        return;
    }
    _theSpringDamping = theSpringDamping;
}

- (void)setTheAnimationOptions:(UIViewAnimationOptions)theAnimationOptions
{
    if (theAnimationOptions == _theAnimationOptions)
    {
        return;
    }
    _theAnimationOptions = theAnimationOptions;
}

- (void)setisInfinite:(BOOL)isInfinite
{
    if (_isInfinite == isInfinite)
    {
        return;
    }
    _isInfinite = isInfinite;
    
    [self methodAdjustPageView];
}
#pragma mark - Getters (Public)

#pragma mark - Setters (Private)

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

#pragma mark - Create Views & Variables

#pragma mark - Actions

#pragma mark - Gestures

- (void)handleHolderViewPanGestureRecognizer:(UIPanGestureRecognizer *)thePanGestureRecognizer
{
    if (self.theViewsArray.count == 0)
    {
        return;
    }
    CGPoint thePointInView =  [thePanGestureRecognizer translationInView:self];
    CGPoint theVelocityInView = [thePanGestureRecognizer velocityInView:self];
    UIGestureRecognizerState theState = thePanGestureRecognizer.state;
    if (theState == UIGestureRecognizerStateBegan)
    {
        self.theIsMoving = YES;
        self.theStartMovingCenterX = self.theHolderView.theCenterX;
        self.theStartMovingCenterY = self.theHolderView.theCenterY;
        NSLog(@"%f",theVelocityInView.y);
        return;
    }
    if (theState == UIGestureRecognizerStateChanged)
    {
        [BZExtensionsManager methodDispatchAfterSeconds:7 withBlock:^
         {
             [self methodIsNeedToAdjustHolderView];
         }];
        switch (self.theViewPagingOrientation)
        {
            case BZPageViewOrientationHorizontal:
            {
                self.theHolderView.theCenterX  =  (thePointInView.x + self.theStartMovingCenterX);
            }
                break;
                
            case BZPageViewOrientationVertical:
            {
                self.theHolderView.theCenterY = (thePointInView.y + self.theStartMovingCenterY);
            }
                break;
        }
        if (!self.isInfinite)
        {
            return;
        }
        if (![self methodIsNeedToAdjustHolderView])
        {
            return;
        }
        UIView *theCurrentView = self.theViewsArray[self.theCurrentPageIndex];
        NSInteger theCurrentArrayIndex = [self.theHolderViewArray indexOfObject:theCurrentView];
        switch (self.theViewPagingOrientation)
        {
            case BZPageViewOrientationHorizontal:
            {
                if (theVelocityInView.x < 0 && theCurrentArrayIndex == self.theHolderViewArray.count - 1)
                {
                    [self methodAdjustTheInfinitiveHolderViewWithScrollDirection:BZPageViewScrollDirectionLeading];
                }
                else if (theVelocityInView.x > 0 && theCurrentArrayIndex == 0)
                {
                    [self methodAdjustTheInfinitiveHolderViewWithScrollDirection:BZPageViewScrollDirectionTrailing];
                }
            }
                break;
            case BZPageViewOrientationVertical:
            {
                if (theVelocityInView.y < 0 && theCurrentArrayIndex == self.theHolderViewArray.count - 1)
                {
                    [self methodAdjustTheInfinitiveHolderViewWithScrollDirection:BZPageViewScrollDirectionLeading];
                }
                else if (theVelocityInView.y > 0 && theCurrentArrayIndex == 0)
                {
                    [self methodAdjustTheInfinitiveHolderViewWithScrollDirection:BZPageViewScrollDirectionTrailing];
                }
            }
                break;
        }

        return;
    }
    self.theIsMoving = NO;
    
    BZAnimation *theBZAnimation = [BZAnimation new];
    theBZAnimation.theDuration = self.theAnimationDuration;
    theBZAnimation.theOptions = self.theAnimationOptions;
    theBZAnimation.theSpringWithDamping = self.theSpringDamping;
    [theBZAnimation methodSetAnimationBlock:^
    {
        switch (self.theViewPagingOrientation)
        {
            case BZPageViewOrientationHorizontal:
            {
                self.theHolderView.theCenterX += thePointInView.x * sqrt(fabs(theVelocityInView.x) / 2000);
            }
                break;
                
            case BZPageViewOrientationVertical:
            {
                self.theHolderView.theCenterY += thePointInView.y * sqrt (fabs(theVelocityInView.y) / 2000);
            }
                break;
        }
        double theViewCenterX = self.theWidth/2;
        double theViewCenterY  = self.theHeight/2;
        CGPoint theHolderViewPoint = [self convertPoint:CGPointMake(theViewCenterX, theViewCenterY)
                                                 toView:self.theHolderView];
        UIView *theView = [self.theHolderView hitTest:theHolderViewPoint withEvent:nil];
        switch (self.theViewPagingOrientation)
        {
            case BZPageViewOrientationHorizontal:
            {
                if (!theView)
                {
                    double theScrollInset = self.theHolderView.theCenterX - self.theStartMovingCenterX;
                    if (theScrollInset < 0)
                    {
                        self.theHolderView.theCenterX += (theHolderViewPoint.x - self.theHolderViewArray.lastObject.theCenterX);
                        theView = self.theHolderViewArray.lastObject;
                        
//                        [self methodAdjustTheInfinitiveHolderViewWithScrollDirection:BZPageViewScrollDirectionTrailing];
                    }
                    else
                    {
                        self.theHolderView.theCenterX += (theHolderViewPoint.x - self.theHolderViewArray.firstObject.theCenterX);
                        theView = self.theHolderViewArray.firstObject;
                        
//                        [self methodAdjustTheInfinitiveHolderViewWithScrollDirection:BZPageViewScrollDirectionLeading];
                    }
                }
                else
                {
                    self.theHolderView.theCenterX += (theHolderViewPoint.x - theView.theCenterX);
                }
                self.theCurrentPageIndex = [self getIndexForView:theView];
                if (self.theDelegate)
                {
                    [self.theDelegate pageView:self didScrollToView:theView atIndex:self.theCurrentPageIndex];
                }
            }
                break;
                
            case BZPageViewOrientationVertical:
            {
                if (!theView)
                {
                    double theScrollInset = self.theHolderView.theCenterY - self.theStartMovingCenterY;
                    if (theScrollInset < 0)
                    {
                        self.theHolderView.theCenterY +=
                        (theHolderViewPoint.y - self.theHolderViewArray.lastObject.theCenterY);
                        theView = self.theHolderViewArray.lastObject;
                    }
                    else
                    {
                        self.theHolderView.theCenterY += (theHolderViewPoint.y - self.theHolderViewArray.firstObject.theCenterY);
                        theView = self.theHolderViewArray.firstObject;
                    }
                }
                else
                {
                    self.theHolderView.theCenterY += (theHolderViewPoint.y - theView.theCenterY);
                }
                self.theCurrentPageIndex = [self getIndexForView:theView];
                if (self.theDelegate)
                {
                    [self.theDelegate pageView:self didScrollToView:theView atIndex:self.theCurrentPageIndex];
                }
            }
                break;
        }
    }];
    [theBZAnimation methodStart];
}

#pragma mark - Delegates ()

#pragma mark - Methods (Public)

- (void)methodAddPage:(UIView * _Nonnull)thePage
{
    BZAssert(thePage);
    if ([self.theViewsArray containsObject:thePage])
    {
        return;
    }
    [self.theHolderView addSubview:thePage];
    [self.theViewsArray addObject:thePage];
    [self methodAdjustHolderView];
    if (self.theViewsArray.count == 1)
    {
        thePage.theCenterX = self.theWidth/2;
        thePage.theCenterY = self.theHeight/2;
    }
    else
    {
        UIView *theLastAddedView = self.theViewsArray[self.theViewsArray.count - 2];
        switch (self.theViewPagingOrientation)
        {
            case BZPageViewOrientationHorizontal:
            {
                thePage.theCenterY = theLastAddedView.theCenterY;
                thePage.theMinX =  theLastAddedView.theMaxX;
            }
                break;
            case BZPageViewOrientationVertical:
            {
                thePage.theCenterX =  theLastAddedView.theCenterX;
                thePage.theCenterY = theLastAddedView.theCenterY + theLastAddedView.theHeight/2 + thePage.theHeight/2;
            }
                break;
        }
    }
    
    self.theCountOfPages++;
    if (self.isInfinite)
    {
        if (self.theViewsArray.count == 1)
        {
            [self.theHolderViewArray addObject:thePage];
            return;
        }
        UIView *theLastView = self.theViewsArray[self.theViewsArray.count-2];
        int theLastViewIndexInHolderViewArray = 0;
        for (int i = 0; i < self.theHolderViewArray.count; i++)
        {
            if (isEqual(theLastView, self.theHolderViewArray[i]))
            {
                theLastViewIndexInHolderViewArray = i;
                break;
            }
        }
        [self.theHolderViewArray insertObject:thePage atIndex:theLastViewIndexInHolderViewArray + 1];
        return;
    }
    [self.theHolderViewArray addObject:thePage];
}

- (void)methodScrollToViewWithIndex:(NSInteger)theIndex
{
    BZAssert(self.isInfinite);
    [self methodPrivateScrollToViewWithIndex:theIndex];
}

- (void)methodScrollToNextPage
{
    if (!self.isInfinite)
    {
        if (self.theCurrentPageIndex == self.theCountOfPages - 1)
        {
            return;
        }
    }
    UIView *theCurrentView = self.theViewsArray[self.theCurrentPageIndex];
    NSInteger theHolderViewIndex = [self.theHolderViewArray indexOfObject:theCurrentView];
    if (theHolderViewIndex == self.theCountOfPages - 1)
    {
        if (self.isInfinite)
        {
            [self methodAdjustTheInfinitiveHolderViewWithScrollDirection:BZPageViewScrollDirectionLeading];
            theHolderViewIndex = [self.theHolderViewArray indexOfObject:theCurrentView];
        }
    }
    [self methodPrivateScrollToViewWithIndex:theHolderViewIndex + 1];
    theCurrentView = self.theHolderViewArray[theHolderViewIndex + 1];
    self.theCurrentPageIndex  = [self.theViewsArray indexOfObject:theCurrentView];
    if (self.theDelegate)
    {
        [self.theDelegate pageView:self didScrollToView:theCurrentView atIndex:self.theCurrentPageIndex];
    }
}

- (void)methodScrollToPreviousPage
{
    if (!self.isInfinite)
    {
        if (self.theCurrentPageIndex == self.theCountOfPages - 1)
        {
            return;
        }
    }
    UIView *theCurrentView = self.theViewsArray[self.theCurrentPageIndex];
    NSInteger theHolderViewIndex = [self.theHolderViewArray indexOfObject:theCurrentView];
    if (theHolderViewIndex == 0)
    {
        if (self.isInfinite)
        {
            [self methodAdjustTheInfinitiveHolderViewWithScrollDirection:BZPageViewScrollDirectionTrailing];
            theHolderViewIndex = [self.theHolderViewArray indexOfObject:theCurrentView];
        }
    }
    [self methodPrivateScrollToViewWithIndex:theHolderViewIndex - 1];
    theCurrentView = self.theHolderViewArray[theHolderViewIndex - 1];
    self.theCurrentPageIndex  = [self.theViewsArray indexOfObject:theCurrentView];
    
    if (self.theDelegate)
    {
        [self.theDelegate pageView:self didScrollToView:theCurrentView atIndex:self.theCurrentPageIndex];
    }
}

#pragma mark - Methods (Private)

- (BOOL)methodIsNeedToAdjustHolderView
{
    UIView *theFirstView = self.theHolderViewArray.firstObject;
    UIView *theLastView = self.theHolderViewArray.lastObject;
    switch (self.theViewPagingOrientation)
    {
        case BZPageViewOrientationHorizontal:
        {
            CGPoint theFirstPoint = [self convertPoint:CGPointMake(theFirstView.theMinX, theFirstView.theHeight/2)
                                              fromView:self.theHolderView];
            CGPoint theLastPoint = [self convertPoint:CGPointMake(theLastView.theMaxX, theFirstView.theHeight/2)
                                             fromView:self.theHolderView];
            if (theFirstPoint.x > 0)
            {
                return YES;
            }
            if (theLastPoint.x < self.theWidth)
            {
                return YES;
            }
        }
            break;
        case BZPageViewOrientationVertical:
        {
            CGPoint theFirstPoint = [self convertPoint:CGPointMake(theFirstView.theWidth/2, theFirstView.theMinY)
                      fromView:self.theHolderView];
            CGPoint theLastPoint = [self convertPoint:CGPointMake(theFirstView.theWidth/2, theLastView.theMaxY)
                                              fromView:self.theHolderView];
            if (theFirstPoint.y > 0)
            {
                return YES;
            }
            if (theLastPoint.y < self.theHeight)
            {
                return YES;
            }
        }
            break;
    }
    return NO;
}

- (void)methodAdjustHolderView
{
    if (self.theViewsArray.count == 0)
    {
          return;
    }
    switch (self.theViewPagingOrientation)
    {
        case BZPageViewOrientationHorizontal:
        {
            self.theHolderView.theHeight = self.theHeight;
            double theWidth = self.theWidth/2 - self.theViewsArray.firstObject.theWidth / 2;
            for (int i = 0; i < self.theViewsArray.count; i++)
            {
                theWidth += self.theViewsArray[i].theWidth;
            }
            if (theWidth > self.theWidth)
            {
                self.theHolderView.theWidth = theWidth;
            }
            else
            {
                self.theHolderView.theWidth = self.theWidth;
            }
        }
            break;
            
        case BZPageViewOrientationVertical:
        {
            self.theHolderView.theWidth = self.theWidth;
            double theHeight = self.theHeight/2 - self.theViewsArray.firstObject.theHeight / 2;
            for (int i = 0; i < self.theViewsArray.count; i++)
            {
                theHeight += self.theViewsArray[i].theHeight;
            }
            if (theHeight > self.theHeight)
            {
                self.theHolderView.theHeight = theHeight;
            }
            else
            {
                self.theHolderView.theHeight = self.theHeight;
            }
            NSLog(@"%f %f",self.theHolderView.theWidth,self.theHolderView.theHeight);
        }
            break;
    }
}

- (void)methodAdjustPageView
{
    self.theHolderView.theMinX = 0;
    self.theHolderView.theMinY = 0;
    NSArray *theSubviews = self.theViewsArray;
    for (UIView *theView in theSubviews)
    {
        [theView removeFromSuperview];
    }
    NSArray *theViewsArray = self.theViewsArray.copy;
    self.theCountOfPages = 0;
    self.theCurrentPageIndex = 0;
    [self.theViewsArray removeAllObjects];
    [self.theHolderViewArray removeAllObjects];
    for (int i = 0; i < theViewsArray.count; i++)
    {
        [self methodAddPage:theViewsArray[i]];
    }
    if (self.theDelegate)
    {
        [self.theDelegate pageView:self didScrollToView:self.theViewsArray.firstObject atIndex:0];
    }
}

- (NSInteger)getIndexForView:(UIView * _Nonnull)theView
{
    BZAssert(theView);
    if (self.theViewsArray.count == 0)
    {
        return -1;
    }
    for (int i = 0; i < self.theViewsArray.count; i++)
    {
        UIView *theCurrentView = self.theViewsArray[i];
        if (isEqual(theView, theCurrentView))
        {
            return i;
        }
    }
    return -1;
}

- (void)methodAdjustTheInfinitiveHolderViewWithScrollDirection:(BZPageViewScrollDirection)theBZPageViewScrollDirection
{
    if (self.theHolderViewArray.count == 1)
    {
        return;
    }
    switch (self.theViewPagingOrientation)
    {
        case BZPageViewOrientationHorizontal:
        {
            switch (theBZPageViewScrollDirection)
            {
                case BZPageViewScrollDirectionLeading:
                {
                    UIView *theAddedView = self.theHolderViewArray.firstObject;
                    self.theHolderView.theMinX = self.theHolderView.theMinX + theAddedView.theWidth;
                    self.theStartMovingCenterX = self.theHolderView.theCenterX;
                    self.theStartMovingCenterY = self.theHolderView.theCenterY;
                    for (int i = 0; i < self.theHolderViewArray.count; i++)
                    {
                        self.theHolderViewArray[i].theMinX -= theAddedView.theWidth;
                    }
                    UIView *theLastArrayView = self.theHolderViewArray.lastObject;
                    theAddedView.theMinX =  theLastArrayView.theMaxX;
                    [self.theHolderViewArray addObject:theAddedView];
                    [self.theHolderViewArray removeObjectAtIndex:0];
                }
                    break;
                case BZPageViewScrollDirectionTrailing:
                {
                    UIView *theAddedView = self.theHolderViewArray.lastObject;
                    self.theHolderView.theMinX = self.theHolderView.theMinX - theAddedView.theWidth;
                    self.theStartMovingCenterX = self.theHolderView.theCenterX;
                    self.theStartMovingCenterY = self.theHolderView.theCenterY;
                    for (int i = 0; i < self.theHolderViewArray.count; i++)
                    {
                        self.theHolderViewArray[i].theMinX += theAddedView.theWidth;
                    }
                    UIView *theFirstArrayView = self.theHolderViewArray.firstObject;
                    theAddedView.theMaxX =  theFirstArrayView.theMinX;
                    [self.theHolderViewArray insertObject:theAddedView atIndex:0];
                    [self.theHolderViewArray removeObjectAtIndex:self.theHolderViewArray.count - 1];
                }
                    break;
            }
        }
            break;
            
        case BZPageViewOrientationVertical:
        {
            switch (theBZPageViewScrollDirection)
            {
                case BZPageViewScrollDirectionLeading:
                {
                    UIView *theAddedView = self.theHolderViewArray.firstObject;
                    self.theHolderView.theMinY = self.theHolderView.theMinY + theAddedView.theHeight;
                    self.theStartMovingCenterX = self.theHolderView.theCenterX;
                    self.theStartMovingCenterY = self.theHolderView.theCenterY;
                    for (int i = 0; i < self.theHolderViewArray.count; i++)
                    {
                        self.theHolderViewArray[i].theMinY -= theAddedView.theHeight;
                    }
                    UIView *theLastArrayView = self.theHolderViewArray.lastObject;
                    theAddedView.theMinY =  theLastArrayView.theMaxY;
                    [self.theHolderViewArray addObject:theAddedView];
                    [self.theHolderViewArray removeObjectAtIndex:0];
                }
                    break;
                case BZPageViewScrollDirectionTrailing:
                {
                    UIView *theAddedView = self.theHolderViewArray.lastObject;
                    self.theHolderView.theMinY = self.theHolderView.theMinY - theAddedView.theHeight;
                    
                    self.theStartMovingCenterX = self.theHolderView.theCenterX;
                    self.theStartMovingCenterY = self.theHolderView.theCenterY;
                    for (int i = 0; i < self.theHolderViewArray.count; i++)
                    {
                        self.theHolderViewArray[i].theMinY += theAddedView.theHeight;
                    }
                    
                    UIView *theFirstArrayView = self.theHolderViewArray.firstObject;
                    theAddedView.theMaxY =  theFirstArrayView.theMinY;
                    
                    [self.theHolderViewArray insertObject:theAddedView atIndex:0];
                    [self.theHolderViewArray removeObjectAtIndex:self.theHolderViewArray.count - 1];
                }
                    break;
            }
        }
            break;
    }
}

- (void)methodPrivateScrollToViewWithIndex:(NSInteger)theIndex
{
    UIView *theCurrentView = self.theViewsArray[self.theCurrentPageIndex];
    NSInteger theHolderViewCurrentIndex = [self.theHolderViewArray indexOfObject:theCurrentView];
    BZAssert((BOOL)(theIndex >= 0 && (self.theViewsArray.count - 1 >= theIndex)));
    if (theIndex == theHolderViewCurrentIndex)
    {
        return;
    }
    self.theCurrentPageIndex = theIndex;
    BZAnimation *theAnimation = [BZAnimation new];
    theAnimation.theDelay = self.theAnimationDuration;
    theAnimation.theSpringWithDamping = self.theSpringDamping;
    theAnimation.theOptions = self.theAnimationOptions;
    theAnimation.theDelay = 0;
    [theAnimation methodSetAnimationBlock:^
     {
         double theViewCenterX = self.theWidth/2;
         double theViewCenterY  = self.theHeight/2;
         CGPoint theHolderViewPoint = [self convertPoint:CGPointMake(theViewCenterX, theViewCenterY)
                                                  toView:self.theHolderView];
         
         switch (self.theViewPagingOrientation)
         {
             case BZPageViewOrientationHorizontal:
             {
                 self.theHolderView.theCenterX +=
                 (theHolderViewPoint.x - self.theHolderViewArray[theIndex].theCenterX);
             }
                 break;
                 
             case BZPageViewOrientationVertical:
             {
                 self.theHolderView.theCenterY +=
                 (theHolderViewPoint.y - self.theHolderViewArray[theIndex].theCenterY);
             }
                 break;
         }
     }];
    [theAnimation methodStart];
}

#pragma mark - Standard Methods

@end































