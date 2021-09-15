//
//  RootModel.h
//  智慧长沙
//
//  Created by 马佳 on 2019/9/10.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AFNetworking.h"


typedef void (^MJHTTPSuccessBlock)(id responseObject , NSURLSessionDataTask * task);
typedef void (^MJHTTPErrorBlock)(id responseObject , NSURLSessionDataTask * task);
typedef void (^MJHTTPFailBlock)(id responseObject , NSURLSessionDataTask * task);


typedef void (^SuccessBlock)(id responseObject);
typedef void (^ErrorBlock)(id responseObject);
typedef void (^FailBlock)(NSError * error);
typedef void (^ProgressBlock)(NSProgress * progress);


@interface RootModel : NSObject <NSCoding>


+(instancetype)model;
-(void)RequestWithUrl:(NSString *)url method:(NSString*)method isJSON:(BOOL)json params:(NSDictionary *)params success:(MJHTTPSuccessBlock)successblock fail:(MJHTTPFailBlock)failblock;


@end

