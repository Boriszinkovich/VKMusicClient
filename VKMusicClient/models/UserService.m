//
//  UserService.m
//  VKMusicClient
//
//  Created by Boris on 3/14/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "UserService.h"

#import "UserDefaults.h"
#import "Song.h"
#import "DataManager.h"

#define HOST_NAME_CONSTANT @"https://api.vk.com/method/"
#define keyNumberOfLoads ((int) 6000)

@interface UserService ()

@property (nonatomic, strong, nonnull) NSMutableDictionary *theServiceDictionary;
@property (nonatomic, assign) NSInteger theCurrentMultiplier;

@end

NSString * const keyErrorDomain = @"Domain";
NSString * const keyResponseString = @"response";
NSString * const keyCountString = @"count";
NSString * const keyItemsString = @"items";
NSString * const keySongIdString = @"id";
NSString * const keyCaptchaError = @"error";

@implementation UserService

#pragma mark - Class Methods (Public)

+ (UserService * _Nonnull)sharedInstance
{
    static UserService *theUserService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      theUserService = [[UserService alloc] initSharedInstance];
                  });
    
    return theUserService;
}

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (instancetype)init
{
    BZAssert(nil);
}

- (instancetype _Nonnull)initSharedInstance
{
    self = [super init];
    if (self)
    {
        [self methodInitUserService];
    }
    return self;
}

