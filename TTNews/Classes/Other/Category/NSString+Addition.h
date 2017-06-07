//
//  NSString+Addition.h
//  360CloudSDK
//
//  Created by ai zhongyuan on 13-1-21.
//  Copyright (c) 2013年 QIHU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLCode)

- (NSString *)URLEncode;

- (NSString *)URLDecode;

@end

@interface NSString (MD5Encode)

- (NSString *)MD5Encode;

@end
