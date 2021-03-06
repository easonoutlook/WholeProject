//
//  NT_MainView.m
//  NaiTangApp
//
//  Created by 张正超 on 14-3-3.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_MainView.h"
#import "NT_AppDetailInfo.h"
#import "NT_AdInfo.h"
#import "NT_AdView.h"
#import "MKNetworkKit.h"
#import "NT_HttpEngine.h"
#import "NT_LoadMoreCell.h"
#import "NT_MainSecondCell.h"
#import "NT_AppDetailViewController.h"
#import "NT_DownLoadModel.h"
#import "NT_OnlineGameDialog.h"
#import "NT_DownloadManager.h"
#import "NT_BaseView.h"
#import "UIImageView+WebCache.h"
#import "NT_UpdateAppInfo.h"
#import "DataService.h"
#import "Utile.h"
#import "SwitchTableView.h"
#import "NT_TopAdView.h"
#import "NT_NoNetworkView.h"
#import "NT_SettingManager.h"
#import "NT_WifiBrowseImage.h"

@interface NT_MainView ()
{
    NT_AppDetailInfo *_appsDetail;
    NT_DownloadModel *_selectedModel;
}

@end

@implementation NT_MainView

@synthesize switchTableView;
@synthesize tableView = _tableView;
@synthesize dataArray;
@synthesize selectedIndex;
@synthesize type = _type;
@synthesize isOnlineGame;
@synthesize delegate;
@synthesize bottomRedHeight;

- (id)initWithFrame:(CGRect)frame type:(AppListType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.type = type;
        self.selectedIndex = -1;
        self.dataArray = [NSMutableArray array];
        _pageNum = 0;
        
        switchTableView = [SwitchTableView shareSwitchTableViewData];
        
        //[[NSUserDefaults standardUserDefaults] setFloat:self.height-(64+13) forKey:KBottomInfo];
        //[[NSUserDefaults standardUserDefaults] synchronize];

        self.type = type;
        //初始化加载默认视图，判断是否有网络
        [self loadDefaultView:type];
        
        //收起无限金币弹出框
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideInstallCell:) name:kNotificationShouldHideInstallCell object:nil];
        //进入前台时刷新
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshdataWithEntryForegroud) name:kApplicationWillEnterForeground object:nil];
    }
    return self;
}

//进入前台时刷新
- (void)refreshdataWithEntryForegroud
{
    self.tableView.contentOffset = CGPointMake(0, -60.0f);
    //初始化加载默认视图，判断是否有网络
    [self loadDefaultView:self.type];
}

//收起无限金币弹出框
- (void)hideInstallCell:(NSNotification *)notification
{
    if (self.selectedIndex != -1) {
        int lastIndex = self.selectedIndex;
        self.selectedIndex = -1;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:lastIndex] withRowAnimation:UITableViewRowAnimationNone];
    }
}

