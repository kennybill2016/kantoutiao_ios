//
//  HUAJSONKit.h
//  HUAJSONKit
//
//  Created by 黄继华 on 15/10/14.
//  Copyright © 2015年 huuang. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Deserializing

@interface NSString (HUAJSONKitDeserializing)

- (id)objectFromJSONString;
- (id)objectFromJSONStringWithError:(NSError **)error;
- (id)immutableObjectFromJSONString;
- (id)immutableObjectFromJSONStringWithError:(NSError **)error;

@end

@interface NSData (HUAJSONKitDeserializing)

- (id)objectFromJSONData;
- (id)objectFromJSONDataWithError:(NSError **)error;
- (id)immutableObjectFromJSONData;
- (id)immutableObjectFromJSONDataWithError:(NSError **)error;

@end

#pragma mark - Serializing

@interface NSString (HUAJSONKitSerializing)

- (NSData *)JSONData;

@end

@interface NSArray (HUAJSONKitSerializing)

- (NSData *)JSONData;
- (NSData *)JSONDataWithError:(NSError **)error;
- (NSString *)JSONString;
- (NSString *)JSONStringWithError:(NSError **)error;

@end

@interface NSDictionary (HUAJSONKitSerializing)

- (NSData *)JSONData;
- (NSData *)JSONDataWithError:(NSError **)error;
- (NSString *)JSONString;
- (NSString *)JSONStringWithError:(NSError **)error;

@end