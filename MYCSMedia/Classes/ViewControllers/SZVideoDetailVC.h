//
//  SZVideoDetailVC.h
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/27.
//

#import <UIKit/UIKit.h>


@interface SZVideoDetailVC : UIViewController

@property(assign,nonatomic)NSInteger detailType;            //0单条视频 1视频集合

@property(strong,nonatomic)NSString * contentId;
@property(strong,nonatomic)NSString * albumId;
@property(strong,nonatomic)NSString * albumName;
@property(strong,nonatomic)NSString * category_name;
@property(strong,nonatomic)NSString * requestId;
@property(assign,nonatomic)BOOL isPreview;



//话题广场 (1:首页  2:小组内  3:话题内 4:个人主页内)
@property(strong,nonatomic)NSString * locationType;
//参数
@property(strong,nonatomic)NSString * groupId;      //小组ID
@property(strong,nonatomic)NSString * topicId;      //话题ID
@property(strong,nonatomic)NSString * userId;       //用户ID


@end
