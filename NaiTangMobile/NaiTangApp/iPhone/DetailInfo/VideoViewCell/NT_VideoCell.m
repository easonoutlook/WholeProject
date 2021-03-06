//
//  NT_VideoCell.m
//  NaiTangApp
//
//  Created by 张正超 on 14-3-6.
//  Copyright (c) 2014年 张正超. All rights reserved.
//
#import "NT_VideoCell.h"


@implementation NT_VideoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        self.alpha = 1.0;
        
        _videoImageView = [[EGOImageView alloc] init];
        _videoTitleLabel = [[UILabel alloc] init];
        _descriptionLabel = [[UILabel alloc] init];
        _dateLabel = [[UILabel alloc] init];
        
        
        if (self.isTemp == YES) {
            _videoImageView.frame = CGRectMake(10, 10, 60, self.height+15);
            _videoTitleLabel.frame = CGRectMake(_videoImageView.right+10, 4, SCREEN_WIDTH-80, 20);
            _descriptionLabel.frame = CGRectMake(_videoTitleLabel.left, _videoTitleLabel.bottom - 2, _videoTitleLabel.width, self.height-20);
            _dateLabel.frame = CGRectMake(_descriptionLabel.left, _descriptionLabel.bottom+5, _descriptionLabel.width, 20);
        }else{
            _videoTitleLabel.frame = CGRectMake(10, 10, self.frame.size.width, 20);
            _descriptionLabel.frame = CGRectMake(10, _videoTitleLabel.bottom - 2, self.frame.size.width - 20, self.height-20);
            _dateLabel.frame = CGRectMake(10, _videoTitleLabel.bottom + 5, self.frame.size.width - 20, 20);
        }
        
        //视频图片
        //        _videoImageView.image = [UIImage imageNamed:@"icon.png"];
        [self.contentView addSubview:_videoImageView];
        
        //视频标题
        _videoTitleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        _videoTitleLabel.text = @"暖暖系列为女性游戏代言";
        [self.contentView addSubview:_videoTitleLabel];
        
        //视频描述
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.text = @"现在市面上独家";
        _descriptionLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_descriptionLabel];
        
        //日期
        _dateLabel.text = @"2014-02-25";
        _dateLabel.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:_dateLabel];
        
        
        //分割线
        UIView * lineImg = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + 59, self.frame.size.width, 1)];
        lineImg.backgroundColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1.0];
        [self addSubview:lineImg];
    }
    return self;
}



- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview)
    {
        [_videoImageView cancelImageLoad];
    }
}
- (void)setImageURL:(NSString *)imageURL
{
    _videoImageView.imageURL = [NSURL URLWithString:imageURL];
}
//无网络请求调用
- (void)setImageURL:(NSString *)imageURL strTemp:(NSString *)temp
{
    NSURL * url = [NSURL URLWithString:imageURL];
    [_videoImageView imageUrl:url tempSTR:temp];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end