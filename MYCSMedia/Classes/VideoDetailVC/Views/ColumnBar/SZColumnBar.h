//
//  SZColumnBar.h
//  智慧长沙
//
//  Created by 马佳 on 2019/9/11.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewsColumnDelegate <NSObject>
-(void)mjview:(UIView*)view didSelectColumn:(id)model collectionviewIndex:(NSInteger)index;
@optional

@end

@interface SZColumnBar : UIView
@property(weak,nonatomic)id <NewsColumnDelegate> columnDelegate;

//先设置
-(void)setCenterAlignStyle;
-(void)setTopicTitles:(NSArray *)columnArr relateScrollView:(UIScrollView*)scroll originX:(CGFloat)oriX minWidth:(CGFloat)minWidth itemMargin:(CGFloat)interSpace initialIndex:(NSInteger)idx;
-(void)setBadgeStr:(NSString*)str atIndex:(NSInteger)idx;
-(void)selectIndex:(NSInteger)idx;

@end

