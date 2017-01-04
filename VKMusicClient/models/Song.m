//
//  Song.m
//  VKMusicClient
//
//  Created by Boris on 3/15/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "Song.h"

#import "DataManager.h"
#import "UserDefaults.h"
#import "UserService.h"

NSString * const keySongIDString = @"id";
NSString * const keyArtistString = @"artist";
NSString * const keyDurationString = @"duration";
NSString * const keyTitleString = @"title";
NSString * const keyURLString = @"url";
NSString * const keyOwnerID = @"owner_id";
NSString * const keySongFilePrefix = @"songPrefix";

@interface Song ()

@property (nonatomic, strong, nonnull) NSFileHandle *theFileHandle;
@property (nonatomic, strong, nonnull) BZSyncBackground *theBZSyncBackground;
@property (nonatomic, strong) Reachability *theInternetReachability;

@end

@implementation Song

@synthesize theFileHandle = _theFileHandle;
@synthesize theBZSyncBackground = _theBZSyncBackground;
@synthesize theInternetReachability = _theInternetReachability;

- (NSData *)theSongData
{
    return [self methodGetPrimitiveValueForSelector:@selector(theSongData)];
}

#pragma mark - Class Methods (Public)

+ (instancetype _Nonnull)methodInitWithDictionary:(NSDictionary * _Nonnull)theDictionary
{
    return [[Song alloc] initWithJSONDictionary:theDictionary];
}

+ (NSArray<Song *> * _Nonnull)methodGetAllUserSongs;
{
    NSManagedObjectContext *theManagedObjectContext = [DataManager sharedInstance].managedObjectContext;
    NSFetchRequest *theFetchRequest = [NSFetchRequest new];
    NSEntityDescription *theDescription =
    [NSEntityDescription entityForName:sfc(self.class)
                inManagedObjectContext:theManagedObjectContext];
    NSSortDescriptor *theSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sfs(@selector(theIndex))
                                                              ascending:YES
                                                                         selector:@selector(localizedStandardCompare:)];
    
    theFetchRequest.sortDescriptors = @[theSortDescriptor];
    theFetchRequest.entity = theDescription;
    theFetchRequest.includesSubentities = NO;
    theFetchRequest.propertiesToFetch = @[sfs(@selector(theSongID))];
    theFetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", sfs(@selector(theOwnerID)), [UserDefaults sharedInstance].theUserIdString];
    NSError *theError = nil;
    NSArray *theResultArray = [theManagedObjectContext executeFetchRequest:theFetchRequest
                                                                     error:&theError];
    BZAssert(!theError);

    return theResultArray;
}

+ (NSArray<Song *> * _Nonnull)methodGetAllNonUserSongs
{
    NSManagedObjectContext *theManagedObjectContext = [DataManager sharedInstance].managedObjectContext;
    NSFetchRequest *theFetchRequest = [NSFetchRequest new];
    NSEntityDescription *theDescription =
    [NSEntityDescription entityForName:sfc(self.class)
                inManagedObjectContext:theManagedObjectContext];
    theFetchRequest.entity = theDescription;
    theFetchRequest.includesSubentities = NO;
    theFetchRequest.propertiesToFetch = @[sfs(@selector(theSongID))];
    theFetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K != %@", sfs(@selector(theOwnerID)), [UserDefaults sharedInstance].theUserIdString];
    NSError *theError = nil;
    NSArray *theResultArray = [theManagedObjectContext executeFetchRequest:theFetchRequest
                                                                     error:&theError];
    BZAssert(!theError);
    return theResultArray;
}

+ (NSArray<Song *> * _Nonnull)methodGetSongsWithOffset:(NSInteger)theOffset
                                                 count:(NSInteger)theCount
{
    NSManagedObjectContext *theManagedObjectContext = [DataManager sharedInstance].managedObjectContext;
    NSFetchRequest *theFetchRequest = [NSFetchRequest new];
    NSEntityDescription *theDescription =
    [NSEntityDescription entityForName:sfc(self.class)
                inManagedObjectContext:theManagedObjectContext];
    theFetchRequest.entity = theDescription;
    theFetchRequest.includesSubentities = NO;
    theFetchRequest.propertiesToFetch = @[sfs(@selector(theSongID))];
    theFetchRequest.fetchLimit = theCount;
    theFetchRequest.fetchOffset = theOffset;
    NSError *theError = nil;
    NSArray *theResultArray = [theManagedObjectContext executeFetchRequest:theFetchRequest
                                                                     error:&theError];
    
    BZAssert(!theError);
    return theResultArray;
}

