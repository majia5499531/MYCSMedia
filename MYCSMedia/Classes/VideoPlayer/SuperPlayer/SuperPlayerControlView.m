#import "SuperPlayerControlView.h"

@implementation SuperPlayerVideoPoint

@end

@implementation SuperPlayerControlView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _compact = YES;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    //根据是否紧凑,重置布局
    if (self.compact)
    {
        [self setCompactConstraint];
    }
    else
    {
        [self setUncompactConstraint];
    }
    
    //通知代理
    [self.delegate controlViewDidLayoutSubviews:self];
}




#pragma mark - 在子类实现
-(void)setCompactConstraint
{
    
}

-(void)setUncompactConstraint
{
    
}

-(void)playerBegin:(SuperPlayerModel *)model
        isLive:(BOOL)isLive
isTimeShifting:(BOOL)isTimeShifting
    isAutoPlay:(BOOL)isAutoPlay
{

}

-(void)setPlayState:(BOOL)isPlay
{

}

-(void)setProgressTime:(NSInteger)currentTime
              totalTime:(NSInteger)totalTime
          progressValue:(CGFloat)progress
          playableValue:(CGFloat)playable
{

}

@end
