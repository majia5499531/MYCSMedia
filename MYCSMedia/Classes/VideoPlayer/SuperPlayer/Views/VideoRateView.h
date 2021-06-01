//
//  VideoRateView.h
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/26.
//

#import <UIKit/UIKit.h>
#import "SuperPlayerViewConfig.h"
#import "SuperPlayerControlView.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoRateView : UIView
@property SuperPlayerViewConfig *playerConfig;
@property (weak) SuperPlayerControlView *controlView;
-(void)updateState;

@end

NS_ASSUME_NONNULL_END
