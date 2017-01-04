//
//  NSObject+BZExtensions.h
//  ScrollViewTask
//
//  Created by BZ on 2/15/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (BZExtensions)

/// defaults to YES
@property (nonatomic, assign) BOOL isFirstLoad;
@property (nonatomic, assign, readonly) NSInteger theRetainCount;

@end






























