//
//  DetailPlayListVC.h
//  VKMusicClient
//
//  Created by Boris on 4/5/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayList;
@class CreatePlayListVC;

@interface DetailPlayListVC : UIViewController

@property (nonatomic, strong, nonnull) PlayList *thePlayList;
@property (nonatomic, strong, nonnull) NSMutableArray *theSongsMutableArray;
@property (nonatomic, strong, nonnull) NSMutableArray *theIndexesMutableArray;
@property (nonatomic, strong, nonnull) NSString *thePlayListNameString;
@property (nonatomic, weak) CreatePlayListVC *thePlayListVC;

@end






























