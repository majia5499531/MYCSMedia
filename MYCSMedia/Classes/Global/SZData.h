//
//  SZData.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/3.
//

#import <Foundation/Foundation.h>
#import "IQDataBinding.h"
#import "SZManager.h"

@interface SZData : NSObject


//监听
@property(strong,nonatomic)NSString * currentContentId;               //内容ID
@property(strong,nonatomic)NSNumber * contentZanTime;                 //点赞变化
@property(strong,nonatomic)NSNumber * contentCollectTime;             //收藏变化
@property(strong,nonatomic)NSNumber * contentCommentsUpdateTime;     //评论变化
@property(strong,nonatomic)NSNumber * contentCreateFollowTime;       //关注发布者
@property(strong,nonatomic)NSNumber * contentStateUpdateTime;        //内容状态变化
@property(strong,nonatomic)NSNumber * contentRelateUpdateTime;       //相关推荐变化
@property(strong,nonatomic)NSNumber * contentBelongAlbumsUpdateTime;         //内容标签变化

//数据
@property(strong,nonatomic)NSMutableDictionary * contentDic;
@property(strong,nonatomic)NSMutableDictionary * contentStateDic;
@property(strong,nonatomic)NSMutableDictionary * contentCommentDic;
@property(strong,nonatomic)NSMutableDictionary * contentRelateContentDic;
@property(strong,nonatomic)NSMutableDictionary * contentRelateContentDislikeDic;
@property(strong,nonatomic)NSMutableDictionary * contentBelongAlbumsDic;;
@property(strong,nonatomic)NSString * currentVideoTab;
@property(strong,nonatomic)NSString * isShowCommentBG;


+(instancetype)sharedSZData;


-(void)requestShortViewZan;
-(void)requestZan:(NSString*)contentId;
-(void)requestCollect:(NSString*)contentId;
-(void)requestCommentZan:(NSString*)commentId replyId:(NSString*)replyId;
-(void)requestFollowUser:(NSString*)userId;
-(void)requestUnFollowUser:(NSString*)userId;
-(void)requestCommentListData;



-(void)requestCategoryData:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;
-(void)requestContentData:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;
-(void)requestMoreContentData:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;
-(void)requestHomepageVideo:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;
-(void)requestHomepageNews:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;


-(void)requestHaikaList:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;
-(void)requestHaikaCode:(NSDictionary*)param Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;
-(void)requestUploadTrackingdata:(NSArray*)data Success:(RMSuccessBlock)successblock Error:(RMErrorBlock)errorblock Fail:(RMFailBlock)failblock;
@end


