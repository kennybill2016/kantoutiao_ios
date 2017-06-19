//
//  HUAJSONKit.m
//  HUAJSONKit
//
//  Created by 黄继华 on 15/10/14.
//  Copyright © 2015年 huuang. All rights reserved.
//

#import "HUAJSONKit.h"

#pragma mark - Deserializing

@implementation NSString (HUAJSONKitDeserializing)

- (id)objectFromJSONString
{
    return [self objectFromJSONStringWithError: nil];
}

- (id)objectFromJSONStringWithError:(NSError *__autoreleasing *)error
{
    return [NSJSONSerialization JSONObjectWithData: [self dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingAllowFragments error: error];
}

- (id)immutableObjectFromJSONString
{
    return [self immutableObjectFromJSONStringWithError: nil];
}

- (id)immutableObjectFromJSONStringWithError:(NSError *__autoreleasing *)error
{
    id object = [self objectFromJSONStringWithError: error];

    if ([object respondsToSelector: @selector(mutableCopy)]) {
        return [object mutableCopy];
    } else {
        return nil;
    }
}

@end


@implementation NSData (HUAJSONKitDeserializing)

- (id)objectFromJSONData
{
    return [self objectFromJSONDataWithError: nil];
}

- (id)objectFromJSONDataWithError:(NSError *__autoreleasing *)error
{
    return [NSJSONSerialization JSONObjectWithData: self options: NSJSONReadingAllowFragments error: error];
}

- (id)immutableObjectFromJSONData
{
    return [self immutableObjectFromJSONDataWithError: nil];
}

- (id)immutableObjectFromJSONDataWithError:(NSError *__autoreleasing *)error
{
    id object = [self objectFromJSONDataWithError: error];

    if ([object respondsToSelector: @selector(mutableCopy)]) {
        return [object mutableCopy];
    } else {
        return nil;
    }
}

@end

#pragma mark - Serializing

@implementation NSString (HUAJSONKitSerializing)

- (NSData *)JSONData
{
    return [self dataUsingEncoding: NSUTF8StringEncoding];
}

@end

@implementation NSArray (HUAJSONKitSerializing)

- (NSData *)JSONData
{
     return [self JSONDataWithError: nil];
}

- (NSData *)JSONDataWithError:(NSError *__autoreleasing *)error
{
    return [NSJSONSerialization dataWithJSONObject: self options: NSJSONWritingPrettyPrinted error: error];
}

- (NSString *)JSONString
{
    return [self JSONStringWithError: nil];
}

- (NSString *)JSONStringWithError:(NSError *__autoreleasing *)error
{
    NSData *data = [self JSONDataWithError: error];
    return [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
}

@end

@implementation NSDictionary (HUAJSONKitSerializing)

- (NSData *)JSONData
{
    return [self JSONDataWithError: nil];
}

- (NSData *)JSONDataWithError:(NSError *__autoreleasing *)error
{
    return [NSJSONSerialization dataWithJSONObject: self options: NSJSONWritingPrettyPrinted error: error];
}

- (NSString *)JSONString
{
    return [self JSONStringWithError: nil];
}

- (NSString *)JSONStringWithError:(NSError *__autoreleasing *)error
{
    NSData *data = [self JSONDataWithError: error];
    return [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
}

@end