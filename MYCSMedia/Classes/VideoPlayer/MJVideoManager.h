//
//  SJVideoPlayer.h
//  智慧长沙
//
//  Created by 马佳 on 2019/10/10.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SuperPlayer.h"
#import "ContentModel.h"


typedef NS_ENUM(NSUInteger, MJVideoControlStyle) {
    MJCONTROL_STYLE_NORMAL = 0,
    MJCONTROL_STYLE_SHORT_VIDEO,
};

typedef NS_ENUM(NSInteger, MJVideoRenderMode) {
    MJRENDER_MODE_FILL_SCREEN    = 0,    ///< 图像铺满屏幕，不留黑边，如果图像宽高比不同于屏幕宽高比，部分画面内容会被裁剪掉。
    MJRENDER_MODE_FILL_EDGE      = 1,    ///< 图像适应屏幕，保持画面完整，但如果图像宽高比不同于屏幕宽高比，会有黑边的存在。
};


@interface MJVideoManager : NSObject

+ (MJVideoManager *)sharedMediaManager;





#pragma mark - Video
+(void)playWindowVideoAtView:(UIView*)view url:(NSString*)videoURL contentModel:(ContentModel*)model renderModel:(MJVideoRenderMode)renderMode controlMode:(MJVideoControlStyle)controlUI;
+(void)pauseWindowVideo;
+(void)destroyVideoPlayer;
+(SuperPlayerView *)videoPlayer;



@end
