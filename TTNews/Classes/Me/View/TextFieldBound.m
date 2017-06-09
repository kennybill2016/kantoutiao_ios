//
//  TextFieldBound.m
//  TTNews
//
//  Created by lijinwei on 2017/6/9.
//  Copyright © 2017年 瑞文戴尔. All rights reserved.
//

#import "TextFieldBound.h"
#define kLeftPadding 10
#define kVerticalPadding 6
#define kHorizontalPadding 130

@implementation TextFieldBound

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGFloat y = bounds.origin.y;
    return CGRectMake(bounds.origin.x,y,bounds.size.width - kHorizontalPadding, bounds.size.height);
}

//- (CGRect)placeholderRectForBounds:(CGRect)bounds {
//    return [self textRectForBounds:bounds];
//}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x,bounds.origin.y,bounds.size.width - kHorizontalPadding, bounds.size.height);
//    return [self textRectForBounds:bounds];
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGFloat y = bounds.origin.y;
    return CGRectMake(bounds.size.width-130,y,30, bounds.size.height);
}

@end
