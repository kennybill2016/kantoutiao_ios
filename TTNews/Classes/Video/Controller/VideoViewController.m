//
//  VideoViewController.m
//  TTNews
//
//  Created by 瑞文戴尔 on 16/4/2.
//  Copyright © 2016年 瑞文戴尔. All rights reserved.
//

#import "VideoViewController.h"
#import <MJRefresh.h>
#import <SVProgressHUD.h>
#import <SDImageCache.h>
#import "TTVideo.h"
#import "TTVideoFetchDataParameter.h"
#import "VideoTableViewCell.h"
#import "VideoPlayView.h"
#import "FullViewController.h"
#import "TTDataTool.h"
#import "TTConst.h"
#import "TTJudgeNetworking.h"
#import <DKNightVersion.h>
#import "SXNetworkTools.h"
#import "SXNewsEntity.h"
#import <MJExtension.h>
#import "SinglePictureNewsTableViewCell.h"
#import "DetailViewController.h"


@interface VideoViewController ()<VideoTableViewCellDelegate, VideoPlayViewDelegate>
{
    NSString* max_time;
    NSString* min_time;
    
    UIView* emptyView;
    UILabel* emtpyTitle;
    UIImageView* emptyImg;

}
@property (nonatomic, strong) NSMutableArray *videoArray;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSString *maxtime;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) FullViewController *fullVc;
@property (nonatomic, weak) VideoPlayView *playView;
@property (nonatomic, weak) VideoTableViewCell *currentSelectedCell;
@property (nonatomic, copy) NSString *currentSkinModel;
@property (nonatomic, assign) BOOL isFullScreenPlaying;

@end

static NSString * const VideoCell = @"VideoCell";

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBasic];
    [self setupTableView];
    [self setupMJRefreshHeader];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.isFullScreenPlaying == NO) {//将要呈现的画面不是全屏播放页面
        [self.playView resetPlayView];
    }
//    self.navigationController.navigationBar.alpha = 1;
}



#pragma mark 基本设置
-(void)setupBasic {
    self.tableView.dk_backgroundColorPicker = DKColorPickerWithRGB(0xf0f0f0, 0x000000, 0xfafafa);
    
    self.navigationController.navigationBar.dk_barTintColorPicker = DKColorPickerWithRGB(0xfa5054,0x444444,0xfa5054);

    self.currentPage = 0;
    self.isFullScreenPlaying = NO;
    
    max_time = @"";
    min_time = @"0";
}

#pragma mark 初始化TableView
- (void)setupTableView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController.navigationBar.frame) , 0, self.tabBarController.tabBar.frame.size.height, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([VideoTableViewCell class]) bundle:nil] forCellReuseIdentifier:VideoCell];
    
    emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)];
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

-(void)didReceiveMemoryWarning {
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        
    }];
    
}

- (void)handleEmptyTap:(UIGestureRecognizer *)gesture
{
    [self LoadNewData];
}

#pragma mark 初始化刷新控件
- (void)setupMJRefreshHeader {
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(LoadNewData)];
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(LoadMoreData)];
}

#pragma mark 加载最新数据
- (void)LoadNewData {
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   @"", @"method",
                                   @"201", @"cid",
                                   @"2",@"page",
                                   @"",@"min_time",
                                   @"4",@"limit",
                                   max_time,@"max_time",
                                   nil];
    NSString* paramsString = [SXNetworkTools genParams:params];
    NSString *requestURL = [NSString stringWithFormat: @"%@?%@", GETVIDEOLIST_CONF_URL,paramsString];
    
    [self loadDataForType:1 withURL:requestURL];
}

#pragma mark 加载更多数据
- (void)LoadMoreData {
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   @"201", @"cid",
                                   @"2",@"page",
                                   min_time,@"min_time",
                                   @"4",@"limit",
                                   @"",@"max_time",
                                   nil];
    NSString* paramsString = [SXNetworkTools genParams:params];
    NSString *requestURL = [NSString stringWithFormat: @"%@?%@", GETVIDEOLIST_CONF_URL,paramsString];
    [self loadDataForType:2 withURL:requestURL];
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
            
            NSArray *arrayM = [TTVideo mj_objectArrayWithKeyValuesArray:temArray];
            NSMutableArray* insertArr = [NSMutableArray arrayWithArray:arrayM];
            if (type == 1) {
                if([[weakSelf videoArray] count]>0) {
                    [weakSelf.videoArray insertObjects:insertArr atIndexes:[NSIndexSet indexSetWithIndexesInRange
                                                                           :NSMakeRange(0,insertArr.count)]];
                }
                else {
                    [weakSelf.videoArray addObjectsFromArray:insertArr];
                }
                
                [weakSelf.tableView.mj_header endRefreshing];
                [weakSelf.tableView reloadData];
            }else if(type == 2){
                [weakSelf.videoArray addObjectsFromArray:insertArr];
                
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
            if([weakSelf.videoArray count]==0) {
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
        if([weakSelf.videoArray count]==0) {
            [emtpyTitle setText:@"网络不给力，请点击刷新"];
            [emptyImg setImage:[UIImage imageNamed:@"empty"]];
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
    return self.videoArray.count;
}


#pragma mark -UITableViewDataSource 返回indexPath对应的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:VideoCell];
    cell.video = self.videoArray[indexPath.row];
    cell.delegate = self;
    cell.indexPath = indexPath;
    return cell;
}

#pragma mark -UITableViewDataSource 返回indexPath对应的cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300;
//    TTVideo *video = self.videoArray[indexPath.row];
//    return video.cellHeight;
}

#pragma mark -UITableViewDelegate 点击了某个cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self pushToVideoCommentViewControllerWithIndexPath:indexPath];
}

#pragma mark 点击某个Cell或点击评论按钮跳转到评论页面
-(void)pushToVideoCommentViewControllerWithIndexPath:(NSIndexPath *)indexPath {
    TTVideo *NewsModel = self.videoArray[indexPath.row];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   NewsModel.type, @"cid",
                                   NewsModel.nid,@"nid",
                                   nil];
    NSString* paramsString = [SXNetworkTools genParams:params];
    NSString *requestURL = [NSString stringWithFormat: @"%@?%@", VIDEODETAIL_CONF_URL,paramsString];
    DetailViewController *viewController = [[DetailViewController alloc] init];
    viewController.url = requestURL;
    viewController.type = NewsModel.type;
    viewController.nid = NewsModel.nid;
    viewController.maintitle = NewsModel.title;
    viewController.navType = NewsModel.navtype;
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

#pragma mark VideoTableViewCell的代理方法
-(void)clickMoreButton:(TTVideo *)video {
    UIAlertController *controller =  [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [controller addAction:[UIAlertAction actionWithTitle:@"收藏" style:UIAlertActionStyleDefault handler:nil]];
    [controller addAction:[UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDefault handler:nil]];
    [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark VideoTableViewCell的代理方法
-(void)clickVideoButton:(NSIndexPath *)indexPath {
}

#pragma mark VideoTableViewCell的代理方法
-(void)clickCommentButton:(NSIndexPath *)indexPath {
    [self pushToVideoCommentViewControllerWithIndexPath:indexPath];
}

-(NSMutableArray *)videoArray {
    if (!_videoArray) {
        _videoArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _videoArray;
}

@end
