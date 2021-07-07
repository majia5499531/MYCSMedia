//
//  SZManager.h
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/28.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SZ_SHARE_PLATFORM)
{
    WECHAT_PLATFORM = 0,
    TIMELINE_PLATFORM,
    QQ_PLATFORM
};

typedef NS_ENUM(NSUInteger, SZ_ENV)
{
    UAT_ENVIROMENT = 0,
    PRD_ENVIROMENT,
};


@protocol SZDelegate <NSObject>
-(NSString*)onGetTGT;
-(void)onShareAction:(SZ_SHARE_PLATFORM)platform title:(NSString*)title image:(NSString*)imgurl desc:(NSString*)desc URL:(NSString*)url;
-(void)onLoginAction;
@end




@interface SZManager : NSObject

//开发环境
@property(assign,nonatomic)SZ_ENV enviroment;
@property(weak,nonatomic) id <SZDelegate> delegate;
@property(strong,nonatomic)NSString * SZRMToken;
@property(strong,nonatomic)NSString * localTGT;

+(SZManager*)sharedManager;
+(NSString*)mjgetBaseURL;

+(void)mjgoToLoginPage;
+(void)mjclearLoginInfo;
+(void)loginSuccess:(NSString*)token TGT:(NSString*)tgt;
+(void)checkLoginStatus;
@end