//初始化加载默认视图，判断是否有网络
- (void)loadDefaultView:(AppListType)type
{
    //首次加载时，无网络的话，显示测试数据，其他时候无网络，是有缓存的数据显示的，无需其他操作
    NSString *netConnection = [[NT_HttpEngine sharedNT_HttpEngine] getCurrentNet];
    BOOL isFirstLoad = [[NSUserDefaults standardUserDefaults] boolForKey:KCategoryIsFirstLoad];
    //首次加载时，无网络的话，显示测试数据，
    if (!isFirstLoad && [netConnection isEqualToString:NETNOTWORKING])
    {
        NT_NoNetworkView *bgView  = bgView = [[NT_NoNetworkView alloc] initWithFrame:CGRectMake(0, -100, SCREEN_WIDTH, SCREEN_HEIGHT)];
        /*
        if (isIOS7&&isIphone5Screen)
        {
            bgView = [[NT_NoNetworkView alloc] initWithFrame:CGRectMake(0, -100, SCREEN_WIDTH, SCREEN_HEIGHT)];
        }
        else if (isIOS7&&!isIphone5Screen)
        {
            bgView = [[NT_NoNetworkView alloc] initWithFrame:CGRectMake(0, -100, SCREEN_WIDTH, SCREEN_HEIGHT)];
        }
        else
        {
            bgView = [[NT_NoNetworkView alloc] initWithFrame:CGRectMake(0, -100, SCREEN_WIDTH, SCREEN_HEIGHT)];
            
        }
        */
        bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:bgView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(networkButtonPressed:)];
        [bgView addGestureRecognizer:tap];
        
        //无网络时，显示图片
        [bgView loadNoNetworkView];
        [bgView.networkButton addTarget:self action:@selector(networkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        //首先移除全部视图
        [self removeAllSubViews];
        [self loadMainData:type];
    }

}

//加载主页数据
- (void)loadMainData:(AppListType)type
{
    //解决ios7下tableview空白
    if (isIOS7)
    {
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self addSubview:tempLabel];
    }
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds];
    if (self.tag == KRankingViewTag)
    {
        tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.bottom);
    }
    tableView.opaque = YES;
    tableView.alpha =1.0;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //tableView.separatorColor = [UIColor colorWithHex:@"#e4e4e4"];
    //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self addSubview:tableView];
    self.tableView = tableView;
    //去掉多余的cell线
    [Utile setExtraCellLineHidden:self.tableView];
    
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - _tableView.bounds.size.height, _tableView.frame.size.width, _tableView.frame.size.height)];
    _refreshHeaderView.delegate = self;
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    [tableView addSubview:_refreshHeaderView];
    [_refreshHeaderView refreshLastUpdatedDate];
    
    //主页-热门
    if (type == AppListTypeHomeHot) {
        /*
         NT_AdView *focusView = [[NT_AdView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
         focusView.alpha = 1.0;
         focusView.opaque = YES;
         focusView.backgroundColor = [UIColor whiteColor];
         self.tableView.tableHeaderView = focusView;
         */
        NT_TopAdView *topAdView = [[NT_TopAdView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        self.tableView.tableHeaderView = topAdView;
    }
    
    [self getDataForPage:1];
    
    //判断视图是否消失，若消失则将无限金币的弹出框收起
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideInstallCell:) name:@"hideInstallCell" object:nil];
}

//网络无连接时点击图片
- (void)networkButtonPressed:(id)sender
{
    [self loadDefaultView:self.type];
}

