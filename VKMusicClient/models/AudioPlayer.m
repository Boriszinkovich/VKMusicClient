//
//  AudioPlayer.m
//  VKMusicClient
//
//  Created by Boris on 3/21/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "AudioPlayer.h"

#import "Song.h"
#import "UserDefaults.h"

#import <AVFoundation/AVFoundation.h>

@interface AudioPlayer ()

@property (strong, nonatomic) AVAudioSession *theAudioSession;
@property (strong, nonatomic) AVPlayer *thePlayer;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isInterrupted;
@property (nonatomic, strong, nonnull) Reachability *theReachability;
@property (nonatomic, strong, nonnull) id theTimeObserver;
@property (nonatomic, strong, nonnull) UserDefaults *theUserDefaults;
@property (nonatomic, strong, nonnull) NSMutableSet<NSNumber *> *theListenedSongSet;
@property (nonatomic, assign) NSInteger theCountOfLoadedSongs;
@property (nonatomic, assign) NSInteger theCurrentSongDuration;

@end

NSString * const keyHeadPhones = @"Headphones";

@implementation AudioPlayer

#pragma mark - Class Methods (Public)

+ (AudioPlayer * _Nonnull)sharedInstance;
{
    static AudioPlayer *theAudioPlayer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      theAudioPlayer = [[AudioPlayer alloc] initSharedInstance];
                  });
    return theAudioPlayer;
}

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (instancetype _Nonnull)initSharedInstance
{
    self = [super init];
    if (self)
    {
        [self methodInitAudioPlayer];
    }
    return self;
}

- (void)methodInitAudioPlayer
{
    self.theAudioSession = [AVAudioSession sharedInstance];
    
    NSError *theCategoryError = nil;
    [self.theAudioSession setCategory:AVAudioSessionCategoryPlayback
                          withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                error:nil];
    
    BZAssert(!theCategoryError);
    
    [self methodChangeAudioOutputDevice];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAVAudioSessionInterruptionNotification:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:[AVAudioSession sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAVAudioSessionRouteChangeNotification:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:[AVAudioSession sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAVAudioSessionMediaServicesWereResetNotification:)
                                                 name:AVAudioSessionMediaServicesWereResetNotification
                                               object:[AVAudioSession sharedInstance]];
    
    Reachability *theReachability = [Reachability reachabilityForInternetConnection];
    self.theReachability = theReachability;
    weakify(self);
    theReachability.reachableBlock = ^(Reachability * reachability)
    {
        strongify(self);
        CMTime theCurrentTime = self.thePlayer.currentItem.currentTime;
        if (self.theCurentSelectedSongIndex > self.theSongArray.count)
        {
            BZAssert(nil);
        }
        if (!isEqual(self.theSongArray[self.theCurentSelectedSongIndex].theLoadedProgress, @"100"))
        {
            [self methodInitAndPlayCurrentSong];
            [self methodSeekToSecond:(NSUInteger)(theCurrentTime.value / theCurrentTime.timescale)];
        }
    };
    [theReachability startNotifier];
    
    self.theSongArray = [Song methodGetAllUserSongs];
    self.theUserDefaults = [UserDefaults sharedInstance];
    self.theListenedSongSet = [NSMutableSet new];
}

