//
//  CacheManager.h
//  TTNews
//
//  Created by lijinwei on 2017/6/16.
//  Copyright © 2017年 瑞文戴尔. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface CacheManager : NSObject

@property (nonatomic, strong) FMDatabase *database;

+ (instancetype)sharedInstance;

- (NSArray *)records;

//缓存详情页信息
- (void)saveContent:(NSString *)gid  withType:(NSString*)cid sourceData:(NSString *)content;
- (NSString *)getContentWithType:(NSString*)cid withGid:(NSString*)gid;

- (void)saveRecords:(NSString*)cid sourceData:(NSArray *)records;
- (NSArray *)recordsWithType:(NSString*)cid;

- (void)deleteAllRecords;

@end
