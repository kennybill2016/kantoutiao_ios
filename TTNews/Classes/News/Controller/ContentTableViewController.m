//
//  ContentTableViewController.m
//  TTNews
//
//  Created by 瑞文戴尔 on 16/3/26.
//  Copyright © 2016年 瑞文戴尔. All rights reserved.
//

#import "ContentTableViewController.h"
#import <MJRefresh.h>
#import <SVProgressHUD.h>
#import "SinglePictureNewsTableViewCell.h"
#import "MultiPictureTableViewCell.h"
#import "DetailViewController.h"
#import "ShowMultiPictureViewController.h"
#import "TTNormalNewsFetchDataParameter.h"
#import "TTDataTool.h"
#import "TTConst.h"
#import <DKNightVersion.h>
#import <SDImageCache.h>
#import "SXNetworkTools.h"
#import "SXNewsEntity.h"
#import <MJExtension.h>
#import "TopTextTableViewCell.h"
#import "TopPictureTableViewCell.h"
#import "BigPictureTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "NoPictureNewsTableViewCell.h"
#import "SXNetworkTools.h"
#import "NativeExpressAdViewCell.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

//ca-app-pub-3940256099942544/2562852117 medium
//ca-app-pub-3940256099942544/2934735716 small
static NSString *const GADAdUnitID = @"ca-app-pub-3940256099942544/2934735716";
static const CGFloat GADAdViewHeight = 100;

@interface ContentTableViewController () <GADNativeExpressAdViewDelegate> {
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

@property (nonatomic, strong) NSMutableArray *headerNewsArray;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSMutableArray *normalNewsArray;
@property (nonatomic, copy) NSString *currentSkinModel;
@property (nonatomic, strong) NSMutableArray *arrayList;
@property(nonatomic,assign)BOOL update;

@end

static NSString * const singlePictureCell = @"SinglePictureCell";
static NSString * const multiPictureCell = @"MultiPictureCell";
static NSString * const bigPictureCell = @"BigPictureCell";
static NSString * const topTextPictureCell = @"TopTextPictureCell";
static NSString * const topPictureCell = @"TopPictureCell";
static NSString * const noPictureCell = @"NoPictureCell";
static NSString * const nativeExpressAdViewCell = @"NativeExpressAdViewCell";

@implementation ContentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _adsToLoad = [[NSMutableArray alloc] init];
    _loadStateForAds = [[NSMutableDictionary alloc] init];

    [self setupBasic];
    [self setupRefresh];
    
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

#pragma mark --private Method--设置tableView
-(void)setupBasic {
    self.tableView.dk_backgroundColorPicker = DKColorPickerWithRGB(0xf0f0f0, 0x000000, 0xfafafa);

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(104, 0, 0, 0);
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TopPictureTableViewCell class]) bundle:nil] forCellReuseIdentifier:topPictureCell];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TopTextTableViewCell class]) bundle:nil] forCellReuseIdentifier:topTextPictureCell];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BigPictureTableViewCell class]) bundle:nil] forCellReuseIdentifier:bigPictureCell];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SinglePictureNewsTableViewCell class]) bundle:nil] forCellReuseIdentifier:singlePictureCell];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MultiPictureTableViewCell class]) bundle:nil] forCellReuseIdentifier:multiPictureCell];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([NativeExpressAdViewCell class]) bundle:nil] forCellReuseIdentifier:nativeExpressAdViewCell];
    
    max_time = @"";
    min_time = @"0";
    self.arrayList = [[NSMutableArray alloc] initWithCapacity:9];
    
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


#pragma mark --private Method--初始化刷新控件
-(void)setupRefresh {
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    [self.tableView.mj_header beginRefreshing];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.currentPage = 1;
}


#pragma mark - /************************* 刷新数据 ***************************/
// ------下拉刷新
- (void)loadData
{
    // http://c.m.163.com//nc/article/headline/T1348647853363/0-30.html
    //#define HOME_PAGE "http://localhost:8887/content/getList.php?cid={0}&max_time={1}&min_time={2}&page={3}&deviceid={4}&tn=1&limit=8&user=temporary1493130412672&content_type=1&dtu=200"

    NSString* qid = @"0";
    if( qid == nil )
        qid = @"0";
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   @"", @"method",
                                   qid, @"qid",
                                   self.type, @"cid",
                                   @"2",@"page",
                                   @"",@"min_time",
                                   max_time,@"max_time",
                                   nil];
    NSString* paramsString = [SXNetworkTools genParams:params];
    NSString *requestURL = [NSString stringWithFormat: @"%@?%@", GETLIST_CONF_URL,paramsString];
    
    [self loadDataForType:1 withURL:requestURL];
}

