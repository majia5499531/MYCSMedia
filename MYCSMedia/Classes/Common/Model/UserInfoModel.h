//
//  UserInfoModel.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/30.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserInfoModel : BaseModel

@property(strong,nonatomic)NSString * gender;
@property(strong,nonatomic)NSString * id;
@property(strong,nonatomic)NSString * nickname;
@property(strong,nonatomic)NSString * cardName;
@property(strong,nonatomic)NSString * permissionCodes;
@property(strong,nonatomic)NSString * username;
@property(strong,nonatomic)NSString * head;
@property(strong,nonatomic)NSString * state;

@end

NS_ASSUME_NONNULL_END
