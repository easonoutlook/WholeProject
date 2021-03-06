//
//  NT_DownloadManager.m
//  NaiTangApp
//
//  Created by 张正超 on 14-3-3.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_DownloadManager.h"
#import "NT_Singleton.h"
#import "BaiduMobStat.h"
#import "NT_SettingManager.h"
#import "NT_NoLimitGoldDialog.h"
#import "NT_MacroDefine.h"
#import "NT_AlertDialog.h"
#import "NT_DownStatusWindow.h"
#import "NT_UpdateAppInfo.h"
#import "NT_HttpEngine.h"
#import "MobileInstallationInstallManager.h"
#import "NT_DownloadModel.h"
#import "NSString+Base64.h"
#import "NT_RepairViewController.h"

@implementation NT_DownloadManager
{
    BOOL flag;
}

+ (NT_DownloadManager *)sharedNT_DownLoadManager
{
    static NT_DownloadManager *sharedNT_DownLoadManager;
    if (!sharedNT_DownLoadManager) {
        sharedNT_DownLoadManager = [[NT_DownloadManager alloc] init];
    }
    return sharedNT_DownLoadManager;
}
- (id)init
{
    if(self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityisChanged:) name: kReachabilityChangedNotification object: nil];
        [self loadArchiver];
        flag = NO;
        if ([[UIDevice currentDevice] isJailbroken]) {
            self.isFirstDownLoad = NO;
            self.isFirstUnlimitGold = NO;
        }
        else{
            self.isFirstDownLoad = YES;
            self.isFirstUnlimitGold = YES;
        }
        self.installedListArray = [NSMutableArray arrayWithCapacity:10];
        if (self.downFinishedArray.count) {
            [self installSoftware:nil];
        }
        
        
        //[self performSelector:@selector(postDownloadStatus) withObject:nil afterDelay:1.0];
    }
    return self;
}

- (void)reachabilityisChanged:(NSNotification* )note
{
    [self.delegate checkNetConnection:self];
}

-(void) saveArchiver     //保存
{
    if (self.downLoadingArray && self.downLoadingArray.count>0) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.downLoadingArray];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"DownLoadManagerDownLoadingArray"];
    }else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DownLoadManagerDownLoadingArray"];
    }
    if (self.downFinishedArray && self.downFinishedArray.count>0) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.downFinishedArray];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"DownLoadManagerDownFinishedArray"];
    }else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DownLoadManagerDownFinishedArray"];
    }
    if (self.installFinishedArray && self.installFinishedArray.count>0) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.installFinishedArray];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"DownLoadManagerInstallFinishedArray"];
    }else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DownLoadManagerInstallFinishedArray"];
    }
    if (self.updateListArray && self.updateListArray.count > 0)
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.updateListArray];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"DownLoadManagerUpdateArray"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DownLoadManagerUpdateArray"];
    }
    if (self.updateIgnoreArray && self.updateIgnoreArray.count > 0)
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.updateIgnoreArray];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"DownLoadManagerUpdateIgnoreArray"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DownLoadManagerUpdateIgnoreArray"];
    }
    
    [USERDEFAULT synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDownloadNumChanged object:nil];
}

-(void) loadArchiver      //加载
{
    if ([[NSUserDefaults standardUserDefaults] dataForKey:@"DownLoadManagerDownLoadingArray"] != nil) {
        self.downLoadingArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"DownLoadManagerDownLoadingArray"]]];
        for (NT_DownloadModel *model in self.downLoadingArray) {
            if (model.loadType != FINISHED) {
                if(model.loadType!=ISMUCHMONEYFIELD)
                {
                    [self startDownLoadWithModel:model indexPath:nil];
                }
            }
        }
        
    }
    else{
        self.downLoadingArray = [[NSMutableArray alloc] init];
    }
    
    if ([[NSUserDefaults standardUserDefaults] dataForKey:@"DownLoadManagerDownFinishedArray"] != nil) {
        self.downFinishedArray = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"DownLoadManagerDownFinishedArray"]];
    }
    else{
        self.downFinishedArray = [[NSMutableArray alloc] init];
    }
    if ([[NSUserDefaults standardUserDefaults] dataForKey:@"DownLoadManagerInstallFinishedArray"] != nil) {
        self.installFinishedArray = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"DownLoadManagerInstallFinishedArray"]];
    }
    else{
        self.installFinishedArray = [[NSMutableArray alloc] init];
    }
    
    //更新数量
    if ([[NSUserDefaults standardUserDefaults] dataForKey:@"DownLoadManagerUpdateArray"] != nil)
    {
        self.updateListArray = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"DownLoadManagerUpdateArray"]];
    }
    else
    {
        self.updateListArray = [[NSMutableArray alloc] init];
    }
    //忽略更新
    if ([[NSUserDefaults standardUserDefaults] dataForKey:@"DownLoadManagerUpdateIgnoreArray"] != nil)
    {
        self.updateIgnoreArray = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"DownLoadManagerUpdateIgnoreArray"]];
    }
    else
    {
        //静态使用alloc
        self.updateIgnoreArray = [[NSMutableArray alloc] init];
    }
    [self somethingRemoved];
}


- (NSString *)getFilePath
{
    NSString *documentsDirectory = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"UnlimitedGoldFile.txt"];
    NSLog(@"file path:%@",filePath);
    return filePath;
}

//by thilong. 添加之前判断应用是否已经在下载中
- (BOOL)isDownloadingModel:(NT_DownloadModel*)model{
    
    for(NT_DownloadModel * mod in self.downLoadingArray)
    {
        /*
         if([mod.gameName isEqualToString:model.gameName] && mod.appID == model.appID)
         {
         
         return YES;
         }
         */
        //by 张正超
        if ([mod.addressName isEqualToString:model.addressName])
        {
            return YES;
        }
    }
    return NO;
}

//by 张正超 添加之前先判断应用是否已经下载完成了但是未安装
- (BOOL)isDownloadingFinishedModel:(NT_DownloadModel *)model
{
    for (NT_DownloadModel *mod in self.downFinishedArray)
    {
        if ([mod.addressName isEqualToString:model.addressName])
        {
            return YES;
        }
    }
    return NO;
}

//by 张正超 添加之前先判断应用是否已经安装完成了
- (BOOL)isInstallFinishedModel:(NT_DownloadModel *)model
{
    for (NT_DownloadModel *mod in self.installFinishedArray)
    {
        if ([mod.addressName isEqualToString:model.addressName])
        {
            return YES;
        }
    }
    return NO;
    
}

- (void)installOrDownloadUpdate:(NT_DownloadModel *)model{
    BOOL downloaded = NO;
    
    for(int i = self.installFinishedArray.count-1;i>=0;i--){
        NT_DownloadModel * mod = self.installFinishedArray[i];
        if([mod.gameName isEqualToString:model.gameName] && mod.appID == model.appID)
        {
            [self.installFinishedArray removeObject:mod];
            break;
        }
    }
    
    for(NT_DownloadModel * mod in self.downFinishedArray){
        if([mod.gameName isEqualToString:model.gameName] && [mod.appID longLongValue] == [model.appID longLongValue])
            downloaded =  YES;
    }
    if(downloaded)
    {
        [self installUnJailBreakSoft:model];
    }
    else
    {
        [self downLoadWithModel:model];
    }
}

