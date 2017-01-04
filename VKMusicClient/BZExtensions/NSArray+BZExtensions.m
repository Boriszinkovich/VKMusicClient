//
//  NSArray+BZExtensions.m
//  ScrollViewTask
//
//  Created by BZ on 2/16/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "NSArray+BZExtensions.h"

#import "BZExtensionsManager.h"

@implementation NSArray (BZExtensions)

- (NSArray * _Nonnull)theArrayWithoutNulls
{
    NSMutableArray *theMutableArray = self.mutableCopy;
    [theMutableArray removeObjectIdenticalTo:[NSNull null]];
    for (int i = 0; i < theMutableArray.count; i++)
    {
        id theArrayElement = theMutableArray[i];
        if ([theArrayElement isKindOfClass:[NSArray class]])
        {
            NSArray *theCurrentArray = [theArrayElement theArrayWithoutNulls];
            theMutableArray[i] = theCurrentArray;
            continue;
        }
        if ([theArrayElement isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *theCurrentDictionary = [theArrayElement theDictionaryWithoutNulls];
            theMutableArray[i] = theCurrentDictionary;
            continue;
        }
    }
    return theMutableArray.copy;
}

@end






























