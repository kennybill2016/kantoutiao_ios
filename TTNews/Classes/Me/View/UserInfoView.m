//
//  UserInfoView.m
//  TTNews
//
//  Created by lijinwei on 2017/6/12.
//  Copyright © 2017年 瑞文戴尔. All rights reserved.
//

#import "UserInfoView.h"
#import <DKNightVersion.h>
#import "UserManager.h"
#import <SDWebImageManager.h>
#import <UIImageView+WebCache.h>
#import "UIColor+HEX.h"


@interface UserInfoView()
@property (nonatomic, weak) UIImageView *avatarImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *contentLabel;

@property (nonatomic, weak) UIImageView *coinImageView;
@property (nonatomic, weak) UIImageView *moneyImageView;
@property (nonatomic, weak) UILabel *coinLabel;
@property (nonatomic, weak) UILabel *moneyLabel;

@property (nonatomic, strong) UIButton *coinBtn;
@property (nonatomic, strong) UIButton *moneyBtn;

@end

@implementation UserInfoView

#pragma mark 初始化View
- (instancetype)initWithFrame:(CGRect)frame {
    if (self= [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (void)initialization {
    UIImageView *avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView = avatarImageView;
    avatarImageView.frame =CGRectMake((kScreenWidth-60)/2, 20, 60, 60);
    avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width * 0.5;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.borderWidth = 2;
    avatarImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self addSubview:avatarImageView];
    
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserImageTap:)];
    [avatarImageView addGestureRecognizer:tapGest];
    avatarImageView.userInteractionEnabled = YES;
    
    
    CGRect rectName = CGRectMake(0, avatarImageView.frame.origin.y+avatarImageView.frame.size.height+10, kScreenWidth, 20);
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:rectName];
    self.nameLabel = nameLabel;
    [self.nameLabel setTextAlignment:NSTextAlignmentCenter];
    nameLabel.font = [UIFont systemFontOfSize:18];
    [nameLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:nameLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, self.nameLabel.frame.origin.y+self.nameLabel.frame.size.height+10, kScreenWidth/2-20, 40);
    button.backgroundColor = [UIColor clearColor];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [button setTitleColor:[UIColor parseColorFromRGB:@"#E6E6E6"] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [button setTitle:@" 金币：200" forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"coin_icon"] forState:UIControlStateNormal];
    self.coinBtn = button;
    [self addSubview:self.coinBtn];
    
    UIButton *moneybutton = [UIButton buttonWithType:UIButtonTypeCustom];
    moneybutton.frame = CGRectMake(kScreenWidth/2+20, self.nameLabel.frame.origin.y+self.nameLabel.frame.size.height+10, kScreenWidth/2-20, 40);
    moneybutton.backgroundColor = [UIColor clearColor];
    [moneybutton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    moneybutton.imageView.contentMode = UIViewContentModeLeft;
    [moneybutton setTitleColor:[UIColor parseColorFromRGB:@"#E6E6E6"] forState:UIControlStateNormal];
    [moneybutton setTitle:@" 零钱：88.88" forState:UIControlStateNormal];
    [moneybutton setImage:[UIImage imageNamed:@"money_icon"] forState:UIControlStateNormal];
    self.moneyBtn = moneybutton;
    [self addSubview:self.moneyBtn];
    
    self.coinBtn.hidden = YES;
    self.moneyBtn.hidden = YES;
}

- (void)updateUI {
    self.nameLabel.text = [UserManager sharedUserManager].username;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[UserManager sharedUserManager].iconurl?:@""] placeholderImage:[UIImage imageNamed:@"defaultUserIcon"] options:SDWebImageTransformAnimatedImage];
}

- (void)handleUserImageTap:(UIGestureRecognizer *)gesture
{
    if([self.delegate respondsToSelector:@selector(tapUserBtn)]) {
        [self.delegate tapUserBtn];
    }
}

@end