// 下载
- (BOOL)downLoadWithModel:(NT_DownloadModel *)model
{
    //百度统计点击下载时的数量
    //BaiduMobStat *statTracker = [BaiduMobStat defaultStat];
    //NSString *gameName=[NSString stringWithFormat:@"下载了'%@'",model.gameName];
    //[statTracker logEvent:@"xiazaicishu" eventLabel:gameName];
    
    NSString *repaired = [[NSUserDefaults standardUserDefaults] objectForKey:KISRepaired];
    if ([repaired isEqualToString:@"NO"])
    {
        //正版、越狱设备都要修复闪退
        if (isIpad&&self.isFirstDownLoad) {
            UIView *view = [NTAppDelegate shareNTAppDelegate].mainController.navigationController.view;
            NT_AlertDialog *alert = [[NT_AlertDialog alloc] initWithFrame:view.bounds];
            [view addSubview:alert];
            self.isFirstDownLoad = NO;
        }
        if (isIphone&&self.isFirstDownLoad) {
            /*
             UIWindow *window = [NTAppDelegate shareNTAppDelegate].window;
             NT_AlertDialog *alert = [[NT_AlertDialog alloc] initWithFrame:window.bounds];
             [window addSubview:alert];
             self.isFirstDownLoad = NO;
             */
            //这个只能是主页下载时，会跳转到提示修复闪退，若是其它页面过来的下载，不能跳转
            NTAppDelegate *appDelegate = (NTAppDelegate *)[[UIApplication sharedApplication] delegate];
            NT_RepairViewController *repairController = [[NT_RepairViewController alloc] init];
            repairController.hidesBottomBarWhenPushed = YES;
            
            [appDelegate.mainController.navigationController pushViewController:repairController animated:YES];
            self.isFirstDownLoad = NO;
            
        }
        
    }
    
    NSRange rang = [model.gameName rangeOfString:@"无限金币"];
    if (rang.location != NSNotFound)
    {
        if (![[UIDevice currentDevice] isJailbroken])
        {
            if (model.appID)
            {
                NSError *error;
                BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:[self getFilePath]];
                if (isExists) {
                    NSString *txtFile = [[NSString alloc] initWithContentsOfFile:[self getFilePath] encoding:NSUTF8StringEncoding error:&error];
                    txtFile = [txtFile stringByAppendingFormat:@"%@|",model.appID];
                    //读取文件后，将无限金币版appid写入文件，以|分割
                    [txtFile writeToFile:[self getFilePath] atomically:YES encoding:NSUTF8StringEncoding error:&error];
                }
                else
                {
                    //创建文件
                    NSString *appID = [NSString stringWithFormat:@"%@|",model.appID];
                    NSData *data = [appID dataUsingEncoding:NSUTF8StringEncoding];
                    [[NSFileManager defaultManager] createFileAtPath:[self getFilePath] contents:data attributes:nil];
                }
            }
            
            //if (isIphone&&self.isFirstUnlimitGold)
            if (isIphone && ![[UIDevice currentDevice] isJailbroken])
            {
                //若是无限金币版，就弹框提示
                //UIView *view = [NTAppDelegate shareNTAppDelegate].mainController.navigationController.view;
                UIWindow *window = [NTAppDelegate shareNTAppDelegate].window;
                NT_NoLimitGoldDialog *nolimitDialog = [[NT_NoLimitGoldDialog alloc] initWithFrame:window.bounds];
                [window addSubview:nolimitDialog];
                self.isFirstUnlimitGold = NO;
            }
        }
    }
    
    //by thilong. 添加之前判断应用是否已经在下载中
    if([self isDownloadingModel:model])
    {
        if (isIpad) {
            [[NTAppDelegate shareNTAppDelegate].mainController.navigationController.view showLoadingMeg:[NSString stringWithFormat:@"%@已经在下载中了",model.gameName] time:1];
        }else
        {
            [NT_DownStatusWindow showMessageIconStr:model.iconName leftText:model.gameName rightText:@"已经在下载中了"];
        }
        return NO;
    }
    
    //by 张正超 添加之前先判断应用是否已经下载完成了（未安装）
    if ([self isDownloadingFinishedModel:model])
    {
        if (isIpad) {
            [[NTAppDelegate shareNTAppDelegate].mainController.navigationController.view showLoadingMeg:[NSString stringWithFormat:@"%@已经下载完成了",model.gameName] time:1];
        }else
        {
            [NT_DownStatusWindow showMessageIconStr:model.iconName leftText:model.gameName rightText:@"已经下载完成了"];
        }
        return NO;
    }
    /*
     //by 张正超 添加之前先判断应用是否已经安装完成了
     if ([self isInstallFinishedModel:model])
     {
     if (isIpad) {
     [[NTAppDelegate shareNTAppDelegate].mainController.navigationController.view showLoadingMeg:[NSString stringWithFormat:@"%@已经安装完成了",model.gameName] time:1];
     }else
     {
     [NT_DownStatusWindow showMessageIconStr:model.iconName leftText:model.gameName rightText:@"已经安装完成了"];
     }
     return NO;
     }
     */
    if (model.addressName)
    {
        if ([model.addressName hasSuffix:@".plist"])
        {
            NSString *urlstr = model.addressName;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlstr]];
            return YES;
        }
        
        int sign = 0;
        for (NT_DownloadModel *submodel in self.downLoadingArray)
        {
            if ([submodel.addressName isEqualToString:model.addressName])
            {
                if (submodel.loadType == LOADING||submodel.loadType == WAITEDOWNLOAD) {
                    model = submodel;
                    sign = 1;
                    break;
                }
                else if (submodel.loadType == FINISHED&&![[UIDevice currentDevice] isJailbroken])
                {
                    // 下载完成未安装（只有非越狱的情况）越狱的下载完成直接安装
                    //未越狱的安装
                    //[self installUnJailBreakSoft:model.saveName];
                    model=submodel;
                    sign=7;
                    break;
                    
                }
                else if (submodel.loadType == PAUSE || submodel.loadType == WAITEDOWNLOAD)
                {
                    //下载暂停或等待下载时，开始下载任务
                    model = submodel;
                    sign = 2;
                    break;
                }
                else if (submodel.loadType==DOWNFAILED)
                {
                    //下载失败
                    model = submodel;
                    sign=3;
                    break;
                }
                NSRange rang = [model.gameName rangeOfString:@"无限金币"];
                if (rang.location != NSNotFound)
                {
                    //若是无限金币下载
                    sign=4;
                    model = submodel;
                    break;
                }
                
            }
        }
        if (sign==1)
        {
            if (isIpad) {
                [[NTAppDelegate shareNTAppDelegate].mainController.navigationController.view showLoadingMeg:[NSString stringWithFormat:@"%@已经在下载中了",model.gameName] time:1];
            }else
            {
                [NT_DownStatusWindow showMessageIconStr:model.iconName leftText:model.gameName rightText:@"已经在下载中了"];
            }
            model.buttonStatus = pauseOn;
        }
        else if (sign==7) {
            model.buttonStatus = installOn;
            [self installUnJailBreakSoft:model];
        }
        else if (sign==2)
        {
            if (isIpad) {
                [[NTAppDelegate shareNTAppDelegate].mainController.navigationController.view showLoadingMeg:[NSString stringWithFormat:@"%@开始下载",model.gameName] time:1];
            }else
            {
                [NT_DownStatusWindow showMessageIconStr:model.iconName leftText:model.gameName rightText:@"开始下载"];
            }
            
            model.loadType = LOADING;
            model.buttonStatus = pauseOn;
            [self saveArchiver];
            //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
            [self startDownLoadWithModel:model indexPath:nil];
        }
        else  if (sign==3)
        {
            if (isIpad) {
                [[NTAppDelegate shareNTAppDelegate].mainController.navigationController.view showLoadingMeg:[NSString stringWithFormat:@"%@重新开始",model.gameName] time:1];
            }else
            {
                [NT_DownStatusWindow showMessageIconStr:model.iconName leftText:model.gameName rightText:@"重新开始"];
            }
            model.loadType = LOADING;
            model.buttonStatus = pauseOn;
            [self startDownLoadWithModel:model indexPath:nil];
            //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
            
        }
        else  if (sign==4)
        {
            //无限金币下载
            if (![[UIDevice currentDevice] isJailbroken])
            {
                model.loadType = ISUNLITMTGOLD;
                model.buttonStatus = waiteOn;
                //[self.downLoadingArray addObject:model];
                //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
                [self saveArchiver];
            }
            else
            {
                model.loadType = LOADING;
                model.buttonStatus = pauseOn;
                //[self.downLoadingArray addObject:model];
                //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
                [self saveArchiver];
                [self startDownLoadWithModel:model indexPath:nil];
                
            }
        }
        
        /*
        if (sign == 0) {
            //已安装应用
            for (NT_DownloadModel *submodel in self.installFinishedArray)
            {
                if (submodel.loadType == INSTALLFINISHED&&![[UIDevice currentDevice] isJailbroken]) {
                    if ([submodel.addressName isEqualToString:model.addressName])
                    {
                        //若版本需要更新时，需要下载安装更新
                        NSString *installedVersion = submodel.version;
                        NSString *updateVersion = model.version;
                        if ([NT_UpdateAppInfo versionCompare:updateVersion and:installedVersion])
                        {
                            model = submodel;
                            sign=5;
                            break;
                        }
                        else
                        {
                            
                            sign = 6;
                            break;
                        }
                    }
                    
                }
            }
            if (sign==5) {
                //若版本需要更新时，需要下载安装更新
                //[self.pauseLoadingArray removeObject:model];
                model.loadType = LOADING;
                model.buttonStatus = pauseOn;
                [self.downLoadingArray addObject:model];
                //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
                [self.delegate refreshViewInDownLoadManager:self shouldReloadData:YES];
                [self saveArchiver];
                [self startDownLoadWithModel:model indexPath:nil];
            }
            if (sign==6) {
                model.buttonStatus = reInstallOn;
                if (isIpad) {
                    [[NTAppDelegate shareNTAppDelegate].mainController.navigationController.view showLoadingMeg:[NSString stringWithFormat:@"%@已经安装过了",model.gameName] time:1];
                }else
                {
                    [NT_DownStatusWindow showMessageIconStr:model.iconName leftText:model.gameName rightText:@"已经安装过了"];
                }
                
            }
        }
         */
        /*
         if (sign == 0) {
         // 判断是否在暂停中  然后重新开始
         for (NT_DownloadModel *submodel in self.pauseLoadingArray) {
         if ([submodel.addressName isEqualToString:model.addressName]) {
         model = submodel;
         sign = 1;
         break;
         }
         }
         if (sign) {
         //[self.pauseLoadingArray removeObject:model];
         model.loadType = LOADING;
         [self.downLoadingArray addObject:model];
         //by thilong [self.delegate refreshViewInDownLoadManager:self];
         [self saveArchiver];
         [self startDownLoadWithModel:model];
         }
         }
         
         if (sign == 0) {
         //判断是否在下载失败中
         for (NT_DownloadModel *submodel in self.downloadFiledArray) {
         if ([submodel.addressName isEqualToString:model.addressName]) {
         model = submodel;
         sign = 1;
         break;
         }
         }
         if (sign) {
         //下载失败的话   重新开始
         [self.downLoadingArray addObject:model];
         model.loadType = LOADING;
         [self.downloadFiledArray removeObject:model];
         [self startDownLoadWithModel:model];
         //by thilong [self.delegate refreshViewInDownLoadManager:self];
         
         }
         }*/
        //        NSFileManager *fm = [[NSFileManager alloc] init];
        //        if ([fm fileExistsAtPath:model.savePath]){
        //            sign = 1;
        //        }
        //        if (sign == 1) {
        //            showAlert(@"已经下载过了！");
        //            return NO;
        //        }else
        
        //无下载任务时开始下载
        if (sign == 0)
        {
            if ([model.addressName hasSuffix:@".ipa"])
            {
                NSRange rang = [model.gameName rangeOfString:@"无限金币"];
                if (rang.location != NSNotFound)
                {
                    //若是无限金币下载
                    if (![[UIDevice currentDevice] isJailbroken])
                    {
                        model.loadType = ISUNLITMTGOLD;
                        model.buttonStatus = waiteOn;
                        [self.downLoadingArray addObject:model];
                        //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
                        [self saveArchiver];
                    }
                    else
                    {
                        model.loadType = LOADING;
                        model.buttonStatus = pauseOn;
                        [self.downLoadingArray addObject:model];
                        //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
                        [self saveArchiver];
                        [self startDownLoadWithModel:model indexPath:nil];
                        
                    }
                    
                }
                else
                {
                    model.loadType = LOADING;
                    model.buttonStatus = pauseOn;
                    //非无限金币下载
                    [self.downLoadingArray addObject:model];
                    //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
                    [self saveArchiver];
                    [self startDownLoadWithModel:model indexPath:nil];
                }
                [self.delegate refreshViewInDownLoadManager:self shouldReloadData:YES];
                //计算下载数量
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",self.downLoadingArray.count] forKey:KDownloadCount];
                [[NSUserDefaults standardUserDefaults] synchronize];
                return YES;
            }
        }
        
    }else
    {
        [NT_StatusBarWindow showMessage:@"地址无效"];
        return NO;
    }
    return NO;
}

