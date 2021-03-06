//
//  NT_MacroDefine.h
//  NaiTangApp
//
//  Created by 张正超 on 14-2-26.
//  Copyright (c) 2014年 张正超. All rights reserved.
//
//  宏定义

// Screen Size
#define SCREEN_WIDTH			CGRectGetWidth([[UIScreen mainScreen] bounds])
#define SCREEN_HEIGHT           CGRectGetHeight([[UIScreen mainScreen] bounds])
#define StatusHeight   20

//Device
#define isRetina            ([UIScreen mainScreen].scale > 1)

//是否iphone5的分辨率
#define isIphone5Screen     (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(320, 568)))
#define iPhone5             ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640,960), [[UIScreen mainScreen] currentMode].size) : NO)
#define isIOS7              ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define isIOS7_1              ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.1)
#define isIOS6              ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define isIOS5              ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)


#define isSimulator         (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)
#define isIphone            (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define isIpad              (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define heightWithoutTab    (ScreenHeight - kTabbarHeight)
#define ScreenHeight        (isIphone5Screen ? 568 : 480)
#define heightList          (ScreenHeight - 20 - kTabbarHeight - kNavigationTopBarHeight)
#define heightAdded         (isIphone5Screen ? 88 : 0)

//当前软件版本号
#define currentVersionString [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
//当前设备的版本号
#define currentDeviceVersion [[[UIDevice currentDevice] systemVersion] floatValue]

// 偏好设置简写
#define USERDEFAULT                         [NSUserDefaults standardUserDefaults]

// 加载图片
#define LOADBUNDLEIMAGE(PATH,TYPE)          [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PATH ofType:TYPE]]

// 设置ARBG
#define COLOR_WITH_ARGB(R,G,B,A)            [UIColor colorWithRed:R / 255.0 green:G / 255.0 blue:B / 255.0 alpha:A]
#define COLOR_WITH_RGB(R,G,B)               [UIColor colorWithRed:R / 255.0 green:G / 255.0 blue:B / 255.0 alpha:1]
#define COLOR_WITH_IMAGENAME(imageName)     [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]]
//黑色半透层
#define TRANSLUCENTCOLOR(A)           [UIColor colorWithRed:0.0f / 255.0 green:0.0f / 255.0 blue:0.0f / 255.0 alpha:A]

//所有文字颜色 标题文字颜色
//#define Text_Color [UIColor colorWithHex:@"#8c9599"]
//#define Text_Color_Title [UIColor colorWithHex:@"#677074"]
#define Text_Color_Title [UIColor colorWithHex:@"#666666"]
#define Text_Color [UIColor colorWithHex:@"#999999"]
#define Text_Color_Setting_Gray [UIColor colorWithHex:@"#666666"]
#define Text_Color_Setting_Light_Gray [UIColor colorWithHex:@"#999999"]


/*更多设置*/
//是否修复闪退
#define KISRepaired  @"isRepaired"
#define KShowUpdateTipsKey @"showUpdateTips"
#define KOnlyDownloadUseWifi @"onlyDownloadUseWifi"
#define KClearDataWhenQuitNT @"clearDataWhenQuitNT"

//主页，是否是第一次加载。若是第一次加载时，显示可更新游戏数量
#define KIsFirstShowUpdateCount  @"showUpdateCount"

//判断是否第一次加载下载中的图片，第二次就显示缓存图片
#define KIsFirstDownloadImage @"downloadImage"
#define KIsFirstFinishedImage @"finishedImage"
#define KIsFirstUpdateImage @"updateImage"

//获取游戏可更新数量  是否需要隐藏可更新数量
#define KUpdateCount  @"updateCount"
#define KIsHiddenUpdateCount @"hiddenCount"
//存储点击的更新按钮的数量  存储点击忽略按钮的数量
#define kClickUpdateCount @"clickUpdateCount"
#define kClickIgnoreCount @"clickIgnoreCount"

//获取搜索无结果Tag值
#define KSearchKeywordTag 2555
#define KSearchTipTag  2556
//搜索有结果得tag值
#define KSearchCount   13556
#define KSearchValue   13557

//隐藏无限金币弹出框
#define kNotificationShouldHideInstallCell @"kNotificationShouldHideInstallCell"
//进入前台刷新数据，这个需要在AppDelegate的applicationWillEnterForeground发送消息
#define kApplicationWillEnterForeground @"ApplicationWillEnterForeground"

