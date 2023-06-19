//
//  MJHUD_Loading.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/2.
//

#import "MJHUD_Loading.h"
#import "SZDefines.h"
#import <SDWebImage/SDWebImage.h>
#import <UIView+MJCategory.h>
#import "UIImage+MJCategory.h"
#import "UIColor+MJCategory.h"

#define kDISPATCH_MAIN_THREAD(mainQueueBlock)       dispatch_async(dispatch_get_main_queue(),mainQueueBlock);

@implementation MJHUD_Loading


+(void)showMiniLoading:(UIView*)view
{
    [MJHUD_Loading showLoadingViewInMainQueueOnView:view words:@"" gifName:@"tinyLoading.gif" size:CGSizeMake(40, 40) hideDelay:0];
}

+(void)showLoadingView:(UIView *)view
{
    [MJHUD_Loading showLoadingViewInMainQueueOnView:view words:@"" gifName:@"normalLoading.gif" size:CGSizeMake(120, 120) hideDelay:0];
}

+(void)showMiniLoadingView:(UIView*)view hideAfterDelay:(NSInteger)secd;
{
    [MJHUD_Loading showLoadingViewInMainQueueOnView:view words:@"" gifName:@"tinyLoading.gif" size:CGSizeMake(40, 40) hideDelay:secd];
}

+(void)showLoadingViewInMainQueueOnView:(UIView*)view words:(NSString*)words gifName:(NSString*)gifName size:(CGSize)imageSize hideDelay:(NSInteger)delay
{
    kDISPATCH_MAIN_THREAD(^{
        //Hud
        MJHUD_Loading * hud = [[MJHUD_Loading alloc]initWithFrame:view.bounds];
        [view addSubview:hud];
        
        //Mask
        [hud.maskView setFrame:hud.bounds];
        hud.maskView.alpha=0;
        
        //BG
        hud.contentView.backgroundColor=[UIColor clearColor];
        hud.contentView.layer.cornerRadius=7;
        hud.contentView.backgroundColor=HW_GRAY_BG_3;
        [hud.contentView setSize:CGSizeMake(imageSize.width*1.7, imageSize.height*1.7)];
        [hud.contentView setCenter:hud.center];
        
        //Icon
        [hud.iconView setFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
        [hud.iconView setCenterX:hud.contentView.width/2];
        [hud.iconView setCenterY:hud.contentView.height/2];
        hud.iconView.contentMode=UIViewContentModeScaleAspectFit;
        NSURL * imgURL = [UIImage getBundleImageURL:gifName];
        [hud.iconView sd_setImageWithURL:imgURL];
        hud.iconView.layer.masksToBounds=YES;
        
        if (delay>0)
        {
            [hud performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:delay];
        }
    })
}




+(void)hideLoadingView:(UIView *)view
{
    kDISPATCH_MAIN_THREAD(^{
        for (UIView * subview in view.subviews)
        {
            if ([subview isKindOfClass:[MJHUD_Loading class]])
            {
                MJHUD_Loading * hud=(MJHUD_Loading*)subview;
                    
                [hud StopAnimation:hud.iconView];
                [hud removeFromSuperview];
                    
            }
            
        }
        
    });
}


#pragma mark - Animation
-(void)startRotationWithBtn:(UIView*)sender
{
    CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue =  [NSNumber numberWithFloat: M_PI * 2];
    animation.duration  = 1.5;
    animation.autoreverses = NO;
    animation.fillMode =kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT;
    [sender.layer addAnimation:animation forKey:nil];
}
-(void)StopAnimation:(UIView*)sender
{
    [sender.layer removeAllAnimations];
}

@end
