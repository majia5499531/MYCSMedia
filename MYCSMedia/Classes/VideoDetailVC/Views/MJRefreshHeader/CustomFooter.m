//
//  CustomFooter.m
//  智慧长沙
//
//  Created by 马佳 on 2019/12/31.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import "CustomFooter.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"

#import <MJRefresh/MJRefresh.h>

@implementation CustomFooter
{
    BOOL MJIsRefreshing;
    BOOL noMoreData;
}

-(UILabel *)MJStateLabel
{
    if (_MJStateLabel==nil)
    {
        _MJStateLabel = [[UILabel alloc]init];
        _MJStateLabel.font=[UIFont systemFontOfSize:12];
        _MJStateLabel.textColor=HW_GRAY_WORD_1;
        _MJStateLabel.textAlignment=NSTextAlignmentCenter;
        [self addSubview:_MJStateLabel];
    }
    return _MJStateLabel;
}

#pragma mark - 重写父类的方法
-(void)prepare
{
    [super prepare];
    
    self.autoTriggerTimes=1;
}

-(void)placeSubviews
{
    [super placeSubviews];
    
    if (!CGRectIsEmpty(self.customFrame))
    {
        [self.MJStateLabel setFrame:self.customFrame];
    }
    else
    {
        [self.MJStateLabel setFrame:CGRectMake(self.frame.size.width/2-150, 13, 300, 20)];
    }
}

-(void)beginRefreshing
{
    if (MJIsRefreshing)
    {
        return;
    }
    
    [super beginRefreshing];
    
    MJIsRefreshing = YES;
    
    
    self.MJStateLabel.text=@"正在努力加载";
}

-(void)endRefreshingWithNoMoreData
{
    [super endRefreshingWithNoMoreData];
    
    //加载结束，显示没有更多
    if (self.customNoMoreDataStr.length)
    {
        self.MJStateLabel.text=self.customNoMoreDataStr;
    }
    else
    {
        self.MJStateLabel.text=@"- 我是有底线的 -";
    }
        
    [self performSelector:@selector(changeState:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.2];
}

-(void)endRefreshing
{
    [super endRefreshing];
    self.MJStateLabel.text=@"上拉获取更多内容";
    
    [self performSelector:@selector(changeState:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.2];
}

-(void)changeState:(NSNumber*)state
{
    MJIsRefreshing = state.boolValue;
}

-(void)resetNoMoreData
{
    [super resetNoMoreData];
    
    self.MJStateLabel.text=@"";
}

@end
