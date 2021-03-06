//
//  NT_WebViewController.m
//  NaiTangApp
//
//  Created by 张正超 on 14-4-9.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_WebViewController.h"

@interface NT_WebViewController ()

@end

@implementation NT_WebViewController

@synthesize webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //返回按钮
    UIButton *leftBt = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) image:[UIImage imageNamed:@"top-back.png"] target:self action:@selector(gotoBack)];
    [leftBt setImage:[UIImage imageNamed:@"top-back-hover.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:leftBt];
    if (isIOS7)
    {
        //设置ios7导航栏两边间距，和ios6以下两边间距一致
        UIBarButtonItem *spaceBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
        spaceBar.width = -10;
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:spaceBar,backItem, nil];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = backItem;
    }
    
    //网址
    if (self.webTitle)
    {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.delegate = self;
        [self.view addSubview:_webView];
        
        
        UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLable.font = [UIFont boldSystemFontOfSize:20];
        titleLable.textColor = [UIColor whiteColor];
        titleLable.backgroundColor = [UIColor clearColor];
        titleLable.text = @"关于我们";
        
        NSString *urlString = nil;
        if ([self.webTitle isEqualToString:@"微博"])
        {
            
            titleLable.text = @"奶糖游戏微博";
            urlString = @"http://weibo.com/naitanggame";
        }
        else if ([self.webTitle isEqualToString:@"官网"])
        {
            titleLable.text = @"奶糖游戏官网";
            urlString = @"http://www.naitang.com";
        }
        
        titleLable.textAlignment = TEXT_ALIGN_CENTER;
        [titleLable sizeToFit];
        self.navigationItem.titleView = titleLable;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        [_webView loadRequest:request];
    }
   
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.view showLoadingMeg:@"加载中.."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.view hideLoading];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.view showLoadingMeg:@"网络异常，加载出错" time:1];
    
}

- (void)gotoBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clear
{
    self.webTitle = nil;
    self.webView = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self clear];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if (isIOS6)
    {
        if ([self isViewLoaded] && self.view.window == nil) {
            self.view = nil;
        }
    }
    [self clear];
}

@end
