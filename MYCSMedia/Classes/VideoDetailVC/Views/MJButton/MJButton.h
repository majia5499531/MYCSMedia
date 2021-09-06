//
//  MJButton.h
//  区块链钱包
//
//  Created by 马佳 on 2018/6/14.
//  Copyright © 2018年 iBESTLOVE_HangZhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJButton : UIButton

//放大点击范围
@property(assign,nonatomic)BOOL ScaleUpBounce;
@property(assign,nonatomic)CGSize ScaleUpSize;

//Frame
@property(assign,nonatomic)CGRect imageFrame;
@property(assign,nonatomic)CGRect titleFrame;

//文字
@property(strong,nonatomic)NSString * mj_text;
@property(strong,nonatomic)NSString * mj_text_sel;

//颜色
@property(strong,nonatomic)UIColor * mj_textColor;
@property(strong,nonatomic)UIColor * mj_textColor_sel;

//font
@property(strong,nonatomic)UIFont * mj_font;
@property(strong,nonatomic)UIFont * mj_font_sel;

//image
@property(strong,nonatomic)NSString * mj_image;
@property(strong,nonatomic)NSString * mj_image_sel;

//image
@property(strong,nonatomic)UIImage * mj_imageObjec;
@property(strong,nonatomic)UIImage * mj_imageObject_sel;

//bg color
@property(strong,nonatomic)UIColor * mj_bgColor;
@property(strong,nonatomic)UIColor * mj_bgColor_sel;

//border color
@property(strong,nonatomic)UIColor * mj_borderColor;
@property(strong,nonatomic)UIColor * mj_borderColor_sel;

//alpha
@property(assign,nonatomic)CGFloat mj_alpha;
@property(assign,nonatomic)CGFloat mj_alpha_sel;

//align
@property(assign,nonatomic)NSTextAlignment mj_align;

//state
@property(assign,nonatomic)BOOL MJSelectState;

@property(assign,nonatomic)NSInteger badgeCount;

@property(strong,nonatomic)NSString * linkUrl;



-(void)setBadgeNum:(NSString*)badge style:(NSInteger)style;

-(void)setRedDotStyle:(NSInteger)style frame:(CGRect)frame;

-(void)setBadgeStr:(NSString*)str;

@end
