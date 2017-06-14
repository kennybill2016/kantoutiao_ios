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
#import <SMS_SDK/SMSSDK.h>
#import "UserManager.h"
#import "SXNetworkTools.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet TextFieldBound *mobileField;
@property (strong, nonatomic) IBOutlet UITextField *verifyField;
@property (strong, nonatomic) IBOutlet UIButton *sendVerifyCodeBtn;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UIView *sepView;
@property (nonatomic, strong) NSTimer* timer;
@property (assign, nonatomic) NSInteger count;

- (IBAction)touchSendVerify:(id)sender;
- (IBAction)touchLogin:(id)sender;

@end

@interface LoginViewController ()<UITextFieldDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"手机登录";
    
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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTap)];
    [self.view addGestureRecognizer:tap];
    
    _mobileField.delegate = self;
    _verifyField.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    self.navigationController.navigationBar.dk_barTintColorPicker = DKColorPickerWithRGB(0xfa5054,0x444444,0xfa5054);
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

#pragma -mark 点击屏幕关闭键盘
- (void)clickTap
{
    [_mobileField resignFirstResponder];
    [_verifyField resignFirstResponder];
}

- (void)updateTime{
    _count ++;
    if (_count >= 60)
    {
        [_timer invalidate];
        _sendVerifyCodeBtn.userInteractionEnabled = YES;
        [_sendVerifyCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        return;
    }
    [_sendVerifyCodeBtn setTitle:[NSString stringWithFormat:@"%ld后重发",60-_count] forState:UIControlStateNormal];
}

- (void)resumeTime {
    [_timer invalidate];
    _count = 0;
    _sendVerifyCodeBtn.userInteractionEnabled = NO;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                              target:self
                                            selector:@selector(updateTime)
                                            userInfo:nil
                                             repeats:YES];
}

- (IBAction)touchSendVerify:(id)sender {
    if(_mobileField.text.length<=0){
        [SXNetworkTools showText:self.view text:@"手机号码不能为空！" hideAfterDelay:2];
        return;
    }
    if([self isMobileNumber:_mobileField.text]) {
        __weak typeof(self) weakSelf = self;
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:_mobileField.text zone:@"86" customIdentifier:nil result:^(NSError *error) {
            if (!error) {
                NSLog(@"验证码发送成功");
                [weakSelf resumeTime];
            }else
            {
                NSLog(@"发送验证码失败");
                [SXNetworkTools showText:self.view text:@"发送验证码失败，请稍候重试！" hideAfterDelay:2];
            }
        }];
    }
    else {
        [SXNetworkTools showText:self.view text:@"输入手机号码无效，请重试！" hideAfterDelay:2];
    }
}

- (IBAction)touchLogin:(id)sender {
    if(_mobileField.text.length<=0){
        [SXNetworkTools showText:self.view text:@"手机号码不能为空！" hideAfterDelay:2];
        return;
    }
    if(_verifyField.text.length<=0){
        [SXNetworkTools showText:self.view text:@"验证码不能为空！" hideAfterDelay:2];
        return;
    }
    if([self isMobileNumber:_mobileField.text]) {
        __weak typeof(self) weakSelf = self;
        [SMSSDK commitVerificationCode:_verifyField.text phoneNumber:_mobileField.text zone:@"86" result:^(SMSSDKUserInfo *userInfo, NSError *error) {
            if(!error) {
                [weakSelf setUserInfoFromMobile:_mobileField.text];
            }
            else {
                [SXNetworkTools showText:self.view text:@"验证码不正确，请重试！" hideAfterDelay:2];
            }
        }];
    }
    else {
        [SXNetworkTools showText:self.view text:@"输入手机号码无效，请重试！" hideAfterDelay:2];
    }
}

// 正则判断手机号码地址格式
- (BOOL)isMobileNumber:(NSString *)mobileNum {
    
    //    电信号段:133/153/180/181/189/177
    //    联通号段:130/131/132/155/156/185/186/145/176
    //    移动号段:134/135/136/137/138/139/150/151/152/157/158/159/182/183/184/187/188/147/178
    //    虚拟运营商:170
    
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[06-8])\\d{8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    return [regextestmobile evaluateWithObject:mobileNum];
}

- (void)setUserInfoFromMobile:(NSString *)mobile {
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   mobile,@"loginid",
                                   nil];
    NSString* paramsString = [SXNetworkTools genParams:params];
    NSString *requestURL = [NSString stringWithFormat: @"%@?%@", USER_CONF_URL,paramsString];
    
    [[[SXNetworkTools sharedNetworkTools] GET:requestURL parameters:nil progress:nil success:^(NSURLSessionDataTask *task, NSDictionary* responseObject) {
        NSLog(@"%@",requestURL);
        NSString *code = [responseObject[@"code"] stringValue];
        if([code isEqualToString:@"0"]) {
            [[UserManager sharedUserManager] setUserInfoFromMobile:mobile];
//            [SXNetworkTools showText:self.view text:@"登录成功！" hideAfterDelay:1];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else {
            NSLog(@"登录失败");
            [SXNetworkTools showText:self.view text:@"登录失败，请稍候再试！" hideAfterDelay:2];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
        [SXNetworkTools showText:self.view text:@"登录失败，请稍候再试！" hideAfterDelay:2];
    }] resume];
}

@end
