//
//  CategoryModel.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/22.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CategoryModel : BaseModel

@property (nonatomic,strong) NSNumber *parentId;
@property (nonatomic,strong) NSNumber *id;
@property (nonatomic,copy) NSString *code;
@property (nonatomic,copy) NSString *jumpUrl;
@property (nonatomic,copy) NSString *iconUrl;
@property (nonatomic,strong) id children;
@property (nonatomic,strong) NSNumber *type;
@property (nonatomic,copy) NSString *name;


@end

NS_ASSUME_NONNULL_END
