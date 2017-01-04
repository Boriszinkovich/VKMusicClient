//
//  NSManagedObject+BZExtensions.m
//  VKMusicClient
//
//  Created by Boris on 3/21/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "NSManagedObject+BZExtensions.h"

@implementation NSManagedObject (BZExtensions)

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

#pragma mark - Setters (Public)

#pragma mark - Getters (Public)

#pragma mark - Setters (Private)

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

#pragma mark - Create Views & Variables

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Delegates ()

#pragma mark - Methods (Public)

- (void)methodSetPrimitiveValue:(id _Nullable)theValue forSelector:(SEL _Nonnull)theSelector
{
    BZAssert([self respondsToSelector:theSelector]);
    [self willChangeValueForKey:sfs(theSelector)];
    [self setPrimitiveValue:theValue forKey:sfs(theSelector)];
    [self didChangeValueForKey:sfs(theSelector)];
}

- (id _Nullable)methodGetPrimitiveValueForSelector:(SEL _Nonnull)theSelector
{
    BZAssert([self respondsToSelector:theSelector]);
    return [self primitiveValueForKey:sfs(theSelector)];
}

#pragma mark - Methods (Private)

#pragma mark - Standard Methods

@end






























