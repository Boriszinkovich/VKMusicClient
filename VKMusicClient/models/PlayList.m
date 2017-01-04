//
//  PlayList.m
//  VKMusicClient
//
//  Created by Boris on 4/4/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "PlayList.h"

#import "Song.h"
#import "DataManager.h"
#import "SongIndex.h"

@implementation PlayList

#pragma mark - Class Methods (Public)

+ (instancetype _Nonnull)methodInit
{
    return [[PlayList alloc] initNewPlayList];
}

+ (NSArray * _Nonnull)methodGetPlayListArray
{
    NSManagedObjectContext *theManagedObjectContext = [DataManager sharedInstance].managedObjectContext;
    NSFetchRequest *theFetchRequest = [NSFetchRequest new];
    NSEntityDescription *theDescription =
    [NSEntityDescription entityForName:sfc(self.class)
                inManagedObjectContext:theManagedObjectContext];
    NSSortDescriptor *theSortDescriptor = [[NSSortDescriptor alloc] initWithKey:sfs(@selector(theCreationDate))
                                                                      ascending:NO];
    theFetchRequest.sortDescriptors = @[theSortDescriptor];
    theFetchRequest.entity = theDescription;
    theFetchRequest.includesSubentities = NO;
    theFetchRequest.propertiesToFetch = @[sfs(@selector(thePlayListName))];
    NSError *theError = nil;
    NSArray *theResultArray = [theManagedObjectContext executeFetchRequest:theFetchRequest
                                                                     error:&theError];
    
    BZAssert(!theError);
    return theResultArray;
}

- (NSArray<SongIndex *>  * _Nonnull)methodGetPlayListIndexesArray
{
    NSArray *theIndexesArray = [[self.theSongIndexSet allObjects] sortedArrayUsingComparator:^
                                NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
                                {
                                    float theFirstValue = ((SongIndex *)(obj1)).theIndexValue.doubleValue;
                                    float theSecondValue = ((SongIndex *)(obj2)).theIndexValue.doubleValue;
                                    if (theFirstValue < theSecondValue)
                                    {
                                        return NSOrderedAscending;
                                    }
                                    else if (theFirstValue == theSecondValue)
                                    {
                                        return NSOrderedSame;
                                    }
                                    else
                                    {
                                        return NSOrderedDescending;
                                    }
                                }];
    return theIndexesArray;
}

+ (BOOL)isPlayListExistsWithName:(NSString * _Nonnull)theSearchString
{
    NSManagedObjectContext *theManagedObjectContext = [DataManager sharedInstance].managedObjectContext;
    NSFetchRequest *theFetchRequest = [NSFetchRequest new];
    NSEntityDescription *theDescription =
    [NSEntityDescription entityForName:sfc(self.class)
                inManagedObjectContext:theManagedObjectContext];
    NSSortDescriptor *theSortDescriptor = [[NSSortDescriptor alloc] initWithKey:sfs(@selector(theCreationDate)) ascending:NO];
    theFetchRequest.sortDescriptors = @[theSortDescriptor];
    theFetchRequest.entity = theDescription;
    NSPredicate *thePredicate = [NSPredicate predicateWithFormat:
                                 @"%K == %@", sfs(@selector(thePlayListName)), theSearchString];
    theFetchRequest.predicate = thePredicate;
    theFetchRequest.includesSubentities = NO;
    theFetchRequest.propertiesToFetch = @[sfs(@selector(thePlayListName))];
    NSUInteger theCount = [theManagedObjectContext countForFetchRequest:theFetchRequest error:nil];
    if (!theCount)
    {
        return NO;
    }
    return YES;
}

- (NSArray<Song *> * _Nonnull)methodGetPlayListSongArray
{
    NSMutableArray *theSongsArray = [NSMutableArray new];
    NSArray *theIndexesArray = [[self.theSongIndexSet allObjects] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
    {
        float theFirstValue = ((SongIndex *)(obj1)).theIndexValue.doubleValue;
        float theSecondValue = ((SongIndex *)(obj2)).theIndexValue.doubleValue;
        if (theFirstValue < theSecondValue)
        {
            return NSOrderedAscending;
        }
        else if (theFirstValue == theSecondValue)
        {
            return NSOrderedSame;
        }
        else
        {
            return NSOrderedDescending;
        }
    }];
    for (int i = 0; i < theIndexesArray.count; i++)
    {
        [theSongsArray addObject:((SongIndex *)theIndexesArray[i]).theSong];
    }
    return theSongsArray;
}

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (instancetype _Nonnull)initNewPlayList
{
    NSManagedObjectContext *theManagedObjectContext = [DataManager sharedInstance].managedObjectContext;
    self = [self initWithEntity:[NSEntityDescription entityForName:sfc(self.class)
                                            inManagedObjectContext:theManagedObjectContext]
 insertIntoManagedObjectContext:theManagedObjectContext];
    if (self)
    {
        [self methodInitPlayList];
    }
    return self;
}

- (void)methodInitPlayList
{
    
}

#pragma mark - Setters (Public)

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

#pragma mark - Methods (Private)

#pragma mark - Standard Methods

@end






























