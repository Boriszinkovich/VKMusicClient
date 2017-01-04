//
//  SongIndex.h
//  VKMusicClient
//
//  Created by Boris on 4/4/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PlayList, Song;

@interface SongIndex : NSManagedObject

+ (void)methodCreateIndexesWithSongArray:(NSArray<Song *> * _Nonnull)theSongArray
                            withPlayList:(PlayList * _Nonnull)thePlayList;

+ (void)methodDeleteSongIndexesWithArray:(NSArray * _Nonnull)theArray;

@end

#import "SongIndex+CoreDataProperties.h"






























