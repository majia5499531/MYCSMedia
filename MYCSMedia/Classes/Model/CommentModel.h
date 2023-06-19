//
//  CommentModel.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/7.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommentModel : BaseModel
@property (nonatomic , copy) NSString             * id;
@property (nonatomic , assign) NSInteger              createBy;
@property (nonatomic , copy) NSString              * head;
@property (nonatomic , copy) NSString              * title;
@property (nonatomic , assign) NSInteger              userId;
@property (nonatomic , assign) NSInteger              contentId;
@property (nonatomic , copy) NSString              * createTime;
@property (nonatomic , copy) NSString              * rcommentId;
@property (nonatomic , assign) NSInteger              pcommentId;
@property (nonatomic , copy) NSString              * editor;
@property (nonatomic , copy) NSString              * nickname;
@property (nonatomic , copy) NSString              * content;
@property (nonatomic , assign) BOOL               onShelve;
@property (nonatomic , assign) BOOL                isTop;
@property (nonatomic , assign) BOOL                whetherLike;
@property (nonatomic , assign) NSInteger            likeCount;


@property(strong,nonatomic)NSString * lastReplyName;
@property(strong,nonatomic)NSString * totalReplyCount;
@property(assign,nonatomic)NSInteger replyShowCount;
@property(assign,nonatomic)NSInteger replyInitialCount;


@end

NS_ASSUME_NONNULL_END
