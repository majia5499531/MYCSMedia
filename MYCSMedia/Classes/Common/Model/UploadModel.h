//
//  UploadModel.h
//  MYCSMedia
//
//  Created by 马佳 on 2022/3/8.
//


#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UploadModel : BaseModel

@property(strong,nonatomic)NSString * id;
@property(strong,nonatomic)NSString * title;
@property(strong,nonatomic)NSString * playDuration;
@property(strong,nonatomic)NSNumber * size;
@property(strong,nonatomic)NSString * height;
@property(strong,nonatomic)NSString * width;
@property(strong,nonatomic)NSString * playUrl;
@property(strong,nonatomic)NSString * createTime;
@property(strong,nonatomic)NSString * imagesUrl;
@property(strong,nonatomic)NSString * thumbnailUrl;


@end

NS_ASSUME_NONNULL_END
