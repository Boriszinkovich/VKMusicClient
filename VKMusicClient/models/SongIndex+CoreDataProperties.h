//
//  SongIndex+CoreDataProperties.h
//  VKMusicClient
//
//  Created by Boris on 4/4/16.
//  Copyright © 2016 BZ. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SongIndex.h"

@interface SongIndex (CoreDataProperties)

@property (nonatomic, retain, nullable) NSString *theIndexValue;
@property (nonatomic, retain, nullable) Song *theSong;
@property (nonatomic, retain, nullable) PlayList *thePlayList;

@end






























