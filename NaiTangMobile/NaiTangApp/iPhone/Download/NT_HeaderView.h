//
//  NT_HeaderView.h
//  NaiTangApp
//
//  Created by 张正超 on 14-3-11.
//  Copyright (c) 2014年 张正超. All rights reserved.
//
//  下载顶部-空间剩余

#import <UIKit/UIKit.h>

@class UIProgressBar;

@interface NT_HeaderView : UIView

@property (nonatomic,strong) UIImageView *backImageView;
@property (nonatomic,strong) UILabel *usedLabel;
@property (nonatomic,strong) UILabel *unUsedLabel;
@property (nonatomic,strong) UIButton *editButton;
@property (nonatomic,strong) UIButton *allStartButton;
@property (nonatomic,strong) UIProgressBar *progressView;

//刷新剩余空间数据
- (void)refreshHeaderData;

@end
