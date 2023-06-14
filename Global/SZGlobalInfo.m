//
//  SZGlobalInfo.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/5.
//

#import "SZGlobalInfo.h"
#import <AFNetworking/AFNetworking.h>
#import "TokenExchangeModel.h"
#import "SZDefines.h"
#import "MJHud.h"
#import "SZManager.h"
#import "SZUserTracker.h"
#import "SZData.h"
#import "RawModel.h"


@interface SZGlobalInfo ()
@end


@implementation SZGlobalInfo


+(SZGlobalInfo *)sharedManager
{
    static SZGlobalInfo * info = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (info == nil)
        {
            info = [[SZGlobalInfo alloc]init];
            
            [info mjloadLocalData];
        }
        });
    return info;
}


#pragma mark - Login
+(void)checkRMLoginStatus:(LoginCallback)result
{
        SZGlobalInfo * globalobjc = [SZGlobalInfo sharedManager];
        
        NSString * newTGT = [[SZManager sharedManager].delegate onGetTGT];
        NSString * localTGT = [SZGlobalInfo sharedManager].localTGT;
        
        //如果我的长沙已登录
        if (newTGT.length)
        {
            //本地有
            if (localTGT.length)
            {
                //两个TGT相同
                if ([newTGT isEqualToString:localTGT])
                {
                    [SZGlobalInfo sharedManager].loginDesc = @"MJToken_我的长沙已登录_数智已登";
                    if (result)
                    {
                        result(YES);
                    }
                }
                
                //TGT不同，则表示切换了用户
                else
                {
                    [SZGlobalInfo sharedManager].loginDesc = @"MJToken_我的长沙切换了用户_重登数智融媒";
                    [SZGlobalInfo mjclearLoginInfo];
                    [globalobjc requestRMToken:newTGT callback:result];
                }
            }
            
            //本地无TGT
            else
            {
                [SZGlobalInfo sharedManager].loginDesc = @"MJToken_我的长沙已登录_登录数智融媒";
                [globalobjc requestRMToken:newTGT callback:result];
            }
        }
        else
        {
            //清理本地token和TGT
            [SZGlobalInfo sharedManager].loginDesc = @"MJToken_我的长沙未登录_清空数智";
            [SZGlobalInfo mjclearLoginInfo];
            
            if (result)
            {
                result(NO);
            }
            
        }
}


+(void)checkLoginStatus:(LoginCallback)result
{
    SZGlobalInfo * info = [SZGlobalInfo sharedManager];
    
    
    //检查融媒是否登录
    [self checkRMLoginStatus:^(BOOL suc) {
            if (suc)
            {
                //是否登录过广电云
                if (info.gdyToken.length)
                {
                    result(YES);
                }
                else
                {
                    [info requestGdyToken:result];
                }
                
            }
            else
            {
                result(NO);
            }
    }];
    
}


#pragma mark - Request
-(void)requestRMToken:(NSString*)tgt callback:(LoginCallback)callback
{
    TokenExchangeModel * model = [TokenExchangeModel model];
    model.isJSON = YES;
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:tgt forKey:@"token"];
    [param setValue:@1 forKey:@"ignoreGdy"];
    
    __weak typeof (self) weakSelf = self;
    [model PostRequestInView:MJ_KEY_WINDOW WithUrl:APPEND_SUBURL(BASE_URL, API_URL_TOKEN_EXCHANGE) Params:param Success:^(id responseObject) {
            [weakSelf requestTokenDone:model TGT:tgt];
        
        if (callback)
        {
            callback(YES);
        }

        } Error:^(id responseObject) {
            if (callback)
            {
                callback(NO);
            }
            
        } Fail:^(NSError *error) {
            if (callback)
            {
                callback(NO);
            }
        }];
}

-(void)requestTokenDone:(TokenExchangeModel*)model TGT:(NSString*)tgt
{
    SZGlobalInfo * instance = [SZGlobalInfo sharedManager];
    instance.localTGT = tgt;
    instance.SZRMToken = model.token;
    instance.userId = model.userInfo.id;
    
    [[NSUserDefaults standardUserDefaults]setValue:instance.SZRMToken forKey:@"SZRM_TOKEN"];
    [[NSUserDefaults standardUserDefaults]setValue:instance.localTGT forKey:@"SZRM_TGT"];
    [[NSUserDefaults standardUserDefaults]setValue:instance.userId forKey:@"SZRM_USER_ID"];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SZRMTokenExchangeDone" object:nil];
}

