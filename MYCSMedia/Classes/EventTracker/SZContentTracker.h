//
//  SZContentTracker.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/31.
//

#import <Foundation/Foundation.h>
#import "ContentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SZContentTracker : NSObject


+(void)trackContentEvent:(NSString*)eventName contentId:(NSString*)contentid;


+(void)trackingVideoPlayingDuration:(ContentModel*)content isPlaying:(BOOL)isplay currentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime;


+(void)trackingVideoPlayingDuration_Replay:(ContentModel*)content isPlaying:(BOOL)isplay currentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime;


@end

NS_ASSUME_NONNULL_END
