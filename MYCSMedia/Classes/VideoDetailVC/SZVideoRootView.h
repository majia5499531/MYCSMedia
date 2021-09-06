//
//  SZVideoRootView.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SZVideoRootView : UIView
-(void)viewWillAppear;
-(void)updateCurrentContentId:(BOOL)force;
@end

NS_ASSUME_NONNULL_END
