//
//  PictureViewController.h
//  TTNews
//
//  Created by 瑞文戴尔 on 16/3/25.
//  Copyright © 2016年 瑞文戴尔. All rights reserved.
//

#import "PictureViewController.h"
#import <MJRefresh.h>
#import <SVProgressHUD.h>
#import <SDImageCache.h>
#import "TTPicture.h"
#import "TTDataTool.h"
#import "TTPictureFetchDataParameter.h"
#import "TTConst.h"
#import "TTJudgeNetworking.h"
#import <DKNightVersion.h>
#import "SinglePictureNewsTableViewCell.h"
#import "SXNetworkTools.h"
#import "NativeExpressAdViewCell.h"
#import "DetailViewController.h"
#import "SXNewsEntity.h"
#import <MJExtension.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

//ca-app-pub-3940256099942544/2562852117 medium
//ca-app-pub-3940256099942544/2934735716 small
static NSString *const GADAdUnitID = @"ca-app-pub-3940256099942544/2934735716";
static const CGFloat GADAdViewHeight = 100;

static NSString * const nativeExpressAdViewCell = @"NativeExpressAdViewCell";

@interface PictureViewController () <GADNativeExpressAdViewDelegate>
{
    NSString* max_time;
    NSString* min_time;
    
    UIView* emptyView;
    UILabel* emtpyTitle;
    UIImageView* emptyImg;
    
    /// List of ads remaining to be preloaded.
    NSMutableArray<GADNativeExpressAdView *> *_adsToLoad;
    /// Mapping of GADNativeExpressAdView ads to their load state.
    NSMutableDictionary<NSString *, NSNumber *> *_loadStateForAds;
}

@property (nonatomic, strong) NSMutableArray *arrayList;
@property(nonatomic,assign)BOOL update;

@end
static NSString * const SinglePictureCell = @"SinglePictureCell";

@implementation PictureViewController

#pragma mark 懒加载
-(NSMutableArray *)arrayList {
    if (!_arrayList) {
        _arrayList = [NSMutableArray array];
    }
    return _arrayList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBasic];
    [self setupTableView];
    [self setupMJRefreshHeader];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.update == YES) {
        [self.tableView.mj_header beginRefreshing];
        self.update = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}



#pragma mark 基本设置
- (void)setupBasic {
    _adsToLoad = [[NSMutableArray alloc] init];
    _loadStateForAds = [[NSMutableDictionary alloc] init];
    
    max_time = @"";
    min_time = @"0";
    self.arrayList = [[NSMutableArray alloc] initWithCapacity:9];
    
    self.tableView.dk_backgroundColorPicker = DKColorPickerWithRGB(0xf0f0f0, 0x000000, 0xfafafa);
    
    self.navigationController.navigationBar.dk_barTintColorPicker = DKColorPickerWithRGB(0xfa5054,0x444444,0xfa5054);

}

#pragma mark 初始化tableview
- (void)setupTableView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController.navigationBar.frame), 0, self.tabBarController.tabBar.frame.size.height, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SinglePictureNewsTableViewCell class]) bundle:nil] forCellReuseIdentifier:SinglePictureCell];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([NativeExpressAdViewCell class]) bundle:nil] forCellReuseIdentifier:nativeExpressAdViewCell];
    
    emptyView = [[UIView alloc] initWithFrame:self.tableView.frame];
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

#pragma mark --初始化刷新控件
- (void)setupMJRefreshHeader {
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(LoadMoreData)];
}

#pragma mark --下拉刷新数据
- (void)loadData {
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   @"", @"method",
                                   @"101", @"cid",
                                   @"2",@"page",
                                   @"",@"min_time",
                                   max_time,@"max_time",
                                   nil];
    NSString* paramsString = [SXNetworkTools genParams:params];
    NSString *requestURL = [NSString stringWithFormat: @"%@?%@", GETLIST_CONF_URL,paramsString];
    
    [self loadDataForType:1 withURL:requestURL];
    
}

#pragma mark --上拉加载更多数据
- (void)LoadMoreData {
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   @"101", @"cid",
                                   @"2",@"page",
                                   min_time,@"min_time",
                                   @"",@"max_time",
                                   nil];
    NSString* paramsString = [SXNetworkTools genParams:params];
    NSString *requestURL = [NSString stringWithFormat: @"%@?%@", GETLIST_CONF_URL,paramsString];
    [self loadDataForType:2 withURL:requestURL];
}

