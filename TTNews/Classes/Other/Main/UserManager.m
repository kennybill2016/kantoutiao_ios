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

@end