//断网时，直接暂停所有下载任务
- (BOOL)pauseAllDownLoadWithModel:(NT_DownloadModel *)model
{
    //停止每秒刷新表格
    //如何动态即时取消延时执行的方法，performSelector: withObject:afterDelay:   比如在异步处理时就会想要取消执行延时调用的方法。使用下面的方法即可实现。
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (model.operation != nil) {
        [model.operation cancel];
        model.operation = nil;
    }
    //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
    if (model.isUpdateModel) {
        [self.updateDelegate refreshUpdateView:self];
    }
    //[self startDownLoadWithModel:model];
    return  YES;
}

// 暂停下载时，开始下载
- (BOOL)pauseDownLoadWithModel:(NT_DownloadModel *)model indexPath:(NSIndexPath *)indexPath
{
    if (model.operation!=nil) {
        [model.operation cancel];
        model.operation = nil;
    }
    
    //停止每秒刷新表格
    //如何动态即时取消延时执行的方法，performSelector: withObject:afterDelay:   比如在异步处理时就会想要取消执行延时调用的方法。使用下面的方法即可实现。
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    model.loadType = PAUSE;
    model.buttonStatus = loadOn;
    //[self.pauseLoadingArray addObject:model];
    //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:indexPath];
    if (model.isUpdateModel) {
        [self.updateDelegate refreshUpdateView:self];
    }
    [self continueDownLoadModel];
    return YES;
}

//按照优先级继续下载
- (void)continueDownLoadModel
{
    int minPriority = INT32_MAX;
    int loadingCount = 0;
    for (NT_DownloadModel *downModel in self.downLoadingArray) {
        if (downModel.loadType == LOADING || downModel.loadType == DOWNFAILEDWITHUNCONNECT) {
            loadingCount++;
        }
        if (minPriority>downModel.priority && downModel.loadType==WAITEDOWNLOAD) {
            minPriority = downModel.priority;
        }
        if (loadingCount>KMAXLOADNUM)
        {
            break;
        }
    }
    if (loadingCount<KMAXLOADNUM&&minPriority!=INT32_MAX) {
        for (NT_DownloadModel *downModel in self.downLoadingArray) {
            if (downModel.loadType==WAITEDOWNLOAD&& downModel.priority== minPriority) {
                downModel.loadType = LOADING;
                downModel.buttonStatus = pauseOn;
                //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
                if (downModel.isUpdateModel) {
                    [self.updateDelegate refreshUpdateView:self];
                }
                [self startDownLoadWithModel:downModel indexPath:nil];
            }
        }
    }
}


// 优先下载
- (void)priorityDownLoad:(NT_DownloadModel *)model
{
    int minPriority = INT32_MAX;
    int loadingCount = 0;
    for (NT_DownloadModel *downModel in self.downLoadingArray) {
        if (downModel.loadType == LOADING) {
            loadingCount++;
        }
        if (minPriority>downModel.priority && downModel.loadType==WAITEDOWNLOAD) {
            minPriority = downModel.priority;
        }
    }
    if (loadingCount<KMAXLOADNUM) {
        model.loadType = LOADING;
        model.loadType = pauseOn;
        [self startDownLoadWithModel:model indexPath:nil];
    }
    else{
        //        if (minPriority!=INT32_MAX){
        //            for (NT_DownloadModel *downModel in self.downLoadingArray) {
        //                if (downModel.loadType == WAITEDOWNLOAD) {
        //                    downModel.priority++;
        //                    NSLog(@"downModel:%d",downModel.priority);
        //                }
        //            }
        loadingCount = 0;
        NT_DownloadModel *lastModel = nil;
        for (int i=0;i<self.downLoadingArray.count;i++) {
            NT_DownloadModel *downModel = self.downLoadingArray[i];
            if (downModel.loadType == LOADING) {
                loadingCount++;
            }
            if (loadingCount==KMAXLOADNUM) {
                lastModel = downModel;
                break;
            }
        }
        //[self.downLoadingArray removeObject:lastModel];
        lastModel.loadType = PAUSE;
        lastModel.buttonStatus = loadOn;
        [self pauseDownLoadWithModel:lastModel indexPath:nil];
        model.loadType = LOADING;
        model.buttonStatus = pauseOn;
        //            model.priority = minPriority;
        [self startDownLoadWithModel:model indexPath:nil];
        
        //            NSLog(@"model:%d",model.priority);
        //        }else
        //        {
        //            model.loadType = WAITEDOWNLOAD;
        //            model.priority = 1;
        //            //by thilong [self.delegate refreshViewInDownLoadManager:self];
        //            if (model.isUpdateModel) {
        //                [self.updateDelegate refreshUpdateView:self];
        //            }
        //        }
        //        if (minPriority!=INT32_MAX){
        //            for (NT_DownloadModel *downModel in self.downLoadingArray) {
        //                if (downModel.loadType == WAITEDOWNLOAD) {
        //                    downModel.priority++;
        //                    NSLog(@"downModel:%d",downModel.priority);
        //                }
        //            }
        //            model.loadType = WAITEDOWNLOAD;
        //            model.priority = minPriority;
        //            NSLog(@"model:%d",model.priority);
        //        }else
        //        {
        //            model.loadType = WAITEDOWNLOAD;
        //            model.priority = 1;
        //            //by thilong [self.delegate refreshViewInDownLoadManager:self];
        //            if (model.isUpdateModel) {
        //                [self.updateDelegate refreshUpdateView:self];
        //            }
        //        }
    }
    //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
    if (model.isUpdateModel) {
        [self.updateDelegate refreshUpdateView:self];
    }
}


