//
//  UserDefaults.h
//  VKMusicClient
//
//  Created by User on 11.03.16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Song.h"

@interface UserDefaults : NSObject

@property (nonatomic, strong, nullable) NSString *theAccessToken;
@property (nonatomic, strong, nullable) NSString *theUserIdString;
@property (nonatomic, strong, nullable) NSString *theMixChosedString;
@property (nonatomic, strong, nullable) NSString *theRepeatSongChosedString;
@property (nonatomic, assign) SongsSortType theSongsSortType;

+ (UserDefaults * _Nonnull)sharedInstance;

@end






























