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

@interface ContentTableViewController ()

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

@implementation ContentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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
                                   @"1",@"page",
                                   @"0",@"min_time",
                                   @"",@"max_time",
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
                                   @"0",@"min_time",
                                   @"",@"max_time",
                                   nil];
    NSString* paramsString = [SXNetworkTools genParams:params];
    NSString *requestURL = [NSString stringWithFormat: @"%@?%@", GETLIST_CONF_URL,paramsString];
    [self loadDataForType:2 withURL:requestURL];
}

- (void)loadDataForType:(int)type withURL:(NSString *)allUrlstring
{
    [[[SXNetworkTools sharedNetworkTools] GET:allUrlstring parameters:nil progress:nil success:^(NSURLSessionDataTask *task, NSDictionary* responseObject) {
        NSLog(@"%@",allUrlstring);
        NSString *code = [responseObject[@"code"] stringValue];
        if([code isEqualToString:@"0"]) {
            NSArray *temArray = responseObject[@"data"][@"data"];
            NSArray *arrayM = [SXNewsEntity mj_objectArrayWithKeyValuesArray:temArray];
            if (type == 1) {
                self.arrayList = [arrayM mutableCopy];
                [self.tableView.mj_header endRefreshing];
                [self.tableView reloadData];
            }else if(type == 2){
                [self.arrayList addObjectsFromArray:arrayM];
                
                [self.tableView.mj_footer endRefreshing];
                [self.tableView reloadData];
            }
        }
        else
            NSLog(@"获取数据失败！");
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
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

#pragma mark -UITableViewDataSource 返回indexPath对应的cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    return 100;
}

#pragma mark -UITableViewDelegate 点击了某个cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SXNewsEntity *NewsModel = self.arrayList[indexPath.row];
    NSInteger contentType = [NewsModel.content_type integerValue];
    if (contentType==0) {
        [self pushToDetailViewControllerWithUrl:NewsModel.url];
    }else if (contentType==2){
        [self pushToDetailViewControllerWithUrl:NewsModel.url];

    }else if (contentType==3){
        [self pushToDetailViewControllerWithUrl:NewsModel.url];

    }else if (contentType==4){
        [self pushToDetailViewControllerWithUrl:NewsModel.url];
//        ShowMultiPictureViewController *viewController = [[ShowMultiPictureViewController alloc] init];
//        viewController.imageUrls = [NSArray arrayWithArray:NewsModel.cover];
//        NSString *text = NewsModel.introduction;
//        if (text == nil || [text isEqualToString:@""]) {
//            text = NewsModel.title;
//        }
//        viewController.text = text;
//        [self.navigationController pushViewController:viewController animated:YES];
    }else if(contentType == 1){
        [self pushToDetailViewControllerWithUrl:NewsModel.url];
    }
    else {
        [self pushToDetailViewControllerWithUrl:NewsModel.url];
    }
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
@end
