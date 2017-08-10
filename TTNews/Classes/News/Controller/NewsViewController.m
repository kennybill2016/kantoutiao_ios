//
//  NewsViewController.m
//  TTNews
//
//  Created by 瑞文戴尔 on 16/3/24.
//  Copyright © 2016年 瑞文戴尔. All rights reserved.
//

#import "NewsViewController.h"
#import <POP.h>
#import <SVProgressHUD.h>
#import <SDImageCache.h>
#import "ContentTableViewController.h"
#import "ChannelCollectionViewCell.h"
#import "TTJudgeNetworking.h"
#import "TTConst.h"
#import "TTTopChannelContianerView.h"
#import "ChannelsSectionHeaderView.h"
#import "TTNormalNews.h"
#import <DKNightVersion.h>
#import "WyhChannelManager.h"
#import "ChannelManagerViewController.h"

@interface NewsViewController()<UIScrollViewDelegate,TTTopChannelContianerViewDelegate,UIGestureRecognizerDelegate>
//@property (nonatomic, strong) NSMutableArray *currentChannelsArray;
@property (nonatomic, weak) TTTopChannelContianerView *topContianerView;
@property (nonatomic, weak) UIScrollView *contentScrollView;
@property (nonatomic, strong) NSArray *arrayLists;

@property (nonatomic, weak) WyhChannelManager *manager;

//@property (nonatomic, strong) WyhSegmentView *segmentView;
//
//@property (nonatomic, strong) WyhContentView *contentView;

@property (nonatomic, strong) NSMutableArray<WyhChannelModel *>* topChannelArr;

@property (nonatomic, strong) NSMutableArray<WyhChannelModel *>* bottomChannelArr;

@property (nonatomic, strong) NSMutableArray<ContentTableViewController *>* contentTableVCArr;

@property (nonatomic, strong) NSMutableArray *topTitleArr;

@end

static NSString * const collectionCellID = @"ChannelCollectionCell";
static NSString * const collectionViewSectionHeaderID = @"ChannelCollectionHeader";

@implementation NewsViewController
//- (NSArray *)arrayLists
//{
//    if (_arrayLists == nil) {
//        _arrayLists = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"NewsURLs.plist" ofType:nil]];
//    }
//    return _arrayLists;
//}

-(void)viewDidLoad {
    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.isCellShouldShake = NO;
    self.view.dk_backgroundColorPicker = DKColorPickerWithRGB(0xf0f0f0, 0x000000, 0xfafafa);
    self.navigationController.navigationBar.dk_barTintColorPicker = DKColorPickerWithRGB(0xfa5054,0x444444,0xfa5054);

    [self initChannel];

    [self setupTopContianerView];
    [self setupChildController];
    [self setupContentScrollView];
//    [self setupCollectionView];
     self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    self.manager = [WyhChannelManager updateWithTopArr:self.topChannelArr BottomArr:self.bottomChannelArr InitialIndex:0 newStyle:nil];
    __weak typeof(&*self) weakself = self;
    
    [WyhChannelManager updateChannelCallBack:^(NSArray<WyhChannelModel *> *top, NSArray<WyhChannelModel *> *bottom, NSInteger chooseIndex) {
        weakself.topChannelArr = [NSMutableArray arrayWithArray:top];
        if (bottom.count!=0) {
            weakself.bottomChannelArr = [NSMutableArray arrayWithArray:bottom];
        }else{
            [weakself.bottomChannelArr removeAllObjects];
        }
        [self refreshContianerView:chooseIndex];
        
        [self saveChannelSettings];
    }];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark --private Method--初始化子控制器
-(void)setupChildController {
    for(NSInteger i = 0; i<self.contentTableVCArr.count; i++) {
        ContentTableViewController* VC = self.contentTableVCArr[i];
        if(VC){
            [VC.view removeFromSuperview];
            [VC removeFromParentViewController];
        }
    }
    [self.contentTableVCArr removeAllObjects];
    for (NSInteger i = 0; i<self.topChannelArr.count; i++) {
        ContentTableViewController *viewController = [[ContentTableViewController alloc] init];
        
        WyhChannelModel* model = self.topChannelArr[i];
        viewController.title = model.channel_name;
        viewController.type = model.type;
        viewController.show = model.isTop;
        [self addChildViewController:viewController];
        [self.contentTableVCArr addObject:viewController];
    }
}

#pragma mark --private Method--初始化上方的新闻频道选择的View
- (void)setupTopContianerView{
    CGFloat top = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    TTTopChannelContianerView *topContianerView = [[TTTopChannelContianerView alloc] initWithFrame:CGRectMake(0, top, [UIScreen mainScreen].bounds.size.width, 30)];
    topContianerView.channelNameArray = self.topChannelArr;
    self.topContianerView  = topContianerView;
    topContianerView.delegate = self;
    [self.view addSubview:topContianerView];
}

- (void)refreshContianerView:(NSInteger)chooseIndex{
    [self setupChildController];
    self.topContianerView.channelNameArray = self.topChannelArr;
    self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width* self.topChannelArr.count, 0);
    [self scrollViewDidEndScrollingAnimation:self.contentScrollView];
    
//    NSAssert(chooseIndex >= 0 && chooseIndex < self.topChannelArr.count, @"设置的下标不合法!!");
    
    if (chooseIndex < 0 || chooseIndex >= self.topChannelArr.count) {
        return;
    }
    [self.topContianerView selectChannelButtonWithIndex:chooseIndex];

}