+ (void)methodDeleteAllNonLoadedFiles
{
    NSManagedObjectContext *theManagedObjectContext = [DataManager sharedInstance].managedObjectContext;
    NSFetchRequest *theFetchRequest = [NSFetchRequest new];
    NSEntityDescription *theDescription =
    [NSEntityDescription entityForName:sfc(self.class)
                inManagedObjectContext:theManagedObjectContext];
    theFetchRequest.entity = theDescription;
    theFetchRequest.includesSubentities = NO;
    theFetchRequest.propertiesToFetch = @[sfs(@selector(theSongID))];
    NSPredicate *theFirstPredicate = [NSPredicate predicateWithFormat:@"%K != 100", sfs(@selector(theLoadedProgress))];
    NSPredicate *theSecondPredicate = [NSPredicate predicateWithFormat:@"%K != 0", sfs(@selector(theLoadedProgress))];
    NSArray *theAndPredicateArray = [NSArray arrayWithObjects:theFirstPredicate, theSecondPredicate, nil];
    theFetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:theAndPredicateArray];
    NSArray *theResultArray = [theManagedObjectContext executeFetchRequest:theFetchRequest
                                                                     error:nil];
    NSString *thePath;
    NSArray *thePathesArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    for (int i = 0; i < theResultArray.count; i++)
    {
        Song *theCurrentSong = ((Song *)theResultArray[i]);
        theCurrentSong.theLoadedProgress = @"0";
        thePath = [[thePathesArray objectAtIndex:0] stringByAppendingPathComponent:keyAppDirectoryName];
        thePath = [thePath stringByAppendingPathComponent:theCurrentSong.theFileURLString];
        if ([[NSFileManager defaultManager] fileExistsAtPath:thePath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:thePath
                                                       error:nil];
        }
        theCurrentSong.theFileURLString = nil;
    }
    [[DataManager sharedInstance] saveContext];
}

+ (NSUInteger)methodGetCountOfLoadedSongs
{
    NSFetchRequest *theFetchRequest = [NSFetchRequest new];
    NSEntityDescription *theDescription =
    [NSEntityDescription entityForName:sfc(self.class)
                inManagedObjectContext:[DataManager sharedInstance].managedObjectContext];
    theFetchRequest.entity = theDescription;
    theFetchRequest.includesSubentities = NO;
    theFetchRequest.propertiesToFetch = @[sfs(@selector(theSongID))];
    theFetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K = 100", sfs(@selector(theLoadedProgress))];
    NSUInteger theCount = [[DataManager sharedInstance].managedObjectContext countForFetchRequest:theFetchRequest
                                                                                         error:nil];
    return theCount;
}

+ (NSArray<Song *> * _Nonnull)methodGetSongsWithSearchString:(NSString * _Nonnull)theSearchString
{
    BZAssert(theSearchString);
    NSArray *theArrayComponents = [theSearchString componentsSeparatedByString:@" "];
    NSMutableArray *theAndPredicateArray = [NSMutableArray new];
    for (int i = 0; i < theArrayComponents.count; i++)
    {
        if (isEqual(theArrayComponents[i], @""))
        {
            continue;
        }
        NSString *theCurrentSearchString = theArrayComponents[i];
        NSPredicate *theArtistPredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", sfs(@selector(theArtist)), theCurrentSearchString];
        NSPredicate *theTitlePredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", sfs(@selector(theTitle)), theCurrentSearchString];
        NSArray *theOrPredicateArray = [NSArray arrayWithObjects:theArtistPredicate, theTitlePredicate, nil];
        [theAndPredicateArray addObject:[NSCompoundPredicate orPredicateWithSubpredicates:theOrPredicateArray]];
    }
    NSPredicate *theUserSongPredicate = [NSPredicate predicateWithFormat:@"%K == %@", sfs(@selector(theOwnerID)), [UserDefaults sharedInstance].theUserIdString];
    [theAndPredicateArray addObject:theUserSongPredicate];
    
    NSManagedObjectContext *theManagedObjectContext = [DataManager sharedInstance].managedObjectContext;
    NSFetchRequest *theFetchRequest = [NSFetchRequest new];
    NSSortDescriptor *theSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sfs(@selector(theIndex))
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)];
    
    NSEntityDescription *theDescription =
    [NSEntityDescription entityForName:sfc(self.class) inManagedObjectContext:theManagedObjectContext];
    theFetchRequest.entity = theDescription;
    theFetchRequest.sortDescriptors = @[theSortDescriptor];
    theFetchRequest.includesSubentities = NO;
    theFetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:theAndPredicateArray];
    theFetchRequest.propertiesToFetch = @[sfs(@selector(theSongID))];
    NSArray *theResultArray = [theManagedObjectContext executeFetchRequest:theFetchRequest error:nil];
    
    return theResultArray;
}

