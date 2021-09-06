//
//  MJToast.m
//  奶茶湾湾
//
//  Created by 马佳 on 2017/7/4.
//  Copyright © 2017年 HW_Tech. All rights reserved.
//

#import "MJHUD_Base.h"


@interface MJHUD_Base ()

@end

@implementation MJHUD_Base

-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor=[UIColor clearColor];
        
        self.maskView=[[UIView alloc]init];
        self.maskView.backgroundColor=[UIColor grayColor];
        [self addSubview:self.maskView];
        
        self.contentView=[[UIView alloc]init];
        [self addSubview:self.contentView];
        
        self.iconView=[[UIImageView alloc]init];
        [self.contentView addSubview:self.iconView];
        
        self.textView=[[UILabel alloc]init];
        [self.contentView addSubview:self.textView];
    }
    return self;
}





#pragma mark - remove
-(void)hidding
{
    [self removeFromSuperview];
}



@end
