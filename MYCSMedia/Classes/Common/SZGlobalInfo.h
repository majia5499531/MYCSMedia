//
//  SZGlobalInfo.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/5.
//

#import <Foundation/Foundation.h>
#import "SZManager.h"
#import "ContentModel.h"

@interface SZGlobalInfo : NSObject


+(SZGlobalInfo *)sharedManager;

@property(strong,nonatomic)NSString * SZRMToken;
@property(strong,nonatomic)NSString * localTGT;
@property(strong,nonatomic)NSString * loginDesc;



+(NSString*)mjgetBaseURL;           //获取BaseURL


+(void)checkLoginStatus;            //检查登陆信息
+(void)mjshowLoginAlert;            //弹出登陆提示框
+(void)mjgoToLoginPage;             //跳登陆页
+(void)mjclearLoginInfo;            //清除登陆状态

+(void)mjshareToPlatform:(SZ_SHARE_PLATFORM)platform content:(ContentModel*)model;          //分享

@end

