//
//  AudioPlayer.h
//  VKMusicClient
//
//  Created by Boris on 3/21/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Song;

@protocol AudioPlayerDelegate;

@interface AudioPlayer : NSObject

@property (nonatomic, strong, nonnull) NSArray<Song *> *theSongArray;
@property (nonatomic, assign) NSUInteger theCurentSelectedSongIndex;
@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, weak, nullable) id<AudioPlayerDelegate> thePlayerDelegate;

+ (AudioPlayer * _Nonnull)sharedInstance;

- (void)methodPlayNext;
- (void)methodPlayPrevious;
- (void)methodPause;
- (void)methodPlay;
- (void)methodStartPlay;
- (NSInteger)methodGetCurrentSongDuration;
- (void)methodSeekToSecond:(NSUInteger)theSecond;
- (NSInteger)methodGetCurrentPlayedSecond;

@end

@protocol AudioPlayerDelegate <NSObject>

@optional

- (void)audioPlayer:(AudioPlayer * _Nonnull) theAudioPlayer
didStartPlayingTheSong:(Song * _Nonnull)theSong;

- (void)audioPlayer:(AudioPlayer * _Nonnull) theAudioPlayer
didPlayAtSecond:(NSUInteger)theSecond;

- (void)audioPlayerWasPaused:(AudioPlayer * _Nonnull) theAudioPlayer;
- (void)audioPlayerWasStarted:(AudioPlayer * _Nonnull) theAudioPlayer;

@end






























