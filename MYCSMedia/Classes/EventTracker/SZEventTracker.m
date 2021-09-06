//
//  SZEventTracker.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/15.
//

#import "SZEventTracker.h"
#import "SZManager.h"


@interface SZEventTracker ()
@property(strong,nonatomic)NSMutableDictionary * startTimeDic;
@property(strong,nonatomic)NSMutableDictionary * stateDic;
@end

@implementation SZEventTracker



+(SZEventTracker *)shareTracker
{
    static SZEventTracker * tracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (tracker == nil)
        {
            tracker = [[SZEventTracker alloc]init];
        }
        });
    return tracker;
}




#pragma mark - API
+(void)trackingVideoPlayWithContentModel:(ContentModel *)model source:(NSString *)source isReplay:(BOOL)replay
{
    NSString * module_source = source;
    NSString * is_renew = [NSString stringWithFormat:@"%d",replay];
    NSString * content_id = model.id;
    NSString * content_name = model.title;
    NSString * content_type = @"视频";
    NSString * publish_time = model.issueTimeStamp;
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:@"首页" forKey:@"module_source"];
    [param setValue:is_renew forKey:@"is_renew"];
    [param setValue:content_id forKey:@"content_id"];
    [param setValue:content_name forKey:@"content_name"];
    [param setValue:@"" forKey:@"content_key"];
    [param setValue:@"" forKey:@"content_list"];
    [param setValue:@"" forKey:@"content_first_classify"];
    [param setValue:@"" forKey:@"content_second_classify"];
    [param setValue:content_type forKey:@"content_type"];
    [param setValue:publish_time forKey:@"publish_time"];
    
    [[SZEventTracker shareTracker]eventUpload:param evnetKey:@"video_play"];
}



+(void)trackingVideoEndWithContentModel:(ContentModel*)model totalTime:(NSString*)time;
{
    NSString * content_id = model.id;
    NSString * content_name = model.title;
    NSString * publish_time = model.issueTimeStamp;
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:content_id forKey:@"content_id"];
    [param setValue:content_name forKey:@"content_name"];
    [param setValue:@"" forKey:@"content_key"];
    [param setValue:@"" forKey:@"content_list"];
    [param setValue:@"" forKey:@"content_first_classify"];
    [param setValue:@"" forKey:@"content_second_classify"];
    [param setValue:publish_time forKey:@"publish_time"];
    [param setValue:time forKey:@"play_duration"];
    
    [[SZEventTracker shareTracker]eventUpload:param evnetKey:@"video_finish"];
}


+(void)trackingVideoDurationWithModel:(ContentModel*)model isPlaying:(BOOL)isplaying;
{
    //内容ID
    NSString * contentId = model.id;
    SZEventTracker * tracker = [SZEventTracker shareTracker];
    
    
    //获取之前的状态
    NSString * stateStr = [tracker.stateDic valueForKey:contentId];
    
    
    //如果切到播放状态
    if (isplaying)
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
            if (duration<555)
            {
                return;
            }
            
//            //配置参数
//            NSString * content_id = model.id;
//            NSString * content_name = model.title;
//            NSString * publish_time = model.issueTimeStamp;
//            NSString * play_duration = [NSString stringWithFormat:@"%ld",duration];
//
//            NSMutableDictionary * param=[NSMutableDictionary dictionary];
//            [param setValue:content_id forKey:@"content_id"];
//            [param setValue:content_name forKey:@"content_name"];
//            [param setValue:@"" forKey:@"content_key"];
//            [param setValue:@"" forKey:@"content_list"];
//            [param setValue:@"" forKey:@"content_first_classify"];
//            [param setValue:@"" forKey:@"content_second_classify"];
//            [param setValue:publish_time forKey:@"publish_time"];
//            [param setValue:play_duration forKey:@"play_duration"];
//
//            //上报
//            [[SZEventTracker shareTracker]eventUpload:param evnetKey:@"video_duration"];
        }
        
        [tracker.stateDic setValue:@"" forKey:contentId];
    }
}



+(void)trackingVideoSpeedRateWithModel:(ContentModel*)model speed:(NSString*)speed
{
    NSString * content_id = model.id;
    NSString * content_name = model.title;
    NSString * publish_time = model.issueTimeStamp;
    
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:speed forKey:@"speed_n"];
    [param setValue:content_id forKey:@"content_id"];
    [param setValue:content_name forKey:@"content_name"];
    [param setValue:@"" forKey:@"content_key"];
    [param setValue:@"" forKey:@"content_list"];
    [param setValue:@"" forKey:@"content_first_classify"];
    [param setValue:@"" forKey:@"content_second_classify"];
    [param setValue:publish_time forKey:@"publish_time"];
    
    
    [[SZEventTracker shareTracker]eventUpload:param evnetKey:@"video_click_speed"];

}



+(void)trackingCommonEvent:(ContentModel*)model eventParam:(NSDictionary*)dic eventName:(NSString*)eventName
{
    NSString * content_id = model.id;
    NSString * content_name = model.title;
    NSString * publish_time = model.issueTimeStamp;
    
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:@"视频" forKey:@"content_type"];
    [param setValue:content_id forKey:@"content_id"];
    [param setValue:content_name forKey:@"content_name"];
    [param setValue:@"" forKey:@"content_key"];
    [param setValue:@"" forKey:@"content_list"];
    [param setValue:@"" forKey:@"content_first_classify"];
    [param setValue:@"" forKey:@"content_second_classify"];
    [param setValue:publish_time forKey:@"publish_time"];
    
    //追加参数
    [param addEntriesFromDictionary:dic];
    
    [[SZEventTracker shareTracker]eventUpload:param evnetKey:eventName];
}



#pragma mark - 上报数据
-(void)eventUpload:(NSDictionary*)param evnetKey:(NSString*)key
{
    [[SZManager sharedManager].delegate onEventTracking:key param:param];
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

@end
