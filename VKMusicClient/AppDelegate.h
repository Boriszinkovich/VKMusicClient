//
//  AppDelegate.h
//  VKMusicClient
//
//  Created by User on 11.03.16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@protocol AppDelegateLoadDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * _Nonnull window;
@property (nonatomic, weak, nullable) id<AppDelegateLoadDelegate> theLoadedDelegate;

@end

@protocol AppDelegateLoadDelegate<NSObject>

@required

- (void)methodAllSongsDidLoad;

@end




