- (void)methodInitUserService
{
    self.theServiceDictionary = [NSMutableDictionary new];
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

- (void)methodLoadAllSongsToCoreDataWithOffset:(NSUInteger)theOffset
                                         count:(NSUInteger)theCount
                                         array:(NSMutableArray * _Nonnull)theLoadedJSONArray
                                    completion:(void (^ _Nullable)(NSError * _Nullable error))theCompletionBlock
{
    BZAssert(theLoadedJSONArray && theCount);
    NSString *theUserIdString = [UserDefaults sharedInstance].theUserIdString;
    NSString *theAccessTokenString = [UserDefaults sharedInstance].theAccessToken;
    BZAssert(theUserIdString && theAccessTokenString);
    BZURLSession *theSession;
    if (!self.theServiceDictionary[keyLoadSongsToCoreData])
    {
        theSession = [BZURLSession new];
        self.theServiceDictionary[keyLoadSongsToCoreData] = theSession;
    }
    else
    {
        theSession = self.theServiceDictionary[keyLoadSongsToCoreData];
    }
    NSString *theLoadUrlString = [NSString stringWithFormat:@"%@audio.get?owner_id=%@?need_user=0&count=%zd&offset=%zd&access_token=%@&v=5.50",HOST_NAME_CONSTANT, theUserIdString, theCount, theOffset, theAccessTokenString];
    NSURL *theNSURL = [NSURL URLWithString:theLoadUrlString];
    weakify(self);
    [theSession methodStartDownloadTaskWithURL:theNSURL
                                 progressBlock:nil
                       completionBlockWithData:^(NSData * _Nullable data, NSError * _Nullable error)
     {
         strongify(self);
         [BZExtensionsManager methodAsyncBackgroundWithBlock:^
          {
              NSError *theError;
              if (!data)
              {
                  theError = [NSError errorWithDomain:keyErrorDomain
                                                 code:UserServiceErrorNoData
                                             userInfo:nil];
                  [BZExtensionsManager methodAsyncMainWithBlock:^
                   {
                       theCompletionBlock(theError);
                   }];
                  return;
              }
              if (error)
              {
                  theError = [NSError errorWithDomain:error.domain code:UserServiceErrorWithError userInfo:error.userInfo];
                  [BZExtensionsManager methodAsyncMainWithBlock:^
                   {
                       theCompletionBlock(theError);
                   }];
                  return;
              }
              NSDictionary *theSongsDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                 options:kNilOptions
                                                                                   error:&theError];
              if (theSongsDictionary[keyCaptchaError])
              {// captcha error
                  NSDictionary *theErrorDictionary = theSongsDictionary[keyCaptchaError];
                  if (!theErrorDictionary[keyCaptchaID] || !theErrorDictionary[keyCaptchaImg])
                  {
                      theError = [NSError errorWithDomain:keyErrorDomain
                                                     code:UserServiceErrorNoData
                                                 userInfo:nil];
                      [BZExtensionsManager methodAsyncMainWithBlock:^
                       {
                           theCompletionBlock(theError);
                       }];
                      return;
                      
                  }
                  NSDictionary* theCapthchaDictionary = [NSDictionary dictionaryWithObjectsAndKeys: theErrorDictionary[keyCaptchaID], keyCaptchaID, theErrorDictionary[keyCaptchaImg], keyCaptchaImg, nil];
                  theError = [NSError errorWithDomain:keyErrorDomain
                                                 code:UserServiceErrorWithCaptcha
                                             userInfo:theCapthchaDictionary];
                  [BZExtensionsManager methodAsyncMainWithBlock:^
                   {
                       theCompletionBlock(theError);
                   }];
                  return;
              }
              if (error)
              {
                  theError = [NSError errorWithDomain:error.domain
                                                 code:UserServiceErrorWithError
                                             userInfo:error.userInfo];
                  [BZExtensionsManager methodAsyncMainWithBlock:^
                   {
                       theCompletionBlock(theError);
                   }];
                  return;
              }
              if (![theSongsDictionary isKindOfClass:[NSDictionary class]])
              {
                  theError = [NSError errorWithDomain:keyErrorDomain
                                                 code:UserServiceErrorNoData
                                             userInfo:nil];
                  [BZExtensionsManager methodAsyncMainWithBlock:^
                   {
                       theCompletionBlock(theError);
                   }];
                  return;
              }
              if (!theSongsDictionary[keyResponseString])
              {
                  theError = [NSError errorWithDomain:keyErrorDomain
                                                 code:UserServiceErrorNoData
                                             userInfo:nil];
                  [BZExtensionsManager methodAsyncMainWithBlock:^
                   {
                       theCompletionBlock(theError);
                   }];
                  return;
              }
              theSongsDictionary = theSongsDictionary[keyResponseString];
              if (!theSongsDictionary[keyCountString])
              {
                  theError = [NSError errorWithDomain:keyErrorDomain
                                                 code:UserServiceErrorNoData
                                             userInfo:nil];
                  [BZExtensionsManager methodAsyncMainWithBlock:^
                   {
                       theCompletionBlock(theError);
                   }];
                  return;
              }
              NSString *theSongsTotalNumberString = [NSString stringWithFormat:@"%@",theSongsDictionary[keyCountString]];
              NSInteger theTotalCount = theSongsTotalNumberString.integerValue;
              if (!theSongsDictionary[keyItemsString])
              {
                  theError = [NSError errorWithDomain:keyErrorDomain
                                                 code:UserServiceErrorNoData
                                             userInfo:nil];
                  [BZExtensionsManager methodAsyncMainWithBlock:^
                   {
                       theCompletionBlock(theError);
                   }];
                  return;
              }
              NSArray *theJSONArray = theSongsDictionary[keyItemsString];
              [theLoadedJSONArray addObjectsFromArray:theJSONArray];
              if (theLoadedJSONArray.count > theTotalCount)
              {
                  BZAssert(nil);
              }
              if (theJSONArray.count)
              {
                  self.theCurrentMultiplier++;
                  [self methodLoadAllSongsToCoreDataWithOffset:theCount * self.theCurrentMultiplier
                                                         count:keyNumberOfLoads
                                                         array:theLoadedJSONArray
                                                    completion:theCompletionBlock];
                  return;
              }
              [BZExtensionsManager methodAsyncMainWithBlock:^
               {
                   NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                   NSManagedObjectContext *mainMOC = [DataManager sharedInstance].managedObjectContext;
                   temporaryContext.parentContext = mainMOC;
                   
                   [temporaryContext performBlock:^{
                       NSManagedObjectContext *theManagedObjectContext = [DataManager sharedInstance].managedObjectContext;
                       NSFetchRequest *theFetchRequest = [NSFetchRequest new];
                       theFetchRequest.entity = [NSEntityDescription entityForName:sfc([Song class])
                                                            inManagedObjectContext:theManagedObjectContext];
                       theFetchRequest.includesSubentities = NO;
                       theFetchRequest.propertiesToFetch = @[sfs(@selector(theSongID))];
                       
                       NSMutableArray *theCurrentSongArray = [theManagedObjectContext
                                                              executeFetchRequest:theFetchRequest
                                                              error:nil].mutableCopy;
                       for (int i = 0; i < theLoadedJSONArray.count; i++)
                       {
                           NSDictionary *theDictionary = theLoadedJSONArray[i];
                           
                           NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"%K == %@", sfs(@selector(theSongID)), [NSString stringWithFormat:@"%@", theDictionary[keySongIdString]]];
                           Song *theNewSong = [theCurrentSongArray filteredArrayUsingPredicate:thePredicate].firstObject;
                           if (theNewSong)
                           {
                               [theNewSong methodFillWithDictionary:theDictionary];
                               theNewSong.theIndex = [NSString stringWithFormat:@"%zd", i];
                               [theCurrentSongArray removeObjectAtIndex:[theCurrentSongArray indexOfObject:theNewSong]];
                           }
                           else
                           {
                               theNewSong = [Song methodInitWithDictionary:theDictionary];
                               theNewSong.theIndex = [NSString stringWithFormat:@"%zd", i];
                           }
                       }
                       for (Song *theSong in theCurrentSongArray)
                       {
                           if (isEqual(theSong.theOwnerID, [UserDefaults sharedInstance].theUserIdString))
                           {
                               [theSong.managedObjectContext deleteObject:theSong];
                           }
                       }
                       if (theManagedObjectContext.hasChanges)
                       {
                           [theManagedObjectContext save:nil];
                       }
                       
                       // do something that takes some time asynchronously using the temp context
                       
                       // push to parent
                       NSError *error;
                       if (![temporaryContext save:&error])
                       {
                           // handle error
                       }
                       
                       // save parent to disk asynchronously
                       [mainMOC performBlock:^{
                           NSError *error;
                           if (![mainMOC save:&error])
                           {
                               // handle error
                           }
                           else
                           {
                               theCompletionBlock(theError);
                           }
                       }];
                   }];
               }];
          }];
     }];
}

