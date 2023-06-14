//
//  MJToast.h
//  奶茶湾湾
//
//  Created by 马佳 on 2017/7/4.
//  Copyright © 2017年 HW_Tech. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^HUD_BLOCK)(id objc);

@interface MJHUD_Base : UIView

@property(strong,nonatomic)UIView * maskView;
@property(strong,nonatomic)UIView * contentView;
@property(strong,nonatomic)UIImageView * iconView;
@property(strong,nonatomic)UILabel * textView;

@property(strong,nonatomic)HUD_BLOCK sureBlock;
@property(strong,nonatomic)HUD_BLOCK cancelBlock;


-(void)hidding;


@end