// 判断直接下载或等待下载
- (BOOL)goOrWaiteDownLoad:(NT_DownloadModel *)model
{
    int loadingCount = 0;
    int maxPriority = 0;
    for (NT_DownloadModel *downModel in self.downLoadingArray) {
        if (downModel.loadType == LOADING || downModel.loadType == DOWNFAILEDWITHUNCONNECT) {
            ++loadingCount;
        }
        if (maxPriority < downModel.priority&&downModel.loadType==WAITEDOWNLOAD) {
            maxPriority = downModel.priority;
        }
        if (loadingCount > KMAXLOADNUM)
        {
            break;
        }
    }
    if (loadingCount > KMAXLOADNUM) {
        model.loadType = WAITEDOWNLOAD;
        model.buttonStatus = waiteOn;
        if (model.isUpdateModel) {
            [self.updateDelegate refreshUpdateView:self];
        }
        //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
        model.priority = maxPriority+1;
        
        //这里不能取消
        //因为若任务是等待的，取消每1秒刷新，那正在下载的俩个任务不会每秒刷新的
        //停止每秒刷新表格
        //如何动态即时取消延时执行的方法，performSelector: withObject:afterDelay:   比如在异步处理时就会想要取消执行延时调用的方法。使用下面的方法即可实现。
        //[NSObject cancelPreviousPerformRequestsWithTarget:self];

        return NO;
    }
    return YES;
}

// 开始下载
- (BOOL)startDownLoadWithModel:(NT_DownloadModel *)model indexPath:(NSIndexPath *)indexPath
{
    //by thilong. 自动重试
    if(!model.isAutoRetry){
        if (model.loadType != LOADING && model.loadType != DOWNFAILEDWITHUNCONNECT) {
            return NO;
        }
    }
    
    if (model.operation != nil) {
        [model.operation cancel];
        model.operation = nil;
    }
    model.isAutoRetry = false;
    
    //by 张正超 开始下载就刷新任务,1s刷一次
    if ([self respondsToSelector:@selector(postDownloadStatus)])
    {
        [self performSelector:@selector(postDownloadStatus) withObject:nil afterDelay:1.0];
    }
    
    if (![self goOrWaiteDownLoad:model]) {
        //        [StatusBarWindow showMessage:[NSString stringWithFormat:@"%@等待下载!",model.gameName]];
        if (isIpad) {
            [[NTAppDelegate shareNTAppDelegate].mainController.navigationController.view showLoadingMeg:[NSString stringWithFormat:@"%@等待下载",model.gameName] time:1];
        }else
        {
            [NT_DownStatusWindow showMessageIconStr:model.iconName leftText:model.gameName rightText:@"等待下载"];
        }
        return NO;
    }
    
    if (model.isUpdateModel)
    {
        [self.updateDelegate refreshUpdateView:self];
    }
    
    NSString *connect = [[NT_HttpEngine sharedNT_HttpEngine] getCurrentNet];
    if (![connect isEqualToString:NETNOTWORKING])
    {
        if (isIpad) {
            [[NTAppDelegate shareNTAppDelegate].mainController.navigationController.view showLoadingMeg:[NSString stringWithFormat:@"%@开始下载",model.gameName] time:1];
        }else
        {
            [NT_DownStatusWindow showMessageIconStr:model.iconName leftText:@"开始下载" rightText:[NSString stringWithFormat:@"本地剩余空间%@B",[self getFreeSpace]]];
            
            //存储剩余空间
            NSNumber *spaceSize = [self getSpaceSize];
            //NSLog(@"spaceSize:%@",spaceSize);
            [[NSUserDefaults standardUserDefaults] setObject:spaceSize forKey:@"spaceSize"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //刷新剩余空间委托
            [self.usedSpaceDelegate refreshUsedSpaceViewManager:self];
        }
        //    [StatusBarWindow showMessage:[NSString stringWithFormat:@"%@开始下载!",model.gameName]];
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    long long length = 0;
    if ([fm fileExistsAtPath:model.savePath])
    {
        NSData *data = [NSData dataWithContentsOfFile:model.savePath];
        length = [data length];
    }else
    {
        [fm createFileAtPath:model.savePath contents:nil attributes:nil];
        length =  0;
    }
    
    
    
    NSString *range = [NSString stringWithFormat:@"bytes=%lld-",length];
    __weak MKNetworkOperation *downloadOperation = [[NT_HttpEngine sharedNT_HttpEngine] operationWithURLString:model.addressName];
    [downloadOperation addHeader:@"Range" withValue:range];
    [downloadOperation addDownloadStream:[NSOutputStream outputStreamToFileAtPath:model.savePath append:YES]];
    if (([model.gameName rangeOfString:@"无限金币版"].location !=NSNotFound) && ![[UIDevice currentDevice] isJailbroken])
    {
        model.loadType = ISMUCHMONEYFIELD;
        model.buttonStatus = waiteOn;
    }
    else{
        [[NT_HttpEngine sharedNT_HttpEngine] enqueueOperation:downloadOperation];
        model.operation = downloadOperation;
    }
    
    __block float increment = 0;
    __block NSTimeInterval firstTime = 0;
    
    [downloadOperation onDownloadProgressChanged:^(double progress) {
        
        long long totalContentLength = downloadOperation.readonlyResponse.expectedContentLength;
        
        /*
         //by thilong.计算空间
         long long __fileSize = totalContentLength + length;
         
         uint64_t freeSpace = [self getFreeDiskspace];//[[NSUserDefaults standardUserDefaults] objectForKey:KFreeSpace];
         const uint64_t checkSize = 1024 *1024 * 2;
         if(freeSpace <= checkSize)
         {
         if (model != nil) {
         model.loadType = DOWNFAILED;
         model.buttonStatus = reloadOn;
         //model.errorCode = SPACE_NOT_ENOUGH_ERROR;
         }
         [downloadOperation cancel];
         [self.delegate shouldTipMemoryNotEnough];
         return;
         }
         */
        
        //by thilong.计算空间
        long long __fileSize = totalContentLength + length;
        
        __block bool ckechFailed = false;
        
        //10秒更新一次空间
        [self perform:^{

            uint64_t freeSpace = [self getFreeDiskspace];//[[NSUserDefaults standardUserDefaults] objectForKey:KFreeSpace];
            const uint64_t checkSize = 1024 *1024 * 2;
            if(freeSpace <= checkSize)
            {
                if (model != nil) {
                    model.loadType = DOWNFAILED;
                    model.buttonStatus = reloadOn;
                    //model.errorCode = SPACE_NOT_ENOUGH_ERROR;
                }
                [downloadOperation cancel];
                [self.delegate shouldTipMemoryNotEnough];
                ckechFailed = true;
                return;
            }

        } afterDelay:10];
        
        if(!ckechFailed){
        //下载计算逻辑更改
        //这个任务每1秒刷新过了，所以不用再委托下载表格刷新了
        model.fileSize = __fileSize;
        if (progress >= increment+0.01)
        {
            model.downSpeed = model.fileSize*(progress-increment)/([[NSDate date] timeIntervalSince1970]-firstTime);
            firstTime = [[NSDate date] timeIntervalSince1970];
            increment = progress;
            model.progress = progress;
            
            //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:indexPath];
            //            if (model.isUpdateModel) {
            //                [self.updateDelegate refreshUpdateView:self];
            //            }
            
            /*
             if (progress >= 1) {
             if (model != nil) {
             model.loadType = FINISHED;
             model.buttonStatus = installOn;
             }
             }
             */
            
            
        }}
    }];
    
    
    __block typeof(self) weak_self = self;
    //下载完成
    [downloadOperation addCompletionHandler:^(MKNetworkOperation *completedOperation)
     {
         //停止每秒刷新表格
         //如何动态即时取消延时执行的方法，performSelector: withObject:afterDelay:   比如在异步处理时就会想要取消执行延时调用的方法。使用下面的方法即可实现。
         [NSObject cancelPreviousPerformRequestsWithTarget:self];
         
         if (model != nil) {
             if (model.operation!=nil) {
                 [model.operation cancel];
                 model.operation = nil;
             }
             
             if (([model.gameName rangeOfString:@"无限金币版"].location !=NSNotFound))
             {
                 if (![[UIDevice currentDevice] isJailbroken]) {
                     model.loadType = ISMUCHMONEYFIELD;
                     model.buttonStatus = waiteOn;
                 }
             }else
             {
                 model.loadType = FINISHED;
                 model.buttonStatus = installOn;
                 
             }
             
             int sign = 0;
             //若已下载，就不添加到已下载列表
             for (NT_DownloadModel *submodel in self.downFinishedArray)
             {
                 if ([submodel.addressName isEqualToString:model.addressName])
                 {
                     sign = 1;
                     break;
                 }
             }
             if (sign==0 && model)
             {
                 //没有下载过，添加到已下载列表
                 [self.downFinishedArray addObject:model];
             }
             
             //新加
             //[self.downFinishedArray addObject:model];
             [self.downLoadingArray removeObject:model];
             
             //改变已用空间数据
             [self.usedSpaceDelegate refreshUsedSpaceViewManager:self];
             
             
             [self saveArchiver];
             [self continueDownLoadModel];
             //下载中-删除游戏列表
             //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
             [self.delegate refreshViewInDownLoadManager:self shouldReloadData:YES];
             //下载完成
             [self.finishedDelegate refreshFinishedManager:self];
             
             //by thilong
             [self somethingRemoved];
             
             //奶糖进入后台，发送本地通知
             if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                 [self addLocalNotification:model.gameName];
             }
             if (model.loadType == ISMUCHMONEYFIELD) {
                 return;
             }
             /*
              if (![[UIDevice currentDevice] isJailbroken]) {
              //将下载完成的游戏名称，保存为游戏名称.plist，通过itms-service企业账号发布的Web地址下载，安装时，直接打开plist的web地址即可安装。若安装成功，就将下载列表的“点击安装”删除
              [self saveAsPlist:model];
              ////by thilong [self.delegate refreshViewInDownLoadManager:self];
              if (model.isUpdateModel) {
              [self.updateDelegate refreshUpdateView:self];
              }
              }else{
              [self goInstallOrWaitInStall:model indexPath:indexPath];
              }
              */
             //by 张正超 越狱的安装使用正版的安装方式
             //将下载完成的游戏名称，保存为游戏名称.plist，通过itms-service企业账号发布的Web地址下载，安装时，直接打开plist的web地址即可安装。若安装成功，就将下载列表的“点击安装”删除
             [self saveAsPlist:model];
             ////by thilong [self.delegate refreshViewInDownLoadManager:self];
             if (model.isUpdateModel) {
                 [self.updateDelegate refreshUpdateView:self];
             }
         }
         
     } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
         NSLog(@"下载失败error %@",error);
         
         
         //停止每秒刷新表格
         //如何动态即时取消延时执行的方法，performSelector: withObject:afterDelay:   比如在异步处理时就会想要取消执行延时调用的方法。使用下面的方法即可实现。
         [NSObject cancelPreviousPerformRequestsWithTarget:self];

         
         NSString *netConnection = [[NT_HttpEngine sharedNT_HttpEngine] getCurrentNet];
         
         //网络未连接
         if ([netConnection isEqualToString:NETNOTWORKING])
         {
             if (model.operation!=nil) {
                 [model.operation cancel];
                 model.operation = nil;
             }
             
             //若下载失败，是网络未开启时，则暂停下载，保存下载进度
             model.loadType = DOWNFAILEDWITHUNCONNECT;
             model.buttonStatus = pauseOn;
             //记录失败编号
             model.errorCode = error.code;
             [self saveArchiver];
             //继续下载下一个任务
             [self continueDownLoadModel];
             //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:indexPath];
         }
         else
         {
             //by thilong.添加自动重试
             if(model.autoRetryTimes<4){
                 model.isAutoRetry = true;
                 model.autoRetryTimes++;
                 typeof(self) strong_self = weak_self;
                 if(strong_self)
                 {
                     [strong_self startDownLoadWithModel:model indexPath:indexPath];
                     return;
                 }
             }
             else{
                 model.autoRetryTimes=0;
             }
             
             
             if (error.code == -1001)
             {
                 //若请求超时-1001 (服务器无响应或wifi设置了代理)
                 if (model.operation!=nil) {
                     [model.operation cancel];
                     model.operation = nil;
                 }
                 model.loadType = LOADING;
                 model.buttonStatus = pauseOn;
                 //记录失败编号
                 model.errorCode = error.code;
                 [self saveArchiver];
                 
             }
             else
             {
                 if (model.operation!=nil) {
                     [model.operation cancel];
                     model.operation = nil;
                 }
                 model.loadType = DOWNFAILED;
                 model.buttonStatus = reloadOn;
                 //存储错误值
                 model.errorCode = error.code;
                 [self saveArchiver];
             }
             if (model.isUpdateModel) {
                 [self.updateDelegate refreshUpdateView:self];
             }
             //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:indexPath];
         }
     }];
    
    return YES;
}

