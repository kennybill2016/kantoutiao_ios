//
//  MeTableViewController.m
//  TTNews
//
//  Created by 瑞文戴尔 on 16/3/25.
//  Copyright © 2016年 瑞文戴尔. All rights reserved.
//

#import "MeTableViewController.h"
#import <SDImageCache.h>
#import "TTDataTool.h"
#import <SVProgressHUD.h>
#import "UIImage+Extension.h"
#import "TTConst.h"
#import "SendFeedbackViewController.h"
#import "AppInfoViewController.h"
#import "EditUserInfoViewController.h"
#import "UIImage+Extension.h"
#import "UserInfoCell.h"
#import "SwitchCell.h"
#import <DKNightVersion.h>
#import "TwoLabelCell.h"
#import "DisclosureCell.h"
#import "UIColor+HEX.h"
#import <UMSocialCore/UMSocialCore.h>
#import "UserManager.h"
#import "SXNetworkTools.h"
#import "LoginViewController.h"
#import "UserLoginCell.h"
#import "UserLoginView.h"
#import "UserInfoView.h"


static NSString *const UserInfoCellIdentifier = @"UserInfoCell";
static NSString *const SwitchCellIdentifier = @"SwitchCell";
static NSString *const TwoLabelCellIdentifier = @"TwoLabelCell";
static NSString *const DisclosureCellIdentifier = @"DisclosureCell";
static NSString *const UserLoginCellIdentifier = @"UserLoginCell";

@interface MeTableViewController () <UserInfoCellDelegate>

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, weak) UISwitch *shakeCanChangeSkinSwitch;
@property (nonatomic, weak) UISwitch *imageDownLoadModeSwitch;
@property (nonatomic, assign) CGFloat cacheSize;
@property (nonatomic, copy) NSString *currentSkinModel;

@property (nonatomic, strong) UIView *userHeaderView;

@property (nonatomic, strong) UserLoginView *headerLoginView;
@property (nonatomic, strong) UIView *emptyHeaderView;

@property (nonatomic, strong) UserInfoView *headerUserView;

@end

CGFloat const footViewHeight = 10;

@implementation MeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"";
    [self caculateCacheSize];
    [self setupBasic];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint point = scrollView.contentOffset;
    if (point.y < -164) {
        CGRect rect = self.userHeaderView.frame;
        rect.origin.y = point.y;
        rect.size.height = -point.y;
        
        self.userHeaderView.frame = rect;
        
        CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
        CGRect rectEmpty = rect;
        rectEmpty.size.height = rect.size.height-164+rectStatus.size.height;
        self.emptyHeaderView.frame = rectEmpty;
        
        CGRect rectLogin = rect;
        rectLogin.origin.y = rect.size.height-164+rectStatus.size.height;
        self.headerLoginView.frame = rectLogin;
        self.headerUserView.frame = rectLogin;
    }
}

-(void)setupBasic{
    self.userHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, -164, kScreenWidth, 164)];
    self.userHeaderView.dk_backgroundColorPicker = DKColorPickerWithRGB(0xfa5054,0x444444,0xfa5054);
    [self.tableView addSubview:self.userHeaderView];
    
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    self.emptyHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, rectStatus.size.height)];
    [self.userHeaderView addSubview:self.emptyHeaderView];
    
    self.headerLoginView = [[UserLoginView alloc] initWithFrame:CGRectMake(0, rectStatus.size.height, kScreenWidth, 164-rectStatus.size.height)];
    [self.userHeaderView addSubview:self.headerLoginView];
    
    self.headerUserView = [[UserInfoView alloc] initWithFrame:self.headerLoginView.frame];
    [self.userHeaderView addSubview:self.headerUserView];
    
    if([UserManager sharedUserManager].isLogined) {
        self.headerLoginView.hidden = YES;
        self.headerUserView.hidden = NO;
        [self.headerUserView updateUI];
    }
    else {
        self.headerLoginView.hidden = NO;
        self.headerUserView.hidden = YES;
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(164, 0, 0, 0);
//        self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController.navigationBar.frame), 0, 0, 0);
    self.tableView.dk_backgroundColorPicker = DKColorPickerWithRGB(0xf0f0f0, 0x000000, 0xfafafa);
    self.tableView.dk_separatorColorPicker = DKColorPickerWithKey(HIGHLIGHTED);
//    self.navigationController.navigationBar.dk_barTintColorPicker = DKColorPickerWithRGB(0xfa5054,0x444444,0xfa5054);
    [self.tableView registerClass:[UserInfoCell class] forCellReuseIdentifier:UserInfoCellIdentifier];
    [self.tableView registerClass:[SwitchCell class] forCellReuseIdentifier:SwitchCellIdentifier];
    [self.tableView registerClass:[TwoLabelCell class] forCellReuseIdentifier:TwoLabelCellIdentifier];
    [self.tableView registerClass:[DisclosureCell class] forCellReuseIdentifier:DisclosureCellIdentifier];
    [self.tableView registerClass:[UserLoginCell class] forCellReuseIdentifier:UserLoginCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserLogin) name:kUserLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserLogout) name:kUserLogoutNotification object:nil];
}

