//
//  DetailViewController.m
//  TTNews
//
//  Created by 瑞文戴尔 on 16/3/29.
//  Copyright © 2016年 瑞文戴尔. All rights reserved.
//

#import "DetailViewController.h"
#import <SDImageCache.h>
#import <SVProgressHUD.h>
#import "TTConst.h"
#import "TTJudgeNetworking.h"
#import <DKNightVersion.h>
#import "SXNetworkTools.h"
#import <UShareUI/UShareUI.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "ZWPreviewImageView.h"
#import "ZWHTMLSDK.h"
#import "CacheManager.h"
#import "SDWebImageManager.h"

@interface DetailViewController ()<UIWebViewDelegate,UIGestureRecognizerDelegate>{
    NSString* content;
    
    UIView* emptyView;
    UILabel* emtpyTitle;
    UIImageView* emptyImg;
}

@property (nonatomic, weak) UIView *shadeView;//(页面模式时，用来使页面变暗)

@property (nonatomic, weak) UIButton *collectButton;
@property (nonatomic, weak) UIWebView *webView;

@property (nonatomic, weak) UIBarButtonItem *backItem;
@property (nonatomic, weak) UIBarButtonItem *forwardItem;
@property (nonatomic, weak) UIBarButtonItem *refreshItem;

@property (nonatomic, strong) GADBannerView *bannerView;

@property (nonatomic, strong) ZWHTMLSDK *htmlSDK;

@property (nonatomic,copy) NSString *adUnitID;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    if([TTJudgeNetworking judge] == NO) {
//        [SVProgressHUD showErrorWithStatus:@"无网络连接"];
//        [self.navigationController popViewControllerAnimated:YES];
//    }
    self.view.dk_backgroundColorPicker = DKColorPickerWithRGB(0xffffff, 0x343434, 0xffffff);
    self.adUnitID=@"";
    [self setupWebView];
    [self setupNaigationBar];
    [self setupEmptyView];
    [self loadData];
    
//    [self setupToolBars];
//    [self setupShadeView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [SVProgressHUD show];
//    self.navigationController.toolbarHidden = NO;

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
//    self.navigationController.toolbarHidden = YES;
}


- (void)dealloc
{
    self.webView.delegate = nil;
}

- (void)setupAdMob {
    if(!self.bannerView&&[self.adUnitID length]>0) {
        self.bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        [self.bannerView setAdSize:kGADAdSizeSmartBannerPortrait];
        [self.view addSubview:self.bannerView];
        self.bannerView.adUnitID = self.adUnitID;//@"ca-app-pub-3940256099942544/2934735716";
        self.bannerView.rootViewController = self;
        
        self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50);
    }
}

- (void)requestAdMob {
    if(self.bannerView) {
        GADRequest *request = [GADRequest request];
        // Requests test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made. GADBannerView automatically returns test ads when running on a
        // simulator.
        //    request.testDevices = @[
        //                            @"2077ef9a63d2b398840261c8221a0c9a"  // Eric's iPod Touch
        //                            ];
        [self.bannerView loadRequest:request];
    }
}

- (void)setupEmptyView{
    emptyView = [[UIView alloc] initWithFrame:self.view.frame];
    emptyView.dk_backgroundColorPicker = DKColorPickerWithRGB(0xf0f0f0, 0x000000, 0xfafafa);
    
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEmptyTap:)];
    [emptyView addGestureRecognizer:tapGest];
    
    [self.view addSubview:emptyView];
    
    emptyImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty"]];
    [emptyImg setFrame:CGRectMake((emptyView.frame.size.width-64)/2, (emptyView.frame.size.height-100)/3, 64, 64)];
    [emptyView addSubview:emptyImg];
    
    emtpyTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, emptyImg.frame.size.height+emptyImg.frame.origin.y+20, emptyView.frame.size.width, 20)];
    [emtpyTitle setText:@"没有更多数据，请点击刷新"];
    [emtpyTitle setTextAlignment:NSTextAlignmentCenter];
    [emtpyTitle setFont:[UIFont systemFontOfSize:16]];
    emtpyTitle.dk_textColorPicker = DKColorPickerWithKey(TEXT);
    [emptyView addSubview:emtpyTitle];
    emptyView.hidden = YES;
}

