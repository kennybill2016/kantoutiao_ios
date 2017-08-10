//
//  ChannelManagerViewController.m
//  TTNews
//
//  Created by lijinwei on 2017/8/7.
//  Copyright © 2017年 瑞文戴尔. All rights reserved.
//

#import "ChannelManagerViewController.h"
#import "WyhChannelManager.h"

@interface ChannelManagerViewController ()

@property (nonatomic, weak) WyhChannelManager *manager;

@property (nonatomic, strong) WyhChannelManagerView *managerView;

@end

@implementation ChannelManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = @"频道管理";
    self.manager = [WyhChannelManager defaultManager];
    [self.view addSubview:self.managerView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - lazy

-(WyhChannelManagerView *)managerView{
    if (!_managerView) {
        
        WyhChannelManagerView *channelView = [WyhChannelManagerView channelViewWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64.0) Manager:self.manager];
        _managerView = channelView;
        [self setupLeftNavBtn];
        [channelView chooseChannelCallBack:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
    }
    return _managerView;
}

- (void)setupLeftNavBtn{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"navigationbar_pic_back_icon"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"navigationbar_back_icon"] forState:UIControlStateHighlighted];
    button.frame = CGRectMake(0, 0, 30, 30);
    // 让按钮内部的所有内容左对齐
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //        [button sizeToFit];
    // 让按钮的内容往左边偏移10
    //        button.dk_backgroundColorPicker = DKColorPickerWithRGB(0xffffff, 0x343434, 0xfafafa);
    
    [button addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 修改导航栏左边的item
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(void)closeAction:(id)sender{
    [WyhChannelManager setUpdateIfNeeds];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
