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




-(NSString *)getToken
{
    return [self.delegate getAccessToken];
}



@end