- (instancetype)init
{
    BZAssert(nil);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setters (Public)

- (void)setTheCurentSelectedSongIndex:(NSUInteger)theCurentSelectedSongIndex
{
    BZAssert(self.theSongArray);
    BZAssert((BOOL)(theCurentSelectedSongIndex < self.theSongArray.count));
    if (_theCurentSelectedSongIndex == theCurentSelectedSongIndex)
    {
        return;
    }
    _theCurentSelectedSongIndex = theCurentSelectedSongIndex;
}

- (void)setTheSongArray:(NSArray<Song *> * _Nonnull)theSongArray
{
    BZAssert(theSongArray);
    if (isEqual(theSongArray, _theSongArray))
    {
        return;
    }
    _theSongArray = theSongArray;
    self.theCountOfLoadedSongs = [self methodGetCountOfLoadedSongs];
}

#pragma mark - Getters (Public)

#pragma mark - Setters (Private)

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

#pragma mark - Create Views & Variables

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Notifications

- (void)receiveAVAudioSessionInterruptionNotification:(NSNotification *)theNotification
{
    NSNumber *theInterruptionType = [theNotification userInfo][AVAudioSessionInterruptionTypeKey];
    NSNumber *theInterruptionOption = [theNotification userInfo][AVAudioSessionInterruptionOptionKey];
    
    switch (theInterruptionType.unsignedIntegerValue)
    {
        case AVAudioSessionInterruptionTypeBegan:
        {
            [self.thePlayer pause];
            self.isInterrupted = YES;
        }
            break;
        case AVAudioSessionInterruptionTypeEnded:
        {

            if (theInterruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume)
            {
                [self methodChangeAudioOutputDevice];
                [self.thePlayer play];
                self.isInterrupted = NO;
            }
        }
            break;
        default:
            BZAssert(nil);
    }
}

- (void)receiveAVAudioSessionRouteChangeNotification:(NSNotification *)theNotification
{
    if (!self.isInterrupted)
    {
        [self.thePlayer pause];
        BOOL isAllowedToPlay = [self methodChangeAudioOutputDevice];
        if (self.isPlaying && isAllowedToPlay)
        {
            [self.thePlayer play];
        }
        else
        {
            self.isPlaying = NO;
            if ([self.thePlayerDelegate respondsToSelector:@selector(audioPlayerWasPaused:)])
            {
                [self.thePlayerDelegate audioPlayerWasPaused:self];
            }
        }
    }
}

- (void)receiveInternalPlayerDidReachEnd:(NSNotification *)theNotification
{
    if (self.theUserDefaults.theRepeatSongChosedString.boolValue)
    {
        [self methodSeekToSecond:0];
        [self methodPlay];
    }
    else
    {
        [self methodPlayNext];
    }
}

- (void)receiveAVAudioSessionMediaServicesWereResetNotification:(NSNotification *)theNotification
{
    BZAssert(nil);
}

#pragma mark - Delegates ()

#pragma mark - Methods (Public)

- (void)methodPlay
{
    if (!self.isPlaying)
    {
        if (self.thePlayer)
        {
            [self.thePlayer play];
        }
        else
        {
            [self methodStartPlay];
        }
        self.isPlaying = YES;
    }
 }

- (void)methodPause
{
    BZAssert(self.thePlayer);
    if (self.isPlaying)
    {
        if (self.thePlayer)
        {
            [self.thePlayer pause];
        }
        self.isPlaying = NO;
    }
}

- (void)methodPlayNext
{
    BOOL isCurrentSongRepeated = [UserDefaults sharedInstance].theRepeatSongChosedString.boolValue;
    if (!isCurrentSongRepeated)
    {
        if (!self.theReachability.isReachable && !isEqual(self.theSongArray[self.theCurentSelectedSongIndex].theLoadedProgress, @"100"))
        {
            [self methodStartPlay];
        }
        else
        {
            [self methodFindNextSong];
            [self methodStartPlay];
        }
    }
    else
    {
        [self methodFindNextSong];
        [self methodInitAndPlayCurrentSong];
    }
}

- (void)methodPlayPrevious
{
    BOOL isCurrentSongRepeated = [UserDefaults sharedInstance].theRepeatSongChosedString.boolValue;
    if (!isCurrentSongRepeated)
    {
        if (!self.theReachability.isReachable && !isEqual(self.theSongArray[self.theCurentSelectedSongIndex].theLoadedProgress, @"100"))
        {
            [self methodFindPreviousSong];
            [self methodInitAndPlayCurrentSong];
        }
        else
        {
            [self methodFindPreviousSong];
            [self methodInitAndPlayCurrentSong];
        }
    }
    else
    {
        [self methodFindPreviousSong];
        [self methodInitAndPlayCurrentSong];
    }
}

- (NSInteger)methodGetCurrentSongDuration
{
    BZAssert((BOOL)(self.theCurentSelectedSongIndex < self.theSongArray.count));
    return self.theSongArray[self.theCurentSelectedSongIndex].theDuration.integerValue;
}

- (void)methodSeekToSecond:(NSUInteger)theSecond
{
    if (!self.thePlayer)
    {
        [self methodStartPlay];
    }
    else
    {
        CMTime cmTime = CMTimeMake(theSecond * 1000, 1000);
        [self.thePlayer seekToTime:cmTime
                   toleranceBefore:kCMTimeZero
                    toleranceAfter:kCMTimePositiveInfinity];
    }
}

- (void)methodStartPlay
{
    BZAssert(self.theSongArray);
    if (!self.theUserDefaults.theRepeatSongChosedString.boolValue && !self.theReachability.isReachable && !isEqual(self.theSongArray[self.theCurentSelectedSongIndex].theLoadedProgress, @"100"))
    {
        if (self.theCountOfLoadedSongs)
        {
            [self methodFindNextSong];
        }
    }
    [self methodInitAndPlayCurrentSong];
}

- (NSInteger)methodGetCurrentPlayedSecond
{
    BZAssert(self.thePlayer);
    CMTime theCurrentTime = self.thePlayer.currentItem.currentTime;
    NSUInteger theSecond = (NSUInteger)((float)theCurrentTime.value /  (float)theCurrentTime.timescale);
    return theSecond;
}

#pragma mark - Methods (Private)

- (BOOL)methodChangeAudioOutputDevice
{
    // choose headphones or none
    [self.theAudioSession setCategory: AVAudioSessionCategoryPlayback error:nil];
    AVAudioSessionPortDescription *theRoutePort = [AVAudioSession sharedInstance].currentRoute.outputs.firstObject;
    NSString *thePortType = theRoutePort.portType;
    BOOL isAllowedToChange = YES;
    if ([thePortType isEqualToString:keyHeadPhones])
    {
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                                           error:nil];
    }
    else
    {
        isAllowedToChange = NO;
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone
                                                           error:nil];
    }
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    return isAllowedToChange;
}

