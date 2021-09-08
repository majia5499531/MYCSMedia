//
//  SZManager.h
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/28.
//

#import <Foundation/Foundation.h>

//分享平台
typedef NS_ENUM(NSUInteger, SZ_SHARE_PLATFORM)
{
    WECHAT_PLATFORM = 0,
    TIMELINE_PLATFORM,
    QQ_PLATFORM
};

//环境
typedef NS_ENUM(NSUInteger, SZ_ENV)
{
    UAT_ENVIROMENT = 0,
    PRD_ENVIROMENT,
};


@protocol SZDelegate <NSObject>

//获取TGT
-(NSString*)onGetTGT;

//分享事件
-(void)onShareAction:(SZ_SHARE_PLATFORM)platform title:(NSString*)title image:(NSString*)imgurl desc:(NSString*)desc URL:(NSString*)url;

//跳转到登录页
-(void)onLoginAction;

//打开webview
-(void)onOpenWebview:(NSString *)url param:(NSDictionary*)param;

//火山埋点SDK
-(void)onEventTracking:(NSString*)key param:(NSDictionary*)param;

//获取设备ID
-(NSString*)onGetUserDevice;

@end




@interface SZManager : NSObject
@property(assign,nonatomic)SZ_ENV enviroment;
@property(weak,nonatomic)id <SZDelegate> delegate;
+(SZManager*)sharedManager;
@end
