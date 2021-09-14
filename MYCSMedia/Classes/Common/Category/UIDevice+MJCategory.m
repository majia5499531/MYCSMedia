//
//  UIDevice+MJCategory.m
//  智慧长沙
//
//  Created by 马佳 on 2019/12/24.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import "UIDevice+MJCategory.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AdSupport/AdSupport.h>

@implementation UIDevice (MJCategory)

//获取运营商类型
+(NSString*)getMobileCarrier
{
  CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
  CTCarrier *carrier = [telephonyInfo subscriberCellularProvider];
 
  NSString * currentCountryCode = [carrier mobileCountryCode];
  NSString * mobileNetWorkCode = [carrier mobileNetworkCode];
  
  if (!currentCountryCode.length)
  {
     return @"无运营商";
  }
    
  else if (![currentCountryCode isEqualToString:@"460"])
  {
     return @"其他";
  }
  
  else if ([mobileNetWorkCode isEqualToString:@"00"] ||
    [mobileNetWorkCode isEqualToString:@"02"] ||
    [mobileNetWorkCode isEqualToString:@"07"])
  {
     return @"中国移动";
  }
 
  else if ([mobileNetWorkCode isEqualToString:@"01"] ||
    [mobileNetWorkCode isEqualToString:@"06"] ||
    [mobileNetWorkCode isEqualToString:@"09"])
  {
     return @"中国联通";
  }
 
  else if ([mobileNetWorkCode isEqualToString:@"03"] ||
    [mobileNetWorkCode isEqualToString:@"05"] ||
    [mobileNetWorkCode isEqualToString:@"11"])
  {
     return @"中国电信";
  }
 
  else if ([mobileNetWorkCode isEqualToString:@"20"])
  {
    return @"中国铁通";
  }
 
  return @"未知运营商";
}


//强制转屏
+(void)MJSetInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
    {
        SEL selector  = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        UIInterfaceOrientation val = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}


#pragma mark - 设备信息
+(NSString*)getIDFA
{
    //用户允许广告追踪
    BOOL enable = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    if (enable)
    {
        NSString * IDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        return IDFA;
    }

    //应用内ID
    else
    {
        NSString * IDFV = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        return IDFV;
    }
}

+(NSString*)getSystemVersion
{
    NSString * systemVersion = [UIDevice currentDevice].systemVersion;
    return systemVersion;
}



@end
