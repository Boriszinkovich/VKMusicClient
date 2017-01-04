//
//  MainVC.h
//  VKMusicClient
//
//  Created by User on 11.03.16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTabBarController : UITabBarController

@property (nonatomic, assign) NSInteger theTabBarHeight;

+ (MainTabBarController * _Nonnull)sharedInstance;

- (UIViewController * _Nonnull)methodGetViewControllerWithIndex:(NSUInteger)theIndex;

@end






























