//
//  PlayList.h
//  VKMusicClient
//
//  Created by Boris on 4/4/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@class Song;
@class SongIndex;

@interface PlayList : NSManagedObject

+ (instancetype _Nonnull)methodInit;
+ (NSArray * _Nonnull)methodGetPlayListArray;
+ (BOOL)isPlayListExistsWithName:(NSString * _Nonnull)theSearchString;

- (NSArray<Song *> * _Nonnull)methodGetPlayListSongArray;
- (NSArray<SongIndex *>  * _Nonnull)methodGetPlayListIndexesArray;

@end

#import "PlayList+CoreDataProperties.h"






























