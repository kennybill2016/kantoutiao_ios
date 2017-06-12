//
//  UserManager.h
//  TTNews
//
//  Created by lijinwei on 2017/6/8.
//  Copyright © 2017年 瑞文戴尔. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUserLoginNotification @"UserLoginNotification"
#define kUserLogoutNotification @"UserLogoutNotification"

@interface UserManager : NSObject

@property (nonatomic,copy) NSString *uid;

@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *iconurl;

@property (nonatomic,copy) NSString *accessToken;
@property (nonatomic,copy) NSString *openid;

+ (instancetype)sharedUserManager;

- (BOOL)isLogined;
- (void)loadUserInfo;

- (void)setUserInfoFromMobile:(NSString*)mobile;
- (void)setUserInfo:(NSString*)userName iconUrl:(NSString*)url uid:(NSString*)uid ;

@end
