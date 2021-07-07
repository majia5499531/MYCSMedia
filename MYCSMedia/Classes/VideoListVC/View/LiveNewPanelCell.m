//
//  LiveNewPanelCell.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/28.
//

#import "LiveNewPanelCell.h"

@implementation LiveNewPanelCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 300, 33)];
        label.text=NSStringFromClass([self class]);
        [self addSubview:label];
    }
    return self;
}
@end
