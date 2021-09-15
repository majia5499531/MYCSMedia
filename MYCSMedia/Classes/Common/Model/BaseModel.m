//
//  BaseModel.m
//  喜鹊红包
//
//  Created by 马佳 on 2018/5/15.
//  Copyright © 2018年 HW_Tech. All rights reserved.
//

#import "BaseModel.h"
#import "MJHUD.h"
#import "NSObject+MJCategory.h"
#import "SZGlobalInfo.h"
#import "YYModel.h"

@implementation BaseModel

//GET
-(void)GETRequestInView:(UIView*)view WithUrl:(NSString *)url Params:(NSDictionary *)params Success:(SuccessBlock)successblock Error:(ErrorBlock)errorblock Fail:(FailBlock)failblock
{
    [self request:@"GET" view:view WithUrl:url Params:params Success:successblock Error:errorblock Fail:failblock];
}

//POST
-(void)PostRequestInView:(UIView*)view WithUrl:(NSString *)url Params:(NSDictionary *)params Success:(SuccessBlock)successblock Error:(ErrorBlock)errorblock Fail:(FailBlock)failblock
{
    [self request:@"POST" view:view WithUrl:url Params:params Success:successblock Error:errorblock Fail:failblock];
    
}

//DELETE
-(void)DeleteRequestInView:(UIView*)view WithUrl:(NSString *)url Params:(NSDictionary *)params Success:(SuccessBlock)successblock Error:(ErrorBlock)errorblock Fail:(FailBlock)failblock
{
    [self request:@"DELETE" view:view WithUrl:url Params:params Success:successblock Error:errorblock Fail:failblock];
}

//PUT
-(void)PutRequestInView:(UIView*)view WithUrl:(NSString *)url Params:(NSDictionary *)params Success:(SuccessBlock)successblock Error:(ErrorBlock)errorblock Fail:(FailBlock)failblock
{
    [self request:@"PUT" view:view WithUrl:url Params:params Success:successblock Error:errorblock Fail:failblock];
}

#pragma mark - 普通请求
-(void)request:(NSString*)method view:(UIView*)view WithUrl:(NSString *)url Params:(NSDictionary *)params Success:(SuccessBlock)successblock Error:(ErrorBlock)errorblock Fail:(FailBlock)failblock
{
    if (!self.hideLoading || !view)
    {
        [MJHUD_Loading showMiniLoading:view];
    }
    
    [self RequestWithUrl:url method:method isJSON:self.isJSON params:params success:^(id responseObject , NSURLSessionDataTask * task) {
    
            if (!self.hideLoading)
            {
                [MJHUD_Loading hideLoadingView:view];
            }
    
            NSLog(@"\n【HTTP响应】 \n URL = %@ \n respObjc = \n %@",task.currentRequest.URL.absoluteString,responseObject);
    
            //读取公共字段
            self.resultcode = [responseObject mj_valueForKey:@"code"];
            self.message = [responseObject mj_valueForKey:@"message"];
    
        
            //业务成功
            if (self.resultcode.integerValue==200)
            {
                [self parseData:[responseObject mj_valueForKey:@"data"]];
                successblock(responseObject);
            }
        
            //其他业务错误
            else
            {
                if (!self.hideErrorMsg)
                {
                    [MJHUD_Notice showNoticeView:self.message inView:view hideAfterDelay:2];
                }
                errorblock(responseObject);
            }
        
    } fail:^(NSError *error,NSURLSessionDataTask * task)
    {
        
        NSLog(@"\n【HTTP响应错误】 \n URL = %@ \n error = \n %@",task.currentRequest.URL.absoluteString,error);
        
        if (!self.hideLoading)
        {
            [MJHUD_Loading hideLoadingView:view];
        }
        
        NSHTTPURLResponse * resp = (NSHTTPURLResponse*)task.response;
        NSInteger httpcode = resp.statusCode;
        
        //处理401错误
        if (httpcode==401)
        {
            [SZGlobalInfo mjclearLoginInfo];
            [SZGlobalInfo mjshowLoginAlert];
            return;
        }
        
        
        //显示Http错误码
        if (!self.hideErrorMsg)
        {
            [MJHUD_Notice showNoticeView:[NSString stringWithFormat:@"网络开小差了\ncode:%ld",(long)httpcode] inView:view hideAfterDelay:2];
        }
        
        
        failblock(error);
    }];
}


#pragma mark - 文件上传
-(void)requestMultipartFileUpload:(NSString *)url model:(NSDictionary *)model fileDataArray:(NSArray*)array fileNameArray:(NSArray*)names success:(SuccessBlock)successblock error:(ErrorBlock)errorBLock fail:(FailBlock)failblock progress:(ProgressBlock)progressBlock
{
    AFHTTPSessionManager * httpManager = [AFHTTPSessionManager manager];
        
    //使用multipart方式上传
    [httpManager POST:url parameters:nil headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
    {
        //文件数据
        for (int i = 0; i<array.count; i++)
        {
            NSData * imageData = array[i];
            
            //文件名
            NSString * fileName = @"iOSName.mp4";
            if (names.count)
            {
                fileName = names[i];
            }
            
            //拼数据
            if (array.count>1)
            {
                [formData appendPartWithFileData:imageData name:@"files" fileName:fileName mimeType:@"video/mp4"];
            }
            else
            {
                [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"video/mp4"];
            }
        }
        
        //模型数据
        NSArray * keys = [model allKeys];
        for (int i = 0; i<keys.count; i++)
        {
            NSString * key = keys[i];
            id item = [model valueForKey:key];
            
            //字符串则UTF8编码
            if ([item isKindOfClass:[NSString class]])
            {
                NSData * itemData =[item dataUsingEncoding:NSUTF8StringEncoding];
                [formData appendPartWithFormData:itemData name:key];
            }
            
            //字典则转JSON
            else if ([item isKindOfClass:[NSDictionary class]])
            {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:item options:NSJSONWritingPrettyPrinted error:nil];
                [formData appendPartWithFormData:jsonData name:key];
            }
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
//            NSLog(@"正在上传--------%@",uploadProgress);
        
        if (progressBlock)
        {
            progressBlock(uploadProgress);
        }
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //读取公共字段
        self.resultcode = [responseObject mj_valueForKey:@"code"];
        self.message = [responseObject mj_valueForKey:@"resultMessage"];
        
        NSLog(@"【上传】\nResp = %@",responseObject);

        [self parseData:responseObject];
        successblock(responseObject);

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"上传接口错误%@",error);
        failblock(error);

    }];
    
}



#pragma mark - LazyLoad
-(NSMutableArray *)dataArr
{
    if (!_dataArr)
    {
        _dataArr=[NSMutableArray array];
    }
    return _dataArr;
}


#pragma mark - 解析数据
-(void)parseData:(id)data
{
    [self yy_modelSetWithDictionary:data];
}
-(void)parseDataFromDic:(NSDictionary *)dic
{
    
}



@end
