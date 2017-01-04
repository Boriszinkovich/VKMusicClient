//
//  NSDictionary+BZExtensions.m
//  ScrollViewTask
//
//  Created by BZ on 2/16/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "NSDictionary+BZExtensions.h"

#import "BZExtensionsManager.h"

@implementation NSDictionary (BZExtensions)

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

#pragma mark - Methods (Private)

#pragma mark - Standard Methods

- (NSDictionary * _Nonnull)theDictionaryWithoutNulls
{
    NSMutableDictionary *theMutableDictionary = self.mutableCopy;
    for (id theDictionaryKey in theMutableDictionary.allKeys)
    {
        id theDictionaryValue = theMutableDictionary[theDictionaryKey];
        if ([theDictionaryValue isKindOfClass:[NSArray class]])
        {
            NSArray *theCurrentArray = [theDictionaryValue theArrayWithoutNulls];
            theMutableDictionary[theDictionaryKey] = theCurrentArray;
            continue;
        }
        if ([theDictionaryValue isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *theCurrentDictionary = [theDictionaryValue theDictionaryWithoutNulls];
            theMutableDictionary[theDictionaryKey] = theCurrentDictionary;
            continue;
        }
        if ([theDictionaryValue isKindOfClass:[NSNull class]])
        {
            [theMutableDictionary removeObjectForKey:theDictionaryKey];
            continue;
        }
    }
    return theMutableDictionary.copy;
}

@end





























