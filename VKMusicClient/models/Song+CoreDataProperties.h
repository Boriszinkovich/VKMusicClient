//
//  Song+CoreDataProperties.h
//  VKMusicClient
//
//  Created by Boris on 4/15/16.
//  Copyright © 2016 BZ. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Song.h"

#import "SongIndex.h"
#import "PlayList.h"

@interface Song (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *theArtist;
@property (nullable, nonatomic, retain) NSString *theDuration;
@property (nullable, nonatomic, retain) NSString *theFileURLString;
@property (nullable, nonatomic, retain) NSString *theIndex;
@property (nullable, nonatomic, retain) NSDate *theLoadDate;
@property (nullable, nonatomic, retain) NSString *theLoadedProgress;
@property (nullable, nonatomic, retain) NSString *theOwnerID;
@property (nullable, nonatomic, retain) NSString *thePopularity;
@property (nullable, nonatomic, retain) NSString *theSongID;
@property (nullable, nonatomic, retain) NSString *theTitle;
@property (nullable, nonatomic, retain) NSString *theURLString;
@property (nullable, nonatomic, retain) NSSet<SongIndex *> *theSongIndex;
@property (nullable, nonatomic, retain) NSSet<PlayList *> *theSongPlayListSet;

@end

@interface Song (CoreDataGeneratedAccessors)

- (void)addTheSongIndexObject:(SongIndex * _Nullable)value;
- (void)removeTheSongIndexObject:(SongIndex * _Nullable)value;
- (void)addTheSongIndex:(NSSet<SongIndex *> * _Nullable)values;
- (void)removeTheSongIndex:(NSSet<SongIndex *> * _Nullable)values;

- (void)addTheSongPlayListSetObject:(PlayList * _Nullable)value;
- (void)removeTheSongPlayListSetObject:(PlayList * _Nullable)value;
- (void)addTheSongPlayListSet:(NSSet<PlayList *> * _Nullable)values;
- (void)removeTheSongPlayListSet:(NSSet<PlayList *> * _Nullable)values;

@end






























