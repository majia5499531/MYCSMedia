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
#import "NSAttributedString+MJCategory.h"
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
    NSMutableAttributedString * str = [NSAttributedString makeDescStyleStr:text lineSpacing:4.5 indent:0];
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
    NSMutableAttributedString * str = [NSAttributedString makeDescStyleStr:text lineSpacing:4.5 indent:0];
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



+(void)showLoginAlert:(HUD_BLOCK)block
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
    hud.contentView.layer.cornerRadius=16;
    [hud.contentView setFrame:CGRectMake(hud.centerX-140, SCREEN_HEIGHT, 280, 500)];
    
    //title
    UILabel * titleLabel=[[UILabel alloc]init];
    [titleLabel setFrame:CGRectMake(0, 15, hud.contentView.width, 20)];
    titleLabel.font=BOLD_FONT(17);
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.textColor=HW_BLACK;
    titleLabel.text=@"提示";
    [hud.contentView addSubview:titleLabel];
     
    //text
    UILabel * descLabel = [[UILabel alloc]init];
    [descLabel setFrame:CGRectMake(40, titleLabel.bottom+15, hud.contentView.width-80, 20)];
    descLabel.font=FONT(13);
    descLabel.text = @"您还未登录，请立即登录";
    descLabel.textColor=HW_BLACK;
    descLabel.textAlignment=NSTextAlignmentCenter;
    [hud.contentView addSubview:descLabel];
    
    //lineH
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, descLabel.bottom+20, hud.contentView.width, MINIMUM_PX)];
    line1.backgroundColor=HW_GRAY_BORDER_2;
    [hud.contentView addSubview:line1];
     
    //cancelBtn
    MJButton * cancelBtn =[[MJButton alloc]initWithFrame:CGRectMake(0, line1.bottom, line1.width/2-0.5, 42)];
    [cancelBtn addTarget:hud action:@selector(hidding) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:HW_BLACK forState:UIControlStateNormal];
    cancelBtn.titleLabel.font=BOLD_FONT(14);
    [hud.contentView addSubview:cancelBtn];
    
    //line2
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(line1.centerX-0.5, line1.bottom, MINIMUM_PX, cancelBtn.height)];
    line2.backgroundColor=HW_GRAY_BORDER_2;
    [hud.contentView addSubview:line2];
    
    //sureBtn
    MJButton * sureBtn =[[MJButton alloc]initWithFrame:CGRectMake(cancelBtn.right+1, line1.bottom, cancelBtn.width, cancelBtn.height)];
    [sureBtn addTarget:hud action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitle:@"登录" forState:UIControlStateNormal];
    [sureBtn setTitleColor:HW_BLACK forState:UIControlStateNormal];
    sureBtn.titleLabel.font=BOLD_FONT(14);
    [hud.contentView addSubview:sureBtn];

    //contentview frame
    [hud.contentView setFrame:CGRectMake(hud.contentView.left, hud.contentView.top, hud.contentView.width, sureBtn.bottom)];
    [hud.contentView setCenterY:hud.centerY];
}


+(void)showAppRoutingAlert:(HUD_BLOCK)block
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
    hud.contentView.layer.cornerRadius=16;
    [hud.contentView setFrame:CGRectMake(hud.centerX-140, SCREEN_HEIGHT, 280, 500)];
    
    //text
    UILabel * descLabel = [[UILabel alloc]init];
    [descLabel setFrame:CGRectMake(20, 20, hud.contentView.width-40, 64)];
    descLabel.font=BOLD_FONT(17);
    descLabel.numberOfLines=2;
    descLabel.attributedText = [NSAttributedString makeTitleStr:@"同款音乐复制成功\n请前往\"剪映\"app进行编辑" lineSpacing:5 indent:0];
    descLabel.textColor=HW_BLACK;
    descLabel.textAlignment=NSTextAlignmentCenter;
    [hud.contentView addSubview:descLabel];
    
    //lineH
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, descLabel.bottom+15, hud.contentView.width, MINIMUM_PX)];
    line1.backgroundColor=HW_GRAY_BORDER_2;
    [hud.contentView addSubview:line1];
     
    //cancelBtn
    MJButton * cancelBtn =[[MJButton alloc]initWithFrame:CGRectMake(0, line1.bottom, line1.width/2-0.5, 42)];
    [cancelBtn addTarget:hud action:@selector(hidding) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:HW_BLACK forState:UIControlStateNormal];
    cancelBtn.titleLabel.font=BOLD_FONT(15);
    [hud.contentView addSubview:cancelBtn];
    
    //line2
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(line1.centerX-0.5, line1.bottom, MINIMUM_PX, cancelBtn.height)];
    line2.backgroundColor=HW_GRAY_BORDER_2;
    [hud.contentView addSubview:line2];
    
    //sureBtn
    MJButton * sureBtn =[[MJButton alloc]initWithFrame:CGRectMake(cancelBtn.right+1, line1.bottom, cancelBtn.width, cancelBtn.height)];
    [sureBtn addTarget:hud action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitle:@"立即前往" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor colorWithHexString:@"1C337A"] forState:UIControlStateNormal];
    sureBtn.titleLabel.font=BOLD_FONT(15);
    [hud.contentView addSubview:sureBtn];

    //contentview frame
    [hud.contentView setFrame:CGRectMake(hud.contentView.left, hud.contentView.top, hud.contentView.width, sureBtn.bottom)];
    [hud.contentView setCenterY:hud.centerY];
    
}

