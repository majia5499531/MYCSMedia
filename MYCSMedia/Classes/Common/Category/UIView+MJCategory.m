//
//  UIView+RMAdditions.m
//  RMCategories
//
//  Created by Richard McClellan on 5/27/13.
//  Copyright (c) 2013 Richard McClellan. All rights reserved.
//


#import "UIView+MJCategory.h"

@implementation UIView (MJCategory)


//获取x
-(CGFloat)left
{
    return self.frame.origin.x;
}

//设置x
- (void)setLeft:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}
//获取x
-(CGFloat)x
{
    return self.frame.origin.x;
}

//设置x
-(void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

//获取y
- (CGFloat)top
{
    return self.frame.origin.y;
}

//设置y
-(void)setTop:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

//获取y
-(CGFloat)y
{
    return self.frame.origin.y;
}

//设置y
-(void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

//获取右上角x
-(CGFloat)right
{
    return self.frame.origin.x + self.frame.size.width;
}

//设置右上角x
-(void)setRight:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

//获取底部y
-(CGFloat)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

//设置底部y
-(void)setBottom:(CGFloat)bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

//获取中心点x
-(CGFloat)centerX
{
    return self.center.x;
}

//设置中心点x
-(void)setCenterX:(CGFloat)centerX
{
    self.center = CGPointMake(centerX, self.center.y);
}

//获取中心点y
-(CGFloat)centerY
{
    return self.center.y;
}

//设置中心点y
-(void)setCenterY:(CGFloat)centerY
{
    self.center = CGPointMake(self.center.x, centerY);
}

//获取宽度
-(CGFloat)width
{
    return self.frame.size.width;
}

//设置宽度啊
-(void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

//获取高度
- (CGFloat)height
{
    return self.frame.size.height;
}

//设置高度
-(void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

//设置左上角点
-(void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

//获取左上角点
-(CGPoint)origin
{
    return self.frame.origin;
}

//设置尺寸
- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

//获取尺寸
-(CGSize)size
{
    return self.frame.size;
}




#pragma mark - MJ Custom
-(void)MJRemoveAllSubviews
{
    for (UIView * subview in self.subviews)
    {
        [subview removeFromSuperview];
    }
}


-(void)MJRemoveAllSubviewsExcept:(NSArray*)objects
{
    for (UIView * subview in self.subviews)
    {
        if (![objects containsObject:subview])
        {
            [subview removeFromSuperview];
        }
    }
}



-(CGFloat)getBottomY
{
    CGFloat bottomY = 0;
    for (UIView * subview in self.subviews)
    {
        if (subview.hidden)
        {
            continue;
        }
        
        if ([self isKindOfClass:[UIScrollView class]])
        {
            Class scrollviewIndicatorClass = NSClassFromString(@"_UIScrollViewScrollIndicator");
            if ([subview isKindOfClass:scrollviewIndicatorClass])
            {
                continue;
            }
        }
        
        if (subview.bottom>bottomY)
        {
            bottomY=subview.bottom;
        }
    }
    
    return bottomY;
}



-(CGFloat)getRightX
{
    CGFloat right = 0;
    for (UIView * subview in self.subviews)
    {
        if (subview.hidden)
        {
            continue;
        }
        
        if ([self isKindOfClass:[UIScrollView class]])
        {
            Class scrollviewIndicatorClass = NSClassFromString(@"_UIScrollViewScrollIndicator");
            if ([subview isKindOfClass:scrollviewIndicatorClass])
            {
                continue;
            }
        }
        
        if (subview.right>right)
        {
            right=subview.right;
        }
    }
    
    return right;
}


-(void)MJSetIndividualAlpha:(CGFloat)value
{
    self.backgroundColor = [UIColor colorWithWhite:0.f alpha:value];
}


-(void)MJSetPartRadius:(CGFloat)radius RoundingCorners:(UIRectCorner)corners
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}


@end
