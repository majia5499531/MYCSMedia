//
//  MJProgressView.h
//  Pods
//
//  Created by 马佳 on 2021/8/26.
//

#import <UIKit/UIKit.h>
#import "MJSlider.h"

NS_ASSUME_NONNULL_BEGIN

@interface MJProgressView : UIView
@property(strong,nonatomic)MJSlider * slider;

-(void)setCurrentTime:(NSInteger)time totalTime:(NSInteger)totalTime progress:(CGFloat)progress isDragging:(BOOL)b;

@end

NS_ASSUME_NONNULL_END
