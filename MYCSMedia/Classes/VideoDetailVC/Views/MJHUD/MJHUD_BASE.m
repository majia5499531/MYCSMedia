//
//  MJToast.m
//  奶茶湾湾
//
//  Created by 马佳 on 2017/7/4.
//  Copyright © 2017年 HW_Tech. All rights reserved.
//

#import "MJHUD_BASE.h"


@interface MJHUD_BASE ()

@end

@implementation MJHUD_BASE

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



#pragma mark - Dealloc
-(void)dealloc
{
    NSLog(@"MJHUD Dealloc");
}


@end
