//
//  PlayListCell.h
//  VKMusicClient
//
//  Created by Boris on 4/4/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayList;

@interface PlayListCell : UITableViewCell <ODTableViewCellHeightProtocol>

@property (nonatomic, strong, nonnull) PlayList *thePlayList;

@end






























