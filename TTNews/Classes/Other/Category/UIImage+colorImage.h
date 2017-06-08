//
//  UIImage+colorImage.h
//  360FreeWiFi
//
//  Created by wangcheng on 16/4/12.
//  Copyright © 2016年 qihoo360. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (colorImage)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;


@end
