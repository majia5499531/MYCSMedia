//
//  ColumnBar.h
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

@interface ColumnBar : UIView
@property(weak,nonatomic)id <NewsColumnDelegate> columnDelegate;

//先设置
-(void)setRelatedScrollView:(UIView*)scrollview;
-(void)setCenterAlignStyle;
-(void)setTopicTitles:(NSArray *)columnArr originX:(CGFloat)oriX minWidth:(CGFloat)minWidth itemMargin:(CGFloat)interSpace;



@end

