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

+(void)trackContentEvent:(NSString*)eventName content:(ContentModel*)contentM;

+(void)trackingVideoPlayingDuration:(ContentModel*)content isPlaying:(BOOL)isplay currentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime;

+(void)trackingVideoPlayingDuration_manual:(ContentModel*)content isPlaying:(BOOL)isplay currentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime;


//记录进度
+(void)recordPlayingProgress:(CGFloat)progess content:(ContentModel*)contentM;

@end

NS_ASSUME_NONNULL_END