/*
//判断视图是否消失，若消失则将无限金币的弹出框收起
- (void)hideInstallCell:(id)sender
{
    //收起无限金币的弹框
    if (self.selectedIndex > -1) {
        int tmp = self.selectedIndex;
        self.selectedIndex = -1;
        //reloadSections必须使用beginUpdates和endUpdates方法
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:tmp] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }

}

- (void)refreshdataWithEntryForegroud
{
    self.tableView.contentOffset = CGPointMake(0, -60.0f);
    [self getDataForPage:1];
}
*/
- (void)getDataForPage:(int)page
{
    /*
    //若第一次图片刷新不出来，使用这个进行第二此刷新头图
    if (self.type == AppListTypeHomeHot) {
        NT_TopAdView *topAdView = [[NT_TopAdView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        self.tableView.tableHeaderView = topAdView;
    }
*/
    /*
     
    if (self.type ==AppListTypeHomeHot) {
        NT_AdView *focusView = [[NT_AdView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        focusView.delegate = self;
        self.tableView.tableHeaderView = focusView;
    }
    */
    if (page <= 1) {
        //        [self showLoadingMeg:@"加载中"];
        //self.tableView.contentOffset = CGPointMake(0, -60.0f);
        [_refreshHeaderView setState:EGOOPullRefreshLoading];
        self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
    }
    else
    {
        [self startLoadingMore];
    }
    _isLoading = YES;
    /*
    MKNKResponseBlock respones = ^(MKNetworkOperation *completedOperation) {
        _isLoading = NO;
        [self stopLoadingMore];
        [self hideLoading];
        [self getDataFinishedWithDic:[completedOperation responseJSONRemoveNull] forPage:page];
        [self doneLoadingTableViewData];
    };
    MKNKResponseErrorBlock error = ^(MKNetworkOperation *completedOperation, NSError *error) {
        [self stopLoadingMore];
        _isLoading = NO;
        [self doneLoadingTableViewData];
        [self showLoadingMeg:@"网络异常" time:1];
    };
    */
    
    NSString *url = @"http://apitest.naitang.com/";
    NSString *urlString = nil;
    switch (self.type) {
        case AppListTypeHomeLastest:
            //[[NT_HttpEngine sharedNT_HttpEngine] getRecForPage:page OnCompletionHandler:respones errorHandler:error];
            break;
        case AppListTypeHomeHot:
        {
            if (isIpad) {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/index/rec_2_2_3_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/index/rec_2_1_3_%d.html",page];
            }else
            {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/index/rec_1_1_3_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/index/rec_1_1_3_%d.html",page];
            }
        }
            //[[NT_HttpEngine sharedNT_HttpEngine] getCurrrentHotFor:page OnCompletionHander:respones errorHandler:error];
            break;
        case AppListTypeTopUp:
        {
            if (isIpad) {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/top/2_2_1_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/top/2_1_1_%d.html",page];
            }else
            {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/top/1_1_1_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/top/1_1_1_%d.html",page];
            }
        }
            //[[NT_HttpEngine sharedNT_HttpEngine] getTopUpForPage:page OnCompletionHandler:respones errorHandler:error];
            break;
        case AppListTypeTopHot:
            //[[NT_HttpEngine sharedNT_HttpEngine] getTopHotForPage:page OnCompletionHandler:respones errorHandler:error];
            break;
        case AppListTypeTopClassical:
        {
            if (isIpad) {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/k7mobile/bibei/2_2_%d_%d.html",page,12] : [NSString stringWithFormat:@"mobile/v1/k7mobile/bibei/2_1_3_%d_%d.html",page,12];
            }else
            {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/k7mobile/bibei/1_1_%d_%d.html",page,12] : [NSString stringWithFormat:@"mobile/v1/k7mobile/bibei/1_1_%d_%d.html",page,12];
            }
        }
            //[[NT_HttpEngine sharedNT_HttpEngine] getMainNecessaryForPage:page pageSize:12 OnCompletionHandler:respones errorHandler:error];
            break;
            /*
        case AppListTypeTopClassical:
            [[NT_HttpEngine sharedNT_HttpEngine] getTopNecessaryForPage:page OnCompletionHandler:respones errorHandler:error];
            break;
             */
        case AppListTypeGameOnlineLastest:
            //[[NT_HttpEngine sharedNT_HttpEngine] getOnlineGameLastestForPage:page OnCompletionHandler:respones errorHandler:error];
            break;
        case AppListTypeGameOnlineHot:
        {
            if (isIpad) {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/net/hot_2_2_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/net/hot_2_1_%d.html",page];
            }
            else
            {
                urlString = [[UIDevice currentDevice] isJailbroken] ? [NSString stringWithFormat:@"mobile/v1/net/hot_1_1_%d.html",page] : [NSString stringWithFormat:@"mobile/v1/net/hot_1_1_%d.html",page];
            }

        }
            //[[NT_HttpEngine sharedNT_HttpEngine] getOnlineGameHotForPage:page OnCompletionHandler:respones errorHandler:error];
            break;
        default:
            break;
    }
    
    urlString = [NSString stringWithFormat:@"%@%@",url,urlString];
    NSLog(@"urlstring:%@",urlString);
    if (urlString)
    {
        [DataService requestWithURL:urlString finishBlock:^(id result)
        {
            NSDictionary *dic = (NSDictionary *)result;
            _isLoading = NO;
            [self stopLoadingMore];
            [self hideLoading];
            [self getDataFinishedWithDic:dic forPage:page];
            [self doneLoadingTableViewData];
            
        } errorBlock:^(id result) {
            [self stopLoadingMore];
            _isLoading = NO;
            [self doneLoadingTableViewData];
            [self showLoadingMeg:@"网络异常" time:1];
        }];
    }
}
- (void)getDataFinishedWithDic:(NSDictionary *)dic forPage:(int)page
{
    if (!dic || ![dic isKindOfClass:[NSDictionary class]] || ![dic[@"status"] boolValue]) {
        [self showLoadingMeg:@"加载出错" time:1];
        return;
    }
    NSArray *arr = dic[@"data"];
    _totalPageNum = [dic[@"page"] intValue];
    _pageNum = page;
    if (page <= 1) {
        [self resetLastUpdateDate];
        [self.dataArray removeAllObjects];
        self.tableView.contentOffset = CGPointZero;
    }
    for (int i = 0; i < arr.count; i++) {
        //by thilong
        if ([(NSDictionary *)arr[i] count])
        {
             [self.dataArray addObject:[NT_AppDetailInfo inforFromDetailDic:arr[i]]];
        }
    }
    [self.tableView reloadData];
}

