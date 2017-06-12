//
//  UserLoginCell.m
//  TTNews
//
//  Created by lijinwei on 2017/6/12.
//  Copyright © 2017年 瑞文戴尔. All rights reserved.
//

#import "UserLoginCell.h"
#import <DKNightVersion.h>

@interface UserLoginCell()
@property (nonatomic, weak) UIImageView *QQImageView;
@property (nonatomic, weak) UIImageView *mobileImageView;
@property (nonatomic, weak) UILabel *qqLabel;
@property (nonatomic, weak) UILabel *mobileLabel;
@property (nonatomic, weak) UILabel *contentLabel;
@end

@implementation UserLoginCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat cellHeight = 100;
        CGFloat margin = 20;
        CGFloat btnWidth = 200;
        
        UIView* sepView = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight-1, kScreenWidth, 1)];
        sepView.dk_backgroundColorPicker = DKColorPickerWithKey(HIGHLIGHTED);
        [self addSubview:sepView];
        
        UIImageView *avatarImageViewBG = [[UIImageView alloc] init];
        avatarImageViewBG.frame =CGRectMake((kScreenWidth-btnWidth)/2, margin-5, cellHeight - 2*margin, cellHeight - 2*margin);
        avatarImageViewBG.layer.cornerRadius = avatarImageViewBG.frame.size.width * 0.5;
        avatarImageViewBG.layer.masksToBounds = YES;
        [avatarImageViewBG setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:avatarImageViewBG];
        
        UITapGestureRecognizer *tapGest1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleQQTap:)];
        [avatarImageViewBG addGestureRecognizer:tapGest1];
        avatarImageViewBG.userInteractionEnabled=YES;
        
        UIImageView *avatarImageView = [[UIImageView alloc] init];
        self.QQImageView = avatarImageView;
        avatarImageView.frame =CGRectMake(avatarImageViewBG.frame.origin.x+(avatarImageViewBG.frame.size.width-22)/2, avatarImageViewBG.frame.origin.y+(avatarImageViewBG.frame.size.height-24)/2, 22, 24);
        UIImage* image = [UIImage imageNamed:@"qq_login"];
        [avatarImageView setImage:image];
        
        [self addSubview:avatarImageView];
        
        UIImageView *mobileImageViewBG = [[UIImageView alloc] init];
        mobileImageViewBG.frame =CGRectMake(avatarImageViewBG.frame.origin.x+btnWidth-avatarImageViewBG.frame.size.width, margin-5, cellHeight - 2*margin, cellHeight - 2*margin);
        mobileImageViewBG.layer.cornerRadius = avatarImageViewBG.frame.size.width * 0.5;
        mobileImageViewBG.layer.masksToBounds = YES;
        [mobileImageViewBG setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:mobileImageViewBG];
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMobileTap:)];
        [mobileImageViewBG addGestureRecognizer:tapGest];
        mobileImageViewBG.userInteractionEnabled = YES;
        
        UIImageView *mobileImageView = [[UIImageView alloc] init];
        self.mobileImageView = mobileImageView;
        mobileImageView.frame =CGRectMake(mobileImageViewBG.frame.origin.x+(mobileImageViewBG.frame.size.width-18)/2, mobileImageViewBG.frame.origin.y+(mobileImageViewBG.frame.size.height-35)/2, 18, 35);
        UIImage* mobileimage = [UIImage imageNamed:@"mobile_login"];
        [mobileImageView setImage:mobileimage];
        
        [self addSubview:mobileImageView];
        
        
        UILabel *qqLabel = [[UILabel alloc] init];
        self.qqLabel = qqLabel;
        [qqLabel setText:@"QQ登录"];
        qqLabel.font = [UIFont systemFontOfSize:12];
        [qqLabel setTextAlignment:NSTextAlignmentCenter];
        
        qqLabel.frame = CGRectMake(avatarImageViewBG.frame.origin.x, avatarImageViewBG.frame.origin.y +avatarImageViewBG.frame.size.height+5, avatarImageViewBG.frame.size.width, 14);
        qqLabel.dk_textColorPicker = DKColorPickerWithKey(TEXT);
        [self addSubview:qqLabel];
        
        UILabel *contentLabel = [[UILabel alloc] init];
        self.contentLabel = contentLabel;
        [contentLabel setText:@"手机登录"];
        [contentLabel setTextAlignment:NSTextAlignmentCenter];
        contentLabel.font = [UIFont systemFontOfSize:12];
        contentLabel.textColor = [UIColor grayColor];
        contentLabel.frame = CGRectMake(mobileImageViewBG.frame.origin.x, mobileImageViewBG.frame.origin.y +mobileImageViewBG.frame.size.height+5, mobileImageViewBG.frame.size.width, 14);
        contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        contentLabel.dk_textColorPicker = DKColorPickerWithKey(TEXT);
        [self addSubview:contentLabel];
        
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setAvatarImage:(UIImage *)image Name:(NSString *)name Signature:(NSString *)content {
    //    self.avatarImageView.image = image;
    //    self.nameLabel.text = name;
    //    self.contentLabel.text = content;
    
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
