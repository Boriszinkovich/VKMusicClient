//
//  SongsCell.h
//  VKMusicClient
//
//  Created by Boris on 3/14/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger
{
    SongsCellStyleNone = 1,
    SongsCellStyleCheckmark,
    SongsCellStyleDelete,
    SongsCellStyleEnumCount = SongsCellStyleDelete
} SongsCellStyle;

@class Song;

@interface SongsCell : UITableViewCell <ODTableViewCellHeightProtocol>

@property (nonatomic, strong, nonnull) Song *theSong;
@property (nonatomic, assign) SongsCellStyle theSongsCellStyle;
@property (nonatomic, assign) BOOL isEditing;

- (void)methodAdjustProgressView;
- (void)methodAdjustCounterLabel;

@end






























