//
//  SZHomeVC.h
//  MYCSMedia-CSAssets
//
//  Created by 马佳 on 2021/6/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SZHomeVC : UIViewController

//初始视频ID
@property(strong,nonatomic)NSString * contentId;

//初始tab
@property(assign,nonatomic)NSInteger initialIndex;
//火山cate
@property(strong,nonatomic)NSString * category_name;
//火山reqId
@property(strong,nonatomic)NSString * requestId;

@end

NS_ASSUME_NONNULL_END