//获取剩余空间大小
- (NSString *)getFreeSpace
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
    //    showAlert(path);
    NSFileManager* fileManager = [[NSFileManager alloc ]init];
    NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
    //    NSNumber *totalSpace = [fileSysAttributes objectForKey:NSFileSystemSize];
    //    NSString *text = [NSString stringWithFormat:@"已占用%0.1fG/剩余%0.1fG",([totalSpace longLongValue] - [freeSpace longLongValue])/1024.0/1024.0/1024.0,[freeSpace longLongValue]/1024.0/1024.0/1024.0];
    return [NSString stringWithFormat:@"%0.1fG",([freeSpace longLongValue])/1024.0/1024.0/1024.0];
}

//获取剩余空间大小
- (NSNumber *)getSpaceSize
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
    //    showAlert(path);
    NSFileManager* fileManager = [[NSFileManager alloc ]init];
    NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
    return freeSpace;
}

//by thilong
- (void)somethingRemoved{
    NSMutableArray *array = self.downLoadingArray;
    [[NTAppDelegate shareNTAppDelegate] setDownloadBadgeValue:array.count > 0 ?[NSString stringWithFormat:@"%d",[array count]] : nil ];
    //是否继续，在这里处理
    //[self continueDownLoadModel];
}

- (bool)anyDownloading{
    int loadingCount = 0;
    for (NT_DownloadModel *downModel in self.downLoadingArray) {
        if (downModel.loadType == LOADING || downModel.loadType == DOWNFAILEDWITHUNCONNECT) {
            loadingCount++;
        }
    }
    return loadingCount > 0;
}

- (void)postDownloadStatus{
    [self.delegate refreshViewInDownLoadManager:self shouldReloadData:NO];
    
    //每1秒刷新一次，因为不是用的定时器每1秒刷新
    [self performSelector:@selector(postDownloadStatus) withObject:nil afterDelay:1.0];
}

- (void)cancelDownloading:(NT_DownloadModel *)model
{
    if (model.operation != nil) {
        [model.operation cancel];
        model.operation = nil;
    }
}

- (void)shouldRescanInstallApps{
    for(int i= _downFinishedArray.count-1;i>=0;i--){
        NT_DownloadModel *model = _downFinishedArray[i];
        if([self InstalledApp:model]){
            int sign = 0;
            //若已安装过，就不添加到已安装列表
            for (NT_DownloadModel *submodel in self.installFinishedArray)
            {
                if ([submodel.addressName isEqualToString:model.addressName])
                {
                    sign = 1;
                    break;
                }
            }
            if (sign==0 && model)
            {
                //未安装过，添加到已安装列表
                [self.installFinishedArray addObject:model];
            }
            //by thilong.2014-04-10
            [_downFinishedArray removeObject:model];
        }
    }
    [self saveArchiver];
    [self.installDelegate refreshInstallView:self];
    [self.finishedDelegate refreshFinishedManager:self];
}

- (void)saveAsPlist:(NT_DownloadModel *)model
{
    //by thilong,none-jailbreak installation for ios 7 and above;
    /*
     if(isIOS7){
     const NSString *installInterface = @"https://a.com/";
     NSMutableArray *params = [[NSMutableArray alloc] init];
     //by thilong,to fix here
     }
     */
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *documentsDirectory = [paths objectAtIndex:0];
    //    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.plist",model.gameName]];
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    //    if (![fileManager fileExistsAtPath: path]){
    //        [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.plist",model.gameName]];
    //    }
    NSString *plistPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches/"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",model.saveName]];
    model.savePlistPath = plistPath;
    [self saveArchiver];
    NSLog(@"保存文件plist路径：%@",plistPath);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:plistPath]) {
        BOOL result = [fm createFileAtPath:plistPath contents:nil attributes:nil];
        NSLog(@"%d",result);
    }
    /*
     else
     {
     NSError *error = nil;
     if ([fm isDeletableFileAtPath:plistPath]){
     if (![fm removeItemAtPath:plistPath error:&error]) {
     NSLog(@"could not delete file: %@",error);
     }
     }
     [fm createFileAtPath:plistPath contents:nil attributes:nil];
     }
     */
    //NSDictionary *item1 = [NSDictionary dictionaryWithObjectsAndKeys:@"software-package",@"kind",[NSString stringWithFormat:@"file://localhost%@",model.savePath],@"url",nil];
    NSDictionary *item1 = [NSDictionary dictionaryWithObjectsAndKeys:@"software-package",@"kind",[NSString stringWithFormat:@"http://127.0.0.1:8999/%@.ipa",model.saveName],@"url",nil];
    NSDictionary *iconItem = [NSDictionary dictionaryWithObjectsAndKeys:@"display-image",@"kind",model.iconName,@"url",nil];
    
    NSArray *assets = [NSArray arrayWithObjects:item1,iconItem, nil];
    
    
    NSString *identifer = @"";
    if (model.package) {
        identifer = model.package;
    }
    else{
        //[StatusBarWindow showMessage:@"缺少包名，无法正常安装"];
    }
    NSDictionary *metadata = [NSDictionary dictionaryWithObjectsAndKeys:identifer,@"bundle-identifier",@"software",@"kind",model.gameName,@"title",model.version,@"bundle-version",nil];
    NSDictionary *item0 = [NSDictionary dictionaryWithObjectsAndKeys:assets,@"assets",metadata,@"metadata",nil];
    NSArray *items = [NSArray arrayWithObjects:item0, nil];
    NSDictionary *rootDic = [NSDictionary dictionaryWithObjectsAndKeys:items,@"items", nil];
    NSLog(@"!111:%@",rootDic);
    if ([rootDic writeToFile:plistPath atomically:YES]) {
        //[self installUnJailBreakSoft:model.saveName];
        [self installUnJailBreakSoft:model];
        //[self repeateInstalled:model];
    }
}

