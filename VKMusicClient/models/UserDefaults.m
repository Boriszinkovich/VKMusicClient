//
//  UserDefaults.m
//  VKMusicClient
//
//  Created by User on 11.03.16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "UserDefaults.h"

#import "AudioPlayer.h"

@interface UserDefaults ()

@property (nonatomic, strong, nullable) NSUserDefaults *theNSUserDefaults;

@end

@implementation UserDefaults

#pragma mark - Class Methods (Public)

+ (UserDefaults * _Nonnull)sharedInstance
{
    static UserDefaults *theUserDefaults;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      theUserDefaults = [[UserDefaults alloc] initSharedInstance];
                  });
    return theUserDefaults;
}

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

- (instancetype)initSharedInstance
{
    self = [super init];
    if (self)
    {
        [self methodInitUserDefaults];
    }
    return self;
}

- (void)methodInitUserDefaults
{
    self.theNSUserDefaults =[NSUserDefaults standardUserDefaults];
}

- (instancetype)init
{
    BZAssert(nil);
}

#pragma mark - Setters (Public)

- (void)setTheAccessToken:(NSString * _Nullable)theAccessToken
{
    [self.theNSUserDefaults setObject:theAccessToken forKey:sfs(@selector(theAccessToken))];
    [self.theNSUserDefaults synchronize];
}

- (void)setTheUserIdString:(NSString * _Nullable)theUserIdString
{
    [self.theNSUserDefaults setObject:theUserIdString forKey:sfs(@selector(theUserIdString))];
    [self.theNSUserDefaults synchronize];
}

- (void)setTheMixChosedString:(NSString *)theMixChosedString
{
    [self.theNSUserDefaults setObject:theMixChosedString forKey:sfs(@selector(theMixChosedString))];
    [self.theNSUserDefaults synchronize];
}

- (void)setTheRepeatSongChosedString:(NSString *)theRepeatSongChosedString
{
    [self.theNSUserDefaults setObject:theRepeatSongChosedString forKey:sfs(@selector(theRepeatSongChosedString))];
    [self.theNSUserDefaults synchronize];
}

- (void)setTheSongsSortType:(SongsSortType)theSongsSortType
{
    BZAssert((BOOL)(theSongsSortType <= SongsSortTypeEnumCount));
    NSString *theSongSortTypeString = [NSString stringWithFormat:@"%zd", theSongsSortType];
    [self.theNSUserDefaults setObject:theSongSortTypeString forKey:sfs(@selector(theSongsSortType))];
    [self.theNSUserDefaults synchronize];
}

#pragma mark - Getters (Public)

- (NSString *)theAccessToken
{
    return [self.theNSUserDefaults objectForKey:sfs(@selector(theAccessToken))];
}

- (NSString *)theUserIdString
{
    return [self.theNSUserDefaults objectForKey:sfs(@selector(theUserIdString))];
}

- (NSString *)theMixChosedString
{
    NSString *theMixChosedString = [self.theNSUserDefaults objectForKey:sfs(@selector(theMixChosedString))];
    if (!theMixChosedString)
    {
        theMixChosedString = @"0";
        self.theMixChosedString = theMixChosedString;
    }
    return theMixChosedString;
}

- (NSString *)theRepeatSongChosedString
{
    NSString *theRepeatSongChosedString = [self.theNSUserDefaults objectForKey:sfs(@selector(theRepeatSongChosedString))];
    if (!theRepeatSongChosedString)
    {
        theRepeatSongChosedString = @"0";
        self.theRepeatSongChosedString = theRepeatSongChosedString;
    }
    return theRepeatSongChosedString;
}

- (SongsSortType)theSongsSortType
{
    NSString *theSongSortTypeString = [self.theNSUserDefaults objectForKey:sfs(@selector(theSongsSortType))];
    if (!theSongSortTypeString)
    {
        theSongSortTypeString = [NSString stringWithFormat:@"%zd", SongsSortTypeDate];
        self.theSongsSortType = theSongSortTypeString.integerValue;
    }
    return theSongSortTypeString.integerValue;
}

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

#pragma mark - Standard Methods

@end






























