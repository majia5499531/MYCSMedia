//
//  SZManager.m
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/28.
//

#import "SZManager.h"
#import <AFNetworking/AFNetworking.h>

@implementation SZManager

+ (SZManager *)sharedManager
{
    static SZManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil)
        {
            manager = [[SZManager alloc]init];

            [[AFNetworkReachabilityManager sharedManager]startMonitoring];
        }
        });
    return manager;
}






+(BOOL)mjgetLoginStatus
{
    return [SZManager sharedManager].SZRMToken.length;
}
+(NSString*)mjgetBaseSysURL
{
    SZManager * instance = [SZManager sharedManager];
    if (instance.enviroment==UAT_ENVIROMENT)
    {
        return @"https://uat-fuse-system.zhcs.csbtv.com";
    }
    else
    {
        return @"https://fuse-system.zhcs.csbtv.com";
    }
}
+(NSString *)mjgetBaseURL
{
    SZManager * instance = [SZManager sharedManager];
    if (instance.enviroment==UAT_ENVIROMENT)
    {
        return @"https://uat-fuse-cms.zhcs.csbtv.com";
    }
    else
    {
        return @"https://fuse-cms.zhcs.csbtv.com";
    }
}
+(void)mjgoToLoginPage
{
    [[SZManager sharedManager].delegate onLoginAction];
}


@end