-(uint64_t)getFreeDiskspace {
    //uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        //NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        //totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    }
    return totalFreeSpace;
}


#pragma mark - InStall mothed
- (void)reStartDownLoadORDelModel:(NT_DownloadModel *)model indexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"下载应用管理" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除任务" otherButtonTitles:@"开始任务",@"优先下载",nil];
    [sheet showInView:[UIApplication sharedApplication].keyWindow withCompletionHandler:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            if (model.operation!=nil) {
                [model.operation cancel];
                model.operation = nil;
            }
            [self delFileWithPath:model.savePath];
            if ([self.downLoadingArray containsObject:model]) {
                [self.downLoadingArray removeObject:model];
                [self.delegate refreshViewInDownLoadManager:self shouldReloadData:YES];
            }
            //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
            [self saveArchiver];
            [self continueDownLoadModel];
        }else if(buttonIndex == 1)
        {
            model.loadType = LOADING;
            [self saveArchiver];
            //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:indexPath];
            [self startDownLoadWithModel:model indexPath:indexPath];
        }else if (buttonIndex == 2)
        {
            // 优先下载
            [self priorityDownLoad:model];
        }
    }];
}
#pragma mark - InStall mothed
- (void)goInstallOrWaitInStall:(NT_DownloadModel *)model indexPath:(NSIndexPath *)indexPath
{
    //    [self.downFinishedArray addObject:model];
    //    [self saveArchiver];
    if (self.downFinishedArray.count == 1) {
        [self installSoftware:indexPath];
    }else
    {
        //        [StatusBarWindow showMessage:[NSString stringWithFormat:@"%@等待安装!",model.gameName]];
        model.loadType = WAITEINSTALL;
        //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:indexPath];
        [self.finishedDelegate refreshFinishedManager:self];
        if (model.isUpdateModel) {
            [self.updateDelegate refreshUpdateView:self];
        }
    }
}

// 安装 待安装队列里的项目
- (void)installSoftware:(NSIndexPath *)indexPath
{
    while(self.downFinishedArray.count>0&&flag==NO){
        flag = YES;
        NT_DownloadModel *model = [self.downFinishedArray objectAtIndex:0];
        //by thilong.2014-04-10
        /*
         if([[UIDevice currentDevice] isJailbroken])
         [self installSoftwareWithModel:model indexPath:indexPath];
         else
         [self installUnJailBreakSoft:model];
         */
        [self installUnJailBreakSoft:model];
    }
}

//越狱版安装成功
- (void)installSoftwareWithModel:(NT_DownloadModel *)model indexPath:(NSIndexPath *)indexPath
{
    //    [StatusBarWindow showMessage:[NSString stringWithFormat:@"%@开始安装",model.gameName]];
    model.loadType = INSTALLING;
    model.buttonStatus = installingOn;
    [self saveArchiver];
    //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:indexPath];
    [self.installDelegate refreshInstallView:self];
    if (model.isUpdateModel) {
        [self.updateDelegate refreshUpdateView:self];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"savePath:%@",model.savePath);
        BOOL result = [MobileInstallationInstallManager InstallIPA:model.savePath MobileInstallionPath:@"/System/Library/PrivateFrameworks/MobileInstallation.framework/MobileInstallation"];
        dispatch_async(dispatch_get_main_queue(),^{
            if (result) {
                //                [StatusBarWindow showMessage:[NSString stringWithFormat:@"%@安装成功！",model.gameName]];
                if (isIpad) {
                    
                    [[NTAppDelegate shareNTAppDelegate].mainController.navigationController.view showLoadingMeg:[NSString stringWithFormat:@"%@安装成功",model.gameName] time:1];
                    
                }else
                {
                    [NT_DownStatusWindow showMessageIconStr:model.iconName leftText:model.gameName rightText:@"安装成功"];
                }
                model.loadType = INSTALLFINISHED;
                model.loadType = reInstallOn;
                if (model.isUpdateModel) {
                    [self.updateDelegate refreshUpdateView:self];
                }
                if (model.savePlistPath)
                {
                    [self delFileWithPath:model.savePlistPath];
                }
                [self delFileWithPath:model.savePath];
                
                int sign = 0;
                if (self.installFinishedArray.count>0)
                {
                    //若已安装过，就不添加到已安装列表
                    for (NT_DownloadModel *submodel in self.installFinishedArray)
                    {
                        if ([submodel.addressName isEqualToString:model.addressName])
                        {
                            sign = 1;
                            break;
                        }
                    }
                    if (sign==0)
                    {
                        //未安装过，添加到已安装列表
                        [self.installFinishedArray addObject:model];
                    }
                    
                }
                else
                {
                    [self.installFinishedArray addObject:model];
                }
                [self.downLoadingArray removeObject:model];
                [self.downFinishedArray removeObject:model];
                
            }
            else
            {
                //showAlert(@"安装出错");
                model.loadType = INSTALLFAILED;
                model.buttonStatus = reInstallOn;
                if (model.isUpdateModel) {
                    [self.updateDelegate refreshUpdateView:self];
                }
                [self.downFinishedArray removeObject:model];
                
            }
            flag = NO;
            [self saveArchiver];
            ////by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:indexPath];
            if (self.downFinishedArray.count>0) {
                [self installSoftware:indexPath];
            }
            //刷新已安装列表
            [self.installDelegate refreshInstallView:self];
        });
    });
}


/*
 //查看正版设备安装成功任务
 - (void)installedUnJailBreak:(NT_DownloadModel *)model
 {
 NSString *installid = model.package;
 if (installid) {
 NSString *appName = [MobileInstallationInstallManager appLocalizedName:model.package];
 if (appName) {
 [self.installFinishedArray addObject:model];
 }
 
 }
 }
 */

//重新安装或删除任务
- (void)reStartInstallOrDelModel:(NT_DownloadModel *)model indexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"下载应用管理" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"重新安装" otherButtonTitles:@"删除任务",nil];
    
    [sheet showInView:[UIApplication sharedApplication].keyWindow withCompletionHandler:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [self goInstallOrWaitInStall:model indexPath:indexPath];
        }else if(buttonIndex == 1)
        {
            if (model.operation!=nil) {
                [model.operation cancel];
                model.operation = nil;
            }
            [self delDownLoadAndContinueWithModel:model indexPath:nil];
            
        }
    }];
}

- (void)tapOut:(UITapGestureRecognizer *)tap
{
    UITapGestureRecognizer *tapG= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOut:)];
    [[UIApplication sharedApplication].keyWindow addGestureRecognizer:tapG];
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0) {
            
            // BOOL alert = [[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]];
            //BOOL action = [[subviews objectAtIndex:0] isKindOfClass:[UIActionSheet class]];
            
            if ([[subviews objectAtIndex:0] isKindOfClass:[UIActionSheet class]]) {
                UIActionSheet *actionSheet = (UIActionSheet *)subviews;
                [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
            }
        }
    }
}

//停止任务或删除任务
- (void)delOrPauseDownLoadWithModel:(NT_DownloadModel *)model indexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"下载应用管理" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除任务" otherButtonTitles:@"暂停任务",nil];
    [sheet showInView:[UIApplication sharedApplication].keyWindow withCompletionHandler:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            if (model.operation!=nil) {
                [model.operation cancel];
                model.operation = nil;
            }
            [self delDownLoadAndContinueWithModel:model indexPath:nil];
        }else if (buttonIndex == 1)
        {
            model.loadType = PAUSE;
            [self pauseDownLoadWithModel:model indexPath:indexPath];
            //[self.downLoadingArray removeObject:model];
            //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:indexPath];
            [self saveArchiver];
        }
    }];
}


