//
//  BZAnimation.h
//  ScrollViewTask
//
//  Created by BZ on 2/23/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BZAnimation : NSObject

///defaults to nil
@property (nonatomic, strong, nonnull) UIView *theView;
///defaults to 0.7
@property (nonatomic, assign) double theDuration;
///defaults to 0
@property (nonatomic, assign) double theDelay;
///defaults to 1
@property (nonatomic, assign) double theSpringWithDamping;
//defaults to 0
@property (nonatomic, assign) double theInitialSpringVelocity;
/// default UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction
@property (nonatomic, assign) UIViewAnimationOptions theOptions;

- (void)methodSetAnimationBlock:(void (^ _Nonnull)())theAnimationBlock;
- (void)methodSetCompletionBlock:(void (^ _Nullable)(BOOL finished))theCompletionBlock;
- (void)methodStart;

@end






























