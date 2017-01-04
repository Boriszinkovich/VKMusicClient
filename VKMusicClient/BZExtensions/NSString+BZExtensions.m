//
//  NSString+BZExtensions.m
//  VKMusicClient
//
//  Created by User on 12.03.16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "NSString+BZExtensions.h"

#import "BZExtensionsManager.h"

@implementation NSString (BZExtensions)

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

#pragma mark - Setters (Public)

#pragma mark - Getters (Public)

- (double)theDeviceValue
{
    NSArray<NSString *> *theStringArray = [self componentsSeparatedByString:@" "];
    BZAssert((BOOL)(theStringArray.count == 4));
    static BZDevice theDevice;
    if (!theDevice)
    {
        theDevice = [BZExtensionsManager getDevice];
    }
    switch (theDevice)
    {
        case BZDeviceIphone4:
        {
            return theStringArray[3].doubleValue;
        }
            break;
        case BZDeviceIphone5:
        {
            return theStringArray[2].doubleValue;
        }
            break;
        case BZDeviceIphone6:
        {
            return theStringArray[1].doubleValue;
        }
            break;
        case BZDeviceIphone6Plus:
        {
            return theStringArray[0].doubleValue;
        }
            break;
        case BZDeviceIpad:
        {
            BZAssert(nil);
//            return theStringArray[0].doubleValue;
        }
    };
    BZAssert(nil);
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






























