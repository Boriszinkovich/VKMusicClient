//
//  BZSyncBackground.h
//  VKMusicClient
//
//  Created by Boris on 3/31/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BZSyncBackground : NSObject

@property (nonatomic, assign) double theDelayInSeconds;

- (void)methodSyncBackgroundWithBlock:(void (^ _Nonnull)())theBlock;

@end






























