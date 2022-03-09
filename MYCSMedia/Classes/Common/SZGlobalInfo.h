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
typedef void (^LoginCallback)(BOOL suc);

+(SZGlobalInfo *)sharedManager;

@property(strong,nonatomic)NSString * SZRMToken;
@property(strong,nonatomic)NSString * localTGT;
@property(strong,nonatomic)NSString * loginDesc;
@property(strong,nonatomic)NSString * gdyToken;
@property(strong,nonatomic)NSString * userId;


+(NSString*)mjgetBaseURL;           //获取BaseURL
+(NSString*)mjgetBaseH5URL;         //获取H5 URL

+(void)checkLoginStatus:(LoginCallback)result;

+(void)mjshowLoginAlert;            //弹出登录提示框
+(void)mjgoToLoginPage;             //跳登录页
+(void)mjclearLoginInfo;            //清除登录状态

+(void)mjshareToPlatform:(SZ_SHARE_PLATFORM)platform content:(ContentModel*)model source:(NSString*)source;          //分享



@end

