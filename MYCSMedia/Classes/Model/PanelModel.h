//
//  PanelModel.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/23.
//

#import "BaseModel.h"
#import "PanelConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PanelModel : BaseModel


@property (nonatomic,strong) NSString *id;
@property (nonatomic,copy) NSString *code;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *typeName;
@property (nonatomic,copy) NSString *typeCode;
@property (nonatomic,copy) NSString *limitCount;
@property (nonatomic,strong) NSNumber *categoryId;
@property (nonatomic,strong) NSNumber *isCategoryPanel;


@property (nonatomic,strong) NSMutableArray * subCategories;

@property (nonatomic,strong) PanelConfigModel * config;
@end

NS_ASSUME_NONNULL_END
