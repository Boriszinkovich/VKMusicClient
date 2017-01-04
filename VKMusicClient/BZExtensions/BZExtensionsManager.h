//
//  BZExtensionsManager.h
//  ScrollViewTask
//
//  Created by BZ on 2/15/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSObject+BZExtensions.h"
#import "UIView+BZExtensions.h"
#import "UIColor+BZExtensions.h"
#import "UIImage+BZExtensions.h"
#import "NSArray+BZExtensions.h"
#import "NSDictionary+BZExtensions.h"
#import "BZPageView.h"
#import "SMPageControl.h"
#import "BZAnimation.h"
#import "Reachability.h"
#import "BZURLSession.h"
#import "BZScope.h"
#import "BZDeviceHardware.h"
#import "NSString+BZExtensions.h"
#import "ODTableView.h"
#import "NSManagedObject+BZExtensions.h"
#import "UISlider+BZExtensions.h"
#import "BZSyncBackground.h"

#ifdef DEBUG
#define BZAssert(var) \
if (!(BOOL)var) \
{ \
abort(); \
}
#else
#define BZAssert(var)
#endif

BOOL isEqual(id _Nullable theObject1, id _Nullable theObject2);
NSString * _Nullable sfs(SEL _Nonnull theSelector);
NSString * _Nullable sfc(Class _Nonnull theClass);

typedef enum : NSUInteger
{
    BZDeviceIphone4 = 1,
    BZDeviceIphone5 = 2,
    BZDeviceIphone6 = 3,
    BZDeviceIphone6Plus = 4,
    BZDeviceIpad = 5,
    BZDevicesCount = BZDeviceIpad
} BZDevice;

@interface BZExtensionsManager : NSObject

+ (double)methodGetStatusBarHeight;
+ (void)methodAsyncMainWithBlock:(void (^ _Nonnull)())theBlock;
+ (void)methodAsyncBackgroundWithBlock:(void (^ _Nonnull)())theBlock;
+ (void)methodSyncMainWithBlock:(void (^ _Nonnull)())theBlock;
+ (void)methodDispatchAfterSeconds:(double)theSeconds
                         withBlock:(void (^ _Nonnull)())theBlock;

+ (BZDevice)getDevice;
+ (void)methodPrintAllFonts;

@end






























