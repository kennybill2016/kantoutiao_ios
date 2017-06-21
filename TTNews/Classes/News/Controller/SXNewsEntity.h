//
//  SXNewsEntity.h
//  TTNews
//
//  Created by 瑞文戴尔 on 16/3/24.
//  Copyright © 2016年 瑞文戴尔. All rights reserved.//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SXNewsEntity : NSObject

/**
 *  新闻发布时间
 */
@property (nonatomic,copy) NSString *publish_time;
@property (nonatomic,copy) NSString *show_time;
/**
 *  标题
 */
@property (nonatomic,copy) NSString *title;
/**
 *  多图数组
 */
@property (nonatomic,strong)NSArray *cover;
@property (nonatomic,copy) NSString *imgsrc;
@property (nonatomic,copy) NSString *content_type;

@property (nonatomic,copy) NSString *nid;
@property (nonatomic,copy) NSString *introduction;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *source;
@property (nonatomic,copy) NSString *navtype;
@property (nonatomic,copy) NSString *type;

@property (nonatomic, assign) CGFloat cellHeight;
+ (instancetype)newsModelWithDict:(NSDictionary *)dict;

@end
