//
//  NSManagedObject+BZExtensions.h
//  VKMusicClient
//
//  Created by Boris on 3/21/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (BZExtensions)

- (void)methodSetPrimitiveValue:(id _Nullable)theValue forSelector:(SEL _Nonnull)theSelector;
- (id _Nullable)methodGetPrimitiveValueForSelector:(SEL _Nonnull)theSelector;

@end






