- (int)rowNum
{
    return [self.dataArray count];
}

#pragma mark -- 
#pragma mark -- NT_AdViewDelegate Method
- (void)toDetailViewControllerDelegate:(UIViewController *)viewController
{
    [self.delegate pushNextViewController:viewController];
}
#pragma -mark tableView dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.dataArray.count) {
        return 0;
    }
    return [self rowNum] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.selectedIndex >= 0 &&(self.selectedIndex == section)) {
        return 2;
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == [self rowNum]) {
        return 40;
    }
    if (indexPath.row == 0 ) {
        //return 165;
        return 71;
    }
    
    NT_AppDetailInfo *info = self.dataArray[self.selectedIndex];
    return [NT_MainSecondCell heightForAppsInfoDetail:info];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == [self rowNum]) {
        static NSString *LastCell = @"LastCell";
        NT_LoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LastCell];
        if (!cell) {
            cell = [[NT_LoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LastCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (_pageNum >= _totalPageNum) {
            [cell endLoading];
            cell.label.text = @"已加载全部内容";
        }
        else
        {
            [cell startLoading];
            //            cell.label.text = @"上拉加载更多...";
        }
        return cell;
    }
    
    if (indexPath.row == 0) {
        static NSString *NT = @"NT";
        NT_MainCell *cell = [tableView dequeueReusableCellWithIdentifier:NT];
        if (!cell) {
            cell = [[NT_MainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NT];
            cell.delegates = self;
            cell.selectedBackgroundView = [[UIView alloc] init];
            cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHex:@"#f2f2f2"];
        }
         [cell formatWithDataArray:self.dataArray indexPath:indexPath selectedIndex:self.selectedIndex];
        return cell;
    }
    else
    {
        NT_MainSecondCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SecondCell"];
        if (!cell) {
            cell = [[NT_MainSecondCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SecondCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegates = self;
        }
        [cell formatWithAppsInfoDetail:self.dataArray[self.selectedIndex]];
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     if (indexPath.section != [self rowNum])
     {
         [tableView deselectRowAtIndexPath:indexPath animated:YES];
         NT_AppDetailViewController *appDetailController = [[NT_AppDetailViewController alloc] init];
         //热门、必备、网游、无限金币等进入详情tag
         appDetailController.typeTag = self.tag;
         appDetailController.infosDetail = self.dataArray[indexPath.section];
         appDetailController.appID = [appDetailController.infosDetail.appId integerValue];
         //[appDetailController getData:appDetailController.appID];
         if (self.isOnlineGame) {
             appDetailController.isOnlineGame = YES;
         }
         appDetailController.hidesBottomBarWhenPushed = YES;
         
         if (self.delegate&&[self.delegate respondsToSelector:@selector(pushNextViewController:)])
         {
             [self.delegate pushNextViewController:appDetailController];
             appDetailController.hidesBottomBarWhenPushed = NO;
         }
     }
}

- (void)startLoadingMore
{
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:[self.dataArray count]];
    NT_LoadMoreCell *cell = (NT_LoadMoreCell *)[self.tableView cellForRowAtIndexPath:lastIndexPath];
    [cell startLoading];
}
- (void)stopLoadingMore
{
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:[self.dataArray count]];
    NT_LoadMoreCell *cell = (NT_LoadMoreCell *)[self.tableView cellForRowAtIndexPath:lastIndexPath];
    [cell endLoading];
}
- (void)getMore
{
    if (_pageNum >= _totalPageNum) {
        return;
    }
    if (_isLoading) {
        return;
    }
    if (_pageNum < 1) {
        return;
    }
    [self getDataForPage:_pageNum + 1];
}

#pragma mark NTTableViewCellDelegate
- (void)tableViewCell:(NT_MainCell *)tableViewCell didSelectSecondModel:(secondModel)model
{
    NT_AppDetailViewController *appDetailController = [[NT_AppDetailViewController alloc] init];
    //热门、必备、网游、无限金币等进入详情tag
    appDetailController.typeTag = self.tag;
    appDetailController.infosDetail = self.dataArray[tableViewCell.indexParh.section];
    appDetailController.appID = [appDetailController.infosDetail.appId integerValue];
    //[appDetailController getData:[appDetailController.infosDetail.appId integerValue]];
    if (self.isOnlineGame&&![[UIDevice currentDevice] isJailbroken]) {
        appDetailController.isOnlineGame = YES;
    }
    appDetailController.hidesBottomBarWhenPushed = YES;
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(pushNextViewController:)])
    {
        [self.delegate pushNextViewController:appDetailController];
        appDetailController.hidesBottomBarWhenPushed = NO;
    }

}
//点击下载按钮
- (BOOL)tableViewCell:(NT_MainCell *)tableViewCell shouldOpenSecondModel:(secondModel)model
{
    int newIndex = tableViewCell.indexParh.section;
    NT_AppDetailInfo *info = self.dataArray[newIndex];
    
    if (![NT_UpdateAppInfo versionCompare:info.minVersion and:[[UIDevice currentDevice] systemVersion]])
    {
        if (info.downloadArray.count <= 1)
        {
            if (!info.downloadArray.count) {
                [self showLoadingMeg:@"获取下载链接失败" time:1];
            }
            else
            {
                NT_DownloadAddInfo *downloadInfo = info.downloadArray[0];
                NT_DownloadModel *downModel = [[NT_DownloadModel alloc] initWithAddress:downloadInfo.download_addr andGameName:info.game_name andRoundPic:info.round_pic andVersion:info.app_version_name andAppID:info.appId];
                downModel.package = info.package;
                _selectedModel = downModel;
                
                if (self.isOnlineGame) {
                    [self onlineDownLoadDialog:info];
                }else
                {
                    [self downloadWithMode:downModel indexPath:[NSIndexPath indexPathForRow:0 inSection:(newIndex)] index:model];
                    
                }
            }
            return NO;
        }
        
        //收起弹出框
        if (self.selectedIndex == newIndex) {
            self.selectedIndex = -1;
            //reloadSections必须使用beginUpdates和endUpdates方法
            [self.tableView beginUpdates];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndex] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            return NO;
        }
        
        //弹出框
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:newIndex];
        if (self.selectedIndex >= 0) {
            [indexSet addIndex:self.selectedIndex];
        }
        self.selectedIndex = newIndex;
        
        //reloadSections必须使用beginUpdates和endUpdates方法
        [self.tableView beginUpdates];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
        
        CGRect rect = [self.tableView rectForSection:self.selectedIndex];
        [self.tableView scrollRectToVisible:rect animated:YES];
        return YES;

    }
    else
    {
        //CGFloat bottomY = [[NSUserDefaults standardUserDefaults] floatForKey:KBottomInfo];
        CGFloat bottomY = self.bottomRedHeight;
        UILabel *_jreLabel = nil;
        if (bottomY)
        {
            //最低版本兼容信息
            //self.height-(64+13)
            _jreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, bottomY, SCREEN_WIDTH, 21)];
        }
        else
        {
            //分类底部红色高度
             _jreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height-(49), SCREEN_WIDTH, 21)];
        }
        _jreLabel.backgroundColor = [UIColor redColor];
        _jreLabel.textAlignment = TEXT_ALIGN_CENTER;
        _jreLabel.textColor = [UIColor whiteColor];
        _jreLabel.font = [UIFont  boldSystemFontOfSize:12];
        _jreLabel.text = [NSString stringWithFormat:@"您的系统版本为%@，需要%@以上版本",[[UIDevice currentDevice] systemVersion],info.minVersion];
        [self addSubview:_jreLabel];
        
        [self perform:^{
            [_jreLabel removeFromSuperview];
        } afterDelay:3];

    }
    return NO;
}