+(void)showUGCNoticeAlert:(HUD_BLOCK)sure cancel:(HUD_BLOCK)cancel
{
    //HUD
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
    hud.contentView.layer.cornerRadius=16;
    [hud.contentView setFrame:CGRectMake(27.5, SCREEN_HEIGHT, SCREEN_WIDTH-55, 500)];
    
    //title
    UILabel * titleLabel=[[UILabel alloc]init];
    [titleLabel setFrame:CGRectMake(0, 24, hud.contentView.width, 20)];
    titleLabel.font=BOLD_FONT(17);
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.textColor=HW_BLACK;
    titleLabel.text=@"内容合作协议";
    [hud.contentView addSubview:titleLabel];
     
    NSString * noticewords = @"1.第一条协议范围内,双方的关系确定为合作关系。为拓展市场更好地、更规范地服务消费者,根据公司的规划,甲方根据乙方的申请和对乙方的经营能力的审核,同意乙方加入公司的销售网络。.第二条订立本协议的目的在于确保甲、乙双方忠实地履行本协议规定的双方的职责和权利。乙方作为单独的企业法人或经营者进行经济活动。因此,他必须遵守对所有企业法人或经营者共同的法律要求,特别是有关资格的规则以及社会的、财务的商业合作协议因此,他必须遵守对所有企业法人或经营者共同的法律要求,特别是有关资格的规则以及社会的、财务的商业合作协合作协合作1.第一条协议范围内,双方的关系确定为合作关系。为拓展市场更好地、更规范地服务消费者,根据公司的规划,甲方根据乙方的申请和对乙方的经营能力的审核,同意乙方加入公司的销售网络。2.第二条订立本协议的目的在于确保甲、乙双方忠实地履行本协议规定的双方的职责和权利。乙方作为单独的企业法人或经营者进行经济活动。因此,他必须遵守对所有企业法人或经营者共同的法律要求,特别是有关资格的规则以及社会的、财务的商业合作协议因此,他必须遵守对所有企业法人或经营者共同的法律要求,特别是有关资格的规则以及社会的、财务的商业合作协合作协合作";
    
    //text
    UITextView * descview = [[UITextView alloc]init];
    descview.editable=NO;
    [descview setFrame:CGRectMake(27, titleLabel.bottom+12, hud.contentView.width-54, hud.contentView.width-40)];
    descview.font=FONT(13);
    descview.text = noticewords;
    descview.textColor=HW_GRAY_BG_6;
    [hud.contentView addSubview:descview];
    
    //lineH
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, descview.bottom+20, hud.contentView.width, MINIMUM_PX)];
    line1.backgroundColor=HW_GRAY_BORDER_3;
    [hud.contentView addSubview:line1];
     
    //cancelBtn
    MJButton * cancelBtn =[[MJButton alloc]initWithFrame:CGRectMake(0, line1.bottom, line1.width/2-0.5, 55)];
    [cancelBtn addTarget:hud action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:HW_BLACK forState:UIControlStateNormal];
    cancelBtn.titleLabel.font=FONT(17);
    [hud.contentView addSubview:cancelBtn];
    
    //line2
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(line1.centerX-0.5, line1.bottom, MINIMUM_PX, cancelBtn.height)];
    line2.backgroundColor=HW_GRAY_BORDER_3;
    [hud.contentView addSubview:line2];
    
    //sureBtn
    MJButton * sureBtn =[[MJButton alloc]initWithFrame:CGRectMake(cancelBtn.right+1, line1.bottom, cancelBtn.width, cancelBtn.height)];
    [sureBtn addTarget:hud action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor colorWithHexString:@"1C337A"] forState:UIControlStateNormal];
    sureBtn.titleLabel.font=FONT(17);
    [hud.contentView addSubview:sureBtn];

    //contentview frame
    [hud.contentView setFrame:CGRectMake(hud.contentView.left, hud.contentView.top, hud.contentView.width, sureBtn.bottom)];
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
