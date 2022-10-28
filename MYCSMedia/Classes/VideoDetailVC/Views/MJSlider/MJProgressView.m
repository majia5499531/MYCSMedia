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
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //监听平移手势
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
        [self addGestureRecognizer:pan];
        
        //滑动条
        _slider = [[MJSlider alloc]init];
        _slider.layer.masksToBounds=YES;
        _slider.enabled=NO;
        _slider.minimumTrackTintColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];;
        _slider.maximumTrackTintColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
        UIImage * dot = [UIImage getBundleImage:@"sz_slider_whiteDot"];
        [_slider setThumbImage:dot forState:UIControlStateNormal];
        [self addSubview:_slider];
        [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.centerY.mas_equalTo(self);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(30);
        }];
        
    }
    return self;
}



-(void)setCurrentTime:(NSInteger)time totalTime:(NSInteger)totalTime progress:(CGFloat)progress isDragging:(BOOL)isDragging;
{
//    timeLabel.text = [self timeFormat:time];
//    totalTimeLabel.text = [self timeFormat:totalTime];
//
    if (!isDragging)
    {
        _slider.value = progress;
    }
}




#pragma mark - 平移手势
-(void)panGestureAction:(UIPanGestureRecognizer*)pan
{
    CGPoint locationPoint = [pan locationInView:self];
        
    static CGFloat originX = 0;
    static CGFloat originPercent = 0;
    static CGFloat endPercent = 0;
    if (pan.state==UIGestureRecognizerStateBegan)
    {
        originX = locationPoint.x;
        originPercent = self.slider.value;
        [self.delegate MJSliderWillChange];
        
        UIImage * dot = [UIImage getBundleImage:@"sz_slider_whiteDot_big"];
        [_slider setThumbImage:dot forState:UIControlStateNormal];
        
    }
    else if (pan.state==UIGestureRecognizerStateChanged)
    {
        CGFloat offsetx = locationPoint.x-originX;
        CGFloat dragPercent = offsetx/self.width;
        self.slider.value = originPercent+dragPercent;
        
        endPercent=self.slider.value;
    }
    else
    {
        [self.delegate MJSliderDidChange:(endPercent)];
        [self.delegate MJSliderEndChange];
        
        
        UIImage * dot = [UIImage getBundleImage:@"sz_slider_whiteDot"];
        [_slider setThumbImage:dot forState:UIControlStateNormal];
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