//删除下载任务
- (void)delDownLoadWithModel:(NT_DownloadModel *)model indexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"下载应用管理" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除任务" otherButtonTitles:nil];
    [sheet showInView:[UIApplication sharedApplication].keyWindow withCompletionHandler:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            if (model.operation!=nil) {
                [model.operation cancel];
                model.operation = nil;
            }
            [self delFileWithPath:model.savePath];
            if ([self.downLoadingArray containsObject:model]) {
                [self.downLoadingArray removeObject:model];
            }
            if ([self.downFinishedArray containsObject:model]) {
                [self.downFinishedArray removeObject:model];
            }
            if ([self.installFinishedArray containsObject:model]) {
                [self.installFinishedArray removeObject:model];
            }
            //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:indexPath];
            [self.delegate refreshViewInDownLoadManager:self shouldReloadData:YES];
            [self saveArchiver];
            [self continueDownLoadModel];
        }
    }];
}

// 删除安装记录
- (void)delInstalleFinishedCellWithModel:(NT_DownloadModel *)model
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"下载应用管理" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除任务" otherButtonTitles:nil];
    [sheet showInView:[UIApplication sharedApplication].keyWindow withCompletionHandler:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [self.installFinishedArray removeObject:model];
            //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
            [self saveArchiver];
            [self continueDownLoadModel];
        }
    }];
}
// 未越狱安装或删除应用
- (void)installOrDelSoftWithModel:(NT_DownloadModel *)model indexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"下载应用管理" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"安装应用" otherButtonTitles:@"删除任务",nil];
    
    [sheet showInView:[UIApplication sharedApplication].keyWindow withCompletionHandler:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            NSLog(@"安装应用");
            
            /*
             if (![[UIDevice currentDevice] isJailbroken]) {
             //将下载完成的游戏名称，保存为游戏名称.plist，通过itms-service企业账号发布的Web地址下载，安装时，直接打开plist的web地址即可安装。若安装成功，就将下载列表的“点击安装”删除
             [self saveAsPlist:model];
             }else{
             [self goInstallOrWaitInStall:model indexPath:indexPath];
             }
             */
            
            //by 张正超 越狱和正版一样的安装方式
            //将下载完成的游戏名称，保存为游戏名称.plist，通过itms-service企业账号发布的Web地址下载，安装时，直接打开plist的web地址即可安装。若安装成功，就将下载列表的“点击安装”删除
            [self saveAsPlist:model];
            
            //[self installUnJailBreakSoft:model.saveName];
            //正版设备是否已经安装过该应用
            //[self installUnJailBreakSoft:model];
            
        }else if (buttonIndex == 1)
        {
            if (model.operation!=nil) {
                [model.operation cancel];
                model.operation = nil;
            }
            if ([self.downLoadingArray containsObject:model]) {
                [self.downLoadingArray removeObject:model];
            }
            if ([self.downFinishedArray containsObject:model]) {
                [self.downFinishedArray removeObject:model];
            }
            //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
            [self.delegate refreshViewInDownLoadManager:self shouldReloadData:YES];
            [self saveArchiver];
            [self delFileWithPath:model.savePath];
            [self delFileWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches/"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",model.saveName]]];
        }
    }];
    
}

