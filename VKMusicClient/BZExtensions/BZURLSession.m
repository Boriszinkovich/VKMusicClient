//
//  BZUrlSession.m
//  GithubClientTask
//
//  Created by User on 04.03.16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "BZURLSession.h"

#import "BZExtensionsManager.h"

@interface BZURLSession () <NSURLSessionDelegate>

@property (nonatomic, strong, nonnull) NSURLSessionDataTask *theMainDataTask;
@property (nonatomic, strong, nonnull) NSURLSession *theMainNSUrlSession;
@property (nonatomic, strong, nullable) NSMutableData *theMutableData;
@property (nonatomic, strong, nullable) NSObject *theLockObject;
@property(copy) void(^theCompletitionBlockWithData)(NSData * _Nullable, NSError * _Nullable);
@property(copy) void(^theCompletitionBlock)(NSError * _Nullable);
@property(copy) void(^theProgressBlock)(double);
@property(copy) void(^theProgressBlockWithData)(double, NSData *);
@property (nonatomic, assign) double theLoadedProgress;

@end

static NSUInteger theIdentifierInteger = 0;

@implementation BZURLSession

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self methodInitBZUrlSession];
    }
    return self;
}

- (void)methodInitBZUrlSession
{
    self.theLockObject = [NSObject new];
}

#pragma mark - Setters (Public)

#pragma mark - Getters (Public)

#pragma mark - Setters (Private)

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

#pragma mark - Create Views & Variables

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Delegates (NSURLSessionDelegate)

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    @synchronized(self)
    {
        if (self.theMutableData)
        {
            [self.theMutableData appendData:data];
            if (self.theProgressBlock)
            {
                [BZExtensionsManager methodSyncMainWithBlock:^
                 {
                     self.theProgressBlock((double)self.theMutableData.length/dataTask.response.expectedContentLength);
                 }];
            }
            else
            {
                return;
            }
            return;
        }
        self.theLoadedProgress += (double)data.length / (double)dataTask.response.expectedContentLength * 100;
        [BZExtensionsManager methodSyncMainWithBlock:^
         {
             self.theProgressBlockWithData(self.theLoadedProgress, data);
         }];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    @synchronized(self.theLockObject)
    {
        if (self.theMutableData)
        {
            [BZExtensionsManager methodSyncMainWithBlock:^
             {
                 self.theCompletitionBlockWithData(self.theMutableData, error);
                 [self methodStop];
                 self.theMutableData = [NSMutableData new];
             }];
            return;
        }
        [BZExtensionsManager methodSyncMainWithBlock:^
         {
             self.theCompletitionBlock(error);
             [self methodStop];
             self.theMutableData = nil;
         }];
    }
}

#pragma mark - Methods (Public)

- (void)methodStop
{
    [self.theMainNSUrlSession invalidateAndCancel];
}

- (void)methodStartDownloadTaskWithURL:(NSURL * _Nonnull)theUrl
                         progressBlock:(void(^ _Nullable)(double theTotalReceivedPercentage))theProgressBlock
               completionBlockWithData:(void(^ _Nullable)(NSData * _Nullable data, NSError * _Nullable theError))theCompletionBlock
{
    BZAssert(theUrl);
    [self methodStop];
    NSString *theIdentifierString = [NSString stringWithFormat:@"%zd%@", theIdentifierInteger++, theUrl.absoluteString];
    self.theMainNSUrlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:theIdentifierString]
                                                       delegate:self
                                                  delegateQueue:nil];
    
    self.theCompletitionBlockWithData = theCompletionBlock;
    self.theProgressBlock = theProgressBlock;
    self.theMutableData = [NSMutableData new];

    NSURLSessionDataTask *theURLSessionDataTask = [self.theMainNSUrlSession dataTaskWithURL:theUrl];
    [theURLSessionDataTask resume];
}

- (void)methodStartDownloadTaskWithURL:(NSURL * _Nonnull)theUrl
                 progressBlockWithData:(void(^ _Nullable)(double theProgress, NSData * _Nullable theReceivedData))theProgressBlock
                       completionBlock:(void(^ _Nullable)(NSError * _Nullable theError))theCompletionBlock
{
    BZAssert(theUrl);
    [self methodStop];
    NSString *theIdentifierString = [NSString stringWithFormat:@"%zd%@", theIdentifierInteger++, theUrl.absoluteString];
    self.theMainNSUrlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:theIdentifierString]
                                                             delegate:self
                                                        delegateQueue:nil];
    
    self.theCompletitionBlock = theCompletionBlock;
    self.theProgressBlockWithData = theProgressBlock;
    self.theMutableData = nil;
    
    NSURLSessionDataTask *theURLSessionDataTask = [self.theMainNSUrlSession dataTaskWithURL:theUrl];
    [theURLSessionDataTask resume];
}

#pragma mark - Methods (Private)

#pragma mark - Standard Methods

@end






