- (void)methodFindNextSong
{
    if (self.theReachability.isReachable || self.theUserDefaults.theRepeatSongChosedString.boolValue)
    {
        if (self.theUserDefaults.theMixChosedString.boolValue)
        {
            [self methodChooseRandomSong];
        }
        else
        {
            [self methodChooseNextCurrentSelectedSongIndex];
        }
    }
    else
    {
        if (self.theUserDefaults.theMixChosedString.boolValue)
        {
            if (!self.theCountOfLoadedSongs)
            {
                return;
            }
            BOOL isFound = NO;
            BOOL isOnlyOne = self.theCountOfLoadedSongs == 1;
            NSInteger theSongCounter = 0;
            while (!isFound)
            {
                NSInteger theRandomNumber = 0 + arc4random() % self.theSongArray.count; 
                NSInteger theMultiplier = 1;
                if (isEqual(self.theSongArray[theRandomNumber].theLoadedProgress, @"100"))
                {
                    theMultiplier = -1;
                }
                else
                {
                    continue;
                }
                NSNumber *theChosedIndexNumber = [NSNumber numberWithInteger:self.theSongArray[theRandomNumber].theSongID.integerValue * theMultiplier];
                BOOL isEqualToCurrentSong = theChosedIndexNumber.integerValue == self.theSongArray[self.theCurentSelectedSongIndex].theSongID.integerValue * theMultiplier;
                if (![self.theListenedSongSet containsObject:theChosedIndexNumber] && (!isEqualToCurrentSong || isOnlyOne))
                {
                    isFound = YES;
                    self.theCurentSelectedSongIndex = theRandomNumber;
                    [self.theListenedSongSet addObject:theChosedIndexNumber];
                    break;
                }
                theSongCounter++;
                if (theSongCounter == self.theSongArray.count)
                {
                    self.theListenedSongSet = [NSMutableSet new];
                    theSongCounter = 0;
                }
            }
        }
        else
        {
            if (!self.theCountOfLoadedSongs)
            {
                return;
            }
            BOOL isFound = NO;
            while (!isFound)
            {
                [self methodChooseNextCurrentSelectedSongIndex];
                if (isEqual(self.theSongArray[self.theCurentSelectedSongIndex].theLoadedProgress, @"100"))
                {
                    break;
                }
            }
        }
    }
}

