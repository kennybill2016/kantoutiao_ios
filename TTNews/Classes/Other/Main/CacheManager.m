//
//  CacheManager.m
//  TTNews
//
//  Created by lijinwei on 2017/6/16.
//  Copyright © 2017年 瑞文戴尔. All rights reserved.
//

#import "CacheManager.h"
#import "NSString+Addition.h"
#import "HUAJSONKit.h"
#import "GTMBase64.h"
#import "SXNewsEntity.h"

@implementation CacheManager

+ (instancetype)sharedInstance
{
    static CacheManager *instance = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        instance = [CacheManager new];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent: @"cache.db"];
        _database = [FMDatabase databaseWithPath:path];
        if (![_database open]) {
            _database = nil;
        };
        [_database executeStatements: @"create table if not exists cacheContent(cacheid text primary key, gid text,cid text,data text);"];
        [_database executeStatements: @"create table if not exists cacheRecords(cacheid text primary key, gid text,cid text,data text);"];
    }
    return self;
}

#pragma mark - add record

- (void)saveContent:(NSString *)gid  withType:(NSString*)cid sourceData:(NSString *)content
{
    NSString* cacheID = [NSString stringWithFormat:@"cid%@gid%@",cid,gid];
    
    NSString *sql = [NSString stringWithFormat: @"delete from cacheContent where cacheid = '%@'", cacheID];
    [self.database executeUpdate: sql];
    
    if(cacheID) {
        NSString *sql = [NSString stringWithFormat: @"insert into cacheContent(cacheid, gid,cid,data) values('%@', '%@','%@','%@')", cacheID, gid,cid,content];
        [self.database executeUpdate: sql];
    }
}

- (NSString *)getContentWithType:(NSString*)cid withGid:(NSString*)gid
{
    NSString* cacheID = [NSString stringWithFormat:@"cid%@gid%@",cid,gid];
    NSString* sql = [NSString stringWithFormat:@"select * from cacheContent where cacheid='%@'",cacheID];
    FMResultSet *reslutSet = [self.database executeQuery: sql];
    while ([reslutSet next]) {
        NSString* data = [reslutSet stringForColumn:@"data"];
        return data;
    }
    return nil;
}

//reocrd
- (void)saveRecords:(NSString*)cid sourceData:(NSArray *)records
{
    for(NSInteger index = 0; index<records.count;index++) {
        NSDictionary* dictItem = [records objectAtIndex:index];
        NSString* gid = dictItem[@"nid"]?:@"";
        NSString* cacheID = [NSString stringWithFormat:@"cid%@gid%@",cid,gid];
        NSString* sourceStr = [dictItem JSONString];
        NSString *sql = [NSString stringWithFormat: @"insert into cacheRecords(cacheid, gid,cid,data) values('%@', '%@','%@','%@')", cacheID, gid,cid,sourceStr];
        [self.database executeUpdate: sql];
    }
}

- (NSArray *)recordsWithType:(NSString*)cid
{
    NSMutableArray *array = [NSMutableArray array];
    NSString* sql = [NSString stringWithFormat:@"select * from cacheRecords where cid='%@'",cid];
    FMResultSet *reslutSet = [self.database executeQuery:sql];
    while ([reslutSet next]) {
        NSString* data = [reslutSet stringForColumn:@"data"];
        NSDictionary *dic = [data objectFromJSONString];
        if (dic) {
            [array insertObject:dic atIndex:0];
        }
    }
    return array;
}

- (NSArray *)records
{
    NSMutableArray *array = [NSMutableArray array];
    FMResultSet *reslutSet = [self.database executeQuery: @"select * from cacheRecords"];
    while ([reslutSet next]) {
        NSString* data = [reslutSet stringForColumn:@"data"];
        NSDictionary *dic = [data objectFromJSONString];
        if (dic) {
            [array insertObject:dic atIndex:0];
        }
    }
    return array;
}

- (void)deleteAllRecords
{
    NSString *sql = [NSString stringWithFormat: @"delete from cacheRecords"];
    [self.database executeUpdate: sql];
    sql = [NSString stringWithFormat: @"delete from cacheContent"];
    [self.database executeUpdate: sql];
}

@end
