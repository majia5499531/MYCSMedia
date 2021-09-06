//
//  SZEventTracker.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/15.
//

#import <Foundation/Foundation.h>
#import "ContentModel.h"


@interface SZEventTracker : NSObject

+(SZEventTracker *)shareTracker;


+(void)trackingVideoPlayWithContentModel:(ContentModel *)model source:(NSString*)source isReplay:(BOOL)replay;

+(void)trackingVideoEndWithContentModel:(ContentModel*)model totalTime:(NSString*)time;

+(void)trackingVideoDurationWithModel:(ContentModel*)model isPlaying:(BOOL)isplaying;

+(void)trackingVideoSpeedRateWithModel:(ContentModel*)model speed:(NSString*)speed;

+(void)trackingCommonEvent:(ContentModel*)model eventParam:(NSDictionary*)param eventName:(NSString*)eventName;


@end


