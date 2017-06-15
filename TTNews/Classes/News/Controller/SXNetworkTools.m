//
//  SXNetworkTools.m
//  TTNews
//
//  Created by 瑞文戴尔 on 16/3/24.
//  Copyright © 2016年 瑞文戴尔. All rights reserved.//

#import "SXNetworkTools.h"
#import "NSString+Addition.h"
#import "QHProgressHUD.h"
#import "UserManager.h"

@implementation SXNetworkTools

+ (instancetype)sharedNetworkTools
{
    static SXNetworkTools*instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // http://c.m.163.com//nc/article/list/T1348649654285/0-20.html
        // http://c.m.163.com/photo/api/set/0096/57255.json
        // http://c.m.163.com/photo/api/set/54GI0096/57203.html
        NSURL *url = [NSURL URLWithString:@"http://home.kuaikanpian.com/"];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        instance = [[self alloc] initWithBaseURL:url sessionConfiguration:config];
        [instance.requestSerializer setTimeoutInterval:10];
        instance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    });
    return instance;
}

+ (instancetype)sharedNetworkToolsWithoutBaseUrl
{
    static SXNetworkTools*instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSURL *url = [NSURL URLWithString:@""];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        instance = [[self alloc]initWithBaseURL:url sessionConfiguration:config];
        
        instance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    });
    return instance;
}

+ (NSString*) getNance:(NSString*)time deviceid:(NSString*)devid randomTick:(NSString*)rtick
{
    NSString* verify = [NSString stringWithFormat:@"%@%@%@",
                        time, devid,rtick];
    NSString* verifyMD5 = [verify MD5Encode];
    
    return verifyMD5;
}

+ (NSString *) uniqueGlobalDeviceIdentifier{
    NSUUID * aid = [[UIDevice currentDevice] identifierForVendor];
    //    NSLog(@"aid ===== %@", [aid UUIDString]);
    NSString* uniqueIdentifier = nil;
    NSUserDefaults *sharedUserDefualt = [NSUserDefaults standardUserDefaults];
    uniqueIdentifier = [sharedUserDefualt objectForKey:@"kUserDefaultUniqueIdentifierKey"];
    if(uniqueIdentifier==nil) {
        uniqueIdentifier = [[aid UUIDString] MD5Encode];
        [sharedUserDefualt setObject:uniqueIdentifier forKey:@"kUserDefaultUniqueIdentifierKey"];
        [sharedUserDefualt synchronize];
    }
    return uniqueIdentifier;
}

+ (NSString*) genParams:(NSDictionary*)myParams
{
    NSString* rtick = [[NSString alloc] initWithFormat:@"%u",arc4random()];
    NSString* devid = [SXNetworkTools uniqueGlobalDeviceIdentifier];
    NSString* curtime = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    NSString* nance = [SXNetworkTools getNance:curtime deviceid:devid?:@"" randomTick:rtick?:@""];
    
    NSString* uid = [UserManager sharedUserManager].uid;
    if( uid == nil )
        uid = @"";

    NSMutableDictionary* defaultParams =
    [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     devid,@"deviceid",
     nance, @"n",
     @"8",@"limit",
     uid,@"uid",
     nil];
    [defaultParams addEntriesFromDictionary:myParams];
    
    NSMutableString* result = [[NSMutableString alloc] initWithCapacity:100];
    NSString* key;
    NSArray *allKeys = [defaultParams allKeys];
    NSCountedSet *sets = [[NSCountedSet alloc] initWithArray:allKeys];
    NSArray *sortKeys = [[sets allObjects] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableString* result_1 = [[NSMutableString alloc] initWithCapacity:100];
    for(key in sortKeys){
        id value = [defaultParams objectForKey:key];
        NSString *value1 = nil;
        if ([value isKindOfClass:[NSNumber class]]) {
            value1 = [[value stringValue] URLEncode];
        }else if ([value isKindOfClass:[NSString class]]){
            value1 = [value URLEncode];
        }
        if( result_1.length > 0 )
            [result_1 appendString:@"&"];
        [result_1 appendFormat:@"%@=%@", key, value1];
    }
    result = result_1;
//    NSString* newSignString = [Tools generateSignString:result];
//    NSString* strRemovedChar = [newSignString stringByAppendingString:@"0c0cde0f10e48e3c240762ef45d43340"];
//    NSString *signStr = [strRemovedChar MD5Encode];
//    [result_1 appendFormat:@"&%@=%@", @"sign", signStr];
    
    return result;
}

+ (NSString *)distanceTimeWithBeforeTime:(double)beTime
{
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    double distanceTime = now - beTime;
    NSString * distanceStr;
    
    NSDate * beDate = [NSDate dateWithTimeIntervalSince1970:beTime];
    NSDateFormatter * df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"HH:mm"];
    NSString * timeStr = [df stringFromDate:beDate];
    
    [df setDateFormat:@"dd"];
    NSString * nowDay = [df stringFromDate:[NSDate date]];
    NSString * lastDay = [df stringFromDate:beDate];
    
    if (distanceTime < 60) {//小于一分钟
        distanceStr = @"刚刚";
    }
    else if (distanceTime <60*60) {//时间小于一个小时
        distanceStr = [NSString stringWithFormat:@"%ld分钟前",(long)distanceTime/60];
    }
    else if(distanceTime <24*60*60 && [nowDay integerValue] == [lastDay integerValue]){//时间小于一天
        distanceStr = [NSString stringWithFormat:@"今天 %@",timeStr];
    }
    else if(distanceTime<24*60*60*2 && [nowDay integerValue] != [lastDay integerValue]){
        
        if ([nowDay integerValue] - [lastDay integerValue] ==1 || ([lastDay integerValue] - [nowDay integerValue] > 10 && [nowDay integerValue] == 1)) {
            distanceStr = [NSString stringWithFormat:@"昨天 %@",timeStr];
        }
        else{
            [df setDateFormat:@"MM-dd HH:mm"];
            distanceStr = [df stringFromDate:beDate];
        }
        
    }
    else if(distanceTime <24*60*60*365){
        [df setDateFormat:@"MM-dd HH:mm"];
        distanceStr = [df stringFromDate:beDate];
    }
    else{
        [df setDateFormat:@"yyyy-MM-dd HH:mm"];
        distanceStr = [df stringFromDate:beDate];
    }
    return distanceStr;
}

+ (void)showText:(UIView*)view text:(NSString *)text hideAfterDelay:(CGFloat)delay {
    [QHProgressHUD hideHUDForView:view animated:NO];
    if(!text || text.length == 0) {
        return;
    }
    QHProgressHUD *hud = [QHProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = QHProgressHUDModeText;
    if (text.length > 15) {
        hud.detailsLabel.numberOfLines = 0;
        hud.detailsLabel.text = text;
    } else {
        hud.label.numberOfLines = 0;
        hud.label.text = text;
    }
    [hud hideAnimated:YES afterDelay:delay];
}

@end
