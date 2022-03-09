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

@property(assign,nonatomic)BOOL whetherFollow;
@property(assign,nonatomic)BOOL whetherLike;
@property(assign,nonatomic)BOOL whetherFavor;

@property(assign,nonatomic)BOOL isManualPlay;
@property(assign,nonatomic)BOOL isFinishPlay;

@property (nonatomic , copy) NSString              * id;
@property (nonatomic , copy) NSString              * thirdPartyId;
@property (nonatomic , copy) NSString               * thirdPartyCode;
@property (nonatomic , copy) NSString              * source;
@property (nonatomic , copy) NSString              * title;
@property (nonatomic , copy) NSString              * brief;
@property (nonatomic , copy) NSString              * keywords;
@property(strong,nonatomic)NSString *   tags;
@property(strong,nonatomic)NSString *   classification;
@property (nonatomic , copy) NSString              * issueTimeStamp;
@property (nonatomic , copy) NSString              * type;
@property (nonatomic , copy) NSString              * external;
@property (nonatomic , copy) NSString              * disableComment;
@property (nonatomic , copy) NSString              * playUrl;
@property (nonatomic , copy) NSString              * timeDif;
@property (nonatomic , copy) NSString              * thumbnailUrl;
@property (nonatomic , copy) NSString              * playDuration;
@property (nonatomic , copy) NSString              * listStyle;
@property (nonatomic , copy) NSString              * pid;
@property (nonatomic , copy) NSString              * imagesUrl;


@property (nonatomic , copy) NSString              * liveStartTime;
@property (nonatomic , copy) NSString              * liveStatus;
@property (nonatomic , copy) NSString              * startTime;
@property (nonatomic , copy) NSString              * endTime;


@property(strong,nonatomic) NSString               * belongActivityId;
@property(strong,nonatomic) NSString               * belongActivityName;
@property(strong,nonatomic) NSString               * belongTopicId;
@property(strong,nonatomic) NSString               * belongTopicName;
@property(strong,nonatomic) NSNumber               * width;
@property(strong,nonatomic) NSNumber               * height;



@property(strong,nonatomic) NSString               * createBy;
@property(strong,nonatomic) NSString               * creatorUsername;
@property(strong,nonatomic) NSString               * creatorNickname;
@property(strong,nonatomic) NSString               * creatorHead;
@property(strong,nonatomic) NSString               * creatorGender;
@property(strong,nonatomic) NSString               * creatorCertMark;
@property(strong,nonatomic) NSString               * creatorCertDomain;


@property(strong,nonatomic) NSString               * issuerName;
@property(strong,nonatomic) NSString               * issuerImageUrl;
@property(strong,nonatomic) NSString               * issuerId;


@property (nonatomic , copy) NSString              * shareImageUrl;
@property (nonatomic , copy) NSString              * shareBrief;
@property (nonatomic , copy) NSString              * shareUrl;
@property (nonatomic , copy) NSString              * shareTitle;

@property (strong,nonatomic)NSString * requestId;
@property (strong,nonatomic) NSString * volcCategory;

@end

NS_ASSUME_NONNULL_END
