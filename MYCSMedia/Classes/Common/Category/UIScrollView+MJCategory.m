//
//  UIScrollView+MJCategory.m
//  区块链钱包
//
//  Created by 马佳 on 2018/7/23.
//  Copyright © 2018年 iBESTLOVE_HangZhou. All rights reserved.
//

#import "UIScrollView+MJCategory.h"
//#import "UIView+MJCategory.h"

@implementation UIScrollView (MJCategory)


-(void)setNoContentInset
{
    if (@available(iOS 11.0, *))
    {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}



-(void)MJAutoSetContentSize_isPaging:(BOOL)pageEnable
{
    CGFloat x=0;
    CGFloat y=0;
    
    for (UIView * v in self.subviews)
    {
        CGFloat vright = v.frame.origin.x + v.frame.size.width;
        if (vright > x)
        {
            x = vright;
        }
        
        CGFloat vbottom = v.frame.origin.y + v.frame.size.height;
        if (vbottom > y)
        {
            y = vbottom;
        }
    }
    
    
    //如果需要分页
    if (pageEnable)
    {
        int j = 1;
        int k = 1;
        
        if (x>self.frame.size.width)
        {
            j = x/self.frame.size.width + 1;
        }
        if(y>self.frame.size.height)
        {
            k = y/self.frame.size.height + 1;
        }
        
        [self setContentSize:CGSizeMake(j*self.frame.size.width, k*self.frame.size.height)];
        
    }
    
    //不需要分页
    else
    {
        [self setContentSize:CGSizeMake(x, y)];
    }
}


-(void)MJAutoSetContentSizeX:(CGFloat)offsetX Y:(CGFloat)offsetY
{
    CGFloat x=0;
    CGFloat y=0;
    
    for (UIView * v in self.subviews)
    {
        CGFloat vright = v.frame.origin.x + v.frame.size.width;
        if (vright > x)
        {
            x = vright;
        }
        
        CGFloat vbottom = v.frame.origin.y + v.frame.size.height;
        if (vbottom > y)
        {
            y = vbottom;
        }
    }
    
    [self setContentSize:CGSizeMake(x+offsetX, y+offsetY)];
}



-(void)MJAutoSetContentSize
{
    [self MJAutoSetContentSize_isPaging:NO];
}

@end
