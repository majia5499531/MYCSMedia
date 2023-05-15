//
//  SZVideoListVC.h
//  MYCSMedia
//
//  Created by 马佳 on 2023/4/8.
//

#import <UIKit/UIKit.h>
@class CategoryModel;
@class ContentListModel;

NS_ASSUME_NONNULL_BEGIN

@interface SZVideoListVC : UIViewController


@property(strong,nonatomic)NSString * panelCode;
@property(assign,nonatomic)BOOL isFocusedVC;
@property(strong,nonatomic)CategoryModel * cateModel;
@property(strong,nonatomic)NSString * contentId;
@property(strong,nonatomic)NSString * category_name;
@property(strong,nonatomic)NSString * requestId;
@property(strong,nonatomic)ContentListModel * dataModel;


-(void)setActivityImg:(NSString *)img1 simpleImg:(NSString *)img2 linkUrl:(NSString *)url;


-(void)requestVideoList;
-(void)requestMoreVideos;
-(void)requestVideoListDone:(ContentListModel*)model;
-(void)requestMoreVideoDone:(ContentListModel*)model;
-(void)requestFailed;

@end

NS_ASSUME_NONNULL_END
