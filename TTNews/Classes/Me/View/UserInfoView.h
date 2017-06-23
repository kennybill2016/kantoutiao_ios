//
//  UserInfoView.h
//  TTNews
//
//  Created by lijinwei on 2017/6/12.
//  Copyright © 2017年 瑞文戴尔. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserInfoViewDelegate <NSObject>

- (void)tapUserBtn;
- (void)tapMoneyBtn;

@end

@interface UserInfoView : UIView

@property (nonatomic,weak)NSObject<UserInfoViewDelegate> *delegate;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)updateUI;

@end