//无限金币弹框下载（分为无限金币或正版或越狱）
#pragma mark InstallSecondCellDelegate
- (void)installSecondCell:(NT_MainSecondCell *)installSecondCell installIndex:(int)index
{
    if (index == 10) {
        int tmp = self.selectedIndex;
        self.selectedIndex = -1;
        //reloadSections必须使用beginUpdates和endUpdates方法
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:tmp] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        return;
    }
    //下载
    NT_DownloadAddInfo *downloadInfo = installSecondCell.appsInfoDetail.downloadArray[index];
    
    NT_AppDetailInfo *modelInfo = self.dataArray[self.selectedIndex];
    NT_DownloadModel *model = [[NT_DownloadModel alloc] initWithAddress:downloadInfo.download_addr andGameName:[NSString stringWithFormat:@"%@%@",modelInfo.game_name,downloadInfo.version_name] andRoundPic:modelInfo.round_pic andVersion:modelInfo.app_version_name  andAppID:modelInfo.appId];
    model.package = modelInfo.package;
    _selectedModel = model;
    if (self.isOnlineGame)
    {
        NSRange rang = [model.gameName rangeOfString:@"无限金币"];
        if (rang.location != NSNotFound)
        {
            //若是无限金币的网游，直接下载，不用弹框
            [self downloadWithMode:model indexPath:[NSIndexPath indexPathForRow:0 inSection:(self.selectedIndex)] index:self.selectedIndex+1];
        }
        else
        {
            //正版或越狱的网游，就需要弹框
            [self onlineDownLoadDialog:installSecondCell.appsInfoDetail];
        }
        
    }else{
        
        [self downloadWithMode:model indexPath:[NSIndexPath indexPathForRow:0 inSection:(self.selectedIndex)] index:self.selectedIndex+1];
    }
    
}

