//
//  UserManager.m
//  TTNews
//
//  Created by lijinwei on 2017/6/8.
//  Copyright © 2017年 瑞文戴尔. All rights reserved.
//

#import "UserManager.h"

NSString * const kUserNameKey = @"UserNameKey";
NSString * const kUidKey = @"UidKey";
NSString * const kUserIconUrlKey = @"UserIconUrlKey";


@implementation UserManager

+ (instancetype)sharedUserManager
{
    static UserManager*instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)loadUserInfo {
    self.username = [[NSUserDefaults standardUserDefaults] stringForKey:kUserNameKey];
    self.uid = [[NSUserDefaults standardUserDefaults] stringForKey:kUidKey];
    self.iconurl = [[NSUserDefaults standardUserDefaults] stringForKey:kUserIconUrlKey];    
}

- (void)saveUserInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoginNotification object:nil userInfo:nil];
    [[NSUserDefaults standardUserDefaults] setValue:self.username forKey:kUserNameKey];
    [[NSUserDefaults standardUserDefaults] setValue:self.uid forKey:kUidKey];
    [[NSUserDefaults standardUserDefaults] setValue:self.iconurl forKey:kUserIconUrlKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setUserInfoFromMobile:(NSString*)mobile{
    [self logout];
    self.username=mobile;
    self.mobile=mobile;
    
    [self saveUserInfo];
}

- (void)setUserInfo:(NSString*)userName iconUrl:(NSString*)url uid:(NSString*)uid{
    [self logout];
    self.username=userName;
    self.iconurl=url;
    self.uid=uid;

    [self saveUserInfo];
}

- (BOOL)isLogined{
    return (self.mobile.length>0 ||self.uid.length>0)?YES:NO;
}

- (void)logout {
    self.username=nil;
    self.iconurl=nil;
    self.uid=nil;
    self.accessToken=nil;
    self.mobile=nil;
}

@end
