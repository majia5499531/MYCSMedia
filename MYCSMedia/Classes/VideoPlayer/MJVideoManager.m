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

+(void)playFullScreenVideoAt:(UIViewController *)controller URL:(NSString *)url
{
    //全屏VC
    MJVideoFullScreen * fullvc = [[MJVideoFullScreen alloc]init];
    fullvc.videoURL = url;
    fullvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [controller presentViewController:fullvc animated:NO completion:nil];
}

+(void)playWindowVideoAtView:(UIView*)view url:(NSString*)videoURL coverImage:(NSString*)image silent:(BOOL)silent repeat:(BOOL)repeat controlStyle:(MJVideoControlStyle)style
{
    //设置播放层
    MJVideoManager * manager = [MJVideoManager sharedMediaManager];
    manager.MJVideoView.fatherView = view;
    manager.MJVideoView.delegate = manager;

    //如果是老url
    if ([videoURL isEqualToString:manager.MJVideoView.playerModel.videoURL] && manager.MJVideoView.isLoaded)
    {
        
        //如果是暂停
        if (manager.MJVideoView.state==StatePause)
        {
            NSLog(@"播放——相同url——恢复播放");
            [manager.MJVideoView resume];
        }
        
        
        //正在播放
        else if (manager.MJVideoView.state==StatePlaying)
        {
            NSLog(@"播放——相同url——正在播放");
        }
        
        //停止播放
        else if (manager.MJVideoView.state==StateStopped)
        {
            NSLog(@"播放——相同url——已停止");
            [MJVideoManager playNewVideo:videoURL];
        }
        
        
        //不是则播放
        else
        {
            NSLog(@"播放——相同url——其他");
            [MJVideoManager playNewVideo:videoURL];
        }
    }
    
    
    //新url
    else
    {
        NSLog(@"播放——不同url");
        [MJVideoManager playNewVideo:videoURL];
    }

}





+(void)playNewVideo:(NSString*)videourl
{
    MJVideoManager * manager = [MJVideoManager sharedMediaManager];
    
    //reset
    [manager.MJVideoView destroyCorePlayer];

    //NewModel
    SuperPlayerModel * playerModel = [[SuperPlayerModel alloc] init];
    playerModel.videoURL = videourl;
    [manager.MJVideoView playWithModel:playerModel];
    
    //config
    manager.MJVideoView.playerConfig.loop = NO;
    manager.MJVideoView.playerConfig.mute=NO;
    manager.MJVideoView.playerConfig.playRate = 1.0 ;
    [manager.MJVideoView controlViewDidUpdateConfig:manager.MJVideoView withReload:NO];
}




//暂停
+(void)pauseWindowVideo
{
    MJVideoManager * manager = [MJVideoManager sharedMediaManager];
    [manager.MJVideoView pause];
}


//销毁
+(void)destroyVideoPlayer
{
    MJVideoManager * manager = [MJVideoManager sharedMediaManager];

    manager.MJVideoView.fatherView = nil;
    
    [manager.MJVideoView destroyCorePlayer];
    
}

@end
