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


+(void)trackingVideoTab:(NSString *)tabName;

+(void)trackingButtonEventName:(NSString *)eventName param:(NSDictionary*)dic;




@end
