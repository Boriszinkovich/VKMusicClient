//
//  Song.h
//  VKMusicClient
//
//  Created by Boris on 3/15/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

typedef enum : NSUInteger
{
    SongsSortTypeDate = 1,
    SongsSortTypePopularity,
    SongsSortTypeEnumCount = SongsSortTypePopularity
} SongsSortType;


@interface Song : NSManagedObject

+ (instancetype _Nonnull)methodInitWithDictionary:(NSDictionary * _Nonnull)theDictionary;
+ (NSArray<Song *> * _Nonnull)methodGetAllUserSongs;
+ (NSArray<Song *> * _Nonnull)methodGetSongsWithOffset:(NSInteger)theOffset
                                                 count:(NSInteger)theCount;

+ (NSArray<Song *> * _Nonnull)methodGetSongsWithSearchString:(NSString * _Nonnull)theSearchString;
+ (void)methodDeleteAllNonUserSongs;
+ (void)methodDeleteAllNonLoadedFiles;
+ (NSUInteger)methodGetCountOfLoadedSongs;

+ (NSArray<Song *> * _Nonnull)methodGetAllNonUserSongs;
+ (NSArray<Song *> * _Nonnull)methodGetLoadedSongsWithSongsSortType:(SongsSortType)theSongsSortType
                                                   withSearchString:(NSString * _Nonnull)theSearchString;
+ (NSUInteger)methodGetCountOfLoadedSongsInSongArray:(NSArray * _Nonnull)theSongArray;

- (void)methodFillWithDictionary:(NSDictionary * _Nonnull)theDictionary;
- (void)methodAppendFileWithData:(NSData * _Nonnull)theData;
- (void)methodDeleteFile;
- (void)methodLoadSong;

@end

#import "Song+CoreDataProperties.h"






























