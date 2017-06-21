//
//  VideoTableViewCell.m
//  TTNews
//
//  Created by 瑞文戴尔 on 16/4/2.
//  Copyright © 2016年 瑞文戴尔. All rights reserved.
//

#import "VideoTableViewCell.h"
#import "TTVideo.h"
#import "TTVideoComment.h"
#import "TTVideoUser.h"
#import "VideoPlayView.h"
#import <DKNightVersion.h>
#import <SDWebImageManager.h>
#import <UIImageView+WebCache.h>

@interface VideoTableViewCell()<VideoPlayViewDelegate,SDWebImageManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *createdTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *AddFriendsButton;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet UIView *VideoContianerView;

@end
@implementation VideoTableViewCell


+(instancetype)cell {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}
- (void)awakeFromNib {
    [super awakeFromNib];

    self.dk_backgroundColorPicker = DKColorPickerWithRGB(0xffffff, 0x343434, 0xfafafa);

    self.contentView.dk_backgroundColorPicker = DKColorPickerWithRGB(0xffffff, 0x343434, 0xfafafa);
//    self.nameLabel.dk_textColorPicker = DKColorPickerWithKey(TEXT);
    self.contentLabel.dk_textColorPicker = DKColorPickerWithKey(TEXT);
    self.createdTimeLabel.dk_textColorPicker = DKColorPickerWithKey(TEXT);

    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"mainCellBackground"];
    self.backgroundView = imageView;
//    [SDWebImageManager sharedManager].delegate = self;
}

- (void)setVideo:(TTVideo *)video {
    _video = video;

    static NSDateFormatter *df;
    if(df == nil)
    {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"YYYY-MM-dd HH:mm"];
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[video.publish_time doubleValue]];
    NSString* time = [df stringFromDate:date];
    
    self.createdTimeLabel.text = time;
    self.contentLabel.text = video.title;
    if(video.imgurl) {
        NSURL* url = [NSURL URLWithString:video.imgurl];
        if(url)
            [self.videoImageView sd_setImageWithURL:url];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)playVideo:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickVideoButton:)]) {
        [self.delegate clickVideoButton:self.indexPath];
    }
}

- (IBAction)more:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickMoreButton:)]) {
        [self.delegate clickMoreButton:self.video];
    }
}

//- (void)setFrame:(CGRect)frame {
//    static CGFloat margin = 10;
//
//    frame.size.width = [UIScreen mainScreen].bounds.size.width;
//    frame.size.height = self.video.cellHeight - margin;
//    [super setFrame:frame];
//}


- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL {

    // NO代表透明
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    
    // 获得上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 添加一个圆
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
//    CGContextAddEllipseInRect(context, rect);
    
    // 裁剪
    CGContextClip(context);
    
    // 将图片画上去
    [image drawInRect:rect];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
}



@end
