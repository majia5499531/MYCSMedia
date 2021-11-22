//
//  SZManager.m
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/28.
//

#import "SZManager.h"
#import <AFNetworking/AFNetworking.h>
#import "TokenExchangeModel.h"
#import "SZDefines.h"
#import "MJHud.h"
#import "SZUserTracker.h"

@implementation SZManager


+(SZManager *)sharedManager
{
    static SZManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil)
        {
            manager = [[SZManager alloc]init];
            [SZUserTracker shareTracker];
            
            [[AFNetworkReachabilityManager sharedManager]startMonitoring];
        }
        });
    return manager;
}



@end
