//
//  BZAnimation.m
//  ScrollViewTask
//
//  Created by BZ on 2/23/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "BZAnimation.h"

#import "BZExtensionsManager.h"

@interface BZAnimation ()

@property (nonatomic, copy, nonnull) void (^ theMainAnimationBlock)();
@property (nonatomic, copy, nullable) void (^ theMainCompletionBlock)(BOOL finished);

@end

@implementation BZAnimation

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self methodInitBZAnimation];
    }
    return self;
}

- (void)methodInitBZAnimation
{
    _theDuration = 0.7;
    _theDelay = 0;
    _theSpringWithDamping = 1;
    _theInitialSpringVelocity = 0;
    _theOptions = UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction;
}

#pragma mark - Setters (Public)

- (void)setTheView:(UIView * _Nonnull)theView
{
    BZAssert(theView);
    if (isEqual(theView, _theView))
    {
        return;
    }
    _theView = theView;
}

- (void)setTheDelay:(double)theDelay
{
    BZAssert((BOOL)(theDelay >= 0));
    if (theDelay == _theDelay)
    {
        return;
    }
    _theDelay = theDelay;
}

- (void)setTheDuration:(double)theDuration
{
    BZAssert((BOOL)(theDuration >= 0))
    if (theDuration == _theDuration)
    {
        return;
    }
    _theDuration = theDuration;
}

- (void)setTheInitialSpringVelocity:(double)theInitialSpringVelocity
{
    if (theInitialSpringVelocity == _theInitialSpringVelocity)
    {
        return;
    }
    _theInitialSpringVelocity = theInitialSpringVelocity;
}

- (void)setTheSpringWithDamping:(double)theSpringWithDamping
{
    BZAssert((BOOL)(theSpringWithDamping >= 0 && theSpringWithDamping <= 1));
    if (theSpringWithDamping == _theSpringWithDamping)
    {
        return;
    }
    _theSpringWithDamping = theSpringWithDamping;
}

- (void)setTheOptions:(UIViewAnimationOptions)theOptions
{
    if (theOptions == _theOptions)
    {
        return;
    }
    _theOptions = theOptions;
}

#pragma mark - Getters (Public)

#pragma mark - Setters (Private)

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

#pragma mark - Create Views & Variables

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Delegates ()

#pragma mark - Methods (Public)

- (void)methodSetAnimationBlock:(void (^ _Nonnull)())theAnimationBlock
{
    BZAssert(theAnimationBlock);
    self.theMainAnimationBlock = theAnimationBlock;
}

- (void)methodSetCompletionBlock:(void (^ _Nullable)(BOOL finished))theCompletionBlock;
{
    self.theMainCompletionBlock = theCompletionBlock;
}

- (void)methodStart
{
    BZAssert(self.theMainAnimationBlock);
    if (self.theView)
    {
        [UIView transitionWithView:self.theView
                          duration:self.theDuration
                           options:self.theOptions
                        animations:^
         {
             self.theMainAnimationBlock();
         }
                        completion:^(BOOL finished)
         {
             if (self.theMainCompletionBlock)
             {
                 self.theMainCompletionBlock(finished);
             }
         }];
        return;
    }
    UIView *theFakeView = [UIView new];
    theFakeView.alpha = 1;
    [UIView animateWithDuration:0
                     animations:^
     {
         theFakeView.alpha = 0;

     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:self.theDuration
                               delay:self.theDelay
              usingSpringWithDamping:self.theSpringWithDamping
               initialSpringVelocity:self.theInitialSpringVelocity
                             options:self.theOptions
                          animations:^
          {
              self.theMainAnimationBlock();
          }
                          completion:^(BOOL finished)
          {
              if (self.theMainCompletionBlock)
              {
                  self.theMainCompletionBlock(finished);
              }
          }];
     }];
}

#pragma mark - Methods (Private)

#pragma mark - Standard Methods

@end






























