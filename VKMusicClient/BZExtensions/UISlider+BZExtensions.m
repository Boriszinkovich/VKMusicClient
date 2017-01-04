//
//  UISlider+BZExtensions.m
//  VKMusicClient
//
//  Created by Boris on 3/23/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "UISlider+BZExtensions.h"

#import "BZExtensionsManager.h"

#import <objc/runtime.h>

@interface UISlider (BZExtensions_private) <UIGestureRecognizerDelegate>

@property (nonatomic, strong, nonnull, readonly) UIPanGestureRecognizer *thePanGestureRecognizer;

@end

@implementation UISlider (BZExtensions)

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

#pragma mark - Setters (Public)

- (void)setIsPanGestureEnabled:(BOOL)isPanGestureEnabled
{
    if (self.isPanGestureEnabled == isPanGestureEnabled)
    {
        return;
    }
    objc_setAssociatedObject(self, @selector(isPanGestureEnabled), @(isPanGestureEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (isPanGestureEnabled)
    {
        [self addGestureRecognizer:self.thePanGestureRecognizer];
    }
    else
    {
        [self removeGestureRecognizer:self.thePanGestureRecognizer];
    }
}

#pragma mark - Getters (Public)

- (BOOL)isPanGestureEnabled
{
    NSNumber *theNumber = objc_getAssociatedObject(self, @selector(isPanGestureEnabled));
    if (!theNumber)
    {
        objc_setAssociatedObject(self, @selector(isPanGestureEnabled), @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        theNumber = @(NO);
    }
    return theNumber.boolValue;
}

#pragma mark - Setters (Private)

#pragma mark - Getters (Private)

- (UIPanGestureRecognizer * _Nonnull)thePanGestureRecognizer
{
    UIPanGestureRecognizer *theCurrentPanGestureRecognizer = objc_getAssociatedObject(self, @selector(thePanGestureRecognizer));
    if (!theCurrentPanGestureRecognizer)
    {
        UIPanGestureRecognizer *theNewPanGestureRecognizer = [UIPanGestureRecognizer new];
        theCurrentPanGestureRecognizer = theNewPanGestureRecognizer;
        theCurrentPanGestureRecognizer.delegate = self;
        [theCurrentPanGestureRecognizer addTarget:self action:@selector(handleHolderViewPanGestureRecognizer:)];
        objc_setAssociatedObject(self, @selector(thePanGestureRecognizer), theCurrentPanGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return theCurrentPanGestureRecognizer;
}

#pragma mark - Lifecycle

#pragma mark - Create Views & Variables

#pragma mark - Actions

#pragma mark - Gestures

- (void)handleHolderViewPanGestureRecognizer:(UIPanGestureRecognizer *)thePanGestureRecognizer
{
    CGPoint thePointInView =  [thePanGestureRecognizer locationInView:self];
    double thePointXValue =  thePointInView.x;
    double theNewSliderValue = self.minimumValue + (self.maximumValue - self.minimumValue) * thePointXValue / self.theWidth;
    self.value = theNewSliderValue;
    UIGestureRecognizerState theState = thePanGestureRecognizer.state;
    if (theState == UIGestureRecognizerStateBegan)
    {
        [self sendActionsForControlEvents:UIControlEventTouchDown];
    }
    else if (theState == UIGestureRecognizerStateChanged)
    {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    else
    {
        [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - Delegates (UIGestureRecognizerDelegate)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Methods (Public)

#pragma mark - Methods (Private)

#pragma mark - Standard Methods

@end






























