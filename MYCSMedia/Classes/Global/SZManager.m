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
#import "SZData.h"

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



+(void)requestCategoryData:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock
{
    [[SZData sharedSZData]requestCategoryData:param Success:successblock Error:errorblock Fail:failblock];
}

+(void)requestContentData:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock
{
    [[SZData sharedSZData]requestContentData:param Success:successblock Error:errorblock Fail:failblock];
}
+(void)requestMoreContentData:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock
{
    [[SZData sharedSZData]requestMoreContentData:param Success:successblock Error:errorblock Fail:failblock];
}
+(void)requestHomepageVideo:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock
{
    [[SZData sharedSZData]requestHomepageVideo:param Success:successblock Error:errorblock Fail:failblock];
}
+(void)requestHomepageNews:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock
{
    [[SZData sharedSZData]requestHomepageNews:param Success:successblock Error:errorblock Fail:failblock];
}


+(void)requestHaikaList:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;
{
    [[SZData sharedSZData]requestHaikaList:param Success:successblock Error:errorblock Fail:failblock];
}

+(void)requestHaikaCode:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;
{
    [[SZData sharedSZData]requestHaikaCode:param Success:successblock Error:errorblock Fail:failblock];
}


@end
