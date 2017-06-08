//
//  UIColor+HEX.h
//  360FreeWiFi
//
//  Created by lisheng on 14/11/4.
//  Copyright (c) 2014年 qihoo360. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HEX)

+ (UIColor *)parseColorFromRGB:(NSString *)rgb;
+ (UIColor *)parseColorFromRGBA:(NSString *)rgb Alpha:(float)alpha;


@end
