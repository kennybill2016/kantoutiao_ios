//
//  DetailViewController.h
//  TTNews
//
//  Created by 瑞文戴尔 on 16/3/29.
//  Copyright © 2016年 瑞文戴尔. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *maintitle;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *publish_time;
@property (nonatomic, copy) NSString *srcurl;
@property (nonatomic, copy) NSString *introduct;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *nid;
@property (nonatomic, copy) NSString *navType;

@end
