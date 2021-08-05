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

@implementation SZGlobalInfo

+(SZGlobalInfo *)sharedManager
{
    static SZGlobalInfo * info = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (info == nil)
        {
            info = [[SZGlobalInfo alloc]init];
        }
        });
    return info;
}



#pragma mark - Login
+(void)checkLoginStatus;
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
                return;
            }
            
            //TGT不同，则表示切换了用户
            else
            {
                [SZGlobalInfo sharedManager].loginDesc = @"MJToken_我的长沙切换了用户_重登数智融媒";
                [SZGlobalInfo mjclearLoginInfo];
                [globalobjc requestToken:newTGT];
            }
        }
        
        //本地无TGT
        else
        {
            [SZGlobalInfo sharedManager].loginDesc = @"MJToken_我的长沙已登录_登录数智融媒";
            [globalobjc requestToken:newTGT];
        }
    }
    else
    {
        //清理本地token和TGT
        [SZGlobalInfo sharedManager].loginDesc = @"MJToken_我的长沙未登录_清空数智";
        [SZGlobalInfo mjclearLoginInfo];
    }
}

//换token成功
+(void)loginSuccess:(NSString*)token TGT:(NSString*)tgt
{
    SZGlobalInfo * instance = [SZGlobalInfo sharedManager];
    instance.SZRMToken = token;
    instance.localTGT = tgt;
    [[NSUserDefaults standardUserDefaults]setValue:token forKey:@"SZRM_TOKEN"];
    [[NSUserDefaults standardUserDefaults]setValue:tgt forKey:@"SZRM_TGT"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SZRMTokenExchangeDone" object:nil];
}


#pragma mark - Request
-(void)requestToken:(NSString*)tgt
{
    TokenExchangeModel * model = [TokenExchangeModel model];
    model.isJSON = YES;
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:tgt forKey:@"token"];
    
    __weak typeof (self) weakSelf = self;
    [model PostRequestInView:MJ_KEY_WINDOW WithUrl:APPEND_SUBURL(BASE_URL, API_URL_TOKEN_EXCHANGE) Params:param Success:^(id responseObject) {
            [weakSelf requestTokenDone:model TGT:tgt];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}

-(void)requestTokenDone:(TokenExchangeModel*)model TGT:(NSString*)tgt
{
    NSLog(@"MJToken_数智融媒登录成功_%@",model.token);
    [SZGlobalInfo loginSuccess:model.token TGT:tgt];
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



//清除登陆相关数据
+(void)mjclearLoginInfo
{
    SZGlobalInfo * instance = [SZGlobalInfo sharedManager];
    instance.SZRMToken = nil;
    instance.localTGT = nil;
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SZRM_TGT"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SZRM_TOKEN"];
}


+(void)mjshareToPlatform:(SZ_SHARE_PLATFORM)platform content:(ContentModel *)model
{
    if ([SZGlobalInfo checkDelegate])
    {
        [[SZManager sharedManager].delegate onShareAction:platform title:model.shareTitle image:model.shareImageUrl desc:model.shareBrief URL:model.shareUrl];
    }
}


//跳转到登陆页
+(void)mjgoToLoginPage
{
    [[SZManager sharedManager].delegate onLoginAction];
}


//弹出登陆提示
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
