//
//  SZManager.m
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/28.
//

#import "SZManager.h"
#import <AFNetworking/AFNetworking.h>
#import "TokenExchangeModel.h"
#import "SZDefines.h"

@implementation SZManager

+(SZManager *)sharedManager
{
    static SZManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil)
        {
            manager = [[SZManager alloc]init];
            
            [[AFNetworkReachabilityManager sharedManager]startMonitoring];
        }
        });
    return manager;
}


#pragma mark - Login
+(void)checkLoginStatus;
{
    SZManager * instance = [SZManager sharedManager];
    
    NSString * newTGT = [[SZManager sharedManager].delegate onGetTGT];
    NSString * localTGT = [SZManager sharedManager].localTGT;
    
    //如果我的长沙已登录
    if (newTGT.length)
    {
        //本地有
        if (localTGT.length)
        {
            //两个TGT相同
            if ([newTGT isEqualToString:localTGT])
            {
                NSLog(@"MJToken_我的长沙已登录_数智已登");
                return;
            }
            
            //TGT不同，则表示切换了用户
            else
            {
                NSLog(@"MJToken_我的长沙切换了用户_重登数智融媒");
                [SZManager mjclearLoginInfo];
                [instance requestToken:newTGT];
            }
        }
        
        //本地无tgt
        else
        {
            NSLog(@"MJToken_我的长沙已登录_登录数智融媒");
            [instance requestToken:newTGT];
        }
    }
    else
    {
        //清理本地token和tgt
        NSLog(@"MJToken_我的长沙未登录");
        [SZManager mjclearLoginInfo];
    }
}



-(void)requestToken:(NSString*)tgt
{
    TokenExchangeModel * model = [TokenExchangeModel model];
    model.isJSON = YES;
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:tgt forKey:@"token"];
    
    __weak typeof (self) weakSelf = self;
    [model PostRequestInView:MJ_KEY_WINDOW WithUrl:APPEND_SUBURL(BASE_URL_SYSTEM, API_URL_TOKEN_EXCHANGE) Params:param Success:^(id responseObject) {
            [weakSelf requestTokenDone:model TGT:tgt];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}
-(void)requestTokenDone:(TokenExchangeModel*)model TGT:(NSString*)tgt
{
    NSLog(@"MJToken_数智融媒登录成功_%@",model.token);
    [SZManager loginSuccess:model.token TGT:tgt];
}


#pragma mark - Other

+(NSString *)mjgetBaseURL
{
    SZManager * instance = [SZManager sharedManager];
    if (instance.enviroment==UAT_ENVIROMENT)
    {
        return @"https://uat-fuse-cms.zhcs.csbtv.com";
    }
    else
    {
        return @"https://fuse-cms.zhcs.csbtv.com";
    }
}


+(NSString*)mjgetBaseSysURL
{
    SZManager * instance = [SZManager sharedManager];
    if (instance.enviroment==UAT_ENVIROMENT)
    {
        return @"https://uat-fuse-system.zhcs.csbtv.com";
    }
    else
    {
        return @"https://fuse-system.zhcs.csbtv.com";
    }
}



-(void)mjloadLoginInfo
{
    self.localTGT = [[NSUserDefaults standardUserDefaults]valueForKey:@"SZRM_TGT"];
    self.SZRMToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"SZRM_TOKEN"];
}

+(void)mjclearLoginInfo
{
    SZManager * instance = [SZManager sharedManager];
    instance.SZRMToken = nil;
    instance.localTGT = nil;
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SZRM_TGT"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"SZRM_TOKEN"];
}


+(void)loginSuccess:(NSString*)token TGT:(NSString*)tgt
{
    SZManager * instance = [SZManager sharedManager];
    instance.SZRMToken = token;
    instance.localTGT = tgt;
    [[NSUserDefaults standardUserDefaults]setValue:token forKey:@"SZRM_TOKEN"];
    [[NSUserDefaults standardUserDefaults]setValue:tgt forKey:@"SZRM_TGT"];
}

+(void)mjgoToLoginPage
{
    [[SZManager sharedManager].delegate onLoginAction];
}


@end
