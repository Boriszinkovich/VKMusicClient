//
//  UIImage+BZExtensions.h
//  ScrollViewTask
//
//  Created by BZ on 2/16/16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BZExtensions)

+ (UIImage * _Nullable)getImageNamed:(NSString * _Nonnull)theImageName;
+ (UIImage * _Nonnull)getImageFromColor:(UIColor * _Nonnull)theColor;

- (UIImage * _Nonnull)getImageWithSize:(CGSize)theSize;

@end






























