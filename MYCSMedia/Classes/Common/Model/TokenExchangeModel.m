//
//  TokenExchangeModel.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/11.
//

#import "TokenExchangeModel.h"
#import "NSObject+YYModel.h"
#import "UserInfoModel.h"
#import "YYModel.h"

@implementation TokenExchangeModel
-(void)parseData:(id)data
{
    [self yy_modelSetWithDictionary:data];
    
    NSDictionary * userDic = [data valueForKey:@"loginSysUserVo"];
    UserInfoModel * userModel = [UserInfoModel model];
    [userModel parseData:userDic];
    self.userInfo = userModel;
    
}

@end
