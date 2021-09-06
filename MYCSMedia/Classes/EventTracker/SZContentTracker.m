//
//  SZContentTracker.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/31.
//

#import "SZContentTracker.h"
#import "NSArray+MJCategory.h"
#import "NSDictionary+MJCategory.h"
#import "SZGlobalInfo.h"
#import "StatusModel.h"
#import "SZDefines.h"

@interface SZContentTracker ()
@property(strong,nonatomic)NSMutableDictionary * startTimeDic;
@property(strong,nonatomic)NSMutableDictionary * stateDic;
@property(strong,nonatomic)NSMutableDictionary * totalTimeDic;
@end

@implementation SZContentTracker



+(SZContentTracker *)shareTracker
{
    static SZContentTracker * tracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (tracker == nil)
        {
            tracker = [[SZContentTracker alloc]init];
        }
        });
    return tracker;
}



//一次性事件5个参数
+(void)trackContentEvent:(NSString*)eventName contentId:(NSString*)contentid
{
    if (eventName.length==0 || contentid.length==0)
    {
        return;
    }
    
    
    
    NSMutableDictionary * bizparam=[NSMutableDictionary dictionary];
    [bizparam setValue:@"click_category" forKey:@"enter_from"];
    [bizparam setValue:@"c2402539" forKey:@"category_name"];
    [bizparam setValue:contentid forKey:@"group_id"];
    [bizparam setValue:@"content_manager_system" forKey:@"params_for_special"];
    [bizparam setValue:[SZContentTracker make__items:contentid] forKey:@"__items"];
    
    
    [[SZContentTracker shareTracker]requestForUploading:bizparam eventKey:eventName];
    
    
}



+(void)trackingVideoPlayingDuration:(ContentModel*)model isPlaying:(BOOL)isplay currentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime
{
    //内容ID
    NSString * contentId = model.id;
    SZContentTracker * tracker = [SZContentTracker shareTracker];
    
    
    //获取之前的状态
    NSString * stateStr = [tracker.stateDic valueForKey:contentId];
    
    //如果切到播放状态
    if (isplay)
    {
        if ([stateStr isEqualToString:@"playing"])
        {
            return;
        }
        else
        {
            //记录时间
            NSInteger timestamp = [[NSDate date]timeIntervalSince1970]*1000;
            [tracker.startTimeDic setValue:[NSNumber numberWithInteger:timestamp] forKey:contentId];
        }
        
        [tracker.stateDic setValue:@"playing" forKey:contentId];
        
        [tracker.totalTimeDic setValue:[NSNumber numberWithFloat:totalTime] forKey:contentId];
    }
    
    
    //如果是切到其他状态
    else
    {
        if (![stateStr isEqualToString:@"playing"])
        {
            return;
        }
        else
        {
            //获取开始时间
            NSInteger timeNow = [[NSDate date]timeIntervalSince1970]*1000;
            NSNumber * timestampObjc = [tracker.startTimeDic valueForKey:contentId];
            NSInteger duration = timeNow - timestampObjc.integerValue;
            
            //时长过短的过滤掉
            if (duration<100)
            {
                return;
            }
            
            
            NSNumber * totaltimeNumber = [tracker.totalTimeDic valueForKey:contentId];
            
            CGFloat maxPercent = 0;
            //如果播放时长距离最大时长小于1秒，则看作100%（内核bug）
            if (totaltimeNumber.floatValue-currentTime<1.0)
            {
                //计算最大百分比
                maxPercent = 100;
            }
            else
            {
                //计算最大百分比
                maxPercent = currentTime/totaltimeNumber.floatValue * 100;
            }
            
            
            //上报
            NSMutableDictionary * bizparam=[NSMutableDictionary dictionary];
            [bizparam setValue:@"click_category" forKey:@"enter_from"];
            [bizparam setValue:@"c2402539" forKey:@"category_name"];
            [bizparam setValue:model.id forKey:@"group_id"];
            [bizparam setValue:@"content_manager_system" forKey:@"params_for_special"];
            [bizparam setValue:[SZContentTracker make__items:model.id] forKey:@"__items"];
            [bizparam setValue:[NSString stringWithFormat:@"%ld",(long)duration] forKey:@"duration"];
            [bizparam setValue:[NSString stringWithFormat:@"%g",maxPercent] forKey:@"percent"];
            
            
            [tracker requestForUploading:bizparam eventKey:@"cms_video_over_auto"];
            
            
//            NSLog(@"mjduration_%g_%g",currentTime,totaltimeNumber.floatValue);
//            NSLog(@"mjduration_时长:%ld_新闻:%@_百分比:%g",duration,model.id,maxPercent);
            
        }
        
        [tracker.stateDic setValue:@"" forKey:contentId];
    }
}


