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
#import "SZUserTracker.h"

@interface SZContentTracker ()
@property(strong,nonatomic)NSMutableDictionary * startTimeDic;
@property(strong,nonatomic)NSMutableDictionary * stateDic;
@property(strong,nonatomic)NSMutableDictionary * totalTimeDic;
@property(strong,nonatomic)NSMutableDictionary * progressDic;
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



#pragma mark - 追踪事件
//一次性事件5个参数
+(void)trackContentEvent:(NSString*)eventName content:(ContentModel*)model
{
    NSString * groupId = model.thirdPartyId;
    
    if (model.thirdPartyId.length==0)
    {
        groupId = model.id;
    }
    
    NSMutableDictionary * bizparam=[NSMutableDictionary dictionary];
    [bizparam setValue:@"click_category" forKey:@"enter_from"];
    [bizparam setValue:model.volcCategory forKey:@"category_name"];
    [bizparam setValue:groupId forKey:@"group_id"];
    [bizparam setValue:@"content_manager_system" forKey:@"params_for_special"];
    [bizparam setValue:[SZContentTracker make__items:groupId] forKey:@"__items"];
    [bizparam setValue:model.requestId forKey:@"req_id"];
    
    [[SZContentTracker shareTracker]requestForUploading:bizparam eventKey:eventName contentModel:model];
        
    NSLog(@"MJContentTracker_once_事件:%@_新闻:%@_cateName:%@",eventName,groupId,model.volcCategory);
}


//播放时长（自动版）
+(void)trackingVideoPlayingDuration:(ContentModel*)model isPlaying:(BOOL)isplay currentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime
{
    //内容ID
    NSString * groupId = model.thirdPartyId;
    if (groupId.length==0)
    {
        groupId = model.id;
    }
    
    
    
    SZContentTracker * tracker = [SZContentTracker shareTracker];
    
    //获取之前的状态
    NSString * stateStr = [tracker.stateDic valueForKey:groupId];
    
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
            [tracker.startTimeDic setValue:[NSNumber numberWithInteger:timestamp] forKey:groupId];
        }
        
        [tracker.stateDic setValue:@"playing" forKey:groupId];
        
        
        //记录总时长
        [tracker.totalTimeDic setValue:[NSNumber numberWithFloat:totalTime] forKey:groupId];
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
            NSNumber * timestampObjc = [tracker.startTimeDic valueForKey:groupId];
            NSInteger duration = timeNow - timestampObjc.integerValue;
            
            //时长过短的过滤掉
            if (duration<100)
            {
                return;
            }
            
            
            //最大进度
            NSNumber * progressNumber = [tracker.progressDic valueForKey:groupId];
            
            
            //上报
            NSMutableDictionary * bizparam=[NSMutableDictionary dictionary];
            [bizparam setValue:@"click_category" forKey:@"enter_from"];
            [bizparam setValue:model.volcCategory forKey:@"category_name"];
            [bizparam setValue:groupId forKey:@"group_id"];
            [bizparam setValue:@"content_manager_system" forKey:@"params_for_special"];
            [bizparam setValue:[SZContentTracker make__items:groupId] forKey:@"__items"];
            [bizparam setValue:[NSString stringWithFormat:@"%ld",(long)duration] forKey:@"duration"];
            [bizparam setValue:progressNumber forKey:@"percent"];
            [bizparam setValue:model.requestId forKey:@"req_id"];
            [tracker requestForUploading:bizparam eventKey:@"cms_video_over_auto" contentModel:model];
            
            
            
            //行为埋点
            ContentModel * contentM = model;
            NSString * finishState = contentM.isFinishPlay? @"是":@"否";
            NSMutableDictionary * param=[NSMutableDictionary dictionary];
            [param setValue:contentM.id forKey:@"content_id"];
            [param setValue:contentM.title forKey:@"content_name"];
            [param setValue:contentM.source forKey:@"content_source"];
            [param setValue:contentM.createBy forKey:@"creator_id"];
            [param setValue:contentM.thirdPartyId forKey:@"third_ID"];
            [param setValue:contentM.keywords forKey:@"content_key"];
            [param setValue:contentM.tags forKey:@"content_list"];
            [param setValue:contentM.classification forKey:@"content_classify"];
            [param setValue:contentM.startTime forKey:@"create_time"];
            [param setValue:contentM.issueTimeStamp forKey:@"publish_time"];
            [param setValue:contentM.type forKey:@"content_type"];
            [param setValue:[NSNumber numberWithInteger:duration] forKey:@"play_duration"];
            [param setValue:finishState forKey:@"is_finish"];
            [SZUserTracker trackingButtonEventName:@"content_video_duration" param:param];
            
            
            

            NSLog(@"MJContentTracker_end_auto_时长:%@_新闻:%@_百分比:%@_cateName:%@",[NSNumber numberWithInteger:duration],groupId,progressNumber,model.volcCategory);
            
        }
        
        [tracker.stateDic setValue:@"" forKey:groupId];
    }
}


