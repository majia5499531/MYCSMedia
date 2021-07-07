//
//  ReviewNewsPanelCell.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/28.
//

#import "ReviewNewsPanelCell.h"

@implementation ReviewNewsPanelCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor brownColor];
        
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 300, 33)];
        label.text=NSStringFromClass([self class]);
        [self addSubview:label];
    }
    return self;
}

-(void)setCellData:(id)data
{
    
}
@end
