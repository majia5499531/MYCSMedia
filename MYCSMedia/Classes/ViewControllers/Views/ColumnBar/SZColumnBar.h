//
//  SZColumnBar.h
//  智慧长沙
//
//  Created by 马佳 on 2019/9/11.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SZColumnBarDelegate <NSObject>
-(void)mjview:(UIView*)view didSelectColumnIndex:(NSInteger)index;
-(void)mjview:(UIView*)view willSelectTab:(NSInteger)index;
@optional
@end

//对齐方式
typedef NS_ENUM(NSUInteger, SZColumnAlignment) {
    SZColumnAlignmentLeft,
    SZColumnAlignmentCenter,
    SZColumnAlignmentSpacebtween,
};


@interface SZColumnBar : UIView
//关联的scrollview，可以是任意尺寸

//初始化
-(instancetype)initWithTitles:(NSArray *)titles relateScrollView:(UIScrollView*)scrollview delegate:(id<SZColumnBarDelegate>)delegate  originX:(CGFloat)oriX itemMargin:(CGFloat)interSpace txtColor:(UIColor*)color selTxtColor:(UIColor*)selcolor lineColor:(UIColor*)linecolor initialIndex:(NSInteger)idx;

//对齐方式
-(void)setAlignStyle:(SZColumnAlignment)style;

//设置颜色
-(void)setTxtColor:(UIColor*)color selectedColor:(UIColor*)selcolor lineColor:(UIColor*)linecolor;

//设置字体

//设置图片
-(void)setUnderlingImage:(NSString*)imgstr;

//设置间距

//设置badge
-(void)setBadgeStr:(NSString*)str atIndex:(NSInteger)idx;

//手动选中
-(void)selectIndex:(NSInteger)idx;

//debug
-(void)debugMode;

//渲染
-(void)refreshView;


@end

