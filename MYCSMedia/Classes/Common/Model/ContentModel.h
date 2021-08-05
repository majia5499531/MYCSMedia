//
//  ContentModel.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/5.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContentModel : BaseModel

@property (nonatomic , assign) NSInteger             favorCountShow;
@property (nonatomic , assign) NSInteger             likeCountShow;
@property (nonatomic , assign) NSInteger             commentCountShow;
@property (nonatomic , assign) NSInteger             viewCountShow;



@property (nonatomic , copy) NSString              * source;
@property (nonatomic , copy) NSString              * title;
@property (nonatomic , copy) NSString              * liveStartTime;
@property (nonatomic , copy) NSString              * liveStatus;
@property (nonatomic , copy) NSString              * brief;
@property (nonatomic , copy) NSString              * keywords;
@property (nonatomic , copy) NSString              * issueTimeStamp;
@property (nonatomic , copy) NSString              * endTime;
@property (nonatomic , copy) NSString              * type;
@property (nonatomic , copy) NSString             * id;
@property (nonatomic , copy) NSString              * external;
@property (nonatomic , copy) NSString              * disableComment;
@property (nonatomic , copy) NSString              * playUrl;
@property (nonatomic , copy) NSString              * timeDif;
@property (nonatomic , copy) NSString              * thumbnailUrl;
@property (nonatomic , copy) NSString              * playDuration;
@property (nonatomic , copy) NSString              * listStyle;
@property (nonatomic , copy) NSString              * startTime;
@property (nonatomic , copy) NSString              * pid;


@property (nonatomic , copy) NSString              * shareImageUrl;
@property (nonatomic , copy) NSString              * shareBrief;
@property (nonatomic , copy) NSString              * shareUrl;
@property (nonatomic , copy) NSString              * shareTitle;


@end

NS_ASSUME_NONNULL_END
