//
//  UserInfoCell.h
//  TTNews
//
//  Created by 瑞文戴尔 on 16/8/10.
//  Copyright © 2016年 瑞文戴尔. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserInfoCellDelegate <NSObject>

- (void)tapQQLogin;
- (void)tapMobileLogin;

@end

@interface UserInfoCell : UITableViewCell

@property (nonatomic,weak)NSObject<UserInfoCellDelegate> *delegate;

-(void)setAvatarImage:(UIImage *)image Name:(NSString *)name Signature:(NSString *)content;
@end