- (void)loadData{
    if([self.navType isEqualToString:@"2"] && self.url.length>0) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    }
    else {
        __weak typeof(self) weakSelf = self;
        [[[SXNetworkTools sharedNetworkTools] GET:self.url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, NSDictionary* responseObject) {
            NSLog(@"%@",self.url);
            NSString *code = [responseObject[@"code"] stringValue];
            if([code isEqualToString:@"0"]) {
                content = responseObject[@"data"][@"content"];
                emptyView.hidden = YES;
                self.adUnitID = responseObject[@"data"][@"adUnitID"];
                [weakSelf setupAdMob];
                NSString* headerHtml = [NSString stringWithFormat:@"<!DOCTYPE HTML><html><head><title>%@</title><meta charset=\"utf-8\"><style>img{max-width:%fpx !important;}</style></head><body><font size=\"4\"><strong>%@</strong></font><br/><font size=\"2\" color=\"gray\">%@  %@</font><br/><br/>%@</body></html>",weakSelf.maintitle,kScreenWidth-20,weakSelf.maintitle,weakSelf.source,weakSelf.publish_time,content];
                ;
                [weakSelf.webView loadHTMLString:headerHtml baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
                [[CacheManager sharedInstance] saveContent:weakSelf.nid withType:weakSelf.type sourceData:headerHtml];
            }
            else {
                NSLog(@"获取数据失败！");
                emtpyTitle.text = @"加载数据失败，请点击刷新";
                [emptyImg setImage:[UIImage imageNamed:@"empty"]];
                emptyView.hidden = NO;
            }
            [SVProgressHUD dismiss];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"%@",error);
            
            NSString* contentRet = [[CacheManager sharedInstance] getContentWithType:self.type withGid:self.nid];
            if(contentRet) {
                emptyView.hidden = YES;
                [weakSelf.webView loadHTMLString:contentRet baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
            }
            else {
                [emtpyTitle setText:@"网络不给力，请点击刷新"];
                [emptyImg setImage:[UIImage imageNamed:@"empty"]];
                emptyView.hidden = NO;
            }
            [SVProgressHUD dismiss];
        }] resume];
    }
}

#pragma mark --private Method--初始化webView
- (void)setupWebView {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.webView = webView;
//    webView.frame = self.view.frame;
    webView.delegate = self;
    [self.webView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:webView];
    [SVProgressHUD show];
    
    UIScreenEdgePanGestureRecognizer *swipeRight = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self  action:@selector(fireBack:)];
    swipeRight.edges = UIRectEdgeLeft;
    swipeRight.delegate = self;
    [webView addGestureRecognizer:swipeRight];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)fireBack:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --private Method--初始化NavigationBar
-(void)setupNaigationBar {
    UIButton *collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.collectButton = collectButton;
    collectButton.frame =CGRectMake(0, 0, 30, 30);
    [collectButton setImage:[UIImage imageNamed:@"share_icon"] forState:UIControlStateNormal];
//    [collectButton setImage:[UIImage imageNamed:@"navigationBarItem_favorite_pressed"] forState:UIControlStateHighlighted];
    [self.collectButton setImage:[[UIImage imageNamed:@"share_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]forState:UIControlStateHighlighted];
    [collectButton addTarget:self action:@selector(shareThisNews) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:collectButton];
}

#pragma mark --private Method--初始化toolBar
- (void)setupToolBars{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"toolbar_back_icon"] imageWithRenderingMode:UIImageRenderingModeAutomatic] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    backItem.enabled = NO;
    self.backItem = backItem;
    
    UIBarButtonItem *forwardItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"toolbar_forward_icon"] imageWithRenderingMode:UIImageRenderingModeAutomatic]  style:UIBarButtonItemStylePlain target:self action:@selector(goForward)];
    forwardItem.enabled = NO;
    self.forwardItem = forwardItem;
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.refreshItem = refreshItem;
    
    self.toolbarItems = @[backItem,forwardItem,flexibleItem,refreshItem];
    backItem.dk_tintColorPicker = DKColorPickerWithKey(TINT);
    forwardItem.dk_tintColorPicker = DKColorPickerWithKey(TINT);
    refreshItem.dk_tintColorPicker = DKColorPickerWithKey(TINT);
    self.navigationController.toolbar.dk_tintColorPicker =  DKColorPickerWithRGB(0xffffff, 0x343434, 0xfafafa);
}

#pragma mark --private Method--初始化shadeView(页面模式时，用来使页面变暗)
- (void)setupShadeView {
    UIView *shadeView = [[UIView alloc] init];
    self.shadeView = shadeView;
    shadeView.backgroundColor = [UIColor blackColor];
    shadeView.alpha = 0.3;
    shadeView.userInteractionEnabled = NO;
    shadeView.frame = self.webView.bounds;
    [self.webView addSubview:shadeView];
}

