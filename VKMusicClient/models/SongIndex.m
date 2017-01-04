//
//  SongIndex.m
//  VKMusicClient
//
//  Created by Boris on 4/4/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "SongIndex.h"

#import "PlayList.h"
#import "Song.h"
#import "DataManager.h"

@implementation SongIndex

#pragma mark - Class Methods (Public)

+ (void)methodCreateIndexesWithSongArray:(NSArray<Song *> * _Nonnull)theSongArray
                            withPlayList:(PlayList * _Nonnull)thePlayList
{
    BZAssert(theSongArray);
    BZAssert(thePlayList);
    SongIndex *theSongIndex;
    for (int i = 0; i < theSongArray.count; i++)
    {
        NSString *theValue = [NSString stringWithFormat:@"%.03f", (float)i];
        theSongIndex = [[SongIndex alloc] initWithSong:theSongArray[i] withPlayList:thePlayList withValue:theValue];
    }
    [[DataManager sharedInstance] saveContext];
}

+ (void)methodDeleteSongIndexesWithArray:(NSArray * _Nonnull)theArray
{
    BZAssert(theArray);
    for (int i = 0; i < theArray.count; i++)
    {
        [[DataManager sharedInstance].managedObjectContext deleteObject:theArray[i]
         ];
    }
}

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (instancetype _Nonnull)initWithSong:(Song * _Nonnull)theSong
                         withPlayList:(PlayList * _Nonnull)thePlayList
                            withValue:(NSString * _Nonnull)theValue
{
    BZAssert((BOOL)(theSong && thePlayList && theValue));
    NSManagedObjectContext *theManagedObjectContext = [DataManager sharedInstance].managedObjectContext;
    self = [self initWithEntity:[NSEntityDescription entityForName:sfc(self.class)
                                            inManagedObjectContext:theManagedObjectContext]
 insertIntoManagedObjectContext:theManagedObjectContext];
    if (self)
    {
        [self methodInitSongIndex];
        [self methodFillSongIndexWithSong:theSong
                             withPlayList:thePlayList
                                withValue:theValue];
    }
    return self;
}

- (void)methodInitSongIndex
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

- (void)methodFillSongIndexWithSong:(Song * _Nonnull)theSong
                       withPlayList:(PlayList * _Nonnull)thePlayList
                          withValue:(NSString * _Nonnull)theValue
{
    BZAssert((BOOL)(theSong && thePlayList && theValue));
    self.thePlayList = thePlayList;
    self.theSong = theSong;
    self.theIndexValue = theValue;
}

#pragma mark - Standard Methods

@end






