// Return string containting memory address location of a GADNativeExpressAdView to be used to
// uniquely identify the the object.
- (NSString *)referenceKeyForAdView:(GADNativeExpressAdView *)adView {
    return [[NSString alloc] initWithFormat:@"%p", adView];
}

- (GADNativeExpressAdView *)createAdMob {
    GADNativeExpressAdView *adView = [[GADNativeExpressAdView alloc]
                                      initWithAdSize:GADAdSizeFromCGSize(
                                                                         CGSizeMake(self.tableView.contentSize.width, GADAdViewHeight))];
    adView.adUnitID = GADAdUnitID;
    adView.rootViewController = self;
    adView.delegate = self;
    //    [arrayM addObject:adView];
    [_adsToLoad addObject:adView];
    _loadStateForAds[[self referenceKeyForAdView:adView]] = @NO;
    [self preloadNextAd];
    return adView;
}

/// Preloads native express ads sequentially. Dequeues and loads next ad from adsToLoad list.
- (void)preloadNextAd {
    if (!_adsToLoad.count) {
        return;
    }
    GADNativeExpressAdView *adView = _adsToLoad.firstObject;
    [_adsToLoad removeObjectAtIndex:0];
    [adView loadRequest:[GADRequest request]];
}

- (void)loadDataForType:(int)type withURL:(NSString *)allUrlstring
{
    __weak typeof(self) weakSelf = self;
    [[[SXNetworkTools sharedNetworkTools] GET:allUrlstring parameters:nil progress:nil success:^(NSURLSessionDataTask *task, NSDictionary* responseObject) {
        NSLog(@"%@",allUrlstring);
        NSString *code = [responseObject[@"code"] stringValue];
        if([code isEqualToString:@"0"]) {
            NSArray *temArray = responseObject[@"data"][@"data"];
            max_time = responseObject[@"data"][@"max_time"];
            min_time = responseObject[@"data"][@"min_time"];
            NSArray *arrayM = [SXNewsEntity mj_objectArrayWithKeyValuesArray:temArray];
            
            GADNativeExpressAdView* adView = [weakSelf createAdMob];
            NSMutableArray* insertArr = [NSMutableArray arrayWithArray:arrayM];
            if(adView) {
                NSMutableArray* adArray = [NSMutableArray arrayWithObject:adView];
                [insertArr insertObjects:adArray atIndexes:[NSIndexSet indexSetWithIndexesInRange
                                                            :NSMakeRange(insertArr.count-1,adArray.count)]];
            }
            if (type == 1) {
                if([weakSelf.arrayList count]>0) {
                    [weakSelf.arrayList insertObjects:insertArr atIndexes:[NSIndexSet indexSetWithIndexesInRange
                                                                           :NSMakeRange(0,insertArr.count)]];
                }
                else {
                    [weakSelf.arrayList addObjectsFromArray:insertArr];
                }
                
                [weakSelf.tableView.mj_header endRefreshing];
                [weakSelf.tableView reloadData];
            }else if(type == 2){
                [weakSelf.arrayList addObjectsFromArray:insertArr];
                
                [weakSelf.tableView.mj_footer endRefreshing];
                [weakSelf.tableView reloadData];
            }
            emptyView.hidden = YES;
        }
        else {
            if (type == 1) {
                [weakSelf.tableView.mj_header endRefreshing];
            }
            else if(type == 2){
                [weakSelf.tableView.mj_footer endRefreshing];
            }
            [weakSelf.tableView reloadData];
            NSLog(@"获取数据失败！");
            if([weakSelf.arrayList count]==0) {
                emtpyTitle.text = @"没有更多数据，请点击刷新";
                [emptyImg setImage:[UIImage imageNamed:@"empty"]];
                emptyView.hidden = NO;
            }
            else {
                emptyView.hidden = YES;
                [SXNetworkTools showText:weakSelf.view text:@"没有更多数据，请稍候再试！" hideAfterDelay:3];
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
        if (type == 1) {
            [weakSelf.tableView.mj_header endRefreshing];
        }
        else if(type == 2){
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        NSLog(@"获取数据失败！");
        if([weakSelf.arrayList count]==0) {
            [emtpyTitle setText:@"网络不给力，请点击刷新"];
            [emptyImg setImage:[UIImage imageNamed:@"disconnected"]];
            emptyView.hidden = NO;
        }
        else {
            emptyView.hidden = YES;
            [SXNetworkTools showText:weakSelf.view text:@"网络连接异常，请稍候再试！" hideAfterDelay:3];
        }
    }] resume];
}// ------想把这里改成block来着

#pragma mark - Table view data source

#pragma mark -UITableViewDataSource 返回tableView有多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark -UITableViewDataSource 返回tableView每一组有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayList.count;
}


#pragma mark -UITableViewDataSource 返回indexPath对应的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.arrayList[indexPath.row] isKindOfClass:[GADNativeExpressAdView class]]) {
        UITableViewCell *reusableAdCell =
        [self.tableView dequeueReusableCellWithIdentifier:@"NativeExpressAdViewCell"
                                             forIndexPath:indexPath];
        
        // Remove previous GADNativeExpressAdView from the content view before adding a new one.
        for (UIView *subview in reusableAdCell.contentView.subviews) {
            [subview removeFromSuperview];
        }
        
        GADNativeExpressAdView *adView = self.arrayList[indexPath.row];
        [reusableAdCell.contentView addSubview:adView];
        // Center GADNativeExpressAdView in the table cell's content view.
        adView.center = reusableAdCell.contentView.center;
        
        return reusableAdCell;
    }
    else {
        SXNewsEntity *NewsModel = self.arrayList[indexPath.row];
        SinglePictureNewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SinglePictureCell"];
        cell.imageUrl = NewsModel.imgsrc;
        cell.contentTittle = NewsModel.title;
        cell.desc = NewsModel.introduction;
        cell.source = NewsModel.source;
        double time = [NewsModel.show_time doubleValue];
        NSString* showTime = [SXNetworkTools distanceTimeWithBeforeTime:time];
        cell.showTime = showTime;
        return cell;
    }
}

