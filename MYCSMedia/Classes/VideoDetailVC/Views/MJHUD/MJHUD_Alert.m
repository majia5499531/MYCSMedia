//
//  MJHUD_Alert.m
//  智慧长沙
//
//  Created by 马佳 on 2019/10/22.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import "MJHUD_Alert.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "UIView+MJCategory.h"
#import <SDWebImage/SDWebImage.h>
#import "NSString+MJCategory.h"
#import "MJButton.h"

@implementation MJHUD_Alert

#pragma mark - Alert
+(void)showAlertViewWithTitle:(NSString *)title text:(NSString *)text sure:(HUD_BLOCK)block
{
    //HUD
    UIView * window = [UIApplication sharedApplication].keyWindow;
    MJHUD_Alert * hud = [[MJHUD_Alert alloc]initWithFrame:window.frame];
    [window addSubview:hud];
    
    //保存block
    hud.sureBlock = block;
    
    //Mask
    [hud.maskView setFrame:hud.bounds];
    hud.maskView.backgroundColor=[UIColor blackColor];
    hud.maskView.alpha=0.5;
     
    //BG
    hud.contentView.backgroundColor=[UIColor whiteColor];
    hud.contentView.layer.cornerRadius=10;
    [hud.contentView setFrame:CGRectMake(hud.centerX-140, SCREEN_HEIGHT, 280, 500)];
    
    //title
    UILabel * titleLabel=[[UILabel alloc]init];
    [titleLabel setFrame:CGRectMake(0, 20, hud.contentView.width, 17)];
    titleLabel.font=BOLD_FONT(16);
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.textColor=HW_BLACK;
    titleLabel.text=title;
    [hud.contentView addSubview:titleLabel];
     
    //text
    UITextView * descLabel = [[UITextView alloc]init];
    [descLabel setFrame:CGRectMake(40, titleLabel.bottom+15, hud.contentView.width-80, 20)];
    descLabel.font=FONT(12);
    NSMutableAttributedString * str = [NSString makeDescStyleStr:text lineSpacing:4.5 indent:0];
    descLabel.attributedText = str;
    descLabel.textColor=HW_BLACK;
    descLabel.textAlignment=NSTextAlignmentCenter;
    descLabel.editable=NO;
    [descLabel sizeToFit];
    if (descLabel.height>SCREEN_HEIGHT/2)
    {
        descLabel.height=SCREEN_HEIGHT/2;
    }
    [descLabel setCenter:CGPointMake(140, titleLabel.bottom+descLabel.height/2+18)];
    [hud.contentView addSubview:descLabel];
    
    //lineH
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, descLabel.bottom+20, hud.contentView.width, 0.5)];
    line1.backgroundColor=[UIColor lightGrayColor];
    [hud.contentView addSubview:line1];
    
    //sureBtn
    MJButton * sureBtn =[[MJButton alloc]initWithFrame:CGRectMake(0, line1.bottom, line1.width, 49)];
    [sureBtn addTarget:hud action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:HW_RED_WORD_1 forState:UIControlStateNormal];
    sureBtn.titleLabel.font=FONT(15);
    [hud.contentView addSubview:sureBtn];

    //contentview frame
    [hud.contentView setFrame:CGRectMake(hud.contentView.left, hud.contentView.top, hud.contentView.width, sureBtn.bottom)];
    [hud.contentView setCenterY:hud.centerY];
}

+ (void)showAlertViewWithTitle:(NSString *)title text:(NSString *)text cancel:(HUD_BLOCK)cancel sure:(HUD_BLOCK)sure
{
    //Hud
    UIView * window = [UIApplication sharedApplication].keyWindow;
    MJHUD_Alert * hud = [[MJHUD_Alert alloc]initWithFrame:window.frame];
    [window addSubview:hud];
    
    //保存block
    hud.sureBlock = sure;
    hud.cancelBlock = cancel;
     
    //Mask
    [hud.maskView setFrame:hud.bounds];
    hud.maskView.backgroundColor=[UIColor blackColor];
    hud.maskView.alpha=0.5;
     
    //BG
    hud.contentView.backgroundColor=[UIColor whiteColor];
    hud.contentView.layer.cornerRadius=10;
    [hud.contentView setFrame:CGRectMake(hud.centerX-140, SCREEN_HEIGHT, 280, 500)];
     

    //title
    UILabel * titleLabel=[[UILabel alloc]init];
    [titleLabel setFrame:CGRectMake(0, 30, hud.contentView.width, 19)];
    titleLabel.font=BOLD_FONT(18);
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.textColor=HW_BLACK;
    titleLabel.text=title;
    [hud.contentView addSubview:titleLabel];
     
    
    //text
    UILabel * descLabel = [[UILabel alloc]init];
    [descLabel setFrame:CGRectMake(0, 0, hud.contentView.width-80, 20)];
    descLabel.font=FONT(16);
    NSMutableAttributedString * str = [NSString makeDescStyleStr:text lineSpacing:4.5 indent:0];
    descLabel.attributedText=str;
    descLabel.textColor=HW_GRAY_WORD_1;
    descLabel.textAlignment=NSTextAlignmentCenter;
    descLabel.numberOfLines=0;
    [descLabel sizeToFit];
    [descLabel setCenter:CGPointMake(hud.contentView.width/2, titleLabel.bottom+28+descLabel.height/2)];
    [hud.contentView addSubview:descLabel];
     
    //lineH
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, descLabel.bottom+30, hud.contentView.width, 1)];
    line1.backgroundColor=HW_GRAY_BG_2;
    [hud.contentView addSubview:line1];
     
    //cancelBtn
    MJButton * cancelBtn =[[MJButton alloc]initWithFrame:CGRectMake(0, line1.bottom, line1.width/2-0.5, 56)];
    [cancelBtn addTarget:hud action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:HW_BLACK forState:UIControlStateNormal];
    cancelBtn.titleLabel.font=BOLD_FONT(18);
    [hud.contentView addSubview:cancelBtn];
    
    //line2
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(line1.centerX-0.5, line1.bottom, 1, cancelBtn.height)];
    line2.backgroundColor=HW_GRAY_BG_2;
    [hud.contentView addSubview:line2];
    
    //sureBtn
    MJButton * sureBtn =[[MJButton alloc]initWithFrame:CGRectMake(cancelBtn.right+1, line1.bottom, cancelBtn.width, cancelBtn.height)];
    [sureBtn addTarget:hud action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:HW_BLACK forState:UIControlStateNormal];
    sureBtn.titleLabel.font=BOLD_FONT(18);
    [hud.contentView addSubview:sureBtn];

    //contentview frame
    [hud.contentView setFrame:CGRectMake(hud.contentView.left, hud.contentView.top, hud.contentView.width, cancelBtn.bottom)];
    [hud.contentView setCenterY:hud.centerY];
}


+(void)hideAlertView
{
    UIView * window = [UIApplication sharedApplication].keyWindow;
    for (UIView * v in window.subviews)
    {
        if ([v isKindOfClass:[MJHUD_Alert class]])
        {
            MJHUD_Alert * hud = (MJHUD_Alert*)v;
            [hud removeFromSuperview];
        }
    }
}



#pragma mark - Common Btn Actions
-(void)sureBtnAction
{
    if (self.sureBlock)
    {
        self.sureBlock(nil);
    }
}

-(void)cancelBtnAction
{
    if (self.cancelBlock)
    {
        self.cancelBlock(nil);
    }
}

@end
