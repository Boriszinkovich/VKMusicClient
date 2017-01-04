//
//  PlayerVC.h
//  VKMusicClient
//
//  Created by Boris on 3/22/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Song;
@class AudioPlayer;

@interface PlayerVC : UIViewController

- (instancetype _Nonnull)initWithSongArray:(NSArray * _Nonnull)theSongArray
              withCurrentSelectedSongIndex:(NSInteger)theCurrentSelectedSongIndex;

- (instancetype _Nonnull)initWithAudioPlayer:(AudioPlayer * _Nonnull)theAudioPlayer;

@end






























