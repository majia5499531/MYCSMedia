//
//  MJHUD_Alert.h
//  智慧长沙
//
//  Created by 马佳 on 2019/10/22.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import "MJHUD_Base.h"

NS_ASSUME_NONNULL_BEGIN

@interface MJHUD_Alert : MJHUD_Base

//Alert
+(void)showLoginAlert:(HUD_BLOCK)block;
+(void)showAlertViewWithTitle:(NSString *)title text:(NSString *)text sure:(HUD_BLOCK)block;
+(void)showAlertViewWithTitle:(NSString*)title text:(NSString*)text cancel:(HUD_BLOCK)cancel sure:(HUD_BLOCK)sure;
+(void)showAppRoutingAlert:(HUD_BLOCK)block;
+(void)hideAlertView;


@end

NS_ASSUME_NONNULL_END
