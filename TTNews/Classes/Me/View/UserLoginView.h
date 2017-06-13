//
//  UserLoginView.h
//  TTNews
//
//  Created by lijinwei on 2017/6/12.
//  Copyright © 2017年 瑞文戴尔. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserInfoCellDelegate <NSObject>

- (void)tapQQLogin;
- (void)tapMobileLogin;

@end

@interface UserLoginView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic,weak)NSObject<UserInfoCellDelegate> *delegate;

@end
