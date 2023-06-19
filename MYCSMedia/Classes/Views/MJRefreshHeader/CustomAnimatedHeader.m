//
//  CustomAnimatedHeader.m
//  智慧长沙
//
//  Created by 马佳 on 2019/12/17.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import "CustomAnimatedHeader.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "UIImage+MJCategory.h"

@implementation CustomAnimatedHeader
{
    CABasicAnimation * anima;
}

-(void)prepare
{
    [super prepare];
    
    self.lastUpdatedTimeLabel.hidden=YES;
    self.stateLabel.hidden=YES;
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    [self.loadingImage setFrame:CGRectMake(self.frame.size.width/2-33, 23.5, 13.5, 14)];
    
    [self.loadingLabel setFrame:CGRectMake(self.loadingImage.frame.origin.x+self.loadingImage.frame.size.width+8, self.loadingImage.frame.origin.y-0.5, 100, 15)];
}



-(void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    
    if (self.pullingPercent>0.25 && self.pullingPercent<1)
    {
        self.loadingLabel.text=@"下拉刷新";
        [self makeImageRotation];
    }
    else if (self.pullingPercent>1)
    {
        self.loadingLabel.text=@"松开刷新";
        [self makeImageRotation];
    }
    else
    {
        self.loadingLabel.text=@"正在刷新";
    }

}

-(void)makeImageRotation
{
    //旋转动画
    NSString * format = [NSString stringWithFormat:@"%.2f",self.pullingPercent];
    CGFloat k = format.floatValue * 6.0;
    static CGFloat old;
    if (old!=k)
    {
        anima = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        anima.fromValue = [NSNumber numberWithFloat:old];
        anima.toValue = [NSNumber numberWithFloat:k];
        anima.duration = 0;
        anima.repeatCount = 1;
        anima.removedOnCompletion=NO;
        anima.fillMode=kCAFillModeForwards;
        [_loadingImage.layer addAnimation:anima forKey:@"rotationAnimation"];
        
        old = k;
    }
}


-(void)endRefreshing
{
    [super endRefreshing];
    
    [_loadingImage.layer removeAllAnimations];
}

-(void)beginRefreshing
{
    [super beginRefreshing];
    
    NSNumber * toValue = anima.toValue;
    
    //旋转动画
    anima = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    anima.fromValue = toValue;
    anima.toValue = [NSNumber numberWithFloat:9999];
    anima.duration = 750;
    anima.repeatCount = 1;
    anima.removedOnCompletion=NO;
    anima.fillMode=kCAFillModeForwards;
    [_loadingImage.layer addAnimation:anima forKey:@"rotationAnimation"];
}




#pragma mark - Lazy Load
-(UIImageView *)loadingImage
{
    if (_loadingImage==nil)
    {
        _loadingImage = [[UIImageView alloc]init];
        _loadingImage.image = [UIImage getBundleImage:@"sz_loadingCircle"];
        
        [self addSubview:_loadingImage];
    }
    return _loadingImage;
}
-(UILabel *)loadingLabel
{
    if (_loadingLabel==nil)
    {
        _loadingLabel = [[UILabel alloc]init];
        _loadingLabel.textColor=HW_GRAY_WORD_1;
        _loadingLabel.font=[UIFont systemFontOfSize:13];
        [self addSubview:_loadingLabel];
    }
    return _loadingLabel;
}


@end
