
//
//  NT_DetailNewsView.m
//  NaiTangApp
//
//  Created by 张正超 on 14-3-7.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_DetailNewsView.h"
#import "NT_DetailNewsInfo.h"
#import "ContentViewController.h"

@implementation NT_DetailNewsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        /*
        UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
        lineImageView.image = [UIImage imageNamed:@"line.png"];
        [self addSubview:lineImageView];
         */
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
        lineView.backgroundColor = [UIColor colorWithHex:@"#f0f0f0"];
        [self addSubview:lineView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 20)];
        titleLabel.text = @"游戏资讯";
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        titleLabel.backgroundColor = [UIColor clearColor];
        //titleLabel.textColor = [UIColor colorWithHex:@"#505a5f"];
        titleLabel.textColor = Text_Color_Title;
        [self addSubview:titleLabel];
        
        _newsView = [[UIView alloc] initWithFrame:CGRectMake(0, 25, SCREEN_WIDTH, KNewsCellHeight)];
        [self addSubview:_newsView];
    }
    return self;
}

//资讯信息
- (void)refreshNewsInfo:(NSArray *)newsArray
{
    if (newsArray.count > 0)
    {
        _newsView.height = newsArray.count * 40;
        
        [newsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NT_DetailNewsInfo *newsInfo = (NT_DetailNewsInfo *)obj;
            
            UIButton *newsButton = [UIButton buttonWithType:UIButtonTypeCustom];
            newsButton.frame = CGRectMake(10, idx*40, SCREEN_WIDTH-20, 39);
            [newsButton setTitle:newsInfo.title forState:UIControlStateNormal];
            [newsButton setTitleColor:Text_Color forState:UIControlStateNormal];
            //按钮文字居左
            newsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            newsButton.titleLabel.width = 200;
            [newsButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [newsButton setBackgroundImage:[UIImage imageNamed:@"white-bg.png"] forState:UIControlStateNormal];
            
            UIImage *img = [[UIImage imageNamed:@"btn-selected.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            [newsButton setBackgroundImage:img forState:UIControlStateHighlighted];
            [_newsView addSubview:newsButton];
            
            newsButton.tag = idx+1;
            [newsButton addTarget:self action:@selector(newsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            if (idx < newsArray.count -1)
            {
                UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, newsButton.bottom, SCREEN_WIDTH - 20, 1)];
                lineImageView.image = [UIImage imageNamed:@"dashed.png"];
                [_newsView addSubview:lineImageView];
                
            }
            
        }];
    }
}

- (void)newsButtonPressed:(id)sender
{
    int index = [(UIButton *)sender tag] - 1;
    if ([self.newsArray count])
    {
        //资讯信息
        NT_DetailNewsInfo *newsInfo = (NT_DetailNewsInfo *)[self.newsArray objectAtIndex:index];
        
        ContentViewController * contenVC = [[ContentViewController alloc] init];
        contenVC.hidesBottomBarWhenPushed = YES;
        contenVC.webUrl = newsInfo.link;
        contenVC.titleText = @"游戏资讯";
        [self.viewController.navigationController pushViewController:contenVC animated:YES];
        self.viewController.hidesBottomBarWhenPushed = YES;
        
    }
}

@end
