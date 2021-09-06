//
//  MJHUD_Selection.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/2.
//

#import "MJHUD_Selection.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "UIView+MJCategory.h"
#import <SDWebImage/SDWebImage.h>
#import "NSString+MJCategory.h"
#import "MJButton.h"
#import "UIImage+MJCategory.h"


@implementation MJHUD_Selection

+(void)showEpisodeSelectionView:(UIView*)view currenIdx:(NSInteger)idx episode:(NSInteger)count clickAction:(HUD_BLOCK)block
{
    //Hud
    UIView * window = [UIApplication sharedApplication].keyWindow;
    MJHUD_Selection * hud = [[MJHUD_Selection alloc]initWithFrame:window.frame];
    [window addSubview:hud];
    
    //保存block
    hud.sureBlock = block;
    
    //Mask
    [hud.maskView setFrame:hud.bounds];
    hud.maskView.backgroundColor=[UIColor blackColor];
    hud.maskView.alpha=0.5;
    
    //scroll
    UIScrollView * scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-30, 160)];
    scroll.backgroundColor=HW_GRAY_BG_4;
    scroll.layer.cornerRadius=5;
    [hud addSubview:scroll];
    
    
    
    if (count<=6)
    {
        [scroll setHeight:130];
    }
    else if (count<=12)
    {
        [scroll setHeight:170];
    }
    else if (count<=18)
    {
        [scroll setHeight:220];
    }
    else if(count<=24)
    {
        [scroll setHeight:270];
    }
    else
    {
        [scroll setHeight:320];
    }
    
    
    CGFloat btnWidth = 30;
    CGFloat marginW = 15;
    CGFloat paddingX = (scroll.width - 5*marginW - 6*btnWidth)/2;
    CGFloat paddingY = 48;
    
    for (int i = 0; i<count; i++)
    {
        MJButton * btn = [[MJButton alloc]initWithFrame:CGRectMake(paddingX + (btnWidth+marginW)*(i%6), paddingY + (btnWidth+marginW)*(i/6), btnWidth, btnWidth)];
        btn.mj_text=[NSString stringWithFormat:@"%d",i+1];
        btn.mj_textColor=HW_WHITE;
        btn.mj_textColor_sel=HW_BLACK;
        btn.mj_bgColor=HW_CLEAR;
        btn.mj_bgColor_sel=HW_WHITE;
        btn.mj_borderColor=HW_WHITE;
        btn.layer.cornerRadius=4;
        btn.tag=i;
        [btn addTarget:hud action:@selector(episodBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.borderWidth=1;
        btn.mj_font=FONT(17);
        [scroll addSubview:btn];
        
        //设置选中
        if (idx >= 0)
        {
            if (idx == i)
            {
                btn.MJSelectState=YES;
            }
        }
    }
    CGFloat bottomY = [scroll getBottomY];
    
    [scroll setContentSize:CGSizeMake(scroll.width, bottomY+paddingY)];

    [scroll setCenter:hud.center];
    
    //close
    MJButton * closebtn = [[MJButton alloc]init];
    [closebtn setFrame:CGRectMake(scroll.right-31, scroll.top + 16.5, 15.5, 15.5)];
    closebtn.ScaleUpBounce=YES;
    closebtn.ScaleUpSize=CGSizeMake(30, 30);
    [closebtn addTarget:hud action:@selector(hidding) forControlEvents:UIControlEventTouchUpInside];
    closebtn.mj_imageObjec = [UIImage getBundleImage:@"sz_episode_close"];
    [hud addSubview:closebtn];
    
}




+(void)showShareView:(HUD_BLOCK)reslt;
{
    //Hud
    UIView * window = [UIApplication sharedApplication].keyWindow;
    MJHUD_Selection * hud = [[MJHUD_Selection alloc]initWithFrame:window.frame];
    [window addSubview:hud];
    
    hud.sureBlock = reslt;
    
    //Mask
    [hud.maskView setFrame:hud.bounds];
    hud.maskView.backgroundColor=[UIColor clearColor];
    
    //touch
    CGFloat height = 160+BOTTOM_SAFEAREA_HEIGHT;
    UIView * touchview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH , SCREEN_HEIGHT-height)];
    touchview.backgroundColor=[UIColor clearColor];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:hud action:@selector(hidding)];
    [touchview addGestureRecognizer:tap];
    [hud addSubview:touchview];
    
    //contentBG
    [hud.contentView setFrame:CGRectMake(0, touchview.bottom, SCREEN_WIDTH, height)];
    hud.contentView.backgroundColor=HW_GRAY_BG_2;
    hud.alpha=1;
    [hud.contentView MJSetPartRadius:16 RoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight];
    
    //title
    UILabel * titleLabel=[[UILabel alloc]init];
    [titleLabel setFrame:CGRectMake(15, 15, 100, 20)];
    titleLabel.text=@"分享到";
    titleLabel.textColor=HW_WHITE;
    titleLabel.alpha=0.7;
    titleLabel.font=FONT(14);
    [hud.contentView addSubview:titleLabel];
    
    //closeBtn
    MJButton * close = [[MJButton alloc]init];
    [close setFrame:CGRectMake(SCREEN_WIDTH-35, titleLabel.top-5, 30, 30)];
    close.mj_imageObjec = [UIImage getBundleImage:@"notice_close"];
    close.imageFrame=CGRectMake(9 , 7, 9, 9 );
    [close addTarget:hud action:@selector(hidding) forControlEvents:UIControlEventTouchUpInside];
    [hud.contentView addSubview:close];
    
    //wecaht
    MJButton * wechatBtn = [[MJButton alloc]initWithFrame:CGRectMake(0, 53, 50, 50)];
    [wechatBtn setImage:[UIImage getBundleImage:@"sz_share_wechat"] forState:UIControlStateNormal];
    wechatBtn.tag=0;
    [hud.contentView addSubview:wechatBtn];
    [wechatBtn setCenterX:SCREEN_WIDTH/4];
    
    //wechatLabel
    UILabel * wechatLabel=[[UILabel alloc]init];
    [wechatLabel setFrame:CGRectMake(0, 0, 55, 20)];
    wechatLabel.text=@"微信";
    wechatLabel.textColor=HW_WHITE;
    wechatLabel.alpha=0.7;
    wechatLabel.font=FONT(13);
    wechatLabel.textAlignment=NSTextAlignmentCenter;
    [hud.contentView addSubview:wechatLabel];
    [wechatLabel setCenterX:wechatBtn.centerX];
    [wechatLabel setCenterY:wechatBtn.bottom+25];
    
    //timeline
    MJButton * timelineBtn = [[MJButton alloc]initWithFrame:CGRectMake(0, 53, 50, 50)];
    [timelineBtn setImage:[UIImage getBundleImage:@"sz_share_timeline"] forState:UIControlStateNormal];
    timelineBtn.tag=1;
    [hud.contentView addSubview:timelineBtn];
    [timelineBtn setCenterX:SCREEN_WIDTH/2];
    
    //wechatLabel
    UILabel * timeLineLabel=[[UILabel alloc]init];
    [timeLineLabel setFrame:CGRectMake(0, 0, 55, 20)];
    timeLineLabel.text=@"朋友圈";
    timeLineLabel.textColor=HW_WHITE;
    timeLineLabel.alpha=0.7;
    timeLineLabel.font=FONT(13);
    timeLineLabel.textAlignment=NSTextAlignmentCenter;
    [hud.contentView addSubview:timeLineLabel];
    [timeLineLabel setCenterX:timelineBtn.centerX];
    [timeLineLabel setCenterY:timelineBtn.bottom+25];
    
    //qq
    MJButton * qqBtn = [[MJButton alloc]initWithFrame:CGRectMake(0, 53, 50, 50)];
    [qqBtn setImage:[UIImage getBundleImage:@"sz_share_qq"] forState:UIControlStateNormal];
    qqBtn.tag=2;
    [hud.contentView addSubview:qqBtn];
    [qqBtn setCenterX:SCREEN_WIDTH*3/4];
    
    //wechatLabel
    UILabel * qqlabel=[[UILabel alloc]init];
    [qqlabel setFrame:CGRectMake(0, 0, 55, 20)];
    qqlabel.text=@"QQ";
    qqlabel.textColor=HW_WHITE;
    qqlabel.alpha=0.7;
    qqlabel.font=FONT(13);
    qqlabel.textAlignment=NSTextAlignmentCenter;
    [hud.contentView addSubview:qqlabel];
    [qqlabel setCenterX:qqBtn.centerX];
    [qqlabel setCenterY:qqBtn.bottom+25];
    
    [timelineBtn addTarget:hud action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [wechatBtn addTarget:hud action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [qqBtn addTarget:hud action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    
}




//上传作品
+(void)showUploadingHudAt:(UIView*)view block1:(HUD_BLOCK)block1 block2:(HUD_BLOCK)block2;
{
    //Hud
    UIView * window = [UIApplication sharedApplication].keyWindow;
    MJHUD_Selection * hud = [[MJHUD_Selection alloc]initWithFrame:window.frame];
    [window addSubview:hud];
    
    hud.sureBlock = block1;
    hud.cancelBlock = block2;
    
    //Mask
    [hud.maskView setFrame:hud.bounds];
    hud.maskView.backgroundColor=[UIColor clearColor];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:hud action:@selector(hidding)];
    [hud.maskView addGestureRecognizer:tap];
    
    //bg
    UIImageView * imageBG = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 160, 111)];
    imageBG.userInteractionEnabled = YES;
    imageBG.image = [UIImage getBundleImage:@"sz_selectionBG"];
    [hud addSubview:imageBG];
    CGPoint point = [view convertPoint:CGPointMake(0,0) toView:view.window];
    
    [imageBG setOrigin:CGPointMake(point.x-117, point.y-110)];
    
    
    //btn1
    MJButton * btn1 = [[MJButton alloc]initWithFrame:CGRectMake(0, 5, imageBG.width, imageBG.height/2-13)];
    btn1.imageFrame=CGRectMake(15, 10, 22, 22);
    btn1.mj_imageObjec = [UIImage getBundleImage:@"sz_hud_copy"];
    btn1.titleFrame=CGRectMake(48, 10, 100, 22);
    btn1.mj_text=@"复制同款音乐";
    btn1.mj_font=FONT(16);
    btn1.mj_textColor=HW_BLACK;
    [btn1 addTarget:hud action:@selector(copyMusicBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [imageBG addSubview:btn1];
    
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, btn1.bottom+4.5, imageBG.width, MINIMUM_PX)];
    line.backgroundColor=HW_GRAY_BORDER;
    [imageBG addSubview:line];
    
    //btn2
    MJButton * btn2 = [[MJButton alloc]initWithFrame:CGRectMake(0, line.bottom+ 5, imageBG.width, btn1.height)];
    btn2.imageFrame=CGRectMake(15, 10, 22, 22);
    btn2.mj_imageObjec = [UIImage getBundleImage:@"sz_hud_upload"];
    btn2.titleFrame=CGRectMake(48, 10, 100, 22);
    btn2.mj_text=@"上传作品";
    btn2.mj_font=FONT(16);
    btn2.mj_textColor=HW_BLACK;
    [btn2 addTarget:hud action:@selector(uploadBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [imageBG addSubview:btn2];
}


#pragma mark - Btn Action
-(void)episodBtnAction:(MJButton*)btn
{
    self.sureBlock([NSNumber numberWithInteger:btn.tag]);
    
    [self hidding];
}

-(void)shareAction:(MJButton*)sender
{
    NSNumber * num = [NSNumber numberWithInteger:sender.tag];
    self.sureBlock(num);
    [self hidding];
}





-(void)copyMusicBtnAction
{
    self.sureBlock(nil);
    
    [self hidding];
}


-(void)uploadBtnAction
{
    self.cancelBlock(nil);
    
    [self hidding];
}


@end
