//
//  MJHUD_Notice.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/2.
//

#import "MJHUD_Notice.h"
#import "UIView+MJCategory.h"
#import "UIImage+MJCategory.h"

@implementation MJHUD_Notice

+(void)showSuccessView:(NSString *)words inView:(UIView *)view hideAfterDelay:(NSTimeInterval)time
{
    //Hud
    MJHUD_Notice * hud = [[MJHUD_Notice alloc]initWithFrame:view.bounds];
    [view addSubview:hud];
    
    //Mask
    [hud.maskView setFrame:hud.bounds];
    hud.maskView.alpha=0;
    
    //BG
    hud.contentView.backgroundColor=[UIColor blackColor];
    [hud.contentView MJSetIndividualAlpha:0.5];
    hud.contentView.layer.cornerRadius=7;
    [hud.contentView setSize:CGSizeMake(140, 140)];
    [hud.contentView setCenter:CGPointMake(view.width/2, view.height/2)];
    
    //Icon
    [hud.iconView setFrame:CGRectMake(0, 33, hud.contentView.width, 44)];
    hud.iconView.contentMode=UIViewContentModeScaleAspectFit;
    hud.iconView.image=[UIImage getBundleImage:@"toast_success"];
    
    //Words
    [hud.textView setFrame:CGRectMake(10, hud.iconView.bottom+21, hud.contentView.width-20, 40)];
    hud.textView.textColor=[UIColor whiteColor];
    hud.textView.numberOfLines=0;
    hud.textView.font=[UIFont systemFontOfSize:15];
    hud.textView.textAlignment=NSTextAlignmentCenter;
    hud.textView.text=words;
    [hud.textView sizeToFit];
    [hud.textView setCenterX:hud.contentView.width/2];
    
    //resize
    CGFloat newHeight = hud.textView.bottom+20;
    if (newHeight>hud.contentView.height)
    {
        [hud.contentView setSize:CGSizeMake(hud.contentView.width, hud.textView.bottom+20)];
        [hud.contentView setCenter:CGPointMake(view.width/2, view.height/2)];
    }
    
    //Dismiss Time
    if (time==0)
    {
        time=1.5;
    }
    [hud performSelector:@selector(removeFromSuperview) withObject:0 afterDelay:time];
}

+(void)showNoticeView:(NSString *)words inView:(UIView *)view hideAfterDelay:(NSTimeInterval)time
{
    [MJHUD_Notice showNoticeView:words inView:view hideAfterDelay:time offSetY:0];
}

+(void)showNoticeView:(NSString *)words inView:(UIView *)view hideAfterDelay:(NSTimeInterval)time offSetY:(CGFloat)offset
{
    if (words.length==0)
    {
        return;
    }
    
    //Hud
    MJHUD_Notice * hud = [[MJHUD_Notice alloc]initWithFrame:view.bounds];
    [view addSubview:hud];

    //Mask
    [hud.maskView setFrame:hud.bounds];
    hud.maskView.backgroundColor=[UIColor clearColor];
    hud.maskView.alpha=0;

    //content
    [hud.contentView setFrame:CGRectMake(0, 0, 100, 100)];
    hud.contentView.backgroundColor=[UIColor blackColor];
    hud.contentView.alpha=0.65;
    hud.contentView.layer.cornerRadius=6;
    
    //text
    UILabel * label=[[UILabel alloc]init];
    [label setFrame:CGRectMake(0, 0, hud.width, 40)];
    label.text=words;
    label.numberOfLines=0;
    label.textColor=[UIColor whiteColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.font=[UIFont systemFontOfSize:17];
    [label sizeToFit];
    [hud addSubview:label];
    
    //updateFrame
    [hud.contentView setWidth:label.width+40];
    [hud.contentView setHeight:label.height+20];
    [hud.contentView setCenterX:hud.centerX];
    [hud.contentView setCenterY:hud.centerY+offset];
    
    //label
    [label setCenter:hud.contentView.center];
    
    //dismiss
    [hud performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:time];
}


@end
