//
//  MJProgressView.m
//  Pods
//
//  Created by 马佳 on 2021/8/26.
//

#import "MJProgressView.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "CustomFooter.h"
#import "CustomAnimatedHeader.h"
#import "SZVideoCell.h"
#import "UIImage+MJCategory.h"
#import "MJButton.h"
#import "MJVideoManager.h"
#import <Masonry/Masonry.h>
#import "SZManager.h"
#import "UIView+MJCategory.h"
#import "SZInputView.h"
#import "SZCommentBar.h"
#import "MJHUD.h"
#import "BaseModel.h"
#import "ContentListModel.h"
#import "ContentModel.h"
#import "TokenExchangeModel.h"
#import "ConsoleVC.h"
#import "SZData.h"
#import "SZGlobalInfo.h"
#import "UIScrollView+MJCategory.h"



@implementation MJProgressView
{
    UIView * trackBG;
    
    UILabel * timeLabel;
    UILabel * totalTimeLabel;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //滑动条
        _slider = [[MJSlider alloc]init];
        _slider.layer.masksToBounds=YES;
        _slider.minimumTrackTintColor=HW_WHITE;
        _slider.maximumTrackTintColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
        UIImage * dot = [UIImage getBundleImage:@"sz_slider_whiteDot"];
        [_slider setThumbImage:dot forState:UIControlStateNormal];
        [self addSubview:_slider];
        [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(74);
            make.centerY.mas_equalTo(self);
            make.right.mas_equalTo(-74);
            make.height.mas_equalTo(self);
        }];
        
        //当前时长
        timeLabel = [[UILabel alloc]init];
        timeLabel.font=[UIFont systemFontOfSize:14];
        timeLabel.textColor=[UIColor whiteColor];
        timeLabel.alpha=0.4;
        timeLabel.textAlignment=NSTextAlignmentCenter;
        [self addSubview:timeLabel];
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.centerY.mas_equalTo(self);
        }];
        
        //总时长
        totalTimeLabel = [[UILabel alloc]init];
        totalTimeLabel.font = [UIFont systemFontOfSize:14];
        totalTimeLabel.textColor = [UIColor whiteColor];
        totalTimeLabel.alpha=0.4;
        timeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:totalTimeLabel];
        [totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-17);
            make.centerY.mas_equalTo(self);
        }];
        
    }
    return self;
}

-(void)setCurrentTime:(NSInteger)time totalTime:(NSInteger)totalTime progress:(CGFloat)progress isDragging:(BOOL)isDragging;
{
    timeLabel.text = [self timeFormat:time];
    totalTimeLabel.text = [self timeFormat:totalTime];
    
    if (!isDragging)
    {
        _slider.value = progress;
    }
}




#pragma mark - 转换
- (NSString *)timeFormat:(NSInteger)totalTime
{
    if (totalTime < 0)
    {
        return @"";
    }
    NSInteger durHour = totalTime / 3600;
    NSInteger durMin = (totalTime / 60) % 60;
    NSInteger durSec = totalTime % 60;
    
    if (durHour > 0)
    {
        return [NSString stringWithFormat:@"%zd:%02zd:%02zd", durHour, durMin, durSec];
    }
    else
    {
        return [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
    }
}



@end
