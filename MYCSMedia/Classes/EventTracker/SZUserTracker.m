//
//  SZUserTracker.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/15.
//

#import "SZUserTracker.h"
#import "SZManager.h"


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
+ (void)trackingButtonClick:(NSString *)btnTitle moduleName:(NSString *)module
{
    
}

+ (void)trackingButtonClick:(NSString *)btnTitle
{
    
}





#pragma mark - 上报数据
-(void)eventUpload:(NSDictionary*)param evnetKey:(NSString*)key
{
    [[SZManager sharedManager].delegate onEventTracking:key param:param];
}





@end
