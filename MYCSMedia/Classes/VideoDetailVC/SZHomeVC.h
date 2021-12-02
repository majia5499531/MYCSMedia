//
//  SZHomeVC.h
//  MYCSMedia-CSAssets
//
//  Created by 马佳 on 2021/6/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SZHomeVC : UIViewController

@property(strong,nonatomic)NSString * contentId;
@property(assign,nonatomic)NSInteger initialIndex;
@property(assign,nonatomic)NSInteger currentSelectIdx;
@property(strong,nonatomic)NSString * category_name;

@end

NS_ASSUME_NONNULL_END