+ (void)methodDeleteAllNonUserSongs
{
    BZAssert([UserDefaults sharedInstance].theUserIdString);
    NSFetchRequest *theFetchRequest = [[NSFetchRequest alloc] initWithEntityName:sfc(self.class)];
    NSEntityDescription *theDescription =
    [NSEntityDescription entityForName:sfc(self.class) inManagedObjectContext:[DataManager sharedInstance].managedObjectContext];
    theFetchRequest.entity = theDescription;
    theFetchRequest.predicate = [NSPredicate predicateWithFormat:@"(%K != %@) AND (%K == 0)",sfs(@selector(theOwnerID)), [UserDefaults sharedInstance].theUserIdString, sfs(@selector(theLoadedProgress))];
    theFetchRequest.includesSubentities = NO;
    theFetchRequest.propertiesToFetch = @[sfs(@selector(theSongID))];
    NSBatchDeleteRequest *theDeleteRequets = [[NSBatchDeleteRequest alloc] initWithFetchRequest:theFetchRequest];
    NSError *theDeleteError = nil;
    [[DataManager sharedInstance].persistentStoreCoordinator executeRequest:theDeleteRequets
                                                                withContext:[DataManager sharedInstance].managedObjectContext
                                                                      error:&theDeleteError];
    [[DataManager sharedInstance] saveContext];
}

+ (NSArray<Song *> * _Nonnull)methodGetLoadedSongsWithSongsSortType:(SongsSortType)theSongsSortType
                                                   withSearchString:(NSString *)theSearchString
{
    if (!theSearchString)
    {
        theSearchString = @"";
    }
    NSMutableArray *theAndPredicateArray = [NSMutableArray new];
    if (!isEqual(theSearchString, @""))
    {
        NSArray *theArrayComponents = [theSearchString componentsSeparatedByString:@" "];
        for (int i = 0; i < theArrayComponents.count; i++)
        {
            if (isEqual(theArrayComponents[i], @""))
            {
                continue;
            }
            NSString *theCurrentSearchString = theArrayComponents[i];
            NSPredicate *theArtistPredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", sfs(@selector(theArtist)), theCurrentSearchString];
            NSPredicate *theTitlePredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", sfs(@selector(theTitle)), theCurrentSearchString];
            NSArray *theOrPredicateArray = [NSArray arrayWithObjects:theArtistPredicate, theTitlePredicate, nil];
            [theAndPredicateArray addObject:[NSCompoundPredicate orPredicateWithSubpredicates:theOrPredicateArray]];
        }
    }
    NSPredicate *theLoadedPredicate = [NSPredicate predicateWithFormat:@"(%K == 100)", sfs(@selector(theLoadedProgress))];
    [theAndPredicateArray addObject:theLoadedPredicate];

    NSFetchRequest *theFetchRequest = [[NSFetchRequest alloc] initWithEntityName:sfc(self.class)];
    NSEntityDescription *theDescription =
    [NSEntityDescription entityForName:sfc(self.class) inManagedObjectContext:[DataManager sharedInstance].managedObjectContext];
    theFetchRequest.entity = theDescription;
    theFetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:theAndPredicateArray];
    theFetchRequest.includesSubentities = NO;
    theFetchRequest.propertiesToFetch = @[sfs(@selector(theSongID))];
    NSSortDescriptor *theSortDescriptor;
    switch (theSongsSortType)
    {
        case SongsSortTypeDate:
        {
            theSortDescriptor = [[NSSortDescriptor alloc] initWithKey:sfs(@selector(theLoadDate))
                                                            ascending:NO];
        }
            break;
        case SongsSortTypePopularity:
        {
            theSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sfs(@selector(thePopularity))
                                                              ascending:NO
                                                               selector:@selector(localizedStandardCompare:)];
        }
            break;
    }
    theFetchRequest.sortDescriptors = @[theSortDescriptor];
    NSArray *theSongArray = [[DataManager sharedInstance].managedObjectContext executeFetchRequest:theFetchRequest
                                                                                             error:nil];
    return theSongArray;
}