+(void)trackingVideoPlayingDuration_Replay:(ContentModel*)model isPlaying:(BOOL)isplay currentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime
{
    //内容ID
    NSString * contentId = model.id;
    SZContentTracker * tracker = [SZContentTracker shareTracker];
    
    
    //获取之前的状态
    NSString * stateStr = [tracker.stateDic valueForKey:contentId];
    
    //如果切到播放状态
    if (isplay)
    {
        if ([stateStr isEqualToString:@"playing"])
        {
            return;
        }
        else
        {
            //记录时间
            NSInteger timestamp = [[NSDate date]timeIntervalSince1970]*1000;
            [tracker.startTimeDic setValue:[NSNumber numberWithInteger:timestamp] forKey:contentId];
        }
        
        [tracker.stateDic setValue:@"playing" forKey:contentId];
        
        [tracker.totalTimeDic setValue:[NSNumber numberWithFloat:totalTime] forKey:contentId];
    }
    
    
    //如果是切到其他状态
    else
    {
        if (![stateStr isEqualToString:@"playing"])
        {
            return;
        }
        else
        {
            //获取开始时间
            NSInteger timeNow = [[NSDate date]timeIntervalSince1970]*1000;
            NSNumber * timestampObjc = [tracker.startTimeDic valueForKey:contentId];
            NSInteger duration = timeNow - timestampObjc.integerValue;
            
            //时长过短的过滤掉
            if (duration<100)
            {
                return;
            }
            
            
            NSNumber * totaltimeNumber = [tracker.totalTimeDic valueForKey:contentId];
            
            CGFloat maxPercent = 0;
            //如果播放时长距离最大时长小于1秒，则看作100%（内核bug）
            if (totaltimeNumber.floatValue-currentTime<1.0)
            {
                //计算最大百分比
                maxPercent = 100;
            }
            else
            {
                //计算最大百分比
                maxPercent = currentTime/totaltimeNumber.floatValue * 100;
            }
            
            
            
            //上报
            NSMutableDictionary * bizparam=[NSMutableDictionary dictionary];
            [bizparam setValue:@"click_category" forKey:@"enter_from"];
            [bizparam setValue:@"c2402539" forKey:@"category_name"];
            [bizparam setValue:model.id forKey:@"group_id"];
            [bizparam setValue:@"content_manager_system" forKey:@"params_for_special"];
            [bizparam setValue:[SZContentTracker make__items:model.id] forKey:@"__items"];
            [bizparam setValue:[NSString stringWithFormat:@"%ld",(long)duration] forKey:@"duration"];
            [bizparam setValue:[NSString stringWithFormat:@"%g",maxPercent] forKey:@"percent"];
            
            
            [tracker requestForUploading:bizparam eventKey:@"cms_video_over"];
            
            
            
            
//            NSLog(@"mjduration_%g_%g",currentTime,totaltimeNumber.floatValue);
//            NSLog(@"mjduration_reload_时长:%ld_新闻:%@_百分比:%g",duration,model.id,maxPercent);
            
        }
        
        [tracker.stateDic setValue:@"" forKey:contentId];
    }
}



#pragma mark - Tools
+(NSArray*)make__items:(NSString*)contentId
{
    NSDictionary * dic = @{@"id":contentId};
    
    NSArray * arr = [NSArray arrayWithObject:dic];
    
    NSDictionary * dic2 = @{@"group_item":arr};
    
    NSArray * arr2 = [NSArray arrayWithObject:dic2];
    
    return arr2;
}





#pragma mark - 工具类
+(NSString*)currentTimeStr
{
    long inter = [[NSDate date] timeIntervalSince1970]*1000;
    NSString * timestr = [NSString stringWithFormat:@"%ld",inter];
    return timestr;
}


