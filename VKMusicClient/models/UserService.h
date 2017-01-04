//
//  UserService.h
//  VKMusicClient
//
//  Created by Boris on 3/14/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger
{
    UserServiceErrorNoData = 1,
    UserServiceErrorWithError,
    UserServiceErrorWithCaptcha,
    UserServiceErrorEnumCount = UserServiceErrorWithError
} UserServiceError;

@class Song;

@interface UserService : NSObject

+ (UserService * _Nonnull)sharedInstance;

- (void)methodLoadSongsWithSearchString:(NSString * _Nonnull)theSearchString
                             withOffset:(NSUInteger)thePage
                                  count:(NSUInteger)theCount
                                taskKey:(NSString * _Nonnull)theTaskKey
                             completion:(void (^ _Nonnull)(NSArray<Song *> * _Nullable theSongsArray, NSUInteger theSongsCount, NSError * _Nullable error))theCompletionBlock;

- (void)methodLoadAllSongsToCoreDataWithCompletion:(void (^ _Nullable)(NSError * _Nullable error))theCompletionBlock;

- (void)methodDownloadSongWithURL:(NSString * _Nonnull)theURLString
                          taskKey:(NSString * _Nonnull)theTaskKey
                         progress:(void(^ _Nullable)(double theProgress, NSData * _Nullable theReceivedData))theProgressBlock
                       completion:(void (^ _Nonnull)(NSError * _Nullable error))theCompletionBlock;

@end






























