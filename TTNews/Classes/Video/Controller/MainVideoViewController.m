//
//  MainVideoViewController.m
//  TTNews
//
//  Created by lijinwei on 2017/6/23.
//  Copyright © 2017年 瑞文戴尔. All rights reserved.
//

#import "MainVideoViewController.h"
#import <POP.h>
#import <SVProgressHUD.h>
#import <SDImageCache.h>
#import "VideoViewController.h"
#import "ChannelCollectionViewCell.h"
#import "TTJudgeNetworking.h"
#import "TTConst.h"
#import "TTTopChannelContianerView.h"
#import "ChannelsSectionHeaderView.h"
#import "TTNormalNews.h"
#import <DKNightVersion.h>
#import "WyhChannelModel.h"

@interface MainVideoViewController()<UIScrollViewDelegate,TTTopChannelContianerViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableArray *currentChannelsArray;
@property (nonatomic, weak) TTTopChannelContianerView *topContianerView;
@property (nonatomic, weak) UIScrollView *contentScrollView;
@property (nonatomic, strong) NSArray *arrayLists;

@end

static NSString * const collectionCellID = @"ChannelCollectionCell";
static NSString * const collectionViewSectionHeaderID = @"ChannelCollectionHeader";


@implementation MainVideoViewController

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
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark --private Method--初始化子控制器
-(void)setupChildController {
    for (NSInteger i = 0; i<self.currentChannelsArray.count; i++) {
        
        VideoViewController *viewController = [[VideoViewController alloc] init];
        
        viewController.title = self.arrayLists[i][@"title"];
        viewController.type = self.arrayLists[i][@"type"];
        [self addChildViewController:viewController];
    }
}

#pragma mark --private Method--初始化上方的新闻频道选择的View
- (void)setupTopContianerView{
    CGFloat top = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    TTTopChannelContianerView *topContianerView = [[TTTopChannelContianerView alloc] initWithFrame:CGRectMake(0, top, [UIScreen mainScreen].bounds.size.width, 30)];
    topContianerView.channelNameArray = self.currentChannelsArray;
    self.topContianerView  = topContianerView;
    topContianerView.delegate = self;
    [topContianerView showAddBtn:NO];
    [self.view addSubview:topContianerView];
}

#pragma mark --private Method--初始化相信新闻内容的scrollView
- (void)setupContentScrollView {
    UIScrollView *contentScrollView = [[UIScrollView alloc] init];
    self.contentScrollView = contentScrollView;
    contentScrollView.frame = self.view.bounds;
    contentScrollView.contentSize = CGSizeMake(contentScrollView.frame.size.width* self.currentChannelsArray.count, 0);
    contentScrollView.pagingEnabled = YES;
    contentScrollView.delegate = self;
    [self.view insertSubview:contentScrollView atIndex:0];
    [self scrollViewDidEndScrollingAnimation:contentScrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == self.contentScrollView) {
        NSInteger index = scrollView.contentOffset.x/self.contentScrollView.frame.size.width;
        VideoViewController *vc = self.childViewControllers[index];
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
    [self.contentScrollView setContentOffset:CGPointMake(self.contentScrollView.frame.size.width * index, 0) animated:YES];
}

#pragma mark --private Method--存储更新后的currentChannelsArray到偏好设置中

- (void)initChannel {
    _currentChannelsArray = [NSMutableArray new];

    _arrayLists = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"VideoURLs.plist" ofType:nil]];
    
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
        [_currentChannelsArray addObject:model];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.navigationController.viewControllers.count == 1)
        return NO;
    else
        return YES;
}

@end