-(void)caculateCacheSize {
    float imageCache = [[SDImageCache sharedImageCache] getSize]/1024.0/1024.0;
//    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"data.sqlite"];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    float sqliteCache = [fileManager attributesOfItemAtPath:path error:nil].fileSize/1024.0/1024.0;
    self.cacheSize = imageCache;
}

#pragma mark - Table view data source

#pragma mark -UITableViewDataSource 返回tableView有多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark -UITableViewDataSource 返回tableView每一组有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return footViewHeight;
}

#pragma mark -UITableViewDataSource 返回indexPath对应的cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footView = [[UIView alloc] init];
    footView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, footViewHeight);
    UIView *lineView1 = [[UIView alloc] init];
    lineView1.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1);
    [footView addSubview:lineView1];
    UIView *lineView2 = [[UIView alloc] init];
    lineView2.frame = CGRectMake(0, footViewHeight - 1, [UIScreen mainScreen].bounds.size.width, 1);
    [footView addSubview:lineView2];
    
    if (section==2) {
        [lineView2 removeFromSuperview];
    }
    return footView;
}

- (UITableViewCell*)cellForUser:(UITableView *)tableView {
    if([UserManager sharedUserManager].isLogined){
        UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:UserInfoCellIdentifier];
        cell.dk_backgroundColorPicker = DKColorPickerWithRGB(0xf0f0f0, 0x000000, 0xfafafa);
        cell.dk_backgroundColorPicker = DKColorPickerWithRGB(0xfa5054,0x444444,0xfa5054);
        cell.textLabel.dk_textColorPicker = DKColorPickerWithKey(TEXT);
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"headerImage"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image == nil) {
            image = [UIImage imageNamed:@"defaultUserIcon"];
            [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
        }
        [cell setAvatarImage:image Name:[UserManager sharedUserManager].username Signature:nil];
        cell.delegate = self;
        return cell;
    }
    else {
        UserLoginCell *cell = [tableView dequeueReusableCellWithIdentifier:UserLoginCellIdentifier];
        cell.dk_backgroundColorPicker = DKColorPickerWithRGB(0xf0f0f0, 0x000000, 0xfafafa);
        cell.textLabel.dk_textColorPicker = DKColorPickerWithKey(TEXT);
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"headerImage"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image == nil) {
            image = [UIImage imageNamed:@"defaultUserIcon"];
            [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
        }
        [cell setAvatarImage:image Name:[UserManager sharedUserManager].username Signature:nil];
        cell.delegate = self;
        return cell;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0&&indexPath.row <1) {
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:SwitchCellIdentifier];
        cell.dk_backgroundColorPicker = DKColorPickerWithRGB(0xffffff, 0x343434, 0xfafafa);
        if (indexPath.row == 1) {
            cell.leftLabel.text = @"摇一摇夜间模式";
            self.shakeCanChangeSkinSwitch = cell.theSwitch;
            BOOL status = [[NSUserDefaults standardUserDefaults] boolForKey:IsShakeCanChangeSkinKey];
            cell.theSwitch.on = status;
            [cell.theSwitch addTarget:self action:@selector(switchDidChange:) forControlEvents:UIControlEventValueChanged];
        } else if (indexPath.row == 0) {
            cell.leftLabel.text = @"夜间模式";
            cell.theSwitch.on= [self.dk_manager.themeVersion isEqualToString:DKThemeVersionNight]?YES:NO;
            self.changeSkinSwitch = cell.theSwitch;
            [cell.theSwitch addTarget:self action:@selector(switchDidChange:) forControlEvents:UIControlEventValueChanged];
        }
        return cell;
        }
    
    //第三组cell
    if (indexPath.section == 0 && indexPath.row == 1) {
        TwoLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:TwoLabelCellIdentifier];
        cell.leftLabel.text = @"清除缓存";
        cell.rightLabel.text = [NSString stringWithFormat:@"%.1f MB",self.cacheSize];
        return cell;
    }
    
    DisclosureCell *cell = [tableView dequeueReusableCellWithIdentifier:DisclosureCellIdentifier];
    if (indexPath.row == 2) {
        cell.leftLabel.text = @"意见反馈";
    } else if(indexPath.row == 3) {
        cell.leftLabel.text = @"关于";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0 && indexPath.row ==1) {
        [SVProgressHUD show];
        [TTDataTool deletePartOfCacheInSqlite];
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
            [SVProgressHUD showSuccessWithStatus:@"缓存清除完毕!"];
            TwoLabelCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.rightLabel.text = [NSString stringWithFormat:@"0.0MB"];
        }];
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        [self.navigationController pushViewController:[[SendFeedbackViewController alloc] init] animated:YES];
    } else if (indexPath.section == 0 && indexPath.row == 3) {
        [self.navigationController pushViewController:[[AppInfoViewController alloc] init] animated:YES];
    }
}

