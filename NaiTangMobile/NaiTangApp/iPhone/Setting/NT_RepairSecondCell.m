//
//  NT_RepairSecondCell.m
//  NaiTangApp
//
//  Created by 张正超 on 14-4-14.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_RepairSecondCell.h"

@implementation NT_RepairSecondCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        //第一步
        UIView *firstView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 180)];
        [self.contentView addSubview:firstView];
        
        UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
        firstButton.frame = CGRectMake(16, 8, 21, 21);
        [firstButton setBackgroundImage:[UIImage imageNamed:@"dot-green@2x.png"] forState:UIControlStateNormal];
        [firstButton setBackgroundImage:[UIImage imageNamed:@"dot-green@2x.png"] forState:UIControlStateHighlighted];
        [firstButton setTitle:@"1" forState:UIControlStateNormal];
        [firstButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [firstButton setTitleColor:[UIColor colorWithHex:@"#ffffff"] forState:UIControlStateNormal];
        [firstView addSubview:firstButton];
        
        UILabel *labFirst = [[UILabel alloc] initWithFrame:CGRectMake(firstButton.right+8, firstButton.top, 200, 21)];
        labFirst.text = @"第一步";
        labFirst.textColor = [UIColor colorWithHex:@"#60bc23"];
        labFirst.font = [UIFont boldSystemFontOfSize:19];
        [firstView addSubview:labFirst];
        
        UILabel *labFirst1 = [[UILabel alloc] initWithFrame:CGRectMake(labFirst.left, labFirst.bottom+5, 300, 20)];
        labFirst1.textColor = Text_Color_Setting_Gray;
        labFirst1.text = @"在电脑上安装奶糖一键安装器";
        labFirst1.font = [UIFont systemFontOfSize:15];
        [firstView addSubview:labFirst1];
        
        UILabel *labFirst2 = [[UILabel alloc] initWithFrame:CGRectMake(labFirst1.left, labFirst1.bottom+5, 80, 20)];
        labFirst2.text = @"下载地址:";
        labFirst2.textColor = Text_Color_Setting_Gray;
        labFirst2.font = [UIFont systemFontOfSize:15];
        [firstView addSubview:labFirst2];
        
        UILabel *labFirst3 = [[UILabel alloc] initWithFrame:CGRectMake(labFirst2.right, labFirst2.top, 200, 20)];
        labFirst3.textColor = [UIColor colorWithHex:@"#60b5fd"];
        labFirst3.text = @"pc.naitang.com";
        labFirst3.font = [UIFont systemFontOfSize:15];
        [firstView addSubview:labFirst3];
        
        UIImageView *imgViewFirst = [[UIImageView alloc] initWithFrame:CGRectMake(labFirst2.left-10, labFirst3.bottom+10, 260, 80)];
        imgViewFirst.image = [UIImage imageNamed:@"repair-second@2x.png"];
        [firstView addSubview:imgViewFirst];
        
        //第二步
        UIView *secondView = [[UIView alloc] initWithFrame:CGRectMake(firstView.left, firstView.bottom, SCREEN_WIDTH, 180)];
        [self.contentView addSubview:secondView];
        
        UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
        secondButton.frame = CGRectMake(16, 8, 21, 21);
        [secondButton setBackgroundImage:[UIImage imageNamed:@"dot-green@2x.png"] forState:UIControlStateNormal];
        [secondButton setBackgroundImage:[UIImage imageNamed:@"dot-green@2x.png"] forState:UIControlStateHighlighted];
        [secondButton setTitle:@"2" forState:UIControlStateNormal];
        [secondButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [secondButton setTitleColor:[UIColor colorWithHex:@"#ffffff"] forState:UIControlStateNormal];
        [secondView addSubview:secondButton];
        
        UILabel *labSecond = [[UILabel alloc] initWithFrame:CGRectMake(secondButton.right+8, secondButton.top, 200, 21)];
        labSecond.text = @"第二步";
        labSecond.textColor = [UIColor colorWithHex:@"#60bc23"];
        labSecond.font = [UIFont boldSystemFontOfSize:19];
        [secondView addSubview:labSecond];
        
        UILabel *labSecond1 = [[UILabel alloc] initWithFrame:CGRectMake(labSecond.left, labSecond.bottom+5, 300, 20)];
        labSecond1.textColor = Text_Color_Setting_Gray;
        labSecond1.text = @"打开奶糖一键安装器连接出现闪退";
        labSecond1.font = [UIFont systemFontOfSize:15];
        [secondView addSubview:labSecond1];
        
        UILabel *labSecond2 = [[UILabel alloc] initWithFrame:CGRectMake(labSecond1.left, labSecond1.bottom+5, 200, 20)];
        labSecond2.text = @"或需要输入账号的设备";
        labSecond2.textColor = Text_Color_Setting_Gray;
        labSecond2.font = [UIFont systemFontOfSize:15];
        [secondView addSubview:labSecond2];
        
        UIImageView *imgViewSecond = [[UIImageView alloc] initWithFrame:CGRectMake(labSecond2.left-10, labSecond2.bottom+10, 260, 80)];
        imgViewSecond.image = [UIImage imageNamed:@"repair-second@2x.png"];
        [secondView addSubview:imgViewSecond];
        
        //第三步
        UIView *thirdView = [[UIView alloc] initWithFrame:CGRectMake(0, secondView.bottom, SCREEN_WIDTH, 180)];
        [self.contentView addSubview:thirdView];
        
        UIButton *thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        thirdButton.frame = CGRectMake(16, 8, 21, 21);
        [thirdButton setBackgroundImage:[UIImage imageNamed:@"dot-green@2x.png"] forState:UIControlStateNormal];
        [thirdButton setBackgroundImage:[UIImage imageNamed:@"dot-green@2x.png"] forState:UIControlStateHighlighted];
        [thirdButton setTitle:@"3" forState:UIControlStateNormal];
        [thirdButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [thirdButton setTitleColor:[UIColor colorWithHex:@"#ffffff"] forState:UIControlStateNormal];
        [thirdView addSubview:thirdButton];
        
        UILabel *labThird = [[UILabel alloc] initWithFrame:CGRectMake(thirdButton.right+8, thirdButton.top, 200, 21)];
        labThird.text = @"第三步";
        labThird.textColor = [UIColor colorWithHex:@"#60bc23"];
        labThird.font = [UIFont boldSystemFontOfSize:19];
        [thirdView addSubview:labThird];
        
        UILabel *labThird1 = [[UILabel alloc] initWithFrame:CGRectMake(labThird.left, labThird.bottom+5, 300, 20)];
        labThird1.textColor = Text_Color_Setting_Gray;
        labThird1.text = @"点击奶糖一键安装器右上角修复闪";
        labThird1.font = [UIFont systemFontOfSize:15];
        [thirdView addSubview:labThird1];
        
        UILabel *labThird2 = [[UILabel alloc] initWithFrame:CGRectMake(labThird1.left, labThird1.bottom+5, 200, 20)];
        labThird2.text = @"退，等待修复完成";
        labThird2.textColor = Text_Color_Setting_Gray;
        labThird2.font = [UIFont systemFontOfSize:15];
        [thirdView addSubview:labThird2];
        
        UIImageView *imgViewThird = [[UIImageView alloc] initWithFrame:CGRectMake(labThird2.left-10, labThird2.bottom+10, 260, 80)];
        imgViewThird.image = [UIImage imageNamed:@"repair-third@2x.png"];
        [thirdView addSubview:imgViewThird];
        
        //虚线
        UIImageView *dashedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, thirdView.bottom+5, 280, 3)];
        dashedImageView.image = [UIImage imageNamed:@"setting-dashed@2x.png"];
        [self.contentView addSubview:dashedImageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
