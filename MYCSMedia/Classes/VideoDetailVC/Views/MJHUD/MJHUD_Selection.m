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

+(void)showEpisodeSelectionView:(UIView*)view episode:(NSInteger)count clickAction:(HUD_BLOCK)block
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
        btn.mj_borderColor=HW_WHITE;
        btn.layer.cornerRadius=4;
        btn.tag=i;
        [btn addTarget:hud action:@selector(episodBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.borderWidth=1;
        btn.mj_font=FONT(17);
        [scroll addSubview:btn];
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



#pragma mark - Btn Action
-(void)episodBtnAction:(MJButton*)btn
{
    self.sureBlock([NSNumber numberWithInteger:btn.tag]);
    
    [self hidding];
}



@end
