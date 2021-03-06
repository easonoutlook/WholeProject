//
//  NT_UserGuidesViewController.m
//  NaiTangApp
//
//  Created by 张正超 on 14-4-3.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_UserGuidesViewController.h"

@interface NT_UserGuidesViewController ()

@property (strong,nonatomic) UIScrollView *guidScrollView;
@property (strong,nonatomic) UIPageControl *pageControl;
@property (strong,nonatomic) UIControl *control;
@property (strong,nonatomic) NSArray *jailbreakPhoneArray;
@property (strong,nonatomic) NSArray *phoneArray;

//存储需要显示的图片和最后一个透明视图
@property (strong,nonatomic) NSArray *allViewArray;

@end

@implementation NT_UserGuidesViewController

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
    
    _guidScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _guidScrollView.pagingEnabled = YES;
    _guidScrollView.delegate = self;
    [_guidScrollView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:_guidScrollView];
    _guidScrollView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
    //if ([[UIDevice currentDevice] isJailbroken])
    if ([[UIDevice currentDevice] isJailbroken] || ![[UIDevice currentDevice] isJailbroken])
    {
        //越狱
        self.jailbreakPhoneArray = [[NSArray alloc] initWithObjects:@"iphone-p1.png",@"iphone-p2.png",@"iphone-p3.png", nil];
        
        //self.guidScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*self.phoneArray.count, SCREEN_HEIGHT);
        if (isIphone)
        {
            //最后一页为view，向右滑动到最后一页
            for (int i=0; i<self.jailbreakPhoneArray.count; i++) {
                
                UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                bgView.backgroundColor = [UIColor clearColor];
                
                [_guidScrollView addSubview:bgView];
                
                //最后一页为view，向右滑动到最后一页
                if (i == self.jailbreakPhoneArray.count-1)
                {
                    //bgView.backgroundColor = [UIColor blackColor];
                    
                }
                UIImageView *imageView = nil;
                if (isIphone5Screen)
                {
                    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 480)];
                }
                else
                {
                    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                }
                imageView.image = [UIImage imageNamed:[self.jailbreakPhoneArray objectAtIndex:i]];
                [bgView addSubview:imageView];
                //第二页按钮点击事件
                if (i==self.jailbreakPhoneArray.count-2)
                {
                    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*i+80, SCREEN_HEIGHT-160, 200, 80)];
                    [control addTarget:self action:@selector(imageControlClick:) forControlEvents:UIControlEventTouchUpInside];
                    [_guidScrollView addSubview:control];
                }
                else if (i == self.jailbreakPhoneArray.count-1)
                {
                    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*i, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                    [control addTarget:self action:@selector(imageControlClick:) forControlEvents:UIControlEventTouchUpInside];
                    [_guidScrollView addSubview:control];
                    
                }

            }
        }
        //最后一页为view，向右滑动到最后一页
        _guidScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*(self.jailbreakPhoneArray.count + 1), SCREEN_HEIGHT-20);
    }
    else if (![UIDevice currentDevice].isJailbroken)
    {
        //正版
        self.phoneArray = [[NSArray alloc] initWithObjects:@"iphone-p1.png",@"iphone-p2.png",@"iphone-p3.png", nil];
        
        if (isIphone)
        {
            //最后一页为view，向右滑动到最后一页
            for (int i=0; i<self.phoneArray.count; i++)
            {
                UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                bgView.backgroundColor = [UIColor whiteColor];
                [_guidScrollView addSubview:bgView];
                
                //最后一页为view，向右滑动到最后一页
                if (i == self.phoneArray.count-1)
                {
                    bgView.backgroundColor = [UIColor clearColor];
                    
                }
                
                UIImageView *imageView = nil;
                if (isIphone5Screen)
                {
                    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-20-480)/2, SCREEN_WIDTH, 480)];
                }
                else
                {
                    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                }
                imageView.image = [UIImage imageNamed:[self.phoneArray objectAtIndex:i]];
                [bgView addSubview:imageView];
               
                //第二页按钮点击事件
                if (i==self.phoneArray.count-2)
                {
                    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*i+80, SCREEN_HEIGHT-160, 200, 80)];
                    [control addTarget:self action:@selector(imageControlClick:) forControlEvents:UIControlEventTouchUpInside];
                    [_guidScrollView addSubview:control];
                }
                else if (i == self.phoneArray.count - 1)
                {
                    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*i, 0, SCREEN_WIDTH, ScreenHeight)];
                    [control addTarget:self action:@selector(imageControlClick:) forControlEvents:UIControlEventTouchUpInside];
                    [_guidScrollView addSubview:control];
                 
                    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
                    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
                    [_guidScrollView addGestureRecognizer:swipeGesture];
                 }
            }
            
        }
        //最后一页为view，向右滑动到最后一页
        _guidScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*(self.phoneArray.count+1), SCREEN_HEIGHT-20);
    }

}

- (void)imageControlClick:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    self.view.hidden = YES;
    [self.view removeFromSuperview];
    NTAppDelegate *delegate= [[UIApplication sharedApplication] delegate];
    [delegate loadRootViewControl:[UIApplication sharedApplication]];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_guidScrollView == scrollView) {
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;//根据坐标算页数
        
        //向右滑动到最后一页
        if (scrollView.contentSize.width/SCREEN_WIDTH == (self.phoneArray.count + 1))
        {
            //向右滑动到最后一页
            if (page==3)
            {
                NTAppDelegate *delegate= [[UIApplication sharedApplication] delegate];
                delegate.window.alpha = 1;
                
                //初始化主页
                [delegate loadRootViewControl:[UIApplication sharedApplication]];
                [delegate loadRootData];
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
                self.view.hidden = YES;
                [self.view removeFromSuperview];
                
            }
            
        }
        //向右滑动到最后一页
        else if (scrollView.contentSize.width/SCREEN_WIDTH == (self.jailbreakPhoneArray.count + 1))
        {
            //向右滑动到最后一页
            if (page == 3)
            {
               
                NTAppDelegate *delegate= [[UIApplication sharedApplication] delegate];
                [delegate loadRootViewControl:[UIApplication sharedApplication]];
                [delegate loadRootData];
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
                self.view.hidden = YES;
                [self.view removeFromSuperview];
            }
        }
    }
    
}

- (void)clear
{
    self.guidScrollView = nil;
    self.pageControl = nil;
    self.control = nil;
    self.jailbreakPhoneArray = nil;
    self.phoneArray = nil;
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