- (void)repeateInstalled:(NT_DownloadModel *)model
{
    if(![NTAppDelegate shareNTAppDelegate].installProxyStarted)
    {
        [[NTAppDelegate shareNTAppDelegate] beginHttpServer];
    }
    
    if (model.package)
    {
        //by thilong,none-jailbreak installation for ios 7 and above;
        if(isIOS7)
        {
            /*
             NSString *saveDir = [model.savePath stringByDeletingLastPathComponent];
             NSLog(@"保存位置 savedir:%@",saveDir);
             NSString *baseDir = [NSString stringWithFormat:@"file://localhost%@",saveDir];
             */
            //端口号四个9都可以。只要不要超过65535就是了。不要用80和21
            //要和appdelegate里面启动时的端口一样
            NSString *baseDir =@"http://127.0.0.1:8999";
            NSString *fileName = [[model.savePath lastPathComponent] stringByDeletingPathExtension];
            NSMutableArray *params = [[NSMutableArray alloc] init];
            [params addObject:BUILD_STR(@"baseUrl=%@",baseDir)];
            [params addObject:BUILD_STR(@"name=%@",fileName)];
            [params addObject:BUILD_STR(@"version=%@",model.version)];
            [params addObject:BUILD_STR(@"appid=%@",model.appID)];
            [params addObject:BUILD_STR(@"bundleID=%@",model.package)];
            NSString *requestParams = [params componentsJoinedByString:@"&"];
            NSLog(@"ssl参数:%@",requestParams);
            //by thilong,2014-04-10
            NSString *encodeStr = [[requestParams base64String] stringByReplacingOccurrencesOfString:@"=" withString:@"%3d"];
            encodeStr = [encodeStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
            NSString *urlStr = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=https://ssl.naitang.com/installProxy/%@",encodeStr];
            
            NSLog(@"安装urlstr:%@",urlStr);
            //by thilong
            //NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSURL *url = [NSURL URLWithString:urlStr];
            if ([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
                
            }
            else{
                showAlert(@"安装出错，请卸载应用并重新下载！");
                
            }
            //by thilong,to fix here
        }
        else
        {
            //企业协议web安装（非越狱）
            NSString *plistPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches/"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",model.saveName]];
            //NSString *urlStr = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=file://localhost%@",plistPath];
            
            //[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            //NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            NSString *urlStr =[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=http://127.0.0.1:8999/%@.plist",model.saveName];
            NSURL *url = [NSURL URLWithString:urlStr];
            
            
            NSLog(@"安装路径：urlstring:%@",[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
            
            if ([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
                
                //[[NSURLCache sharedURLCache] removeAllCachedResponses];
                
                [self perform:^{
                    if ([self InstalledApp:model])
                    {
                        /*
                         //若已经安装应用，主页等列表按钮显示“已安装”
                         [self.installedListArray addObject:model.appID];
                         [[NSUserDefaults standardUserDefaults] setObject:self.installedListArray forKey:InstalledAppList];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         */
                        int sign = 0;
                        if (self.installFinishedArray.count>0)
                        {
                            //若已安装过，就不添加到已安装列表
                            for (NT_DownloadModel *submodel in self.installFinishedArray)
                            {
                                if ([submodel.addressName isEqualToString:model.addressName])
                                {
                                    sign = 1;
                                    break;
                                }
                            }
                            if (sign==0)
                            {
                                //未安装过，添加到已安装列表
                                [self.installFinishedArray addObject:model];
                            }
                            
                        }
                        else
                        {
                            [self.installFinishedArray addObject:model];
                        }
                        
                        //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
                        model.loadType = INSTALLFINISHED;
                        model.buttonStatus = reInstallOn;
                        [self saveArchiver];
                        if (model.isUpdateModel) {
                            [self.updateDelegate refreshUpdateView:self];
                        }
                        //[self.finishedDelegate refreshFinishedManager:self];
                        [self delFileWithPath:model.savePath];
                        //[self.installFinishedArray addObject:model];
                        [self.downLoadingArray removeObject:model];
                        [self.downFinishedArray removeObject:model];
                        //[self.installDelegate refreshInstallView:self];
                        [self.finishedDelegate refreshFinishedManager:self];
                    }
                } afterDelay:30];
                
                
                
            }
            else
            {
                showAlert(@"安装出错，请卸载应用并重新下载！");
                
            }
        }
    }
    else
    {
        showAlert(@"安装出错，无包名!");
    }
}

//正版设备是否已经安装过该应用
- (BOOL)installUnJailBreakSoft:(NT_DownloadModel *)model
{
    if(![NTAppDelegate shareNTAppDelegate].installProxyStarted)
    {
        [[NTAppDelegate shareNTAppDelegate] beginHttpServer];
    }
    
    if (model)
    {
        //根据BundleID进行匹配
        if (model.package)
        {
            BOOL isInstalled = [self InstalledApp:model];
            if (isInstalled)
            {
                //若安装过，返回
                model.loadType = INSTALLFINISHED;
                model.buttonStatus = reInstallOn;
                if (model.isUpdateModel) {
                    [self.updateDelegate refreshUpdateView:self];
                }
                //若安装过，删除ipa和plist文件
                [self delFileWithPath:model.savePath];
                [self delFileWithPath:model.savePlistPath];
                
                //刷新剩余空间
                [self.usedSpaceDelegate refreshUsedSpaceViewManager:self];
                
                int sign = 0;
                if (self.installFinishedArray.count>0)
                {
                    //若已安装过，就不添加到已安装列表
                    for (NT_DownloadModel *submodel in self.installFinishedArray)
                    {
                        if ([submodel.addressName isEqualToString:model.addressName])
                        {
                            sign = 1;
                            break;
                        }
                    }
                    if (sign==0)
                    {
                        //未安装过，添加到已安装列表
                        [self.installFinishedArray addObject:model];
                    }
                    
                }
                else
                {
                    [self.installFinishedArray addObject:model];
                }
                
                //[self.downLoadingArray removeObject:model];
                [self.downFinishedArray removeObject:model];
                //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
                
                [self saveArchiver];
                
                [self.finishedDelegate refreshFinishedManager:self];
                //[self.installDelegate refreshInstallView:self];
                return YES;
            }
            else
            {
                //by thilong,none-jailbreak installation for ios 7 and above;
                
                if(isIOS7)
                {
                    /*
                     NSString *saveDir = [model.savePath stringByDeletingLastPathComponent];
                     NSLog(@"保存位置 savedir:%@",saveDir);
                     NSString *baseDir = [NSString stringWithFormat:@"file://localhost%@",saveDir];
                     */
                    //端口号四个9都可以。只要不要超过65535就是了。不要用80和21
                    //要和appdelegate里面启动时的端口一样
                    NSString *baseDir =@"http://127.0.0.1:8999";
                    NSString *fileName = [[model.savePath lastPathComponent] stringByDeletingPathExtension];
                    NSMutableArray *params = [[NSMutableArray alloc] init];
                    [params addObject:BUILD_STR(@"baseUrl=%@",baseDir)];
                    [params addObject:BUILD_STR(@"name=%@",fileName)];
                    [params addObject:BUILD_STR(@"version=%@",model.version)];
                    [params addObject:BUILD_STR(@"appid=%@",model.appID)];
                    [params addObject:BUILD_STR(@"bundleID=%@",model.package)];
                    NSString *requestParams = [params componentsJoinedByString:@"&"];
                    NSLog(@"ssl参数:%@",requestParams);
                    //by thilong,2014-04-10
                    NSString *encodeStr = [[requestParams base64String] stringByReplacingOccurrencesOfString:@"=" withString:@"%3d"];
                    encodeStr = [encodeStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
                    NSString *urlStr = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=https://ssl.naitang.com/installProxy/%@",encodeStr];
                    
                    NSLog(@"安装urlstr:%@",urlStr);
                    //by thilong
                    //NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    NSURL *url = [NSURL URLWithString:urlStr];
                    if ([[UIApplication sharedApplication] canOpenURL:url])
                    {
                        [[UIApplication sharedApplication] openURL:url];
                        return YES;
                    }
                    else{
                        showAlert(@"安装出错，请卸载应用并重新下载！");
                        return NO;
                    }
                    //by thilong,to fix here
                }
                else
                {
                    //企业协议web安装（非越狱）
                    //NSString *plistPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches/"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",model.saveName]];
                    //NSString *urlStr = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=file://localhost%@",plistPath];
                    
                    //[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    
                    //NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    
                    NSString *urlStr =[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=http://127.0.0.1:8999/%@.plist",model.saveName];
                    NSURL *url = [NSURL URLWithString:urlStr];
                    
                    
                    NSLog(@"安装路径：urlstring:%@",[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
                    
                    if ([[UIApplication sharedApplication] canOpenURL:url])
                    {
                        [[UIApplication sharedApplication] openURL:url];
                        
                        //[[NSURLCache sharedURLCache] removeAllCachedResponses];
                        
                        [self perform:^{
                            if ([self InstalledApp:model])
                            {
                                /*
                                 //若已经安装应用，主页等列表按钮显示“已安装”
                                 [self.installedListArray addObject:model.appID];
                                 [[NSUserDefaults standardUserDefaults] setObject:self.installedListArray forKey:InstalledAppList];
                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                 */
                                int sign = 0;
                                if (self.installFinishedArray.count>0)
                                {
                                    //若已安装过，就不添加到已安装列表
                                    for (NT_DownloadModel *submodel in self.installFinishedArray)
                                    {
                                        if ([submodel.addressName isEqualToString:model.addressName])
                                        {
                                            sign = 1;
                                            break;
                                        }
                                    }
                                    if (sign==0)
                                    {
                                        //未安装过，添加到已安装列表
                                        [self.installFinishedArray addObject:model];
                                    }
                                    
                                }
                                else
                                {
                                    [self.installFinishedArray addObject:model];
                                }
                                
                                //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
                                model.loadType = INSTALLFINISHED;
                                model.buttonStatus = reInstallOn;
                                [self saveArchiver];
                                if (model.isUpdateModel) {
                                    [self.updateDelegate refreshUpdateView:self];
                                }
                                
                                [self delFileWithPath:model.savePath];
                                //[self.installFinishedArray addObject:model];
                                [self.downLoadingArray removeObject:model];
                                [self.downFinishedArray removeObject:model];
                                
                                [self saveArchiver];
                                [self.finishedDelegate refreshFinishedManager:self];
                                //[self.installDelegate refreshInstallView:self];
                                
                            }
                        } afterDelay:20];
                        
                        
                        return YES;
                    }
                    else
                    {
                        showAlert(@"安装出错，请卸载应用并重新下载！");
                        return NO;
                    }
                    
                }
                
            }
        }
        else
        {
            showAlert(@"无包名，安装出错");
            return NO;
        }
    }
    return NO;
}

- (BOOL)InstalledApp:(NT_DownloadModel *)model
{
    if (model)
    {
        //根据BundleID进行匹配
        NSArray *arr = [NSArray arrayWithObject:model.package];
        NSArray *installedArray = [MobileInstallationInstallManager IPAInstalled:arr];
        
        if (installedArray.count)
        {
            //判断该应用的版本号，若为新版本，则替换旧版本。
            
            for (NSDictionary *installedDictionary in installedArray)
            {
                //设备上有的应用的版本号
                NSString *installVersion = [installedDictionary objectForKey:@"CFBundleVersion"];
                
                if ([NT_UpdateAppInfo versionCompare:model.version and:installVersion])
                {
                    //可更新
                    break;
                }
                else
                {
                    return YES;
                }
            }
            //                NSString *gameName = [NSString stringWithFormat:@"“%@”已经安装过了",model.gameName];
            //                showAlert(gameName);
        }
    }
    return NO;
}

//继续安装
- (void)delDownLoadAndContinueWithModel:(NT_DownloadModel *)model indexPath:(NSIndexPath *)indexPath
{
    [self delFileWithPath:model.savePath];
    [self.downLoadingArray removeObject:model];
    //by thilong [self.delegate refreshViewInDownLoadManager:self indexPath:nil];
    [self.delegate refreshViewInDownLoadManager:self shouldReloadData:YES];
    [self saveArchiver];
    [self continueDownLoadModel];
}

//删除文件路径
- (void)delFileWithPath:(NSString *)filePath
{
    NSLog(@"delete filepath:%@",filePath);
    NSError *error = nil;
    NSFileManager *fm = [[NSFileManager alloc] init];
    if ([fm fileExistsAtPath:filePath]) {
        if ([fm isDeletableFileAtPath:filePath]){
            if (![fm removeItemAtPath:filePath error:&error]) {
                NSLog(@"could not delete file: %@",error);
            }
        }
    }
    
}

//奶糖通知
- (void)addLocalNotification:(NSString *)gameName
{
    //    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //    [[UIApplication sharedApplication] cancelAllLocalNotifications];  //取消所有的通知
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {   //判断系统是否支持本地通知
        NSDate *date = [NSDate date];
        //        int hour = [date getHour];
        //        if (hour >= 21 || hour < 9) {
        //            date = [NSDate dateFromString:[NSString stringWithFormat:@"%d-%02d-%02d 17:00:00",[date getYear],[date getMonth],[date getDay]] withFormat:@"yyyy-MM-dd HH:mm:ss"];
        //        }
        notification.fireDate=[NSDate dateWithTimeInterval:1 sinceDate:date];//60*24*7];  //本次开启立即执行的周期
        //        [self alertForMeg:[notification.fireDate description]];
        notification.repeatInterval=0;//kCFCalendarUnitWeekday;  //循环通知的周期
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.alertBody= [NSString stringWithFormat:@"%@下载完成，请回到奶糖完成安装！",gameName];
        //NSLocalizedString([NSString stringWithFormat:@"%@下载完成，请回到奶糖完成安装！",gameName], nil);   //弹出的提示信息
        //        notification.applicationIconBadgeNumber=1;    //应用程序的右上角小数字
        notification.soundName= UILocalNotificationDefaultSoundName;  //本地化通知的声音
        notification.alertAction = NSLocalizedString(@"确定", nil);   //弹出的提示框按钮
        [[UIApplication sharedApplication]   scheduleLocalNotification:notification];
    }
}


@end

