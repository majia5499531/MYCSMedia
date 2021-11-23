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
+ (void)trackingVideoTab:(NSString *)btnTitle moduleIndex:(NSInteger)moduleIdx
{
    static NSInteger lastIdx = -1;
    NSString * eventName = @"";
    
    
    if (lastIdx==-1)
    {
        lastIdx = moduleIdx;
        return;
    }
    else if(lastIdx==moduleIdx)
    {
        return;
    }
    else if (moduleIdx==2)
    {
        
    }
    else
    {
        lastIdx = moduleIdx;
    }
    
    
    
    if (moduleIdx==0)
    {
        eventName = @"short_video_home_click";
    }
    else if(moduleIdx==1)
    {
        eventName = @"well_life_home_click";
    }
    else
    {
        if (lastIdx==0)
        {
            eventName = @"well_life_home_click";
        }
        else
        {
            eventName = @"short_video_home_click";
        }
        
        
    }
    
    
    
    
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:eventName forKey:@"eventName"];
    [param setValue:btnTitle forKey:@"button_name"];
    
    [self eventUpload:param evnetKey:eventName];
    
}

+ (void)trackingButtonClick:(NSString *)btnTitle moduleIndex:(NSInteger)moduleIdx
{
    //忽略直播tab下的按钮点击
    if (moduleIdx==2)
    {
        return;
    }
    
    NSString * eventName = @"";
    if (moduleIdx==0)
    {
        eventName = @"well_life_home_click";
    }
    else
    {
        eventName = @"short_video_home_click";
    }
    
    
    
    
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:eventName forKey:@"eventName"];
    [param setValue:btnTitle forKey:@"button_name"];
    
    [self eventUpload:param evnetKey:eventName];
    
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
    NSLog(@"user_tracking_%@",[param convertToJSON]);
    [[SZManager sharedManager].delegate onEventTracking:key param:param];
}





@end
