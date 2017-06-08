//
//  AppDelegate.m
//  TTNews
//
//  Created by 瑞文戴尔 on 16/3/24.
//  Copyright © 2016年 瑞文戴尔. All rights reserved.
//

#import "AppDelegate.h"
#import "TTTabBarController.h"
#import "TTConst.h"
#import <UMSocialCore/UMSocialCore.h>
#import <SMS_SDK/SMSSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupUserDefaults];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[TTTabBarController alloc] init];
    [self.window makeKeyAndVisible];
    
    //初始化应用，appKey和appSecret从后台申请得
    [SMSSDK registerApp:@"1e86dbfc4687e"
             withSecret:@"88be18ee2217aa8c3e721a8ed1626f97"];
    
    [[UMSocialManager defaultManager] openLog:YES];
    [[UMSocialManager defaultManager] setUmSocialAppkey:@"59255cf0aed1796e04001ae6"];
    
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wx16907b0df42cf132" appSecret:@"16b46a81b2c70b6c97eceb4a3d69d71f" redirectURL:@"http://www.kuaikanpian.com"];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1106207188"/*设置QQ平台的appID*/  appSecret:@"ghlLP7dNh7WZJizp" redirectURL:@"http://www.kuaikanpian.com"];
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"3921700954"  appSecret:@"04b48b094faeb16683c32669824ebdad" redirectURL:@"http://www.kuaikanpian.com"];
    return YES;
}

-(void)setupUserDefaults {
    
    BOOL isShakeCanChangeSkin = [[NSUserDefaults standardUserDefaults] boolForKey:IsShakeCanChangeSkinKey];
    if (!isShakeCanChangeSkin) {
        [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:IsShakeCanChangeSkinKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    BOOL isDownLoadNoImageIn3G = [[NSUserDefaults standardUserDefaults] boolForKey:IsDownLoadNoImageIn3GKey];
    if (!isDownLoadNoImageIn3G) {
        [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:IsDownLoadNoImageIn3GKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:UserNameKey];
    if (userName==nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"微信登录" forKey:UserNameKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *userSignature = [[NSUserDefaults standardUserDefaults] stringForKey:UserSignatureKey];
    if (userSignature==nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"登录后查看我的零钱和金币" forKey:UserSignatureKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

@end