+(NSString*)currentDeviceModel
{
    return [[UIDevice currentDevice]model];
}

+(NSString*)currentSysVersion
{
    return [[UIDevice currentDevice]systemVersion];
}


+(NSString*)currentDeviceUniqueId
{
    return [[SZManager sharedManager].delegate onGetUserDevice];
}

+(NSString*)currentAppVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}




#pragma mark - 公共参数
+(NSDictionary*)generate_User
{
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    
    [param setValue:[SZContentTracker currentDeviceUniqueId] forKey:@"bddid"];
    [param setValue:[SZContentTracker currentDeviceUniqueId] forKey:@"user_unique_id"];
    
    return param;
}


+(NSDictionary*)generate_IDS
{
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:[SZContentTracker currentDeviceUniqueId] forKey:@"device_id"];
    [param setValue:[SZContentTracker currentDeviceUniqueId] forKey:@"user_unique_id"];
    [param setValue:[SZGlobalInfo sharedManager].userId forKey:@"user_id"];
    
    return param;
}


+(NSArray*)generate_EVENTS:(NSString*)key param:(NSDictionary*)param
{
    NSMutableDictionary * event=[NSMutableDictionary dictionary];
    [event setValue:key forKey:@"event"];
    [event setValue:[SZContentTracker currentTimeStr] forKey:@"local_time_ms"];
    [event setValue:[param convertToJSON]  forKey:@"params"];
    
    NSArray * arr = [NSArray arrayWithObject:event];
    
    return arr;
}



+(NSDictionary*)generate_HEADER
{
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:@"rangers_12216_my_changsha_app" forKey:@"app_name"];
    [param setValue:@"" forKey:@"ab_sdk_version"];
    [param setValue:@"" forKey:@"app_channel"];
    [param setValue:@"" forKey:@"app_package"];
    [param setValue:@"" forKey:@"app_platform"];
    [param setValue:[SZContentTracker currentAppVersion] forKey:@"app_version"];
    [param setValue:@"" forKey:@"client_ip"];
    
    [param setValue:[SZContentTracker currentDeviceModel] forKey:@"device_model"];
    [param setValue:@"apple" forKey:@"device_brand"];
    [param setValue:@"ios" forKey:@"os_name"];
    [param setValue:[SZContentTracker currentSysVersion] forKey:@"os_version"];
    [param setValue:@"" forKey:@"platform"];
    [param setValue:@"" forKey:@"traffic_type"];
    
    return param;

}



#pragma mark - Request
-(void)requestForUploading:(NSDictionary*)bizParam eventKey:(NSString*)eventName
{
    NSArray * events = [SZContentTracker generate_EVENTS:eventName param:bizParam];
    
    NSDictionary * user = [SZContentTracker generate_User];
    
    NSDictionary * ids = [SZContentTracker generate_IDS];
    
    NSDictionary * header = [SZContentTracker generate_HEADER];
    
    
    NSMutableDictionary * requestParam=[NSMutableDictionary dictionary];
    [requestParam setValue:events forKey:@"events"];
    [requestParam setValue:user forKey:@"user"];
    [requestParam setValue:ids forKey:@"ids"];
    [requestParam setValue:header forKey:@"header"];
    
    NSLog(@"%@",[requestParam convertToJSON]);
    
    StatusModel * model = [StatusModel model];
    model.isJSON=YES;
    
    [model PostRequestInView:nil WithUrl:APPEND_SUBURL(BASE_URL, API_URL_CONTENT_TRACKING) Params:requestParam Success:^(id responseObject) {
        
    } Error:^(id responseObject) {
        
    } Fail:^(NSError *error) {
        
    }];
    
    
}





#pragma mark - 懒加载
-(NSMutableDictionary *)startTimeDic
{
    if (_startTimeDic==nil)
    {
        _startTimeDic = [NSMutableDictionary dictionary];
    }
    return _startTimeDic;;
}

-(NSMutableDictionary *)stateDic
{
    if (_stateDic==nil)
    {
        _stateDic = [NSMutableDictionary dictionary];
    }
    return _stateDic;
}

-(NSMutableDictionary *)totalTimeDic
{
    if (_totalTimeDic==nil)
    {
        _totalTimeDic = [NSMutableDictionary dictionary];
    }
    return _totalTimeDic;
}

@end