- (void)methodChooseNextCurrentSelectedSongIndex
{
    if (self.theCurentSelectedSongIndex == self.theSongArray.count - 1)
    {
        self.theCurentSelectedSongIndex = 0;
    }
    else
    {
        self.theCurentSelectedSongIndex++;
    }
}

- (void)methodChoosePreviousSongIndex
{
    if (self.theCurentSelectedSongIndex == 0)
    {
        self.theCurentSelectedSongIndex = self.theSongArray.count - 1;
    }
    else
    {
        self.theCurentSelectedSongIndex--;
    }
}

- (void)methodFindPreviousSong
{
    if (self.theReachability.isReachable)
    {
        if (self.theUserDefaults.theMixChosedString.boolValue || self.theUserDefaults.theRepeatSongChosedString.boolValue)
        {
            [self methodChooseRandomSong];
        }
        else
        {
            [self methodChoosePreviousSongIndex];
        }
    }
    else
    {
        if (self.theUserDefaults.theMixChosedString.boolValue)
        {
            if (!self.theCountOfLoadedSongs)
            {
                return;
            }
            BOOL isFound = NO;
            BOOL isOnlyOne = self.theCountOfLoadedSongs == 1;
            NSInteger theSongCounter = 0;
            while (!isFound)
            {
                NSInteger theRandomNumber = 0 + arc4random() % self.theSongArray.count;
                NSInteger theMultiplier = 1;
                if (isEqual(self.theSongArray[theRandomNumber].theLoadedProgress, @"100"))
                {
                    theMultiplier = -1;
                }
                else
                {
                    continue;
                }
                NSNumber *theChosedIndexNumber = [NSNumber numberWithInteger:self.theSongArray[theRandomNumber].theSongID.integerValue * theMultiplier];
                BOOL isEqualToCurrentSong = theChosedIndexNumber.integerValue == self.theSongArray[self.theCurentSelectedSongIndex].theSongID.integerValue * theMultiplier;
                if (![self.theListenedSongSet containsObject:theChosedIndexNumber] && (!isEqualToCurrentSong || isOnlyOne))
                {
                    isFound = YES;
                    self.theCurentSelectedSongIndex = theRandomNumber;
                    [self.theListenedSongSet addObject:theChosedIndexNumber];
                    break;
                }
                theSongCounter++;
                 if (theSongCounter == self.theSongArray.count)
                {
                    self.theListenedSongSet = [NSMutableSet new];
                    theSongCounter = 0;
                }
            }
        }
        else
        {
            if (!self.theCountOfLoadedSongs)
            {
                return;
            }
            BOOL isFound = NO;
            while (!isFound)
            {
                [self methodChoosePreviousSongIndex];
                if (isEqual(self.theSongArray[self.theCurentSelectedSongIndex].theLoadedProgress, @"100"))
                {
                    break;
                }
            }
        }
    }
}

- (void)methodChooseRandomSong
{
    BOOL isFound = NO;
    NSInteger theSongCounter = 0;
    while (!isFound)
    {
        NSInteger theRandomNumber = 0 + arc4random() % self.theSongArray.count; // выбираем рандомное количество вопросов для данной категории
        NSInteger theMultiplier = 1;
        if (isEqual(self.theSongArray[theRandomNumber].theLoadedProgress, @"100"))
        {
            theMultiplier = -1;
        }
        NSNumber *theChosedIndexNumber = [NSNumber numberWithInteger:self.theSongArray[theRandomNumber].theSongID.integerValue * theMultiplier];
        if (![self.theListenedSongSet containsObject:theChosedIndexNumber])
        {
            isFound = YES;
            self.theCurentSelectedSongIndex = theRandomNumber;
            [self.theListenedSongSet addObject:theChosedIndexNumber];
            break;
        }
        theSongCounter++;
        if (theSongCounter == self.theSongArray.count)
        {
            self.theListenedSongSet = [NSMutableSet new];
            theSongCounter = 0;
        }
    }
}

