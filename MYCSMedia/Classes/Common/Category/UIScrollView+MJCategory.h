//
//  UIScrollView+MJCategory.h
//  区块链钱包
//
//  Created by 马佳 on 2018/7/23.
//  Copyright © 2018年 iBESTLOVE_HangZhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (MJCategory)

-(void)setNoContentInset;

-(void)MJAutoSetContentSize;
-(void)MJAutoSetContentSize_isPaging:(BOOL)pageEnable;
-(void)MJAutoSetContentSizeX:(CGFloat)offset Y:(CGFloat)offset;

@end
