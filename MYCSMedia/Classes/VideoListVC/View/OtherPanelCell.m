//
//  OtherPanelCell.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/25.
//

#import "OtherPanelCell.h"

@implementation OtherPanelCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor=[UIColor orangeColor];
        
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 300, 33)];
        label.text=@"Unknow Type Content";
        [self addSubview:label];
    }
    return self;
}
@end
