//
//  BZDeviceHardware.m
//  VKMusicClient
//
//  Created by User on 12.03.16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "BZDeviceHardware.h"

#include <sys/types.h>
#include <sys/sysctl.h>

@implementation BZDeviceHardware

#pragma mark - Class Methods (Public)

+ (NSString *)getPlatform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *theMachine = malloc(size);
    sysctlbyname("hw.machine", theMachine, &size, NULL, 0);
    NSString *thePlatform = [NSString stringWithUTF8String:theMachine];
    free(theMachine);
    return thePlatform;
}

+ (NSString *)getPlatformString
{
    NSString *thePlatform = [self getPlatform];
    // Apple TV
    if ([thePlatform isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2G";
    if ([thePlatform isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3G";
    if ([thePlatform isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3G";
    if ([thePlatform isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4G";
    
    // Apple Watch
    if ([thePlatform isEqualToString:@"Watch1,1"])      return @"Apple Watch";
    if ([thePlatform isEqualToString:@"Watch1,2"])      return @"Apple Watch";
    
    // iPhone
    if ([thePlatform isEqualToString:@"iPhone1,1"])    return @"iPhone";
    if ([thePlatform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([thePlatform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([thePlatform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([thePlatform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([thePlatform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([thePlatform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([thePlatform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([thePlatform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([thePlatform isEqualToString:@"iPhone5,3"])    return @"iPhone 5C (GSM)";
    if ([thePlatform isEqualToString:@"iPhone5,4"])    return @"iPhone 5C (GSM+CDMA)";
    if ([thePlatform isEqualToString:@"iPhone6,1"])    return @"iPhone 5S (GSM)";
    if ([thePlatform isEqualToString:@"iPhone6,2"])    return @"iPhone 5S (GSM+CDMA)";
    if ([thePlatform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([thePlatform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([thePlatform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([thePlatform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    
    // iPod
    if ([thePlatform isEqualToString:@"iPod1,1"])      return @"iPod Touch";
    if ([thePlatform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([thePlatform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([thePlatform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([thePlatform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([thePlatform isEqualToString:@"iPod7,1"])      return @"iPod Touch 6G";
    
    // iPad
    if ([thePlatform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([thePlatform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([thePlatform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([thePlatform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([thePlatform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([thePlatform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([thePlatform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([thePlatform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([thePlatform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([thePlatform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([thePlatform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([thePlatform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([thePlatform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([thePlatform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([thePlatform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([thePlatform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([thePlatform isEqualToString:@"iPad6,7"])      return @"iPad Pro (WiFi)";
    if ([thePlatform isEqualToString:@"iPad6,8"])      return @"iPad Pro (Cellular)";
    
    // iPad Mini
    if ([thePlatform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([thePlatform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([thePlatform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([thePlatform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([thePlatform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([thePlatform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([thePlatform isEqualToString:@"iPad4,7"])      return @"iPad mini 3 (WiFi)";
    if ([thePlatform isEqualToString:@"iPad4,8"])      return @"iPad mini 3 (Cellular)";
    if ([thePlatform isEqualToString:@"iPad4,9"])      return @"iPad mini 3 (China Model)";
    if ([thePlatform isEqualToString:@"iPad5,1"])      return @"iPad mini 4 (WiFi)";
    if ([thePlatform isEqualToString:@"iPad5,2"])      return @"iPad mini 4 (Cellular)";
    
    // Simulator
    if ([thePlatform isEqualToString:@"i386"])         return @"Simulator";
    if ([thePlatform isEqualToString:@"x86_64"])       return @"Simulator";
    return thePlatform;
}

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

@end






























