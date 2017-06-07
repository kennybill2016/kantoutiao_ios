//
//  NSString+Addition.m
//  360CloudSDK
//
//  Created by ai zhongyuan on 13-1-21.
//  Copyright (c) 2013年 QIHU. All rights reserved.
//

#import "NSString+Addition.h"
#import "NSData+Addition.h"

@implementation NSString (URLCode)

- (NSString *)URLEncode
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                          (__bridge CFStringRef)self,
                                                                          
                                                                          NULL,
                                                                          
                                                                          (CFStringRef)@"!*'\"();@:&=+$,/?%#[]% ",
                                                                          
                                                                          kCFStringEncodingUTF8);
}

- (NSString *)URLDecode
{
    return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                        (__bridge CFStringRef)self,                                                                                       CFSTR(""),                                                                                       kCFStringEncodingUTF8);
}

@end

@implementation NSString (MD5Encode)

- (NSString *)MD5Encode
{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] MD5Encode];
}

@end

@implementation NSString (PathExtensions)

- (NSString*)removeLastPathCharacter;
{
    if ([self length] < 1)
    {
        // empty string
        return self;
    }
    
    unichar lastChar = [self characterAtIndex:([self length] - 1)];
    if (lastChar == L'\\' || lastChar == L'/')
    {
        return [self substringToIndex:[self length]-1];
    }
    else
    {
        return self;
    }
}

- (NSString *)firstPathComponent
{
    NSRange range = [self rangeOfString:@"/"];
    if (range.location == NSNotFound) {
        // 没有找到
        return self;
    }
    
    return [self substringToIndex:range.location];
}

- (NSString *)stringByDeletingFirstPathComponent
{
    NSRange range = [self rangeOfString:@"/"];
    if (range.location == NSNotFound) {
        // 没有找到
        return @"";
    }
    
    return [self substringFromIndex:(range.location + range.length)];
}

@end

@implementation NSString (Truncate)

// "0123456789" (maxLen:7)-> "01...89"
- (NSString *) stringWithMiddleTruncate:(NSUInteger)maxLen
{
    assert(maxLen >= 5);
    
    int exceedLen = (int)[self length] - (int)maxLen;
    if (exceedLen <= 0)
    {
        // 小于等于MaxLen
        return self;
    }
    
    // 大于MaxLen
    int endLen = ((int)maxLen - 3) / 2;
    int frontLen = ((int)maxLen - 3) - endLen;
    
    NSString * strFront = [self substringToIndex:frontLen];
    NSString * strEnd = [self substringFromIndex:([self length] - endLen)];
    return [NSString stringWithFormat:@"%@...%@", strFront, strEnd];
}

// "0123456789" (maxLen:7)-> "0123..."
- (NSString *) stringWithTailTruncate:(NSUInteger)maxLen
{
    assert(maxLen >= 4);
    
    int exceedLen = (int)[self length] - (int)maxLen;
    if (exceedLen <= 0)
    {
        // 小于等于MaxLen
        return self;
    }
    
    // 大于MaxLen
    int frontLen = (int)maxLen - 3;
    
    NSString * strFront = [self substringToIndex:frontLen];
    return [NSString stringWithFormat:@"%@...", strFront];
}

// "0123456789" (maxLen:7)-> "...6789"
- (NSString *) stringWithHeadTruncate:(NSUInteger)maxLen
{
    assert(maxLen >= 4);
    
    int exceedLen = (int)[self length] - (int)maxLen;
    if (exceedLen <= 0)
    {
        // 小于等于MaxLen
        return self;
    }
    
    // 大于MaxLen
    int endLen = (int)maxLen - 3;
    
    NSString * strEnd = [self substringFromIndex:([self length] - endLen)];
    return [NSString stringWithFormat:@"...%@", strEnd];
}

@end

@implementation NSString (UTF8Chinese)

- (BOOL)isAllUTF8Chinese {
    
    BOOL ret = YES;
    
    NSUInteger len = [self length];
    const char *pName = [self cStringUsingEncoding:NSUTF8StringEncoding];
    
    if ((pName == NULL) || (len != strlen(pName))){
        
        for(int i = 0; i < len; i++) {
            
            int a = [self characterAtIndex:i];
            if( a < 0x4e00 || a > 0x9fff){
                ret = NO;
                break;
            }
        }
    }else {
        ret = NO;
    }
    return ret;
}

- (BOOL)has4BytesEmoji
{
    BOOL result = NO;

    NSRange range;
    for (int i = 0; i < self.length; i += range.length) {
        range = [self rangeOfComposedCharacterSequenceAtIndex: i];
        NSString *substring = [self substringWithRange: range];
        NSData *data = [substring dataUsingEncoding: NSUTF8StringEncoding];
        if ([data length] >= 4) {
            result = YES;
            break;
        }
    }

    return result;
}

@end
