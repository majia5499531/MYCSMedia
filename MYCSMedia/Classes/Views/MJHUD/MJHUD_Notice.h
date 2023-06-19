//
//  MJHUD_Notice.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/2.
//

#import "MJHUD_Base.h"

NS_ASSUME_NONNULL_BEGIN

@interface MJHUD_Notice : MJHUD_Base
//成功
+(void)showSuccessView:(NSString*)words inView:(UIView*)view hideAfterDelay:(NSTimeInterval)time;

//提示
+(void)showNoticeView:(NSString *)words inView:(UIView *)view hideAfterDelay:(NSTimeInterval)time;
+(void)showNoticeView:(NSString *)words inView:(UIView *)view hideAfterDelay:(NSTimeInterval)time offSetY:(CGFloat)offset;

@end

NS_ASSUME_NONNULL_END
