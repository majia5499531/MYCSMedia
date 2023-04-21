//
//  SJVideoPlayer.m
//  智慧长沙
//
//  Created by 马佳 on 2019/10/10.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import "MJVideoManager.h"
#import "MJVideoFullScreen.h"
#import <SDWebImage/SDWebImage.h>
#import "SZUserTracker.h"
#import "SZContentTracker.h"
@interface MJVideoManager ()<SuperPlayerDelegate>

//腾讯
@property(strong,nonatomic)SuperPlayerView * MJVideoView;

@end

@implementation MJVideoManager

#pragma mark - Singleton
+ (MJVideoManager *)sharedMediaManager
{
    static MJVideoManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil)
        {
            manager = [[MJVideoManager alloc]init];
            manager.MJVideoView = [[SuperPlayerView alloc] init];
        }
        });
    return manager;
}




#pragma mark - 腾讯播放器
+(SuperPlayerView *)videoPlayer
{
    return [MJVideoManager sharedMediaManager].MJVideoView;
}



+(void)playWindowVideoAtView:(UIView*)view url:(NSString*)videoURL contentModel:(ContentModel*)model renderModel:(MJVideoRenderMode)renderMode controlMode:(MJVideoControlStyle)controlUI
{
    //设置播放层
    MJVideoManager * manager = [MJVideoManager sharedMediaManager];
    manager.MJVideoView.fatherView = view;
    manager.MJVideoView.delegate = manager;
    if (controlUI==MJCONTROL_STYLE_SHORT_VIDEO)
    {
        manager.MJVideoView.disableInteraction = YES;
        manager.MJVideoView.controlView.hidden = YES;
    }
    else
    {
        manager.MJVideoView.disableInteraction=NO;
        manager.MJVideoView.controlView.hidden=NO;
    }
    
    
    
    //发广播
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SZRMVideoWillPlay" object:nil];
    
    //如果是老url，并且已经加载完成
    if ([videoURL isEqualToString:manager.MJVideoView.playerModel.videoURL] && manager.MJVideoView.isLoaded)
    {
        
        //如果是暂停
        if (manager.MJVideoView.playerState==StatePause)
        {
            [manager.MJVideoView resume];
        }
        
        
        //正在播放
        else if (manager.MJVideoView.playerState==StatePlaying)
        {
            [manager.MJVideoView resume];
        }
        
        //停止播放
        else if (manager.MJVideoView.playerState==StateStopped)
        {
            [MJVideoManager playNewVideo:videoURL contentModel:model renderMode:renderMode];
        }
        
        
        //不是则播放
        else
        {
            [MJVideoManager playNewVideo:videoURL contentModel:model renderMode:renderMode];
        }
    }
    
    
    //新url
    else
    {
        [MJVideoManager playNewVideo:videoURL contentModel:model renderMode:renderMode];
    }
    
}




//播放新视频
+(void)playNewVideo:(NSString*)videourl contentModel:(ContentModel*)contentModel renderMode:(MJVideoRenderMode)renderMode
{
    MJVideoManager * manager = [MJVideoManager sharedMediaManager];
    
    //删除原播放器
    [manager.MJVideoView destroyCorePlayer];
    
    //归零初始配置
    manager.MJVideoView.playerConfig.loop = NO;
    manager.MJVideoView.playerConfig.mute=NO;
    manager.MJVideoView.playerConfig.playRate = 1.0 ;
    manager.MJVideoView.playerConfig.renderMode = renderMode;
    
    
    //content model
    manager.MJVideoView.externalModel = contentModel;
    
    //是否是自动播放（手动播放会埋点不同的事件）
    manager.MJVideoView.isManualPlay = contentModel.isManualPlay;
    
    //NewModel
    SuperPlayerModel * playerModel = [[SuperPlayerModel alloc] init];
    playerModel.videoURL = videourl;
    [manager.MJVideoView playWithModel:playerModel];
    
    //tracking
    [SZContentTracker trackContentEvent:@"cms_client_show" content:contentModel];
}



//暂停
+(void)pauseWindowVideo
{
    MJVideoManager * manager = [MJVideoManager sharedMediaManager];
    
    if (manager.MJVideoView.isLoaded)
    {
        [manager.MJVideoView pause];
        manager.MJVideoView.playerState=StateIntoBackground;
        
    }
    else
    {
        [MJVideoManager destroyVideoPlayer];
    }
}


//销毁
+(void)destroyVideoPlayer
{
    MJVideoManager * manager = [MJVideoManager sharedMediaManager];
    manager.MJVideoView.fatherView = nil;
    [manager.MJVideoView destroyCorePlayer];
}




@end
