//
//  UserManager.m
//  TTNews
//
//  Created by lijinwei on 2017/6/8.
//  Copyright © 2017年 瑞文戴尔. All rights reserved.
//

#import "UserManager.h"

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

//uid=B36811DAC55EE945F1CC64E6A114F8A5
//token=5BFB253C926E6E34A9A1544FF3311D5C

- (void)setUserInfo:(NSString*)userName iconUrl:(NSString*)url uid:(NSString*)uid token:(NSString*)token mobile:(NSString*)mobile{
    
    self.username=userName;
    self.iconurl=url;
    self.uid=uid;
    self.accessToken=token;
    self.mobile=mobile;
}

@end
