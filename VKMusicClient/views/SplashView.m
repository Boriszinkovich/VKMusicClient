//
//  MySplashView.m
//  VKMusicClient
//
//  Created by User on 11.03.16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "SplashView.h"

@implementation SplashView

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self methodInit];
    }
    return self;
}

- (void)methodInit
{
    [self createAllViews];
}

#pragma mark - Setters (Public)

#pragma mark - Getters (Public)

#pragma mark - Setters (Private)

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

#pragma mark - Create Views & Variables

- (void)createAllViews
{
    if (!self.isFirstLoad)
    {
        return;
    }
    self.isFirstLoad = NO;
    
    UIWindow *theWindow = [UIApplication sharedApplication].keyWindow;
    
    self.theWidth = theWindow.theWidth;
    self.theHeight = theWindow.theHeight;
    
    UIImageView *theImageView = [UIImageView new];
    [self addSubview:theImageView];
    theImageView.theHeight = theImageView.superview.theHeight;
    theImageView.theWidth = theImageView.superview.theWidth;
    theImageView.image = [UIImage getImageNamed:@"bg"];
}

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Delegates ()

#pragma mark - Methods (Public)

#pragma mark - Methods (Private)

#pragma mark - Standard Methods

@end






























