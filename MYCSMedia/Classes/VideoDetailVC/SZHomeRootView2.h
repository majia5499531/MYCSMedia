//
//  SZHomeRootView2.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SZHomeRootView2 : UIView
@property(strong,nonatomic)NSString * contentId;
@property(assign,nonatomic)BOOL selected;
-(void)viewWillAppear;
-(void)needUpdateCurrentContentId_now:(BOOL)force;
@end

NS_ASSUME_NONNULL_END
