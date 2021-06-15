//
//  VideoModel.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/5.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoModel : BaseModel
@property (nonatomic , copy) NSString              * source;
@property (nonatomic , copy) NSString              * title;
@property (nonatomic , assign) NSInteger              favorCountShow;
@property (nonatomic , copy) NSString              * external;
@property (nonatomic , assign) NSInteger              commentCountShow;
@property (nonatomic , copy) NSString              * liveStartTime;
@property (nonatomic , copy) NSString              * liveStatus;
@property (nonatomic , copy) NSString              * shareTitle;
@property (nonatomic , copy) NSString              * brief;
@property (nonatomic , copy) NSString              * shareImageUrl;
@property (nonatomic , copy) NSString              * keywords;
@property (nonatomic , copy) NSString              * issueTimeStamp;
@property (nonatomic , copy) NSString              * shareBrief;
@property (nonatomic , copy) NSString              * endTime;
@property (nonatomic , copy) NSString              * type;
@property (nonatomic , copy) NSString             * id;
@property (nonatomic , copy) NSString              * shareH5;
@property (nonatomic , assign) NSInteger              likeCountShow;
@property (nonatomic , copy) NSString              * disableComment;
@property (nonatomic , copy) NSString              * playUrl;
@property (nonatomic , copy) NSString              * timeDif;
@property (nonatomic , copy) NSString              * thumbnailUrl;
@property (nonatomic , copy) NSString              * playDuration;
@property (nonatomic , copy) NSString              * listStyle;
@property (nonatomic , copy) NSString              * startTime;
@property (nonatomic , assign) NSInteger              viewCountShow;
@property(strong,nonatomic)NSString                * pid;

@end

NS_ASSUME_NONNULL_END
