//
//  LoginViewController.m
//  TTNews
//
//  Created by lijinwei on 2017/6/9.
//  Copyright © 2017年 瑞文戴尔. All rights reserved.
//

#import "LoginViewController.h"
#import "TextFieldBound.h"
#import <DKNightVersion.h>
#import "UIColor+HEX.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet TextFieldBound *mobileField;
@property (strong, nonatomic) IBOutlet UITextField *verifyField;
@property (strong, nonatomic) IBOutlet UIButton *sendVerifyCodeBtn;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UIView *sepView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"手机登录";
    
    self.view.dk_backgroundColorPicker = DKColorPickerWithRGB(0xf0f0f0, 0x000000, 0xfafafa);
    
    [_loginView setBackgroundColor:[UIColor whiteColor]];
    _loginView.layer.cornerRadius = 4;
    _loginView.layer.borderWidth = 1;
    _loginView.layer.borderColor = [UIColor parseColorFromRGB:@"#EFEFEF"].CGColor;
    _loginView.layer.masksToBounds = YES;
    
    _mobileField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _verifyField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [_sepView setBackgroundColor:[UIColor parseColorFromRGB:@"#f0f0f0"]];
    _sendVerifyCodeBtn.layer.cornerRadius = 4;
    _sendVerifyCodeBtn.dk_backgroundColorPicker = DKColorPickerWithRGB(0xfa5054,0x444444,0xfa5054);
    [_sendVerifyCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _loginBtn.layer.cornerRadius = 4;
    _loginBtn.dk_backgroundColorPicker = DKColorPickerWithRGB(0xfa5054,0x444444,0xfa5054);
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    _loginBtn.enabled = NO;
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

@end
