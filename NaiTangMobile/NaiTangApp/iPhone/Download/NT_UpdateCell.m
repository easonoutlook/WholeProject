//
//  NT_UpdateCell.m
//  NaiTangApp
//
//  Created by 张正超 on 14-3-15.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_UpdateCell.h"
#import "UIImageView+WebCache.h"
#import "NT_UpdateAppInfo.h"
#import "NT_MacroDefine.h"
#import "NT_CustomButtonStyle.h"

@implementation NT_UpdateCell

@synthesize updateInfoLabel = _updateInfoLabel;
@synthesize customButtonStyle = _customButtonStyle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _customButtonStyle = [[NT_CustomButtonStyle alloc] init];
    
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.nameLabel.left, 52, 8, 8)];
        imageView.image = [UIImage imageNamed:@"update-plus.png"];
        [self.contentView addSubview:imageView];
        
        _updateInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _updateInfoLabel.textColor = Text_Color;
        _updateInfoLabel.font = [UIFont systemFontOfSize:10];
        _updateInfoLabel.tag = KUpdateInfoTag;
        _updateInfoLabel.numberOfLines = 0;
        [self.contentView addSubview:_updateInfoLabel];
   
        /*
        //分割线，若滑动时显示分割线，需要cell高度-1，不然往上滑动时，无分割线
        _splitView = [[UIView alloc] initWithFrame:CGRectMake(0, 70.5, SCREEN_WIDTH, 0.5)];
        _splitView.tag = 368;
        _splitView.backgroundColor = [UIColor colorWithHex:@"#f0f0f0"];
        [self.contentView addSubview:_splitView];
         */
    }
    return self;
}

- (void)refreshUpdateData:(NT_UpdateAppInfo *)updateInfo isOpenUpdate:(BOOL)isUpdate isAllIgnore:(BOOL)isAllIgnore
{
    //by 张正超 使用图片缓存方式显示
    [self.iconView setImageURL:[NSURL URLWithString:updateInfo.iconName]];
    
    //[self.iconView setImageWithURL:[NSURL URLWithString:updateInfo.iconName] placeholderImage:[UIImage imageNamed:@"default-icon.png"]];
    /*
    BOOL isFirst = [[NSUserDefaults standardUserDefaults] boolForKey:KIsFirstUpdateImage];
    if (!isFirst)
    {
        //若是第一次显示下载中，则加载图片
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KIsFirstUpdateImage];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //by 张正超 使用图片缓存方式显示
        [self.iconView setImageURL:[NSURL URLWithString:updateInfo.iconName]];
    }
    else
    {
        //第二次使用缓存图片
        [self.iconView imageUrl:[NSURL URLWithString:updateInfo.iconName] tempSTR:@"false"];
    }
*/
    self.nameLabel.text = updateInfo.game_name;
    self.versionSizeLabel.frame = CGRectMake(self.nameLabel.left, 29, 240, 20);
    self.versionSizeLabel.text = [NSString stringWithFormat:@"版本:%@  大小:%@",updateInfo.version_name,NSStringFromSize([updateInfo.fileSize intValue])];
    
    self.dateLabel.frame = CGRectMake(self.nameLabel.left+12, 45, 200, 20);
    self.dateLabel.text = @"更新详情";
    
    /*
    if (isUpdate)
    {
        //修改高度
        NSString *info = updateInfo.news_version;
        CGSize size = CGSizeMake(SCREEN_WIDTH-20, MAXFLOAT);
        CGSize maxSize = [info sizeWithFont:[UIFont systemFontOfSize:10] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        
        UILabel *updateLabel = (UILabel *)[self.contentView viewWithTag:KUpdateInfoTag];
        updateLabel.numberOfLines = 0;
        updateLabel.size = maxSize;
        updateLabel.text = updateInfo.news_version;
    }
    */
    
    if (isAllIgnore)
    {
        [self.installedButton setBackgroundImage:[UIImage imageNamed:@"btn-read.png"] forState:UIControlStateNormal];
        [self.installedButton setBackgroundImage:[UIImage imageNamed:@"btn-read-hover.png"] forState:UIControlStateHighlighted];
        [self.installedButton setTitle:@"忽略" forState:UIControlStateNormal];
        [self.installedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    }
    else
    {
        if (updateInfo.updateState == 0)
        {
            [_customButtonStyle customButton:self.installedButton title:@"更新" titleColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:12] bgImage:[UIImage imageNamed:@"btn-blue.png"] highlightedImage:[UIImage imageNamed:@"btn-blue-hover.png"]];
        }
        else
        {
            if (updateInfo.updateState == FINISHED || updateInfo.updateState == WAITEINSTALL || updateInfo.updateState == INSTALLING)
            {
                [_customButtonStyle customButton:self.installedButton title:@"安装" titleColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:12] bgImage:[UIImage imageNamed:@"btn-blue.png"] highlightedImage:[UIImage imageNamed:@"btn-blue-hover.png"]];
            }
            else if (updateInfo.updateState == INSTALLFINISHED || updateInfo.updateState == INSTALLFAILED)
            {
                
            }
            else
            {
                [_customButtonStyle customButton:self.installedButton title:@"下载中" titleColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:12] bgImage:[UIImage imageNamed:@"btn-blue.png"] highlightedImage:[UIImage imageNamed:@"btn-blue-hover.png"]];
            }

        }
    }
}

//展开更新详情
+ (CGFloat)openUpdateDetailInfo:(NT_UpdateAppInfo *)updateInfo
{
    NSString *info = updateInfo.news_version;
    CGSize size = CGSizeMake(SCREEN_WIDTH-20, MAXFLOAT);
    CGSize maxSize = [info sizeWithFont:[UIFont systemFontOfSize:10] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    maxSize.height += 10;
    return MAX(71, maxSize.height + 71);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
