//
//  MJHUD_Loading.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/2.
//

#import "MJHUD_BASE.h"

NS_ASSUME_NONNULL_BEGIN

@interface MJHUD_Loading : MJHUD_BASE

+(void)showMiniLoading:(UIView*)view;
+(void)showLoadingView:(UIView*)view;
+(void)showMiniLoadingView:(UIView*)view hideAfterDelay:(NSInteger)secd;
+(void)hideLoadingView:(UIView*)view;

@end

NS_ASSUME_NONNULL_END