- (void)methodInitAndPlayCurrentSong
{
    [self.thePlayer removeTimeObserver:self.theTimeObserver];
    self.theCurrentSongDuration = 0;
    Song *theSong = self.theSongArray[self.theCurentSelectedSongIndex];
    NSURL *theLoadedURL;
    if (!isEqual(theSong.theLoadedProgress, @"100"))
    {
        theLoadedURL = [NSURL URLWithString:theSong.theURLString];
    }
    else
    {
        NSString *thePath;
        NSArray *thePathesArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        thePath = [[thePathesArray objectAtIndex:0] stringByAppendingPathComponent:keyAppDirectoryName];
        thePath = [thePath stringByAppendingPathComponent:theSong.theFileURLString];
        theLoadedURL = [NSURL fileURLWithPath:thePath];
    }
    AVPlayerItem *thePlayerItem = [[AVPlayerItem alloc] initWithURL: theLoadedURL];
    self.thePlayer = [[AVPlayer alloc] initWithPlayerItem:thePlayerItem];
    self.thePlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveInternalPlayerDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.thePlayer currentItem]];
//    [self.thePlayer addObserver:self
//                     forKeyPath:@"currentItem.loadedTimeRanges"
//                        options:NSKeyValueObservingOptionNew
//                        context:nil];
    
    [self.thePlayer play];
    self.theCurrentSongDuration = [self methodGetCurrentSongDuration];
    self.isPlaying = YES;
    if ([self.thePlayerDelegate respondsToSelector:@selector(audioPlayer:didStartPlayingTheSong:)])
    {
        [self.thePlayerDelegate audioPlayer:self
                     didStartPlayingTheSong:theSong];
    }
//    double theListenCounterValue = theSong.theListenCounter.doubleValue + 1;
//    theSong.theListenCounter = [NSString stringWithFormat:@"%.d", theSong.theListenCounter.doubleValue + 1];
    double thePopularityValue = theSong.thePopularity.floatValue + 1;
    theSong.thePopularity =  [NSString stringWithFormat:@"%.02f", thePopularityValue];
    if ([theSong.managedObjectContext hasChanges])
    {
        [theSong.managedObjectContext save:nil];
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:keyPopularityChangedNotification
     object:theSong];
    CMTime theObserverInterval = CMTimeMake(1000, 1000); // 1 second
    weakify(self)
    self.theTimeObserver = [self.thePlayer addPeriodicTimeObserverForInterval:theObserverInterval
                                                                        queue:nil
                                                                   usingBlock:^(CMTime time)
                            {
                                strongify(self)
                                CMTime theEndTime = CMTimeConvertScale (self.thePlayer.currentItem.asset.duration, self.thePlayer.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
                                if (CMTimeCompare(theEndTime, kCMTimeZero) != 0)
                                {
                                    NSUInteger theSecond = (NSUInteger)((float)time.value /  (float)time.timescale);
//                                    if (theSecond == (self.theCurrentSongDuration / 2))
//                                    {
//                                    }
                                    if ([self.thePlayerDelegate respondsToSelector:@selector(audioPlayer:didPlayAtSecond:)])
                                    {
                                        [self.thePlayerDelegate audioPlayer:self didPlayAtSecond:theSecond];
                                    }
                                }
                            }];
}

- (NSInteger)methodGetCountOfLoadedSongs
{
    return [Song methodGetCountOfLoadedSongs];
}

#pragma mark - Standard Methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSArray *theTimeRanges = (NSArray *)change[NSKeyValueChangeNewKey];
    if (theTimeRanges && theTimeRanges.count)
    {
        CMTimeRange timerange = [theTimeRanges[0] CMTimeRangeValue];
        NSLog(@" . . . %.5f -> %.5f", CMTimeGetSeconds(timerange.start), CMTimeGetSeconds(CMTimeAdd(timerange.start, timerange.duration)));
    }
}

@end






























