//
//  PanelConfigModel.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/23.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PanelConfigModel : BaseModel

@property(strong,nonatomic)NSString * horizontal;
@property (nonatomic,strong) NSNumber *listStyle;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) NSNumber *showPlayDuration;
@property (nonatomic,strong) NSNumber *enableFilter;
@property (nonatomic,copy) NSString *typeCode;
@property (nonatomic,strong) NSMutableArray *filterItems;
@property (nonatomic,strong) NSMutableArray *contentTypes;
@property (nonatomic,strong) NSNumber *canShare;
@property (nonatomic,strong) NSNumber *canFavor;
@property (nonatomic,copy) NSString *code;
@property (nonatomic,strong) NSNumber *canComment;
@property (nonatomic,copy) NSString *typeName;
@property (nonatomic,strong) NSNumber *canLike;


@property(strong,nonatomic)NSString * imageUrl;
@property(strong,nonatomic)NSString * jumpUrl;
@property(strong,nonatomic)NSString * backgroundImageUrl;

@property(strong,nonatomic)NSString * volcengineCategoryId;

@end

NS_ASSUME_NONNULL_END