//网游弹出框
- (void)onlineDownLoadDialog:(NT_AppDetailInfo *)info
{
    UIWindow *window = [NTAppDelegate shareNTAppDelegate].window;
    NT_OnlineGameDialog *online = [[NT_OnlineGameDialog alloc] initWithFrame:window.bounds appsInfo:info];
    [online.ntDownBtn addTarget:self action:@selector(ntDownBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [online.appStoreDownBtn addTarget:self action:@selector(appStoreDownBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _appsDetail = info;
    [window addSubview:online];
}

// 奶糖账号下载按钮点击
- (void)ntDownBtnClick:(UIButton *)btn
{
    if(_selectedModel != nil)
    {
        [self downloadWithMode:_selectedModel indexPath:[NSIndexPath indexPathForRow:0 inSection:(self.selectedIndex)] index:self.selectedIndex+1];
        /*
        BOOL isDownLoad = [[NT_DownloadManager sharedNT_DownLoadManager] downLoadWithModel:_selectedModel];
        
        if (isDownLoad)
        {
            //网游，使用奶糖账号下载，底部tabbar需要下载数量
            NSString *downloadCountString = [[NSUserDefaults standardUserDefaults] objectForKey:KDownloadCount];
            if (downloadCountString)
            {
                UITabBarController *tabController = [NTAppDelegate shareNTAppDelegate].tabController;
                [[tabController.tabBar.items objectAtIndex:4] setBadgeValue:downloadCountString];
                
            }
        }
         */
    }
}

//  打开appstore按钮点击
- (void)appStoreDownBtnClick:(UIButton *)btn
{
    [self.delegate presentToItunes:_appsDetail.apple_id itunesButton:btn];
    /*
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        [self openAppWithIdentifier:_appsDetail.apple_id];
    }else
    {
        [self outerOpenAppWithIdentifier:_appsDetail.apple_id goAppStore:btn];
    }
     */
}

//itunes下载
- (void)openAppWithIdentifier:(NSString *)appId {
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
    storeProductVC.delegate = self;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:appId forKey:SKStoreProductParameterITunesItemIdentifier];
    [self showLoadingMeg:@"加载中.."];
    [self setLoadingUserInterfaceEnable:YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenLoading:)];
    [self addGestureRecognizer:tapGesture];
    [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
        if (tapGesture) {
            [self removeGestureRecognizer:tapGesture];
        }
        [self hideLoading];
        if (result) {
            [self.delegate presentNextViewController:storeProductVC];
            //[[NTAppDelegate shareNTAppDelegate].mainController.navigationController presentViewController:storeProductVC animated:YES completion:nil];
        }
    }];
    //    NSString *str = [NSString stringWithFormat:@"http://itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@",appId];
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8",appId]]];
}

- (void)hiddenLoading:(UITapGestureRecognizer *)tap
{
    if (tap) {
        [self removeGestureRecognizer:tap];
    }
    [self hideLoading];
}

// ios6 以下设备
- (void)outerOpenAppWithIdentifier:(NSString *)appId  goAppStore:(UIButton*)btn{
    NSString *urlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8", appId];
    NSURL *url = [NSURL URLWithString:urlStr];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [btn.superview setHidden:YES];
        [btn.superview removeFromSuperview];
        [[UIApplication sharedApplication] openURL:url];
        
    }
    
    
}

