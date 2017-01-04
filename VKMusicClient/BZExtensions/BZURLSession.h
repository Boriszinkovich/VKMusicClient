//
//  BZUrlSession.h
//  GithubClientTask
//
//  Created by User on 04.03.16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface BZURLSession : NSObject

- (void)methodStop;

- (void)methodStartDownloadTaskWithURL:(NSURL * _Nonnull)theUrl
                         progressBlock:(void(^ _Nullable)(double theTotalReceivedPercentage))theProgressBlock
               completionBlockWithData:(void(^ _Nullable)(NSData * _Nullable data, NSError * _Nullable theError))theCompletionBlock;

- (void)methodStartDownloadTaskWithURL:(NSURL * _Nonnull)theUrl
                 progressBlockWithData:(void(^ _Nullable)(double theProgress, NSData * _Nullable theReceivedData))theProgressBlock
                       completionBlock:(void(^ _Nullable)(NSError * _Nullable theError))theCompletionBlock;


@end






























