//
//  ContentStateModel.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/8.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContentStateModel : BaseModel

@property (nonatomic , assign) NSInteger              viewCountShow;
@property (nonatomic , copy) NSString *               contentId;
@property (nonatomic , copy) NSString *               id;
@property (nonatomic , assign) NSInteger              playCountShow;
@property (nonatomic , assign) BOOL              whetherLike;
@property (nonatomic , assign) BOOL              whetherFavor;
@property (nonatomic , assign) BOOL              whetherFollow;
@property (nonatomic , assign) NSInteger              likeCountShow;
@property (nonatomic , assign) NSInteger              favorCountShow;
@property (nonatomic , assign) NSInteger              commentCountShow;

@end

NS_ASSUME_NONNULL_END
