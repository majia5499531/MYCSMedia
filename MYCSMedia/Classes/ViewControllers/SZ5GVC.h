//
//  SZMediaVC.h
//  MYCSMedia
//
//  Created by 马佳 on 2023/4/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SZ5GVC : UIViewController
@property(assign,nonatomic)NSInteger initialIndex;
@property(strong,nonatomic)NSString * contentId;
//火山cate
@property(strong,nonatomic)NSString * category_name;
//火山reqId
@property(strong,nonatomic)NSString * requestId;
@end

NS_ASSUME_NONNULL_END
