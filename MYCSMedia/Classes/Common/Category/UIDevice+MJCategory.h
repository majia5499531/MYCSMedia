//
//  UIDevice+MJCategory.h
//  智慧长沙
//
//  Created by 马佳 on 2019/12/24.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface UIDevice (MJCategory)

//运营商名
+(NSString*)getMobileCarrier;

//强制转屏
+(void)MJSetInterfaceOrientation:(UIInterfaceOrientation)orientation;

//获取广告ID
+(NSString*)getIDFA;

//获取系统版本
+(NSString*)getSystemVersion;

@end
