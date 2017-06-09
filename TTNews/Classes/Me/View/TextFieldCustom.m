//
//  TextFieldCustom.m
//  TTNews
//
//  Created by lijinwei on 2017/6/9.
//  Copyright © 2017年 瑞文戴尔. All rights reserved.
//

#import "TextFieldCustom.h"
#define kLeftPadding 10
#define kVerticalPadding 6

@implementation TextFieldCustom

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGFloat y = bounds.origin.y + kVerticalPadding;
    return CGRectMake(bounds.origin.x,y,bounds.size.width-30, bounds.size.height - kVerticalPadding*2);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

//- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
//    CGFloat y = bounds.origin.y;
//    return CGRectMake(bounds.size.width-30,y,30, bounds.size.height);
//}

@end
