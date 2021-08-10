//
//  ZQVideoFullScreen.m
//  ZQVideoPlayer
//
//  Created by wang on 2018/10/20.
//  Copyright © 2018 wang. All rights reserved.
//

#import "MJVideoFullScreen.h"
#import "SuperPlayer.h"
#import "MJVideoManager.h"
@interface MJVideoFullScreen ()<SuperPlayerDelegate>
@end

@implementation MJVideoFullScreen

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        self.view.backgroundColor= [UIColor blackColor];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    SuperPlayerView * playview = [MJVideoManager videoPlayer];
    
    
    //重置状态
    [playview destroyCorePlayer];
    
    //play
    SuperPlayerModel * playerModel = [[SuperPlayerModel alloc] init];
    playerModel.videoURL = self.videoURL;
    
    playview.coverImageView.backgroundColor=[UIColor blackColor];
    playview.playerConfig.loop = NO;
    playview.playerConfig.mute=NO;
    playview.playerConfig.playRate=1.0;
    [playview playWithModel:playerModel];
    
    //全屏
    playview.controlView.fullScreenState=YES;
    playview.controlView.onlyFullscreenMode=YES;
    playview.delegate=self;
    
    [playview switchToFullScreenMode:YES];
}



#pragma mark - Delegate
- (void)superPlayerDidClickBackAction:(SuperPlayerView *)player
{
    SuperPlayerView * playview = [MJVideoManager videoPlayer];
    [player setFatherView:nil];
    playview.controlView.fullScreenState=NO;
    playview.controlView.onlyFullscreenMode=NO;
    [playview switchToFullScreenMode:NO];
    
    [player pause];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
