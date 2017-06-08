//
//  UserManager.h
//  TTNews
//
//  Created by lijinwei on 2017/6/8.
//  Copyright © 2017年 瑞文戴尔. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserManager : NSObject

@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *mobile;

+ (instancetype)sharedUserManager;

@end