//判断分类 搜索 是否首次加载，若首次加载无网络显示，则显示测试数据
#define KCategoryIsFirstLoad  @"categortyFirst"
#define KSearchIsFirstLoad  @"searchFirst"

//网络状态及默认图
#define KNetStatus  @"netStatus"
#define KPlaceHoldImgSrc @"placeHoldImgSrc"

//下载无网络底部红色提示 无内存底部红色提示
#define KNetworkTipStatus @"networkStatus"
#define KNoSpaceTipStatus @"noSpaceStatus"


// arr[0]
#if !defined(__IPHONE_6_0) || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
@interface NSArray (subscripts)
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
@end
@interface NSMutableArray (subscripts)
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
@end
// //dict[@"foo"]
@interface  NSDictionary (subscripts)
- (id)objectForKeyedSubscript:(id)key;
@end
@interface  NSMutableDictionary (subscripts)
- (void)setObject:(id)obj forKeyedSubscript:(id)key;
@end
#endif

//下载中
#define KDownloadCount  @"downloadCount"

//下载完成
#define KFinishedHeadCellTag 21
#define KFinishedVersionSizeTag  22
#define KFinishedDateTag  23
#define KFinishedInstallButtonTag 24

//更新
#define KUpdateInfoTag  31

//底部红色信息
#define KBottomInfo  @"bottomInfo"

//空闲空间
#define KFreeSpace  @"freeSpace"

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
#define kCGImageAlphaPremultipliedLast  (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast)
#else
#define kCGImageAlphaPremultipliedLast  kCGImageAlphaPremultipliedLast
#endif

//文本位置
#ifdef __IPHONE_6_0
# define TEXT_ALIGN_LEFT NSTextAlignmentLeft
# define TEXT_ALIGN_CENTER NSTextAlignmentCenter
# define TEXT_ALIGN_RIGHT  NSTextAlignmentRight
#else
# define TEXT_ALIGN_LEFT UITextAlignmentLeft
# define TEXT_ALIGN_CENTER UITextAlignmentCenter
# define TEXT_ALIGN_RIGHT  UITextAlignmentRight
#endif

//文件值截取
#ifdef __IPHONE_6_0
# define LINE_BREAK_WORD_WRAP NSLineBreakByWordWrapping
#else
# define LINE_BREAK_WORD_WRAP UILineBreakModeWordWrap
#endif




#pragma mark --Recommend

//首页-热门-展示量
int umengLogRecHotListShow;
//首页-热门-内容点击
int umengLogRecHotContClick;

//首页-越狱-无限金币-展示量
int umengLogRecNoLimitGoldListShow;
//首页-越狱-无限金币-内容点击
int umengLogRecNoLimitGoldContClick;

// 推荐-装机必备-展示量
int umengLogRecZjbbListShow;

// 推荐-装机必备-内容点击量
int umengLogRecZjbbContClick;

// 推荐-网络游戏-展示量
int umengLogRecWlyxListShow;

// 推荐-网络游戏-内容点击量
int umengLogRecWlyxContClick;

// 推荐-排行榜-展示量
int umengLogRecRankListShow;

// 推荐-排行榜-内容点击量
int umengLogRecRankContClick;

#pragma mark --Search

// 搜索-展示量
int umengLogSearchShow;

// 搜索-检索量
int umengLogSearchUse;

// 搜索-结果点击量
int umengLogSearchResultClick;

#pragma mark --FindGame

// 找游戏-展示量
int umengLogFindGameShow;

// 找游戏-全部分类-展示量
int umengLogFindGameAll_Show;

// 找游戏-全部分类-下载按钮点击
int umengLogFindGameAll_DownloadClick;

#pragma mark --Gift

// 礼包-展示量
int umengLogGiftListShow;

// 礼包-礼包详情-展示量
int umengLogGiftDetailShow;

// 礼包-礼包详情-领取
int umengLogGiftDetailGet;

// 礼包-礼包详情-领取成功
int umengLogGiftDetailGetSuccess;

//修复闪退成功次数
int umengLogRepairSuccessedCount;

//设置-修复闪退帮助有用按钮点击次数
int umengLogRepairedClick;

//设置-修复闪退帮助没用按钮点击次数
int umengLogNoRepairedClick;