#pragma mark -UITableViewDataSource 返回indexPath对应的cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.arrayList[indexPath.row] isKindOfClass:[GADNativeExpressAdView class]]) {
        GADNativeExpressAdView *adView = self.arrayList[indexPath.row];
        BOOL isLoaded = [_loadStateForAds[[self referenceKeyForAdView:adView]] boolValue];
        return isLoaded ? GADAdViewHeight : 0;
    }
    return 100;
}

#pragma mark -UITableViewDelegate 点击了某个cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.arrayList[indexPath.row] isKindOfClass:[GADNativeExpressAdView class]]) {
        return;
    }
    SXNewsEntity *NewsModel = self.arrayList[indexPath.row];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   @"101", @"cid",
                                   NewsModel.nid,@"nid",
                                   nil];
    NSString* paramsString = [SXNetworkTools genParams:params];
    NSString *requestURL = [NSString stringWithFormat: @"%@?%@", DETAIL_CONF_URL,paramsString];
    DetailViewController *viewController = [[DetailViewController alloc] init];
    viewController.url = requestURL;
    viewController.maintitle = NewsModel.title;
    static NSDateFormatter *df;
    if(df == nil)
    {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"YYYY-MM-dd HH:mm"];
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[NewsModel.publish_time doubleValue]];
    NSString* time = [df stringFromDate:date];
    viewController.publish_time = time;
    viewController.source = NewsModel.source;
    viewController.srcurl = NewsModel.url;
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)didReceiveMemoryWarning {
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        
    }];
    
}

- (void)handleEmptyTap:(UIGestureRecognizer *)gesture
{
    [self loadData];
}

- (void)nativeExpressAdViewDidReceiveAd:(GADNativeExpressAdView *)nativeExpressAdView {
    // Mark native express ad as succesfully loaded.
    _loadStateForAds[[self referenceKeyForAdView:nativeExpressAdView]] = @YES;
    //    // Load the next ad in the adsToLoad list.
    [self preloadNextAd];
    NSLog(@"nativeExpressAdViewDidReceiveAd load success");
}

- (void)nativeExpressAdView:(GADNativeExpressAdView *)nativeExpressAdView
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad: %@", error.localizedDescription);
    // Load the next ad in the adsToLoad list.
    [self preloadNextAd];
}

@end
