//
//  CreatePlayListVC.h
//  VKMusicClient
//
//  Created by Boris on 4/4/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayList;

@interface CreatePlayListVC : UIViewController

@property (nonatomic, strong, nonnull) PlayList *thePlayList;
@property (nonatomic, strong, nonnull) NSMutableArray *theChosedSongsArray;
@property (nonatomic, strong, nonnull) NSMutableArray *theIndexesMutableArray;
@property (nonatomic, strong, nonnull) NSString *thePlayListNameString;

@end






























