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

//是否同意隐私协议;
-(BOOL)applicationIsAgreePrivacy;

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





typedef void (^RMSuccessBlock)(id responseObject);
typedef void (^RMErrorBlock)(id responseObject);
typedef void (^RMFailBlock)(NSError * error);

@interface SZManager : NSObject
@property(assign,nonatomic)SZ_ENV enviroment;
@property(weak,nonatomic)id <SZDelegate> delegate;
+(SZManager*)sharedManager;



+(void)requestCategoryData:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;
+(void)requestContentData:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;;
+(void)requestMoreContentData:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;;
+(void)requestHomepageVideo:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;;
+(void)requestHomepageNews:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;;

+(void)requestHaikaList:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;;
+(void)requestHaikaCode:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;;
+(void)requestUploadTrackingdata:(NSArray*)data Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;
@end
