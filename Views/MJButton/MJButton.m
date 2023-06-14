//
//  MJButton.m
//  区块链钱包
//
//  Created by 马佳 on 2018/6/14.
//  Copyright © 2018年 iBESTLOVE_HangZhou. All rights reserved.
//

#import "MJButton.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "UIView+MJCategory.h"

@implementation MJButton
{
    UILabel * badgeLabel;
    UIView * redDot;
}

#pragma mark - 点击区域放大
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect bounds =self.bounds;
    
    //自定义放大
    if (!CGSizeEqualToSize(self.ScaleUpSize, CGSizeZero))
    {
        CGFloat widthDelta = self.ScaleUpSize.width - bounds.size.width;
        CGFloat heightDelta = self.ScaleUpSize.height - bounds.size.height;
        bounds =CGRectInset(bounds, -widthDelta, -heightDelta);
        return CGRectContainsPoint(bounds, point);
    }
    
    //默认放大
    else if (self.ScaleUpBounce)
    {
        CGRect bounds =self.bounds;
        CGFloat heightDelta = 44 - bounds.size.height;
        bounds =CGRectInset(bounds, 0, -heightDelta);
        return CGRectContainsPoint(bounds, point);
    }
    
    //不放大
    else
    {
        bounds =CGRectInset(bounds, 0, 0);
        return CGRectContainsPoint(bounds, point);
    }
    
}

//imageFrame
-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    if (_imageFrame.size.width>0)
    {
        return _imageFrame;
    }
    else
    {
        return [super imageRectForContentRect:contentRect];
    }
}


//title frame
-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    if (_titleFrame.size.width>0)
    {
        return _titleFrame;
    }
    else
    {
        return [super titleRectForContentRect:contentRect];
    }
}


//align
//- (UILabel *)titleLabel
//{
//    if (_mj_align>0)
//    {
//        UILabel * label = [super titleLabel];
//        label.textAlignment=NSTextAlignmentCenter;
//        return label;
//    }
//    else
//    {
//        return [super titleLabel];
//    }
//}

#pragma mark - setter方法
//文字
-(void)setMj_text:(NSString *)mj_text
{
    _mj_text=mj_text;
    [self setTitle:mj_text forState:UIControlStateNormal];
}

//图片
- (void)setMj_image:(NSString *)mj_image
{
    _mj_image=mj_image;
    [self setImage:MJImageNamed(mj_image) forState:UIControlStateNormal];
}

//图片对象
- (void)setMj_imageObjec:(UIImage *)mj_imageObjec
{
    _mj_imageObjec = mj_imageObjec;
    [self setImage:mj_imageObjec forState:UIControlStateNormal];
}

//文字颜色
- (void)setMj_textColor:(UIColor *)mj_textColor
{
    _mj_textColor = mj_textColor;
    [self setTitleColor:mj_textColor forState:UIControlStateNormal];
}

//bgcolor
-(void)setMj_bgColor:(UIColor *)mj_bgColor
{
    _mj_bgColor = mj_bgColor;
    [self setBackgroundColor:_mj_bgColor];
}

//borderColor
-(void)setMj_borderColor:(UIColor *)mj_borderColor
{
    _mj_borderColor = mj_borderColor;
    self.layer.borderColor=_mj_borderColor.CGColor;
}


//Font
-(void)setMj_font:(UIFont *)mj_font
{
    _mj_font = mj_font;
    self.titleLabel.font=mj_font;
}

//align
-(void)setMj_align:(NSTextAlignment)mj_align
{
    _mj_align = mj_align;
    self.titleLabel.textAlignment=mj_align;
}

//alpha
-(void)setMj_alpha:(CGFloat)mj_alpha
{
    _mj_alpha = mj_alpha;
    self.alpha=mj_alpha;
}






#pragma mark - 切换点击状态
-(void)setMJSelectState:(BOOL)MJSelectState
{
    _MJSelectState = MJSelectState;
    
    if (_MJSelectState==YES)
    {
        if (_mj_image_sel.length)
        {
            [self setImage:MJImageNamed(_mj_image_sel) forState:UIControlStateNormal];
        }
        if (_mj_imageObject_sel)
        {
            [self setImage:_mj_imageObject_sel forState:UIControlStateNormal];
        }
        if (_mj_text_sel.length)
        {
            [self setTitle:_mj_text_sel forState:UIControlStateNormal];
        }
        if (_mj_textColor_sel)
        {
            [self setTitleColor:_mj_textColor_sel forState:UIControlStateNormal];
        }
        if (_mj_font_sel)
        {
            [self.titleLabel setFont:_mj_font_sel];
        }
        if (_mj_bgColor_sel)
        {
            self.backgroundColor = _mj_bgColor_sel;
        }
        if (_mj_borderColor_sel)
        {
            self.layer.borderColor=_mj_borderColor_sel.CGColor;
        }
        if (_mj_alpha_sel>0)
        {
            self.alpha=_mj_alpha_sel;
        }
        if (badgeLabel.text.length)
        {
            badgeLabel.hidden=YES;
        }
    }
    else
    {
        if (_mj_image.length)
        {
            [self setImage:MJImageNamed(_mj_image) forState:UIControlStateNormal];
        }
        if (_mj_imageObjec)
        {
            [self setImage:_mj_imageObjec forState:UIControlStateNormal];
        }
        if (_mj_text.length)
        {
            [self setTitle:_mj_text forState:UIControlStateNormal];
        }
        if (_mj_textColor)
        {
            [self setTitleColor:_mj_textColor forState:UIControlStateNormal];
        }
        if (_mj_font)
        {
            [self.titleLabel setFont:_mj_font];
        }
        if (_mj_bgColor)
        {
            self.backgroundColor = _mj_bgColor;
        }
        if (_mj_borderColor)
        {
            self.layer.borderColor=_mj_borderColor.CGColor;
        }
        if (_mj_alpha>0)
        {
            self.alpha=_mj_alpha;
        }
        if (badgeLabel.text.length)
        {
//            badgeLabel.hidden=NO;
        }
    }
}