#pragma mark --private Method--初始化相信新闻内容的scrollView
- (void)setupContentScrollView {
    UIScrollView *contentScrollView = [[UIScrollView alloc] init];
    self.contentScrollView = contentScrollView;
    contentScrollView.frame = self.view.bounds;
    contentScrollView.contentSize = CGSizeMake(contentScrollView.frame.size.width* self.topChannelArr.count, 0);
    contentScrollView.pagingEnabled = YES;
    contentScrollView.delegate = self;
    [self.view insertSubview:contentScrollView atIndex:0];
    [self scrollViewDidEndScrollingAnimation:contentScrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == self.contentScrollView) {
        NSInteger index = scrollView.contentOffset.x/self.contentScrollView.frame.size.width;
        ContentTableViewController *vc = self.childViewControllers[index];
        vc.view.frame = CGRectMake(scrollView.contentOffset.x, 0, self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.height);
        vc.tableView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController.navigationBar.frame)+self.topContianerView.scrollView.frame.size.height, 0, self.tabBarController.tabBar.frame.size.height, 0);
        [scrollView addSubview:vc.view];
        for (int i = 0; i<self.contentScrollView.subviews.count; i++) {
            NSInteger currentIndex = vc.tableView.frame.origin.x/self.contentScrollView.frame.size.width;
            if ([self.contentScrollView.subviews[i] isKindOfClass:[UITableView class]]) {
                UITableView *theTableView = self.contentScrollView.subviews[i];
                NSInteger theIndex = theTableView.frame.origin.x/self.contentScrollView.frame.size.width;
                NSInteger gap = theIndex - currentIndex;
                if (gap<=2&&gap>=-2) {
                    continue;
                } else {
                    [theTableView removeFromSuperview];
                }
            }
            
        }
        
    }
}

#pragma mark --UIScrollViewDelegate-- 滑动的减速动画结束后会调用这个方法
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.contentScrollView) {
        [self scrollViewDidEndScrollingAnimation:scrollView];
        NSInteger index = scrollView.contentOffset.x/self.contentScrollView.frame.size.width;
        [self.topContianerView selectChannelButtonWithIndex:index];
    }
}

#pragma mark --UICollectionViewDataSource-- 返回每个UICollectionViewCell发Size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat kDeviceWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat kMargin = 10;
    return CGSizeMake((kDeviceWidth - 5*kMargin)/4, 40);
}

#pragma mark --TTTopChannelContianerViewDelegate--选择了某个新闻频道，更新scrollView的contenOffset
- (void)chooseChannelWithIndex:(NSInteger)index {
    [WyhChannelManager defaultManager].initialIndex = index;
    [self.contentScrollView setContentOffset:CGPointMake(self.contentScrollView.frame.size.width * index, 0) animated:YES];
}

- (void)showOrHiddenAddChannelsCollectionView:(UIButton *)button {
    ChannelManagerViewController *vc = [ChannelManagerViewController new];
    [self.navigationController pushViewController:vc animated:YES ];
}

#pragma mark --private Method--存储更新后的currentChannelsArray到偏好设置中

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.navigationController.viewControllers.count == 1)
        return NO;
    else
        return YES;
}

#pragma mark - lazy

-(NSMutableArray *)topTitleArr{
    
    _topTitleArr = [NSMutableArray new];
    for (WyhChannelModel *model in self.topChannelArr) {
        [_topTitleArr addObject:model.channel_name];
    }
    return _topTitleArr;
}

- (void)initChannel {
    _topChannelArr = [NSMutableArray new];
    _bottomChannelArr = [NSMutableArray new];
    _contentTableVCArr = [NSMutableArray new];
    
    NSArray* localItem = [[NSUserDefaults standardUserDefaults] objectForKey:@"ChannelSettings"];
    if(localItem.count>0) {
        _arrayLists = [NSArray arrayWithArray:localItem];
    }
    else {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"NewsURLs" ofType:@"plist"];
        _arrayLists = [NSArray arrayWithContentsOfFile:path];
        
    }
    
    for (int i = 0; i < _arrayLists.count; i++) {
        WyhChannelModel *model = [WyhChannelModel new];
        NSDictionary* dict = _arrayLists[i];
        NSString* type;
        if ([[dict objectForKey:@"type"] respondsToSelector:@selector(stringValue)]) {
            type = [[dict objectForKey:@"type"] stringValue];
        }
        else {
            type = [NSString stringWithString:[dict objectForKey:@"type"]];
        }
        model.isHot = NO;
        model.isEnable = NO;
        model.type = type;
        model.isTop = [dict[@"isTop"] boolValue];
        model.channel_name = dict[@"title"];
        if(model.isTop) {
            [_topChannelArr addObject:model];
        }
        else {
            [_bottomChannelArr addObject:model];
        }
    }
}

-(void)saveChannelSettings {
    NSMutableArray* channelArray = [NSMutableArray new];
    for (int i = 0; i < _topChannelArr.count; i++) {
        WyhChannelModel *model = [_topChannelArr objectAtIndex:i];
        
        NSMutableDictionary* dict = [NSMutableDictionary new];
        [dict setValue:model.type forKey:@"type"];
        [dict setValue:model.channel_name forKey:@"title"];
        [dict setValue:[NSNumber numberWithBool:model.isTop] forKey:@"isTop"];
        [channelArray addObject:dict];
    }
    for (int i = 0; i < _bottomChannelArr.count; i++) {
        WyhChannelModel *model = [_bottomChannelArr objectAtIndex:i];

        NSMutableDictionary* dict = [NSMutableDictionary new];
        [dict setValue:model.type forKey:@"type"];
        [dict setValue:model.channel_name forKey:@"title"];
        [dict setValue:[NSNumber numberWithBool:model.isTop] forKey:@"isTop"];
        [channelArray addObject:dict];
    }
    
    NSArray* saveArray = [NSArray arrayWithArray:channelArray];
    [[NSUserDefaults standardUserDefaults] setObject:saveArray forKey:@"ChannelSettings"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

