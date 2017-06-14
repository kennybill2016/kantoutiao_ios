//
//  UserLoginView.m
//  TTNews
//
//  Created by lijinwei on 2017/6/12.
//  Copyright © 2017年 瑞文戴尔. All rights reserved.
//

#import "UserLoginView.h"
#import <DKNightVersion.h>

@interface UserLoginView()

@property (nonatomic, weak) UIImageView *QQImageView;
@property (nonatomic, weak) UIImageView *mobileImageView;
@property (nonatomic, weak) UILabel *qqLabel;
@property (nonatomic, weak) UILabel *mobileLabel;
@property (nonatomic, weak) UILabel *contentLabel;

@end

@implementation UserLoginView

#pragma mark 初始化View
- (instancetype)initWithFrame:(CGRect)frame {
    if (self= [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (void)initialization {
    CGFloat cellHeight = self.frame.size.height;
    CGFloat margin = 40;
    CGFloat btnWidth = 240;
    CGFloat imageHeight = 66;
    
//    UIView* sepView = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight-1, kScreenWidth, 1)];
//    sepView.dk_backgroundColorPicker = DKColorPickerWithKey(HIGHLIGHTED);
//    [self addSubview:sepView];
    
    UIImageView *avatarImageViewBG = [[UIImageView alloc] init];
    avatarImageViewBG.frame =CGRectMake((kScreenWidth-btnWidth)/2+(btnWidth/2-imageHeight)/2+1, (cellHeight-imageHeight)/2+1, imageHeight-2, imageHeight-2);
    avatarImageViewBG.layer.cornerRadius = avatarImageViewBG.frame.size.width * 0.5;
    avatarImageViewBG.layer.masksToBounds = YES;
    [avatarImageViewBG setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:avatarImageViewBG];
//    avatarImageViewBG.hidden = YES;
    
    
    UIImageView *avatarImageView = [[UIImageView alloc] init];
    self.QQImageView = avatarImageView;
    avatarImageView.frame =CGRectMake((kScreenWidth-btnWidth)/2+(btnWidth/2-imageHeight)/2, (cellHeight-imageHeight)/2, imageHeight, imageHeight);//CGRectMake(avatarImageViewBG.frame.origin.x+(avatarImageViewBG.frame.size.width-46)/2, avatarImageViewBG.frame.origin.y+(avatarImageViewBG.frame.size.height-46)/2, 46, 46);
    UIImage* image = [UIImage imageNamed:@"qq_login"];
    [avatarImageView setImage:image];
    
    [self addSubview:avatarImageView];
    
    UITapGestureRecognizer *tapGest1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleQQTap:)];
    [avatarImageViewBG addGestureRecognizer:tapGest1];
    avatarImageViewBG.userInteractionEnabled=YES;

    
    UIImageView *mobileImageViewBG = [[UIImageView alloc] init];
    mobileImageViewBG.frame = CGRectMake((kScreenWidth-btnWidth)/2+btnWidth/2+(btnWidth/2-imageHeight)/2+1, (cellHeight-imageHeight)/2+1, imageHeight-2, imageHeight-2);
    mobileImageViewBG.layer.cornerRadius = avatarImageViewBG.frame.size.width * 0.5;
    mobileImageViewBG.layer.masksToBounds = YES;
    [mobileImageViewBG setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:mobileImageViewBG];
//    mobileImageViewBG.hidden = YES;
    
    
    UIImageView *mobileImageView = [[UIImageView alloc] init];
    self.mobileImageView = mobileImageView;
    mobileImageView.frame = CGRectMake((kScreenWidth-btnWidth)/2+btnWidth/2+(btnWidth/2-imageHeight)/2, (cellHeight-imageHeight)/2, imageHeight, imageHeight);//CGRectMake(mobileImageViewBG.frame.origin.x+(mobileImageViewBG.frame.size.width-46)/2, mobileImageViewBG.frame.origin.y+(mobileImageViewBG.frame.size.height-46)/2, 46, 46);
    UIImage* mobileimage = [UIImage imageNamed:@"mobile_login"];
    [mobileImageView setImage:mobileimage];
    
    [self addSubview:mobileImageView];
    
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMobileTap:)];
    [mobileImageViewBG addGestureRecognizer:tapGest];
    mobileImageViewBG.userInteractionEnabled = YES;
    
    UILabel *qqLabel = [[UILabel alloc] init];
    self.qqLabel = qqLabel;
    [qqLabel setText:@"QQ登录"];
    qqLabel.font = [UIFont systemFontOfSize:12];
    [qqLabel setTextAlignment:NSTextAlignmentCenter];
    qqLabel.textColor = [UIColor whiteColor];
    
    qqLabel.frame = CGRectMake(avatarImageViewBG.frame.origin.x, avatarImageViewBG.frame.origin.y +avatarImageViewBG.frame.size.height+5, avatarImageViewBG.frame.size.width, 14);
//    qqLabel.dk_textColorPicker = DKColorPickerWithKey(BAR);
    [self addSubview:qqLabel];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    self.contentLabel = contentLabel;
    [contentLabel setText:@"手机登录"];
    [contentLabel setTextAlignment:NSTextAlignmentCenter];
    contentLabel.font = [UIFont systemFontOfSize:12];
    contentLabel.textColor = [UIColor whiteColor];
    contentLabel.frame = CGRectMake(mobileImageViewBG.frame.origin.x, mobileImageViewBG.frame.origin.y +mobileImageViewBG.frame.size.height+5, mobileImageViewBG.frame.size.width, 14);
    contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:contentLabel];
}

- (void)handleQQTap:(UIGestureRecognizer *)gesture
{
    if([self.delegate respondsToSelector:@selector(tapQQLogin)]) {
        [self.delegate tapQQLogin];
    }
}

- (void)handleMobileTap:(UIGestureRecognizer *)gesture
{
    if([self.delegate respondsToSelector:@selector(tapMobileLogin)]) {
        [self.delegate tapMobileLogin];
    }
}

@end
