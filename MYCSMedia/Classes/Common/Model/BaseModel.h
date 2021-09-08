//
//  BaseModel.h
//  喜鹊红包
//
//  Created by 马佳 on 2018/5/15.
//  Copyright © 2018年 HW_Tech. All rights reserved.
//

#import "RootModel.h"

@interface BaseModel : RootModel

@property(assign,nonatomic)BOOL isJSON;
@property(assign,nonatomic)BOOL hideLoading;
@property(assign,nonatomic)BOOL hideErrorMsg;
@property(strong,nonatomic)NSString * resultcode;
@property(strong,nonatomic)NSString * message;
@property(strong,nonatomic)NSMutableArray * dataArr;
@property(assign,nonatomic)NSInteger pageIndex;
@property(assign,nonatomic)NSInteger logLevel;

-(void)GETRequestInView:(UIView*)view WithUrl:(NSString *)url Params:(NSDictionary *)params Success:(SuccessBlock)successblock Error:(ErrorBlock)errorblock Fail:(FailBlock)failblock;
-(void)PostRequestInView:(UIView*)view WithUrl:(NSString *)url Params:(NSDictionary *)params Success:(SuccessBlock)successblock Error:(ErrorBlock)errorblock Fail:(FailBlock)failblock;
-(void)DeleteRequestInView:(UIView*)view WithUrl:(NSString *)url Params:(NSDictionary *)params Success:(SuccessBlock)successblock Error:(ErrorBlock)errorblock Fail:(FailBlock)failblock;
-(void)PutRequestInView:(UIView*)view WithUrl:(NSString *)url Params:(NSDictionary *)params Success:(SuccessBlock)successblock Error:(ErrorBlock)errorblock Fail:(FailBlock)failblock;

-(void)requestMultipartFileUpload:(NSString *)url model:(NSDictionary *)model fileDataArray:(NSArray*)array fileNameArray:(NSArray*)names success:(SuccessBlock)successblock error:(ErrorBlock)errorBLock fail:(FailBlock)failblock progress:(ProgressBlock)progressBlock;

-(void)parseData:(id)data;
-(void)parseDataFromDic:(NSDictionary*)dic;

@end