- (void)loadMoreData
{
    NSString* qid = @"0";
    if( qid == nil )
        qid = @"0";
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   self.type, @"cid",
                                   qid, @"qid",
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
                                                                       :NSMakeRange(insertArr.count/2,adArray.count)]];
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
        NSInteger contentType = [NewsModel.content_type integerValue];
        if (contentType==0) {
            TopPictureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:topPictureCell];
            [cell.imgIcon sd_setImageWithURL:[NSURL URLWithString:NewsModel.imgsrc] placeholderImage:[UIImage imageNamed:@"302"]];
            cell.LblTitleLabel.text = NewsModel.title;
            return cell;
        }else if (contentType==2){
            TopTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:topTextPictureCell];
            [cell.imgIcon sd_setImageWithURL:[NSURL URLWithString:NewsModel.imgsrc] placeholderImage:[UIImage imageNamed:@"302"]];
            cell.LblTitleLabel.text = NewsModel.title;
            return cell;
        }else if (contentType==3){
            BigPictureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bigPictureCell];
            [cell.imgIcon sd_setImageWithURL:[NSURL URLWithString:NewsModel.imgsrc] placeholderImage:[UIImage imageNamed:@"302"]];
            cell.LblTitleLabel.text = NewsModel.title;
            return cell;
        }else if (contentType==4){
            MultiPictureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:multiPictureCell];
            cell.theTitle = NewsModel.title;
            cell.source = NewsModel.source;
            cell.imageUrls = [NSArray arrayWithArray:NewsModel.cover];
            double time = [NewsModel.show_time doubleValue];
            NSString* showTime = [SXNetworkTools distanceTimeWithBeforeTime:time];
            cell.showTime = showTime;
            return cell;
        }else if (contentType==1){
            SinglePictureNewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:singlePictureCell];
            cell.imageUrl = NewsModel.imgsrc;
            cell.contentTittle = NewsModel.title;
            cell.desc = NewsModel.introduction;
            cell.source = NewsModel.source;
            double time = [NewsModel.show_time doubleValue];
            NSString* showTime = [SXNetworkTools distanceTimeWithBeforeTime:time];
            cell.showTime = showTime;
            return cell;
        }
        else {
            NoPictureNewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noPictureCell];
            cell.titleText = NewsModel.title;
            cell.contentText = NewsModel.introduction;
            return cell;
        }
    }
}

#pragma mark -UITableViewDataSource 返回indexPath对应的cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.arrayList[indexPath.row] isKindOfClass:[GADNativeExpressAdView class]]) {
        GADNativeExpressAdView *adView = self.arrayList[indexPath.row];
        BOOL isLoaded = [_loadStateForAds[[self referenceKeyForAdView:adView]] boolValue];
        return isLoaded ? GADAdViewHeight : 0;
    }
    else {
        SXNewsEntity *NewsModel = self.arrayList[indexPath.row];
        NSInteger contentType = [NewsModel.content_type integerValue];
        if (contentType==0){
            return 245;
        }else if(contentType==2) {
            return 245;
        }else if(contentType==3) {
            return 170;
        }else if (contentType==4){
            return 150;
        }else if (contentType==1){
            return 100;
        }
    }
    return 100;
}

#pragma mark -UITableViewDelegate 点击了某个cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.arrayList[indexPath.row] isKindOfClass:[GADNativeExpressAdView class]]) {
        return;
    }
    SXNewsEntity *NewsModel = self.arrayList[indexPath.row];
    NSString* qid = @"0";
    if( qid == nil )
        qid = @"0";
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   self.type, @"cid",
                                   qid, @"qid",
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
    /*
    NSInteger contentType = [NewsModel.content_type integerValue];
    if (contentType==0) {
        [self pushToDetailViewControllerWithUrl:NewsModel.url];
    }else if (contentType==2){
        [self pushToDetailViewControllerWithUrl:NewsModel.url];

    }else if (contentType==3){
        [self pushToDetailViewControllerWithUrl:NewsModel.url];

    }else if (contentType==4){

//        [self pushToDetailViewControllerWithUrl:requestURL];
//        ShowMultiPictureViewController *viewController = [[ShowMultiPictureViewController alloc] init];
//        viewController.imageUrls = [NSArray arrayWithArray:NewsModel.cover];
//        NSString *text = NewsModel.introduction;
//        if (text == nil || [text isEqualToString:@""]) {
//            text = NewsModel.title;
//        }
//        viewController.text = text;
//        [self.navigationController pushViewController:viewController animated:YES];
    }else if(contentType == 1){

    }
    else {
    }*/
}

#pragma mark --private Method--点击了某一条新闻，调转到新闻对应的网页去
-(void)pushToDetailViewControllerWithUrl:(NSString *)url {
    DetailViewController *viewController = [[DetailViewController alloc] init];
    viewController.url = url;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark --懒加载--normalNewsArray
-(NSMutableArray *)normalNewsArray {
    if (!_normalNewsArray) {
        _normalNewsArray = [NSMutableArray array];
    }
    return _normalNewsArray;
}

#pragma mark --懒加载--headerNewsArray
-(NSMutableArray *)headerNewsArray {
    if (!_headerNewsArray) {
        _headerNewsArray = [NSMutableArray array];
    }
    return _headerNewsArray;
}
-(void)didReceiveMemoryWarning {
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    
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
