//
//  NSObject+BZExtensions.m
//  ScrollViewTask
//
//  Created by BZ on 2/15/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "NSObject+BZExtensions.h"

#import "BZExtensionsManager.h"

#import <objc/runtime.h>

@implementation NSObject (BZExtensions)

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

#pragma mark - Setters (Public)

- (void)setIsFirstLoad:(BOOL)isFirstLoad
{
    if (self.isFirstLoad == isFirstLoad)
    {
        return;
    }
    objc_setAssociatedObject(self, @selector(isFirstLoad), @(isFirstLoad), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Getters (Public)

- (BOOL)isFirstLoad
{
    NSNumber *theNumber = objc_getAssociatedObject(self, @selector(isFirstLoad));
    if (!theNumber)
    {
        objc_setAssociatedObject(self, @selector(isFirstLoad), @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        theNumber = @(YES);
    }
    return theNumber.boolValue;
}

- (NSInteger)theRetainCount
{
    return CFGetRetainCount((__bridge CFTypeRef) self);
}

#pragma mark - Setters (Private)

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

#pragma mark - Create Views & Variables

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Delegates ()

#pragma mark - Methods (Public)

#pragma mark - Methods (Private)

#pragma mark - Standard Methods

@end






























