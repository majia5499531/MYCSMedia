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

+(void)trackingButtonClick:(NSString *)btnTitle eventName:(NSString*)eventName moduleName:(NSString*)module;
+(void)trackingButtonClick:(NSString*)btnTitle;




@end