#pragma mark -UIWebViewDelegate-将要加载Webview
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if([self.navType isEqualToString:@"2"] && self.url.length>0) {
    }
    else if ([self.htmlSDK zw_handlePreviewImageRequest:request]) {
        return NO;
    }
    return YES;
}

#pragma mark -UIWebViewDelegate-已经开始加载Webview
- (void)webViewDidStartLoad:(UIWebView *)webView {
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
           //执行事件
        [SVProgressHUD dismiss];
    });
}

#pragma mark -UIWebViewDelegate-已经加载Webview完毕
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
    self.backItem.enabled = webView.canGoBack;
    self.forwardItem.enabled = webView.canGoForward;
    
//    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    NSLog(@"title=%@",title);
    if([self.navType isEqualToString:@"2"] && self.url.length>0) {
    }
    else {
        self.htmlSDK = [ZWHTMLSDK zw_loadBridgeJSWebview:webView];
        self.htmlSDK.blockHandlePreview = ^(NSArray *allImageArray, NSInteger index) {
            ZWPreviewImageView *showView = [ZWPreviewImageView showImageWithArray:allImageArray withShowIndex:index];
            [showView showRootWindow];
        };
    }
    [self requestAdMob];
}

#pragma mark -UIWebViewDelegate-加载Webview失败
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [SVProgressHUD dismiss];
}


#pragma mark --private Method--返回上一个页面
-(void)goBack {
    [self.webView goBack];
}

#pragma mark --private Method--前进到下一个页面
-(void)goForward {
    [self.webView goForward];
}

#pragma mark --private Method--刷新当前页面
-(void)refresh {
    [self.webView reload];
}

#pragma mark --private Method--收藏这条新闻
-(void)collectThisNews {
    self.collectButton.selected = !self.collectButton.selected;
    if (self.collectButton.selected) {
        [SVProgressHUD showSuccessWithStatus:@"收藏成功"];
        [self.collectButton setImage:[UIImage imageNamed:@"navigationBarItem_favorited_normal"] forState:UIControlStateNormal];
        [self.collectButton setImage:[UIImage imageNamed:@"navigationBarItem_favorited_pressed"] forState:UIControlStateHighlighted];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"取消收藏"];
        [self.collectButton setImage:[UIImage imageNamed:@"navigationBarItem_favorite_normal"] forState:UIControlStateNormal];
        [self.collectButton setImage:[UIImage imageNamed:@"navigationBarItem_favorite_pressed"] forState:UIControlStateHighlighted];
    }
}

- (void)handleEmptyTap:(UIGestureRecognizer *)gesture
{
    [self loadData];
}

- (void)shareThisNews {
    __weak typeof(self)weakSelf = self;
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"] ] ||
       [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]] ||
       [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sinaweibo://"]] ) {
        [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone),@(UMSocialPlatformType_Sina),@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_WechatFavorite)]];
        [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
            // 根据获取的platformType确定所选平台进行下一步操作
            [weakSelf shareWebPageToPlatformType:platformType];
        }];
    }
    else {
        [self shareSystem];
    }
}

- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType {
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
//    UIImage *imageToShare = [UIImage imageNamed:@"appinfoimage"];
//    NSString* thumbURL =  @"https://mobile.umeng.com/images/pic/home/social/img-1.png";
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:self.maintitle descr:self.introduct thumImage:self.imgurl];
    //设置网页地址
    shareObject.webpageUrl = self.srcurl;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
    }];
}

- (void)openShareSystem:(UIImage*)image{
    NSURL *urlToShare = [NSURL URLWithString:self.srcurl];
    NSArray *activityItems = @[self.maintitle, image, urlToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    //不出现在活动项目
    activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeAssignToContact,UIActivityTypeAddToReadingList];
    
    UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(UIActivityType activityType, BOOL completed, NSArray * returnedItems, NSError * activityError)
    {
    };
    
    activityVC.completionWithItemsHandler = myBlock;
    
    UIViewController * rootVc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVc presentViewController:activityVC animated:TRUE completion:nil];
}

- (void)shareSystem {
    __weak typeof(self) weakSelf = self;
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:self.imgurl] options:0
                                               progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                   if(image){
                                                       [self openShareSystem:image];
                                                   }
                                                   else {
                                                       [SXNetworkTools showText:weakSelf.view text:@"分享失败，请稍候重试！" hideAfterDelay:3];
                                                   }
                                               }];
}

@end
