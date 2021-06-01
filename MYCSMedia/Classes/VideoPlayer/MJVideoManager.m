//
//  SJVideoPlayer.m
//  智慧长沙
//
//  Created by 马佳 on 2019/10/10.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import "MJVideoManager.h"
#import "MJVideoFullScreen.h"



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
    //播放地址容错
    if (videoURL.length==0)
    {
        NSLog(@"播放地址出错啦");
        return;
    }

    //设置播放层
    MJVideoManager * manager = [MJVideoManager sharedMediaManager];
    manager.MJVideoView.fatherView = view;
    manager.MJVideoView.delegate = manager;

    //如果是之前播放，被暂停了
    if ([videoURL isEqualToString:manager.MJVideoView.playerModel.videoURL] && manager.MJVideoView.isLoaded && manager.MJVideoView.repeatBtn.hidden==YES)
    {
        //暂停
        [manager.MJVideoView resume];
    }
    else
    {
        //停止
        [manager.MJVideoView resetPlayer];

        //设置新URL（该方法仅设置URL）
        SuperPlayerModel * playerModel = [[SuperPlayerModel alloc] init];
        playerModel.videoURL = videoURL;
        [manager.MJVideoView playWithModel:playerModel];
    }
    
    //封面
    manager.MJVideoView.coverImageView.backgroundColor=[UIColor blackColor];
    
    //重复播放
    manager.MJVideoView.loop = repeat;
    
    //静音
    manager.MJVideoView.playerConfig.mute=silent;
    
    if (style==MJControlStyleDisalbeGesture)
    {
        manager.MJVideoView.controlView.hidden=YES;
        manager.MJVideoView.disableGesture=YES;
    }
    else
    {
        manager.MJVideoView.disableGesture=NO;
    }
    
    //更新配置
    [manager.MJVideoView controlViewDidUpdateConfig:manager.MJVideoView withReload:NO];
}

//销毁或暂停
+(void)cancelPlayingWindowVideo
{
    MJVideoManager * manager = [MJVideoManager sharedMediaManager];

    manager.MJVideoView.fatherView = nil;
    
    //未加载完时，直接销毁
    if (manager.MJVideoView.isLoaded == NO)
    {
        [manager.MJVideoView resetPlayer];
    }
    else
    {
        [manager.MJVideoView pause];
    }
}

//暂停
+(void)pauseWindowVideo
{
    MJVideoManager * manager = [MJVideoManager sharedMediaManager];
    [manager.MJVideoView pause];
}


@end
