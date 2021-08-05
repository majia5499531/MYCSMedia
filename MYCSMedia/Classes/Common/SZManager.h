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
-(NSString*)onGetTGT;
-(void)onShareAction:(SZ_SHARE_PLATFORM)platform title:(NSString*)title image:(NSString*)imgurl desc:(NSString*)desc URL:(NSString*)url;
-(void)onLoginAction;
-(void)onOpenWebview:(NSString *)url param:(NSDictionary*)param;
@end




@interface SZManager : NSObject


@property(assign,nonatomic)SZ_ENV enviroment;
@property(weak,nonatomic)id <SZDelegate> delegate;

+(SZManager*)sharedManager;


@end
