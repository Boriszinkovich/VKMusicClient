//
//  PlayList+CoreDataProperties.h
//  VKMusicClient
//
//  Created by Boris on 4/5/16.
//  Copyright © 2016 BZ. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PlayList.h"

@class SongIndex;

@interface PlayList (CoreDataProperties)

@property (nonatomic, retain, nullable) NSString *thePlayListName;
@property (nonatomic, retain, nullable) NSDate *theCreationDate;
@property (nonatomic, retain, nullable) NSSet<SongIndex *> *theSongIndexSet;
@property (nonatomic, retain, nullable) NSSet<Song *> *theSongSet;

@end

@interface PlayList (CoreDataGeneratedAccessors)

- (void)addThePlayListSongIndexObject:(SongIndex * _Nonnull)value;
- (void)removeThePlayListSongIndexObject:(SongIndex * _Nonnull)value;
- (void)addThePlayListSongIndex:(NSSet<SongIndex *> * _Nonnull)values;
- (void)removeThePlayListSongIndex:(NSSet<SongIndex *> * _Nonnull)values;

- (void)addTheSongSetObject:(Song * _Nonnull)value;
- (void)removeTheSongSetObject:(Song * _Nonnull)value;
- (void)addTheSongSet:(NSSet<Song *> * _Nonnull)values;
- (void)removeTheSongSet:(NSSet<Song *> * _Nonnull)values;

@end






























