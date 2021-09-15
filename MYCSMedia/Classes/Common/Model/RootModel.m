//
//  RootModel.m
//  智慧长沙
//
//  Created by 马佳 on 2019/9/10.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import "RootModel.h"
#import "SZGlobalInfo.h"
#import <objc/message.h>
#import "NSDictionary+MJCategory.h"

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
    
    //HTTP请求输出
    if (json)
    {
        NSString * jsonstr = [params convertToJSON];
        NSLog(@"\n【HTTP请求】 \n Method = %@ \n URL = %@ \r param = \r%@ \n Header = \n%@",method,url,jsonstr,httpManager.requestSerializer.HTTPRequestHeaders);
    }
    else
    {
        NSLog(@"\n【HTTP请求】 \n Method = %@ \n URL = %@ \r param = \r%@ \n Header = \n%@",method,url,params,httpManager.requestSerializer.HTTPRequestHeaders);
    }
    
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
    else if ([method isEqualToString:@"POST"])
    {
        [httpManager POST:url parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    successblock(responseObject,task);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    failblock(error,task);
                }];
    }
    
    
    //DELETE
    else if ([method isEqualToString:@"DELETE"])
    {
        [httpManager DELETE:url parameters:params headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            successblock(responseObject,task);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    failblock(error,task);
                }];
    }
    
    
    //PUT
    else if ([method isEqualToString:@"PUT"])
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
    NSString * token = [SZGlobalInfo sharedManager].SZRMToken;
    if (token.length)
    {
        NSString * authTokenStr = [NSString stringWithFormat:@"%@",token];
        [httpManager.requestSerializer setValue:authTokenStr forHTTPHeaderField:@"token"];
    }
    else
    {
        [httpManager.requestSerializer setValue:nil forHTTPHeaderField:@"token"];
    }
    
    //关闭cookie
    NSHTTPCookie*cookie;

    NSHTTPCookieStorage*storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    for (cookie in[storage cookies])
    {
        if ([cookie.name isEqualToString:@"token"])
        {
            [storage deleteCookie:cookie];
        }
    }
    
    //AcceptType
    httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
}



#pragma mark - Model
+(instancetype)model
{
    return [[[self class]alloc]init];
}


#pragma mark - 序列化
//获取属性列表（字符串数组）
+(NSArray *)propertyOfSelf
{
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList(self, &count);
    NSMutableArray *properNames =[NSMutableArray array];
    for (int i = 0; i < count; i++)
    {
        Ivar ivar = ivarList[i];
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSString *key = [name substringFromIndex:1];
        
        [properNames addObject:key];
    }
    free(ivarList);
    return [properNames copy];
}

-(void)encodeWithCoder:(NSCoder *)enCoder
{
    NSArray *properNames = [[self class] propertyOfSelf];
    for (NSString *propertyName in properNames)
    {
        [enCoder encodeObject:[self valueForKey:propertyName] forKey:propertyName];
    }
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    NSArray *properNames = [[self class] propertyOfSelf];
    for (NSString *propertyName in properNames)
    {
        [self setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
    }
    return  self;
}

-(NSString *)description
{
    NSString * className = NSStringFromClass([self class]);
    NSMutableString *descriptionString = [NSMutableString stringWithFormat:@"\n打印 %@:\n",className];
    NSArray *properNames = [[self class] propertyOfSelf];
    for (NSString *propertyName in properNames)
    {
        NSString *propertyNameString = [NSString stringWithFormat:@"%@ - %@\n",propertyName,[self valueForKey:propertyName]];
        [descriptionString appendString:propertyNameString];
    }
    
    return [descriptionString copy];
}


@end