-(void)requestGdyToken:(LoginCallback)callback
{
    RawModel * model = [RawModel model];
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:@"" forKey:@"gdy"];
    
    model.isJSON=YES;
    __weak typeof (self) weakSelf = self;
    [model PostRequestInView:nil WithUrl:APPEND_SUBURL(BASE_URL, API_URL_GDY_TOKEN) Params:param Success:^(id responseObject) {
        
        if (model.JSON.length)
        {
            [weakSelf requestGdyTokenDone:model.JSON];
            
            if (callback)
            {
                callback(YES);
            }
        }
        else
        {
            if (callback)
            {
                callback(NO);
            }
        }
        
        } Error:^(id responseObject) {
            
            if (callback)
            {
                callback(NO);
            }
            
        } Fail:^(NSError *error) {
            
            if (callback)
            {
                callback(NO);
            }
            
        }];
}

-(void)requestGdyTokenDone:(NSString*)gdyToken
{
    [SZGlobalInfo sharedManager].gdyToken = gdyToken;
    [[NSUserDefaults standardUserDefaults]setValue:gdyToken forKey:@"SZRM_GDY_TOKEN"];
}


#pragma mark - Other
//获取baseURL
+(NSString *)mjgetBaseURL
{
    SZManager * instance = [SZManager sharedManager];
    if (instance.enviroment==UAT_ENVIROMENT)
    {
        return @"https://uat-fuse-api-gw.zhcs.csbtv.com";
    }
    else
    {
        return @"https://fuse-api-gw.zhcs.csbtv.com";
    }
}


//获取H5地址
+(NSString*)mjgetBaseH5URL
{
    SZManager * instance = [SZManager sharedManager];
    if (instance.enviroment==UAT_ENVIROMENT)
    {
        return @"https://uat-h5.zhcs.csbtv.com";
    }
    else
    {
        return @"https://h5.zhcs.csbtv.com";
    }
}



//清除登录数据
+(void)mjclearLoginInfo
{
    SZGlobalInfo * instance = [SZGlobalInfo sharedManager];
    instance.SZRMToken = nil;
    instance.localTGT = nil;
    instance.gdyToken = nil;
    instance.userId = nil;
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SZRM_TGT"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SZRM_TOKEN"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SZRM_GDY_TOKEN"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SZRM_USER_ID"];
}

//读取登录数据
-(void)mjloadLocalData
{
    self.localTGT = [[NSUserDefaults standardUserDefaults]valueForKey:@"SZRM_TGT"];
    self.SZRMToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"SZRM_TOKEN"];
    self.gdyToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"SZRM_GDY_TOKEN"];
    self.userId = [[NSUserDefaults standardUserDefaults]valueForKey:@"SZRM_USER_ID"];
}

//分享
+(void)mjshareToPlatform:(SZ_SHARE_PLATFORM)platform content:(ContentModel*)contentM source:(NSString*)source
{
    if ([SZGlobalInfo checkDelegate])
    {
        [[SZManager sharedManager].delegate onShareAction:platform title:contentM.shareTitle image:contentM.shareImageUrl desc:contentM.shareBrief URL:contentM.shareUrl];
        
        //行为埋点
        NSMutableDictionary * param=[NSMutableDictionary dictionary];
        [param setValue:contentM.id forKey:@"content_id"];
        [param setValue:contentM.title forKey:@"content_name"];
        [param setValue:contentM.source forKey:@"content_source"];
        [param setValue:contentM.thirdPartyId forKey:@"third_ID"];
        [param setValue:contentM.keywordsShow forKey:@"content_key"];
        [param setValue:contentM.tagsShow forKey:@"content_list"];
        [param setValue:contentM.classification forKey:@"content_classify"];
        [param setValue:contentM.createTime forKey:@"create_time"];
        [param setValue:contentM.startTime forKey:@"publish_time"];
        [param setValue:contentM.type forKey:@"content_type"];
        [param setValue:source forKey:@"transmit_location"];
        
        [SZUserTracker trackingButtonEventName:@"content_transmit" param:param];
    }
    
}


//跳转到登录页
+(void)mjgoToLoginPage
{
    [[SZManager sharedManager].delegate onLoginAction];
}


//弹出登录提示
+(void)mjshowLoginAlert
{
    [MJHUD_Alert showLoginAlert:^(id objc) {
        [MJHUD_Alert hideAlertView];
        [SZGlobalInfo mjgoToLoginPage];
    }];
}



#pragma mark - Check
+(BOOL)checkDelegate
{
    id delegate = [SZManager sharedManager].delegate;
    if (delegate && [delegate respondsToSelector:@selector(onShareAction:title:image:desc:URL:)])
    {
        return YES;;
    }
    else
    {
        NSLog(@"请实现SZDelegate方法");
        return NO;;
    }
}

@end