+ (NSUInteger)methodGetCountOfLoadedSongsInSongArray:(NSArray * _Nonnull)theSongArray
{
    NSPredicate *thePredicate = [NSPredicate predicateWithFormat:
                                 @"%K == '100'", sfs(@selector(theLoadedProgress))];
    NSArray *theLoadedSongsArray = [theSongArray filteredArrayUsingPredicate:thePredicate];
    return theLoadedSongsArray.count;
}

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (instancetype _Nonnull)initWithJSONDictionary:(NSDictionary *)theDictionary
{
    NSManagedObjectContext *theManagedObjectContext = [DataManager sharedInstance].managedObjectContext;
    self = [self initWithEntity:[NSEntityDescription entityForName:sfc(self.class)
                                            inManagedObjectContext:theManagedObjectContext]
 insertIntoManagedObjectContext:theManagedObjectContext];
    if (self)
    {
        [self methodInitSong];
        [self methodFillWithDictionary:theDictionary];
    }
    return self;
}

- (void)methodInitSong
{
    
}

#pragma mark - Setters (Public)

#pragma mark - Getters (Public)

#pragma mark - Setters (Private)

- (void)setTheSongID:(NSString * _Nullable)theSongID
{
    [self methodSetPrimitiveValue:theSongID forSelector:@selector(theSongID)];
}

- (void)setTheArtist:(NSString * _Nullable)theArtist
{
    [self methodSetPrimitiveValue:theArtist forSelector:@selector(theArtist)];
}

- (void)setTheTitle:(NSString * _Nullable)theTitle
{
    [self methodSetPrimitiveValue:theTitle forSelector:@selector(theTitle)];
}

- (void)setTheDuration:(NSString * _Nullable)theDuration
{
    [self methodSetPrimitiveValue:theDuration forSelector:@selector(theDuration)];
}

- (void)setTheSongData:(NSData * _Nullable)theSongData
{
    [self methodSetPrimitiveValue:theSongData forSelector:@selector(theSongData)];
}

- (void)setTheURLString:(NSString * _Nullable)theURLString
{
    [self methodSetPrimitiveValue:theURLString forSelector:@selector(theURLString)];
}

- (void)setTheOwnerID:(NSString * _Nullable)theOwnerID
{
    [self methodSetPrimitiveValue:theOwnerID forSelector:@selector(theOwnerID)];
}

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

#pragma mark - Create Views & Variables

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Notifications

#pragma mark - Delegates ()

#pragma mark - Methods (Public)

- (void)methodFillWithDictionary:(NSDictionary * _Nonnull)theDictionary
{
    NSString *theSongID;
    id theObject = theDictionary[keySongIDString];
    if (theObject && ![theObject isEqual:[NSNull null]])
    {
        theSongID = [NSString stringWithFormat:@"%@", theObject];
    }
    self.theSongID = theSongID;
    theObject = theDictionary[keyArtistString];
    NSString *theArtist;
    if (theObject && ![theObject isEqual:[NSNull null]])
    {
        theArtist = [NSString stringWithFormat:@"%@", theObject];
    }
    self.theArtist = theArtist;
    NSString *theDuration;
    theObject = theDictionary[keyDurationString];
    if (theObject && ![theObject isEqual:[NSNull null]])
    {
        theDuration = [NSString stringWithFormat:@"%@", theObject];
    }
    self.theDuration = theDuration;
    NSString *theTitle;
    theObject = theDictionary[keyTitleString];
    if (theObject && ![theObject isEqual:[NSNull null]])
    {
        theTitle = [NSString stringWithFormat:@"%@", theObject];;
    }
    self.theTitle = theTitle;
    NSString *theURLString;
    theObject = theDictionary[keyURLString];
    if (theObject && ![theObject isEqual:[NSNull null]])
    {
        theURLString = [NSString stringWithFormat:@"%@", theObject];
    }
    self.theURLString = theURLString;
    if (!self.theLoadedProgress)
    {
        self.theLoadedProgress = @"0";
    }
    if (!self.thePopularity)
    {
        self.thePopularity = @"0";
    }
    NSString *theOwnerIDString;
    theObject = theDictionary[keyOwnerID];
    if (theObject && ![theObject isEqual:[NSNull null]])
    {
        theOwnerIDString = [NSString stringWithFormat:@"%@", theObject];
    }
    self.theOwnerID = theOwnerIDString;
}