- (void)methodLoadAllSongsToCoreDataWithCompletion:(void (^ _Nullable)(NSError * _Nullable error))theCompletionBlock
{
    NSMutableArray *theJSONArray = [NSMutableArray new];
    [self methodLoadAllSongsToCoreDataWithOffset:0
                                           count:keyNumberOfLoads
                                           array:theJSONArray
                                      completion:theCompletionBlock];
}

- (void)methodLoadSongsWithSearchString:(NSString * _Nonnull)theSearchString
                             withOffset:(NSUInteger)theOffset
                                  count:(NSUInteger)theCount
                                taskKey:(NSString * _Nonnull)theTaskKey
                             completion:(void (^ _Nonnull)(NSArray<Song *> * _Nullable theSongsArray, NSUInteger theSongsCount, NSError * _Nullable error))theCompletionBlock
{
    BZAssert(theTaskKey && theCompletionBlock && theCount && theSearchString);
    theSearchString = [theSearchString stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceCharacterSet]];
    
    NSString *theUserIdString = [UserDefaults sharedInstance].theUserIdString;
    NSString *theAccessTokenString = [UserDefaults sharedInstance].theAccessToken;
    BZAssert(theUserIdString && theAccessTokenString);
    BZURLSession *theSession;
    if (!self.theServiceDictionary[theTaskKey])
    {
        theSession = [BZURLSession new];
        self.theServiceDictionary[theTaskKey] = theSession;
    }
    else
    {
        theSession = self.theServiceDictionary[theTaskKey];
    }
    NSString *theLoadUrlString = [NSString stringWithFormat:@"%@audio.search?q=%@&search_own=0&auto_complete=1&count=%zd&offset=%zd&access_token=%@&v=5.50",HOST_NAME_CONSTANT, theSearchString, theCount, theOffset, theAccessTokenString];
    //    NSLog(@"%@", theLoadUrlString);
    NSURL *theNSURL = [NSURL URLWithString:[theLoadUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [theSession methodStartDownloadTaskWithURL:theNSURL
                                 progressBlock:nil
                       completionBlockWithData:^(NSData * _Nullable data, NSError * _Nullable error)
     {
         [BZExtensionsManager methodAsyncBackgroundWithBlock:^
          {
              NSError *theError;
              if (!data)
              {
                  theError = [NSError errorWithDomain:keyErrorDomain
                                                 code:UserServiceErrorNoData
                                             userInfo:nil];
                  [BZExtensionsManager methodAsyncMainWithBlock:^
                   {
                       theCompletionBlock(nil, 0, theError);
                   }];
                  return;
              }
              if (error)
              {
                  theError = [NSError errorWithDomain:error.domain code:UserServiceErrorWithError userInfo:error.userInfo];
                  [BZExtensionsManager methodAsyncMainWithBlock:^
                   {
                       theCompletionBlock(nil, 0, theError);
                   }];
                  return;
              }
              NSDictionary *theSongsDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                 options:kNilOptions
                                                                                   error:&theError];
              if (error)
              {
                  theError = [NSError errorWithDomain:error.domain
                                                 code:UserServiceErrorWithError
                                             userInfo:error.userInfo];
                  [BZExtensionsManager methodAsyncMainWithBlock:^
                   {
                       theCompletionBlock(nil, 0, theError);
                   }];
                  return;
              }
              if (![theSongsDictionary isKindOfClass:[NSDictionary class]])
              {
                  theError = [NSError errorWithDomain:keyErrorDomain
                                                 code:UserServiceErrorNoData
                                             userInfo:nil];
                  [BZExtensionsManager methodAsyncMainWithBlock:^
                   {
                       theCompletionBlock(nil, 0, theError);
                   }];
                  return;
              }
              if (theSongsDictionary[keyCaptchaError])
              {// captcha error
                  NSDictionary *theErrorDictionary = theSongsDictionary[keyCaptchaError];
                  if (!theErrorDictionary[keyCaptchaID] || !theErrorDictionary[keyCaptchaImg])
                  {
                      theError = [NSError errorWithDomain:keyErrorDomain
                                                     code:UserServiceErrorNoData
                                                 userInfo:nil];
                      [BZExtensionsManager methodAsyncMainWithBlock:^
                       {
                           theCompletionBlock(nil, 0, theError);
                       }];
                      return;
                      
                  }
                  NSDictionary* theCapthchaDictionary = [NSDictionary dictionaryWithObjectsAndKeys: theErrorDictionary[keyCaptchaID], keyCaptchaID, theErrorDictionary[keyCaptchaImg], keyCaptchaImg, nil];
                  theError = [NSError errorWithDomain:keyErrorDomain
                                                 code:UserServiceErrorWithCaptcha
                                             userInfo:theCapthchaDictionary];
                  [BZExtensionsManager methodAsyncMainWithBlock:^
                   {
                       theCompletionBlock(nil, 0, theError);
                   }];
                  return;
              }
              if (!theSongsDictionary[keyResponseString])
              {
                  theError = [NSError errorWithDomain:keyErrorDomain
                                                 code:UserServiceErrorNoData
                                             userInfo:nil];
                  [BZExtensionsManager methodAsyncMainWithBlock:^
                   {
                       theCompletionBlock(nil, 0, theError);
                   }];
                  return;
              }
              theSongsDictionary = theSongsDictionary[keyResponseString];
              if (!theSongsDictionary[keyCountString])
              {
                  theError = [NSError errorWithDomain:keyErrorDomain
                                                 code:UserServiceErrorNoData
                                             userInfo:nil];
                  [BZExtensionsManager methodAsyncMainWithBlock:^
                   {
                       theCompletionBlock(nil, 0, theError);
                   }];
                  return;
              }
              NSString *theSongsTotalNumberString = [NSString stringWithFormat:@"%@",theSongsDictionary[keyCountString]];
              NSInteger theTotalCount = theSongsTotalNumberString.integerValue;
              if (!theSongsDictionary[keyItemsString])
              {
                  theError = [NSError errorWithDomain:keyErrorDomain
                                                 code:UserServiceErrorNoData
                                             userInfo:nil];
                  [BZExtensionsManager methodAsyncMainWithBlock:^
                   {
                       theCompletionBlock(nil, 0, theError);
                   }];
                  return;
              }
              [BZExtensionsManager methodAsyncMainWithBlock:^
               {
                   NSArray<Song *> *theNonUserSongsArray = [Song methodGetAllNonUserSongs];
                   
                   NSArray *theJSONArray = theSongsDictionary[keyItemsString];
                   NSMutableArray<Song *> *theNewSongArray = [NSMutableArray new];
                   for (int i = 0; i < theJSONArray.count; i++)
                   {
                       NSDictionary *theDictionary = theJSONArray[i];
                       BOOL isInCoreData = NO;
                       for (int  j  =  0; j < theNonUserSongsArray.count; j++)
                       {
                           if (isEqual(theNonUserSongsArray[j].theSongID, [NSString stringWithFormat:@"%@", theDictionary[@"id"]]))
                           {
                               isInCoreData = YES;
                               [theNewSongArray addObject:theNonUserSongsArray[j]];
                           }
                       }
                       if (!isInCoreData)
                       {
                           Song *theNewSong;
                           theNewSong = [Song methodInitWithDictionary:theDictionary];
                           [theNewSongArray addObject:theNewSong];
                       }
                   }
                   if ([[DataManager sharedInstance].managedObjectContext hasChanges])
                   {
                       [[DataManager sharedInstance].managedObjectContext save:nil];
                   }
                   theCompletionBlock(theNewSongArray, theTotalCount, theError);
               }];
          }];
     }
     ];
}

