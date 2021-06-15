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

@end

NS_ASSUME_NONNULL_END
