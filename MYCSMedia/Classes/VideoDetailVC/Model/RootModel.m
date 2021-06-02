//
//  RootModel.m
//  智慧长沙
//
//  Created by 马佳 on 2019/9/10.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import "RootModel.h"
#import "NSObject+MJCategory.h"
#import "SZManager.h"
#import "UIDevice+MJCategory.h"

@implementation RootModel

#pragma mark - 请求
-(void)RequestWithUrl:(NSString *)url method:(NSString*)method isJSON:(BOOL)json params:(NSDictionary *)params success:(MJHTTPSuccessBlock)successblock fail:(MJHTTPFailBlock)failblock
{
    static AFHTTPSessionManager * httpManager;
    if (httpManager==nil)
    {
        httpManager = [AFHTTPSessionManager manager];
    }
    
    //JSON
    if (json)
    {
        httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    else
    {
        httpManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    
    //配置
    [self configAFNetWorking:httpManager];
    
    NSLog(@"\n【HTTP请求】 \n %@ method \n URL = %@ \r param = \r%@ \n Header = \n%@",method,url,params,httpManager.requestSerializer.HTTPRequestHeaders);
    
    //GET
    if ([method isEqualToString:@"GET"])
    {
        [httpManager GET:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    successblock(responseObject,task);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    failblock(error,task);
                }];
        
    }
    
    
    //POST
    if ([method isEqualToString:@"POST"])
    {
        [httpManager POST:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    successblock(responseObject,task);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    failblock(error,task);
                }];
        
    }
    
    
    //DELETE
    if ([method isEqualToString:@"DELETE"])
    {
        [httpManager DELETE:url parameters:params headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            successblock(responseObject,task);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    failblock(error,task);
                }];
    }
    
    
    //PUT
    if ([method isEqualToString:@"PUT"])
    {
        
        [httpManager PUT:url parameters:params headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    successblock(responseObject,task);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    failblock(error,task);
                }];
        
    }
}



#pragma mark - 配置AF
-(void)configAFNetWorking:(AFHTTPSessionManager*)httpManager
{
    //超时
    [httpManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    httpManager.requestSerializer.timeoutInterval = 7.f;
    [httpManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    //加token到请求头
    NSString * token = [SZManager sharedManager].getToken;
    if (token.length)
    {
        NSString * authTokenStr = [NSString stringWithFormat:@"Bearer %@",token];
        [httpManager.requestSerializer setValue:authTokenStr forHTTPHeaderField:@"authorization"];
    }
    else
    {
        [httpManager.requestSerializer setValue:nil forHTTPHeaderField:@"authorization"];
    }
    
    //加设备号
    NSString * deviceID = [UIDevice getIDFA];
    [httpManager.requestSerializer setValue:deviceID forHTTPHeaderField:@"deviceId"];
    
    //acceptType
    httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
}



#pragma mark - Model
+(instancetype)model
{
    return [[[self class]alloc]init];
}


#pragma mark - 序列化
-(void)encodeWithCoder:(NSCoder *)coder
{
    [self MJ_encode:coder];
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super init])
    {
        [self MJ_decode:coder];
    }
    return self;
}

@end
