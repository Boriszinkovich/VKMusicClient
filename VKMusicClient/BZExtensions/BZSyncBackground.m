//
//  BZSyncBackground.m
//  VKMusicClient
//
//  Created by Boris on 3/31/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "BZSyncBackground.h"

#import "BZExtensionsManager.h"

@interface BZSyncBackground ()

@property(nonatomic, strong, nonnull) NSOperationQueue *theOperationQueue;
@property (nonatomic, strong, nonnull) NSDate *theLastOperationDate;

@end

@implementation BZSyncBackground

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (instancetype _Nonnull)init
{
    self = [super init];
    if (self)
    {
        [self methodInitBZSyncBackground];
    }
    return self;
}

- (void)methodInitBZSyncBackground
{
    _theOperationQueue = [NSOperationQueue new];
    _theOperationQueue.maxConcurrentOperationCount = 1;
}

#pragma mark - Setters (Public)

- (void)setTheDelayInSeconds:(double)theDelayInSeconds
{
    BZAssert((BOOL)(theDelayInSeconds >= 0));
    _theDelayInSeconds = theDelayInSeconds;
}

#pragma mark - Getters (Public)

#pragma mark - Setters (Private)

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

#pragma mark - Create Views & Variables

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Notifications

#pragma mark - Delegates ()

#pragma mark - Methods (Public)

- (void)methodSyncBackgroundWithBlock:(void (^ _Nonnull)())theBlock
{
    BZAssert(theBlock);
    if (self.theDelayInSeconds)
    {
        self.theLastOperationDate = [NSDate new];
    }
    weakify(self);
    void (^theOperationBlock)() = ^void()
    {
        strongify(self);
        if (self.theDelayInSeconds)
        {
            usleep(self.theDelayInSeconds * 1000000);
            NSDate *theNewDate = [NSDate new];
            if ([theNewDate timeIntervalSinceDate:self.theLastOperationDate] < self.theDelayInSeconds)
            {
                return;
            }
        }
        theBlock();
    };
    NSBlockOperation *theOperation = [NSBlockOperation blockOperationWithBlock:theOperationBlock];
    theOperation.queuePriority = NSOperationQueuePriorityHigh;
    [self.theOperationQueue addOperation:theOperation];
}

#pragma mark - Methods (Private)

#pragma mark - Standard Methods

@end






