#pragma mark - 标记
-(void)setBadgeNum:(NSString*)badge style:(NSInteger)style
{
    _badgeCount = badge.integerValue;
    
    if (badge.intValue==0)
    {
        badgeLabel.hidden=YES;
        return;
    }
    
    
    if (badgeLabel==nil)
    {
        badgeLabel=[[UILabel alloc]init];
        [badgeLabel setFrame:CGRectMake(0, 0, 0, 14)];
        badgeLabel.font=FONT(8);
        [self addSubview:badgeLabel];
    }
    
    badgeLabel.hidden=NO;
    badgeLabel.text=badge;
    
    //样式
    if (style==0)
    {
        CGSize sz = [badgeLabel sizeThatFits:badgeLabel.frame.size];
        [badgeLabel setFrame:CGRectMake(0, 0, sz.width+10, 14)];
        [badgeLabel setCenter:CGPointMake(self.frame.size.width-17, 12)];
        badgeLabel.textColor=HW_WHITE;
        badgeLabel.textAlignment=NSTextAlignmentCenter;
        badgeLabel.layer.backgroundColor=HW_RED_WORD_1.CGColor;
        badgeLabel.layer.cornerRadius=7;
    }
    
    else if(style==1)
    {
        CGSize sz = [badgeLabel sizeThatFits:badgeLabel.frame.size];
        [badgeLabel setFrame:CGRectMake(0, 0, sz.width, 14)];
        badgeLabel.textAlignment=NSTextAlignmentLeft;
        badgeLabel.textColor=[UIColor blackColor];
        [badgeLabel setOrigin:CGPointMake(self.frame.size.width/2+9, 6)];
    }
    
    else if (style==2)
    {
        CGSize sz = [badgeLabel sizeThatFits:badgeLabel.frame.size];
        [badgeLabel setFrame:CGRectMake(0, 0, sz.width, 14)];
        badgeLabel.textAlignment=NSTextAlignmentLeft;
        [badgeLabel setOrigin:CGPointMake(30, 5)];
        
        if (self.MJSelectState)
        {
            badgeLabel.textColor=HW_RED_WORD_1;
        }
        else
        {
            badgeLabel.textColor=HW_GRAY_WORD_1;
        }
    }
}


-(void)setRedDotStyle:(NSInteger)style frame:(CGRect)frame
{
    //创建角标
    if (redDot==nil)
    {
        redDot = [[UIView alloc]init];
        [redDot setFrame:CGRectMake(self.frame.size.width-15.5, 3, 11, 11)];
        redDot.layer.cornerRadius=redDot.frame.size.height/2;
        redDot.layer.borderWidth=1.5;
        redDot.layer.borderColor=HW_WHITE.CGColor;
        redDot.backgroundColor=HW_RED_WORD_1;
        [self addSubview:redDot];
    }
    
    //frame
    if (frame.size.width>0&&frame.size.height>0)
    {
        [redDot setFrame:frame];
    }
    
    
    if (style==0)
    {
        redDot.hidden=YES;
    }
    else
    {
        redDot.hidden=NO;
    }
    
}


-(void)setBadgeStr:(NSString*)str
{
    if (badgeLabel==nil)
    {
        badgeLabel=[[UILabel alloc]init];
        badgeLabel.font=FONT(8);
        badgeLabel.layer.backgroundColor=HW_RED_WORD_1.CGColor;
        badgeLabel.layer.cornerRadius=7;
        badgeLabel.textColor=HW_WHITE;
        badgeLabel.textAlignment=NSTextAlignmentCenter;
        badgeLabel.height = 14;
        badgeLabel.width = 30;
        [self addSubview:badgeLabel];
        
    }
    badgeLabel.text = str;
    [badgeLabel sizeToFit];
    [badgeLabel setFrame:CGRectMake(self.width-12, 1, badgeLabel.width+6, 14)];
        
}

@end
