//
//  FavouritesVC.h
//  VKMusicClient
//
//  Created by User on 12.03.16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Song;

@protocol FavouiteVCDeleteSongDelegate;

@interface FavouritesVC : UIViewController 

@property (nonatomic, weak) id<FavouiteVCDeleteSongDelegate> theDeleteSongDelegate;
@property (nonatomic, assign) BOOL isEditing;

@end

@protocol FavouiteVCDeleteSongDelegate <NSObject>

@optional

- (void)favouriteVC:(FavouritesVC * _Nonnull)theFavouriteVC
      didDeleteSong:(Song * _Nonnull)theSong;

@end




