- (void)methodAppendFileWithData:(NSData * _Nonnull)theData
{
    if (!self.theBZSyncBackground)
    {
        self.theBZSyncBackground = [BZSyncBackground new];
    }
    [self.theBZSyncBackground methodSyncBackgroundWithBlock:^
     {
         [BZExtensionsManager methodSyncMainWithBlock:^
          {
              if (!self.theFileURLString)
              {
                  self.theFileURLString = [NSString stringWithFormat:@"%@%@.mp3", keySongFilePrefix, self.theSongID];
                  self.theLoadedProgress = @"1";
                  if ([self.managedObjectContext hasChanges])
                  {
                      [self.managedObjectContext save:nil];
                  }
                  NSString *thePath;
                  NSArray *thePathesArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                  thePath = [[thePathesArray objectAtIndex:0] stringByAppendingPathComponent:keyAppDirectoryName];
                  thePath = [thePath stringByAppendingPathComponent:self.theFileURLString];
                  if (![[NSFileManager defaultManager] fileExistsAtPath:thePath])
                  {
                      [[NSFileManager defaultManager] createFileAtPath:thePath
                                                              contents:nil
                                                            attributes:nil];
                  }
                  self.theFileHandle = [NSFileHandle fileHandleForWritingAtPath:thePath];
              }
          }];
         [self.theFileHandle seekToEndOfFile];
         [self.theFileHandle writeData:theData];
     }];
}

- (void)methodDeleteFile
{
    BZAssert(self.theFileURLString);
    NSString *thePath;
    NSArray *thePathesArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    thePath = [[thePathesArray objectAtIndex:0] stringByAppendingPathComponent:keyAppDirectoryName];
    thePath = [thePath stringByAppendingPathComponent:self.theFileURLString];
    if ([[NSFileManager defaultManager] fileExistsAtPath:thePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:thePath
                                                   error:nil];
    }
    self.theLoadedProgress = @"0";
    self.theFileURLString = nil;
    if (self.managedObjectContext.hasChanges)
    {
        [self.managedObjectContext save:nil];
    }
}

- (void)methodLoadSong
{
    if (!self.theInternetReachability)
    {
        self.theInternetReachability  = [Reachability reachabilityForInternetConnection];
    }
    if (!self.theInternetReachability.isReachable)
    {
        return;
    }
    BZAssert(self.theURLString);
    if (self.theFileURLString)
    {
        return;
    }
    NSString *theLoadKeyString = [NSString stringWithFormat:@"%@%@", keyLoadSongPrefix, self.theSongID];
    weakify(self);
    [[UserService sharedInstance] methodDownloadSongWithURL:self.theURLString
                                                    taskKey:theLoadKeyString
                                                   progress:^(double theProgress, NSData * _Nullable theReceivedData)
     {
         strongify(self);
         [self methodAppendFileWithData:theReceivedData];
         if (theProgress - [self.theLoadedProgress integerValue] > 5 || (!self.theLoadedProgress && theProgress > 1))
         {
             self.theLoadedProgress = [NSString stringWithFormat:@"%zd", (NSInteger)theProgress];
             if ([self.managedObjectContext hasChanges])
             {
                 [self.managedObjectContext save:nil];
             }
             [[NSNotificationCenter defaultCenter]
              postNotificationName:keySongLoadProgressNotification
              object:self];
         }
     }
                                                 completion:^(NSError * _Nullable error)
     {
         strongify(self);
         if (error)
         {
             [Song methodDeleteAllNonLoadedFiles];
             return;
         }
         self.theLoadedProgress = @"100";
         self.theLoadDate = [NSDate new];
         [self.managedObjectContext save:nil];
         [[NSNotificationCenter defaultCenter]
          postNotificationName:keySongDidLoadNotification
          object:self];
     }];
}

#pragma mark - Methods (Private)

#pragma mark - Standard Methods

@end






























