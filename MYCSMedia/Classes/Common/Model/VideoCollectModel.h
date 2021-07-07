//
//  VideoCollectModel.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/5.
//

#import "BaseModel.h"
#import "ContentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoCollectModel : BaseModel
@property (nonatomic , copy) NSString              * source;
@property (nonatomic , copy) NSString              * status;
@property (nonatomic , copy) NSString              * title;
@property (nonatomic , copy) NSString              * favorCountShow;
@property (nonatomic , copy) NSString              * commentCountShow;
@property (nonatomic , copy) NSString              * liveStatus;
@property (nonatomic , copy) NSString              * shareTitle;
@property (nonatomic , copy) NSString              * brief;
@property (nonatomic , copy) NSString              * shareImageUrl;
@property (nonatomic , copy) NSString              * endTime;
@property (nonatomic , copy) NSString              * shareBrief;
@property (nonatomic , copy) NSString              * type;
@property (nonatomic , assign) NSString            * id;
@property (nonatomic , assign) BOOL              disableComment;
@property (nonatomic , copy) NSString              * shareH5;
@property (nonatomic , copy) NSString              * likeCountShow;
@property (nonatomic , copy) NSString              * classList;
@property (nonatomic , copy) NSString              * listStyle;
@property (nonatomic , copy) NSString              * startTime;
@property (nonatomic , copy) NSString              * viewCountShow;
@end

NS_ASSUME_NONNULL_END