#pragma mark SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:^{
        if (isIOS7) {
            viewController.navigationController.view.top = 20;
            viewController.view.height = [NTAppDelegate shareNTAppDelegate].window.height - 20;
            /*
            [NTAppDelegate shareNTAppDelegate].mainController.navigationController.view.top = 20;
            [NTAppDelegate shareNTAppDelegate].mainController.navigationController.view.height = [NTAppDelegate shareNTAppDelegate].window.height - 20;
             */
        }
    }];
}

//下载
- (BOOL)addDownloadWithInfo:(NT_DownloadAddInfo *)downloadInfo appsInfoDetail:(NT_AppDetailInfo *)modelInfo
{
    NT_DownloadModel *model = [[NT_DownloadModel alloc] initWithAddress:downloadInfo.download_addr andGameName:modelInfo.game_name andRoundPic:modelInfo.round_pic andVersion:modelInfo.app_version_name andAppID:modelInfo.appId];
    model.package = modelInfo.package;
    // YES 可以下载，并且开始下载   NO 下载地址无效或者已经下载过了
    BOOL isDownLoad = [[NT_DownloadManager sharedNT_DownLoadManager] downLoadWithModel:model];
    return isDownLoad;
}

//下载动画
- (void)downloadWithMode:(NT_DownloadModel *)model indexPath:(NSIndexPath *)indexPath index:(int)index
{
    //网络连接状态
    NSString *netConnection = [[NT_HttpEngine sharedNT_HttpEngine] getCurrentNet];
    
    //若设置里打开只在wifi下下载游戏，即在3G状态就不下载
    if ([NT_SettingManager onlyDownloadUseWifi] && [netConnection isEqualToString:NETWORKVIA3G])
    {
        showAlert(@"当前是2G/3G网络，您开启了只在Wifi下下载游戏功能");
    }
    else
    {
        index = 1;
        NT_MainCell *cell = (NT_MainCell *)[_tableView cellForRowAtIndexPath:indexPath];
        
        NT_BaseView *imageView = (NT_BaseView *)[cell.contentView viewWithTag:index];
        [imageView.button setTitle:@"下载中" forState:UIControlStateNormal];
        [imageView.button setBackgroundImage:[UIImage imageNamed:@"btn-green-download-hover.png"] forState:UIControlStateNormal];
        CGRect convertRect = [cell convertRect:imageView.appIcon.frame toView:self];
        convertRect.origin.x += (index-1)*SCREEN_WIDTH;
        EGOImageView *iconImgView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"default-icon.png"]];
        //若有缓存，使用缓存
        [iconImgView imageUrl:[NSURL URLWithString:model.iconName] tempSTR:@"false"];
        /*
        NT_WifiBrowseImage *wifiImage = [[NT_WifiBrowseImage alloc] init];
        [wifiImage wifiBrowseImage:iconImgView urlString:model.iconName];
         */
        //[iconImgView setImageWithURL:[NSURL URLWithString:model.iconName]];
        iconImgView.frame = convertRect;
        iconImgView.clipsToBounds = YES;
        iconImgView.layer.cornerRadius = 15;
        iconImgView.layer.borderWidth = 1;
        [self addSubview:iconImgView];
        [UIView animateWithDuration:0.7 animations:^{
            //iconImgView.center = CGPointMake(4*SCREEN_WIDTH/5.0, SCREEN_HEIGHT-49);
            iconImgView.center = CGPointMake(SCREEN_WIDTH+100, SCREEN_HEIGHT-49);
            iconImgView.bounds = CGRectMake(0, 0, 0, 0);
        }];
        
        [self perform:^{
            [imageView.button setTitle:@"免费下载" forState:UIControlStateNormal];
            [imageView.button setBackgroundImage:[UIImage imageNamed:@"btn-green-download.png"] forState:UIControlStateNormal];
            [imageView.button setBackgroundImage:[UIImage imageNamed:@"btn-green-download-hover.png"] forState:UIControlStateHighlighted];
        } afterDelay:5];
        
        // YES 可以下载，并且开始下载   NO 下载地址无效或者已经下载过了
        BOOL flag = [[NT_DownloadManager sharedNT_DownLoadManager] downLoadWithModel:model];
        if (flag)
        {
            NSString *downloadCountString = [[NSUserDefaults standardUserDefaults] objectForKey:KDownloadCount];
            if (downloadCountString)
            {
                UITabBarController *tabController = [NTAppDelegate shareNTAppDelegate].tabController;
                [[tabController.tabBar.items objectAtIndex:4] setBadgeValue:downloadCountString];
                
            }
        }

    }

}

