//
//  SZUserTracker.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/15.
//

#import <Foundation/Foundation.h>
#import "ContentModel.h"


@interface SZUserTracker : NSObject

+(SZUserTracker *)shareTracker;


+(void)trackingVideoTab:(NSString *)btnTitle moduleIndex:(NSInteger)moduleIdx;
+(void)trackingButtonClick:(NSString *)btnTitle moduleIndex:(NSInteger)moduleIdx;
+ (void)trackingButtonEventName:(NSString *)eventName param:(NSDictionary*)dic;




@end