-(void)switchDidChange:(UISwitch *)theSwitch {
    if (theSwitch == self.changeSkinSwitch) {
        if (theSwitch.on == YES) {//切换至夜间模式
            self.dk_manager.themeVersion = DKThemeVersionNight;
            self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];

        } else {
            self.dk_manager.themeVersion = DKThemeVersionNormal;
            self.tabBarController.tabBar.barTintColor = [UIColor whiteColor];

        }
    
    } else if (theSwitch == self.shakeCanChangeSkinSwitch) {//摇一摇夜间模式
        BOOL status = self.shakeCanChangeSkinSwitch.on;
        [[NSUserDefaults standardUserDefaults] setObject:@(status) forKey:IsShakeCanChangeSkinKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if([self.delegate respondsToSelector:@selector(shakeCanChangeSkin:)]) {
            [self.delegate shakeCanChangeSkin:status];
        }
   }
}

-(void)didReceiveMemoryWarning {
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    
}

- (void)tapQQLogin{
    __weak typeof(self) weakSelf = self;
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_QQ currentViewController:nil completion:^(id result, NSError *error) {
        if (error) {
            
        } else {
            UMSocialUserInfoResponse *resp = result;
            
            // 授权信息
            NSLog(@"QQ uid: %@", resp.uid);
            NSLog(@"QQ openid: %@", resp.openid);
            NSLog(@"QQ accessToken: %@", resp.accessToken);
            NSLog(@"QQ expiration: %@", resp.expiration);
            
            // 用户信息
            NSLog(@"QQ name: %@", resp.name);
            NSLog(@"QQ iconurl: %@", resp.iconurl);
            NSLog(@"QQ gender: %@", resp.unionGender);
            
            // 第三方平台SDK源数据
            NSLog(@"QQ originalResponse: %@", resp.originalResponse);

            [weakSelf setUserInfoFromQQ:resp];
        }
    }];
}

- (void)tapMobileLogin{
    LoginViewController* loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (void)setUserInfoFromQQ:(UMSocialUserInfoResponse *)resp {
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   resp.uid,@"loginid",
                                   nil];
    NSString* paramsString = [SXNetworkTools genParams:params];
    NSString *requestURL = [NSString stringWithFormat: @"%@?%@", USER_CONF_URL,paramsString];
    
    [[[SXNetworkTools sharedNetworkTools] GET:requestURL parameters:nil progress:nil success:^(NSURLSessionDataTask *task, NSDictionary* responseObject) {
        NSLog(@"%@",requestURL);
        NSString *code = [responseObject[@"code"] stringValue];
        if([code isEqualToString:@"0"]) {
            [[UserManager sharedUserManager] setUserInfo:resp.name iconUrl:resp.iconurl uid:resp.openid];
            [SXNetworkTools showText:self.view text:@"登录成功！" hideAfterDelay:1];
        }
        else {
            NSLog(@"授权QQ登录失败");
            [SXNetworkTools showText:self.view text:@"登录失败，请稍候再试！" hideAfterDelay:2];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
        [SXNetworkTools showText:self.view text:@"登录失败，请稍候再试！" hideAfterDelay:2];
    }] resume];

}

- (void)onUserLogin{
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)onUserLogout{
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
