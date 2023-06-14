//
//  ContentCollectionModel.h
//  MYCSMedia
//
//  Created by 马佳 on 2023/4/13.
//

#import "BaseModel.h"
#import "ContentModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ContentCollectionModel : BaseModel
@property(strong,nonatomic)ContentModel * collectionModel;
@end

NS_ASSUME_NONNULL_END
