//
//  SZ5GWebVC.h
//  MYCSMedia
//
//  Created by 马佳 on 2023/4/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SZ5GWebVC : UIViewController
@property(strong,nonatomic)NSString * categoryCode;
@property(strong,nonatomic)NSString * webtitle;
@property(strong,nonatomic)NSString * url;


-(void)naviBackAction;

@end

NS_ASSUME_NONNULL_END
