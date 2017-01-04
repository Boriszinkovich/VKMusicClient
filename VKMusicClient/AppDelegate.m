//
//  AppDelegate.m
//  VKMusicClient
//
//  Created by User on 11.03.16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "AppDelegate.h"

#import "MainTabBarController.h"
#import "SplashView.h"
#import "UserService.h"
#import "UserDefaults.h"
#import "Song.h"
#import "PlayerVC.h"
#import "DataManager.h"

@interface AppDelegate ()

@property (nonatomic, strong, nonnull) Reachability *theReachability;
@property (nonatomic, assign) BOOL isReachabilityAlowedToWork;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:keyAppDirectoryName];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])	//Does directory already exist?
    {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"Create directory error: %@", error);
        }
    }

    Reachability *theReachability = [Reachability reachabilityForInternetConnection];
    self.theReachability = theReachability;
    weakify(self);
    theReachability.reachableBlock = ^(Reachability * reachability)
    {
        if (![UserDefaults sharedInstance].theAccessToken)
        {
            return;
        }
        [BZExtensionsManager methodAsyncMainWithBlock:^
         {
             strongify(self);
             [self.theReachability stopNotifier];
             UserService *theUserService = [UserService sharedInstance];
             [theUserService methodLoadAllSongsToCoreDataWithCompletion:^(NSError * _Nullable error)
              {
                  if (![self.theLoadedDelegate respondsToSelector:@selector(methodAllSongsDidLoad)])
                  {
                      return;
                  }
                      [self.theLoadedDelegate methodAllSongsDidLoad];
              }];
         }];
    };
    [theReachability startNotifier];
    
    self.window = [UIWindow new];
    self.window.theWidth = [UIScreen mainScreen].bounds.size.width;
    self.window.theHeight = [UIScreen mainScreen].bounds.size.height;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    MainTabBarController *theRootController = [MainTabBarController sharedInstance];
    UINavigationController *theNavigationController = [[UINavigationController alloc] initWithRootViewController:theRootController];
    self.window.rootViewController = theNavigationController;
    
    SplashView *theSplashView = [SplashView new];
    [self.window addSubview:theSplashView];
    [BZExtensionsManager methodDispatchAfterSeconds:1
                                          withBlock:^
    {
        BZAnimation *theAnimation = [BZAnimation new];
        theAnimation.theDuration = 2;
        [theAnimation methodSetAnimationBlock:^
        {
            theSplashView.alpha = 0;
        }];
        [theAnimation methodStart];
    }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self.theReachability stopNotifier];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (![UserDefaults sharedInstance].theAccessToken)
    {
        return;
    }
    [Song methodDeleteAllNonUserSongs];
    [Song methodDeleteAllNonLoadedFiles];
    [[UserService sharedInstance] methodLoadAllSongsToCoreDataWithCompletion:^(NSError * _Nullable error)
     {
         if (![self.theLoadedDelegate respondsToSelector:@selector(methodAllSongsDidLoad)])
         {
             return;
         }
         [self.theLoadedDelegate methodAllSongsDidLoad];
     }];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

@end