-(void)reloadTableViewDataSource
{
    _isRefreshing = YES;
    [self getDataForPage:1];
}
-(void)doneLoadingTableViewData
{
    _isRefreshing = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
}
#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //刷新
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    CGPoint origin = scrollView.contentOffset;
    
    if (scrollView.contentSize.height > scrollView.frame.size.height && scrollView.contentSize.height - origin.y <= self.height+40) {
        [self getMore];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    if (scrollView.contentSize.height <= scrollView.height) {
        return;
    }
    //    CGPoint origin = scrollView.bounds.origin;
    //    NSLog(@"22222:%f,%f,%f",scrollView.contentSize.height,origin.y,self.height);
    //    if (scrollView.contentSize.height - origin.y <= self.height - 60) {
    //        [self getMore];
    //    }
}

- (void)resetLastUpdateDate
{
    [USERDEFAULT setObject:[NSDate date] forKey:[self currentLastDateKey]];
    [USERDEFAULT synchronize];
}
- (NSString *)currentLastDateKey
{
    NSString *userdefaultKey = [NSString stringWithFormat:@"BaseAppTableView-%d",self.type];
    return userdefaultKey;
}
#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _isLoading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    
    NSDate *date = [USERDEFAULT objectForKey:[self currentLastDateKey]];
    if (![date isKindOfClass:[NSDate class]]) {
        date = nil;
    }
    if (!date) {
        return [[NSDate date] dateafterMonth:1];
    }
	return [NSDate date];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationShouldHideInstallCell object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationWillEnterForeground object:nil];
    self.tableView = nil;
    self.dataArray = nil;
    self.selectedIndex = 0;
    self.type = 0;
    self.isOnlineGame = false;
    self.delegate = nil;
    self.switchTableView = nil;
    self.bottomRedHeight = 0;
    
}

@end