- (void)methodDownloadSongWithURL:(NSString * _Nonnull)theURLString
                          taskKey:(NSString * _Nonnull)theTaskKey
                         progress:(void(^ _Nullable)(double theProgress, NSData * _Nullable theReceivedData))theProgressBlock
                       completion:(void (^ _Nonnull)(NSError * _Nullable error))theCompletionBlock
{
    BZAssert(theTaskKey && theCompletionBlock && theURLString);
    BZURLSession *theSession;
    if (!self.theServiceDictionary[theTaskKey])
    {
        theSession = [BZURLSession new];
        self.theServiceDictionary[theTaskKey] = theSession;
    }
    else
    {
        theSession = self.theServiceDictionary[theTaskKey];
    }
    NSURL *theNSURL = [NSURL URLWithString:[theURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [theSession methodStartDownloadTaskWithURL:theNSURL
                         progressBlockWithData:^(double theProgress, NSData * _Nullable theReceivedData)
     {
         theProgressBlock(theProgress, theReceivedData);
     }
                               completionBlock:^(NSError * _Nullable theError)
     {
         if (!theError)
         {
             
             theCompletionBlock(nil);
         }
         else
         {
             theCompletionBlock([NSError errorWithDomain:@"Domain" code:111 userInfo:nil]);
         }
     }];
}

#pragma mark - Methods (Private)

#pragma mark - Standard Methods

@end






























