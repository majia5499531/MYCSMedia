#import <UIKit/UIKit.h>
#import "SuperPlayer.h"
#import "SuperPlayerModel.h"
#import "SuperPlayerViewConfig.h"

@class SuperPlayerControlView;
@class SuperPlayerView;


@protocol SuperPlayerDelegate <NSObject>
@optional
//返回事件
- (void)superPlayerDidClickBackAction:(SuperPlayerView *)player;
//全屏改变通知
- (void)superPlayerDidChangeFullScreenState:(SuperPlayerView *)player;
//播放开始通知
- (void)superPlayerDidStartPlay:(SuperPlayerView *)player;
//播放结束通知
- (void)superPlayerDidFinishPlay:(SuperPlayerView *)player;
//播放错误通知
- (void)superPlayerError:(SuperPlayerView *)player errCode:(int)code errMessage:(NSString *)why;
@end



// 播放器的状态
typedef NS_ENUM(NSInteger, SuperPlayerState) {
    StateFailed,     // 播放失败
    StateBuffering,  // 缓冲中
    StatePlaying,    // 播放中
    StateStopped,    // 停止播放
    StatePause,      // 暂停播放
};




@interface SuperPlayerView : UIView

//UI
@property (nonatomic, weak) id<SuperPlayerDelegate> delegate;
@property (nonatomic, weak) UIView *fatherView;
@property (nonatomic,strong) SuperPlayerControlView *controlView;
@property (nonatomic,strong) UIImageView *coverImageView;
@property(strong,nonatomic)UIView *fullScreenBlackView;;
@property (nonatomic, strong) UIButton *repeatBtn;
@property(strong,nonatomic)UIView * sharingView;



//状态
@property (nonatomic, assign) SuperPlayerState state;                //播放状态
@property (readonly) BOOL isLive;                                      //是否是直播流
@property (nonatomic) BOOL disableGesture;                            //是否允许竖屏手势
@property (readonly)  BOOL isDragging;                                //是否在手势中
@property (readonly)  BOOL  isLoaded;                                 //是否加载成功
@property BOOL autoPlay;                                               //是否自动播放（在playWithModel前设置)
@property (nonatomic) CGFloat playDuration;                          //视频总时长
@property (nonatomic) CGFloat playCurrentTime;                       //视频当前播放时间
@property CGFloat startTime;                                          //起始播放时间，用于从上次位置开播
@property (readonly) SuperPlayerModel *playerModel;                 //播放的视频Model
@property SuperPlayerViewConfig *playerConfig;                      //播放器配置
@property TXImageSprite *imageSprite;                                //视频雪碧图
@property NSArray *keyFrameDescList;                                 //关键帧信息




//操作API
/**
 * 播放model
 */
- (void)playWithModel:(SuperPlayerModel *)playerModel;

/**
 * 重置player
 */
- (void)destroyCorePlayer;

/**
 * 播放
 */
- (void)resume;

/**
 * 暂停
 * @warn isLoaded == NO 时暂停无效
 */
- (void)pause;

/**
 *  从xx秒开始播放视频跳转
 *
 *  @param dragedSeconds 视频跳转的秒数
 */
- (void)seekToTime:(NSInteger)dragedSeconds;




//补充
-(void)controlViewDidUpdateConfig:(SuperPlayerView *)controlView withReload:(BOOL)reload;

-(void)switchToFullScreenMode:(BOOL)fullScreen;

@end
