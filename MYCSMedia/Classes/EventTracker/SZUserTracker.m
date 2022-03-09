//
//  SZUserTracker.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/15.
//

#import "SZUserTracker.h"
#import "SZManager.h"
#import "NSDictionary+MJCategory.h"

@interface SZUserTracker ()
@property(strong,nonatomic)NSMutableDictionary * startTimeDic;
@property(strong,nonatomic)NSMutableDictionary * stateDic;
@end

@implementation SZUserTracker



+(SZUserTracker *)shareTracker
{
    static SZUserTracker * tracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (tracker == nil)
        {
            tracker = [[SZUserTracker alloc]init];
        }
        });
    return tracker;
}




#pragma mark - tracking
+(void)trackingVideoTab:(NSString *)tabName;
{
    [SZUserTracker trackingButtonEventName:@"short_video_page_click" param:@{@"button_name":tabName}];
    
}





+ (void)trackingButtonEventName:(NSString *)eventName param:(NSDictionary*)dic
{
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:eventName forKey:@"eventName"];
    [param addEntriesFromDictionary:dic];
    [self eventUpload:param evnetKey:eventName];
}





#pragma mark - 上报数据
+(void)eventUpload:(NSDictionary*)param evnetKey:(NSString*)key
{
    NSLog(@"user_tracking_%@_%@",key,[param convertToJSON]);
    [[SZManager sharedManager].delegate onEventTracking:key param:param];
}





@end
