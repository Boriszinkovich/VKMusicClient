//
//  DataManager.h
//  VKMusicClient
//
//  Created by Boris on 3/15/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@interface DataManager : NSObject

@property (nonatomic, strong, nonnull) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, nonnull) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, nonnull) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DataManager * _Nonnull)sharedInstance;

- (void)saveContext;
- (NSURL * _Nonnull)applicationDocumentsDirectory;

@end






