//播放时长（手动版）
+(void)trackingVideoPlayingDuration_manual:(ContentModel*)model isPlaying:(BOOL)isplay currentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime
{
    //内容ID
    NSString * groupId = model.thirdPartyId;
    
    if (groupId.length==0)
    {
        groupId = model.id;
    }
    
    
    SZContentTracker * tracker = [SZContentTracker shareTracker];
    
    
    //获取之前的状态
    NSString * stateStr = [tracker.stateDic valueForKey:groupId];
    
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
            [tracker.startTimeDic setValue:[NSNumber numberWithInteger:timestamp] forKey:groupId];
        }
        
        [tracker.stateDic setValue:@"playing" forKey:groupId];
        
        [tracker.totalTimeDic setValue:[NSNumber numberWithFloat:totalTime] forKey:groupId];
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
            NSNumber * timestampObjc = [tracker.startTimeDic valueForKey:groupId];
            NSInteger duration = timeNow - timestampObjc.integerValue;
            
            //时长过短的过滤掉
            if (duration<100)
            {
                return;
            }
            
            
            //最大百分比
            NSNumber * progressNumber = [tracker.progressDic valueForKey:groupId];
            
            //上报
            NSMutableDictionary * bizparam=[NSMutableDictionary dictionary];
            [bizparam setValue:@"click_category" forKey:@"enter_from"];
            [bizparam setValue:model.volcCategory forKey:@"category_name"];
            [bizparam setValue:groupId forKey:@"group_id"];
            [bizparam setValue:@"content_manager_system" forKey:@"params_for_special"];
            [bizparam setValue:[SZContentTracker make__items:groupId] forKey:@"__items"];
            [bizparam setValue:[NSString stringWithFormat:@"%ld",(long)duration] forKey:@"duration"];
            [bizparam setValue:progressNumber forKey:@"percent"];
            [bizparam setValue:model.requestId forKey:@"req_id"];
            
            [tracker requestForUploading:bizparam eventKey:@"cms_video_over" contentModel:model];
            
            
            
            //行为埋点
            ContentModel * contentM = model;
            NSMutableDictionary * param=[NSMutableDictionary dictionary];
            NSString * finishState = contentM.isFinishPlay? @"是":@"否";
            [param setValue:contentM.id forKey:@"content_id"];
            [param setValue:contentM.title forKey:@"content_name"];
            [param setValue:contentM.source forKey:@"content_source"];
            [param setValue:contentM.createBy forKey:@"creator_id"];
            [param setValue:contentM.thirdPartyId forKey:@"third_ID"];
            [param setValue:contentM.keywords forKey:@"content_key"];
            [param setValue:contentM.tags forKey:@"content_list"];
            [param setValue:contentM.classification forKey:@"content_classify"];
            [param setValue:contentM.startTime forKey:@"create_time"];
            [param setValue:contentM.issueTimeStamp forKey:@"publish_time"];
            [param setValue:contentM.type forKey:@"content_type"];
            [param setValue:[NSNumber numberWithInteger:duration] forKey:@"play_duration"];
            [param setValue:finishState forKey:@"is_finish"];
            [SZUserTracker trackingButtonEventName:@"content_video_duration" param:param];
            
            
            NSLog(@"MJContentTracker_end_manual_时长:%@_新闻:%@_百分比:%@_cateName:%@",[NSNumber numberWithInteger:duration],groupId,progressNumber,model.volcCategory);
            
        }
        
        [tracker.stateDic setValue:@"" forKey:groupId];
    }
}


+(void)recordPlayingProgress:(CGFloat)progess content:(ContentModel*)contentM
{
    NSString * groupId = contentM.thirdPartyId;
    if (groupId.length==0)
    {
        groupId = contentM.id;
    }
    
    progess = progess * 100.00;
    
    SZContentTracker * tracker = [SZContentTracker shareTracker];
    
    NSNumber * progressNumber = [tracker.progressDic valueForKey:groupId];
    
    //为空则记录
    if (progressNumber==nil)
    {
        
        progressNumber = [NSNumber numberWithFloat:progess];
    }
    else
    {
        CGFloat lasetProgress = progressNumber.floatValue;

        
        //有更大值则记录
        if (progess>lasetProgress)
        {
            progressNumber = [NSNumber numberWithFloat:progess];
        }
        
    }
    
    
    
    [[SZContentTracker shareTracker].progressDic setValue:progressNumber forKey:groupId];
}


#pragma mark - 工具方法
+(NSArray*)make__items:(NSString*)contentId
{
    NSDictionary * dic = @{@"id":contentId};
    
    NSArray * arr = [NSArray arrayWithObject:dic];
    
    NSDictionary * dic2 = @{@"group_item":arr};
    
    NSArray * arr2 = [NSArray arrayWithObject:dic2];
    
    return arr2;
}

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
-(void)requestForUploading:(NSDictionary*)bizParam eventKey:(NSString*)eventName contentModel:(ContentModel*)content
{
    if (content.thirdPartyId.length==0 || content.volcCategory.length==0)
    {
        return;
    }
    
//    NSString * contentId = [bizParam valueForKey:@"group_id"];
//    NSLog(@"request_%@_%@",eventName,content.brief.length>0 ? content.brief : content.title);
    
    
    NSArray * events = [SZContentTracker generate_EVENTS:eventName param:bizParam];
    
    NSDictionary * user = [SZContentTracker generate_User];
    
    NSDictionary * ids = [SZContentTracker generate_IDS];
    
    NSDictionary * header = [SZContentTracker generate_HEADER];
    
    
    NSMutableDictionary * requestParam=[NSMutableDictionary dictionary];
    [requestParam setValue:events forKey:@"events"];
    [requestParam setValue:user forKey:@"user"];
    [requestParam setValue:ids forKey:@"ids"];
    [requestParam setValue:header forKey:@"header"];
    
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
-(NSMutableDictionary *)progressDic
{
    if (_progressDic==nil)
    {
        _progressDic = [NSMutableDictionary dictionary];
    }
    return _progressDic;;
}

@end
