#import "SuperPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "SuperPlayer.h"
#import "SuperPlayerControlViewDelegate.h"
#import "J2Obj.h"
#import "SuperPlayerView+Private.h"
#import "DataReport.h"
#import "TXCUrl.h"
#import "StrUtils.h"
#import "UIView+Fade.h"
#import "TXBitrateItemHelper.h"
#import "UIView+MMLayout.h"
#import "SPDefaultControlView.h"
#import "MJVideoFullScreen.h"
#import "MJVideoManager.h"
#import "UIImage+MJCategory.h"
#import "SZData.h"
#import "SZGlobalInfo.h"
#import "SZUserTracker.h"
#import "SZContentTracker.h"
#import "SZUserTracker.h"


static UISlider * _volumeSlider;

#define CellPlayerFatherViewTag  200

//忽略编译器的警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"




@implementation SuperPlayerView
{
    SuperPlayerState playstate_beforeIntoBackground;
    SuperPlayerControlView *_controlView;           //控制层
}



#pragma mark - 生命周期
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initializeThePlayer];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initializeThePlayer];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    //让视图层frame与本层保持一致
    if (self.subviews.count > 0)
    {
        UIView *innerView = self.subviews[0];
        if ([innerView isKindOfClass:NSClassFromString(@"TXIJKSDLGLView")] ||
            [innerView isKindOfClass:NSClassFromString(@"TXCAVPlayerView")])
        {
            innerView.frame = self.bounds;
        }
    }
}

-(void)dealloc
{
    [self removeAllNotifications];
    
    [self.netWatcher stopWatch];
    
    [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
    
    [self.volumeView removeFromSuperview];
}


#pragma mark - 初始化
-(void)initializeThePlayer
{
    //bgcolor
    self.backgroundColor=[UIColor clearColor];
    
    //创建一个系统音量view，隐藏在屏幕外，是为了监听音量变化，且不再展示系统默认的音量view
    CGRect frame = CGRectMake(0, -100, 10, 0);
    self.volumeView = [[MPVolumeView alloc] initWithFrame:frame];
    [self.volumeView sizeToFit];
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (!window.isHidden)
        {
            [window addSubview:self.volumeView];
            break;
        }
    }
    
    //单例slider
    _volumeSlider = nil;
    for (UIView *view in [self.volumeView subviews])
    {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"])
        {
            _volumeSlider = (UISlider *)view;
            break;
        }
    }
    
    //配置
    _playerConfig = [[SuperPlayerViewConfig alloc] init];
    
    //自动播放
    self.autoPlay = YES;
    
    //网络监控
    self.netWatcher = [[NetWatcher alloc] init];
    
    //网络监控
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    
    //添加监听
    [self addNotifications];
    
    //添加手势监听
    [self addGestureRecognizers];

}




#pragma mark - Setter
//设置播放的状态
-(void)setPlayerState:(SuperPlayerState)playerState
{
    _playerState = playerState;
    
//    NSLog(@"playstate_%@_%@",[self playStateDesc:playerState] , self.externalModel.title);
    
    
    //内容埋点
    if (self.isManualPlay)
    {
        if (playerState==2)
        {
            [SZContentTracker trackingVideoPlayingDuration_manual:self.externalModel isPlaying:YES currentTime:self.playCurrentTime totalTime:self.vodPlayer.duration];
        }
        else if (playerState == StateFailed || playerState==StateStopped || playerState==StateIntoBackground) //失败、停止、切后台，则记录时间
        {
            [SZContentTracker trackingVideoPlayingDuration_manual:self.externalModel isPlaying:NO currentTime:self.playCurrentTime totalTime:0];
        }
    }
    else
    {
        if (playerState==2)
        {
            [SZContentTracker trackingVideoPlayingDuration:self.externalModel isPlaying:YES currentTime:self.playCurrentTime totalTime:self.vodPlayer.duration];
        }
        else if (playerState == StateFailed || playerState==StateStopped || playerState==StateIntoBackground) //失败、停止、切后台，则记录时间
        {
            [SZContentTracker trackingVideoPlayingDuration:self.externalModel isPlaying:NO currentTime:self.playCurrentTime totalTime:0];
        }
    }
    
    
    
    //重播时长
    if (self.isReplay)
    {
        
    }
    
    
    
    //是否在缓冲
    if (playerState == StateBuffering)
    {
        [self.spinner startAnimating];
    }
    else
    {
        [self.spinner stopAnimating];
    }
    
    
    self.middlePlayBtn.hidden=YES;
    
    //播放状态
    if (playerState == StatePlaying)
    {
        if (self.coverImageView.alpha == 1)
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.coverImageView.alpha = 0;
            }];
        }
    }
    else if (playerState == StateFailed)
    {
        
    }
    else if (playerState == StateStopped)
    {
        self.coverImageView.alpha = 1;
    }
    
    else if (playerState == StatePause)
    {
        if (!self.controlView.isFullScreen)
        {
            self.middlePlayBtn.hidden=NO;
        }
        
    }
}

//设置控制层
-(void)setControlView:(SuperPlayerControlView *)controlView
{
    //创建控制层
    if (_controlView == controlView)
    {
        return;
    }
    [_controlView removeFromSuperview];
    controlView.delegate = self;
    [self addSubview:controlView];
    
    //初始化
    [controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [controlView playerBegin:self.playerModel isLive:self.isLive isTimeShifting:self.isShiftPlayback isAutoPlay:self.autoPlay];
    [controlView setTitle:_controlView.title];
    [controlView setPointArray:_controlView.pointArray];
    
    //保存指针
    _controlView = controlView;
}

-(void)addPlayerToFatherView:(UIView *)view
{
    [self removeFromSuperview];
    
    if (view)
    {
        [view addSubview:self];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsZero);
        }];
    }
}

-(void)setFatherView:(UIView *)fatherView
{
    if (fatherView != _fatherView)
    {
        [self addPlayerToFatherView:fatherView];
    }
    _fatherView = fatherView;
}







#pragma mark - 监听 设备 & 手势
-(void)addNotifications
{
    //app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    
    //app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //监测设备方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    //监听系统音量
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(volumeChanged:)
                                                         name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                       object:nil];
    
}


-(void)removeAllNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [self removeObserver:self forKeyPath:@"state"];
}


//添加手势
-(void)addGestureRecognizers
{
    //单击
    self.singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
    self.singleTap.delegate                = self;
    self.singleTap.numberOfTouchesRequired = 1; //手指数
    self.singleTap.numberOfTapsRequired    = 1;
    [self addGestureRecognizer:self.singleTap];
    
    //双击(播放/暂停)
    self.doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    self.doubleTap.delegate                = self;
    self.doubleTap.numberOfTouchesRequired = 1; //手指数
    self.doubleTap.numberOfTapsRequired    = 2;
    [self addGestureRecognizer:self.doubleTap];

    //解决点击当前view时候响应其他控件事件
    [self.singleTap setDelaysTouchesBegan:YES];
    [self.doubleTap setDelaysTouchesBegan:YES];
    
    //双击失败响应单击事件
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    
    //添加平移手势，用来控制音量、亮度、快进快退
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    panRecognizer.delegate = self;
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelaysTouchesBegan:YES];
    [panRecognizer setDelaysTouchesEnded:YES];
    [panRecognizer setCancelsTouchesInView:YES];
    [self addGestureRecognizer:panRecognizer];
}



#pragma mark - 设备监听回调
//进入后台
- (void)appDidEnterBackground:(NSNotification *)notify
{
    self.didEnterBackground = YES;
    
    playstate_beforeIntoBackground = self.playerState;
    self.playerState = StateIntoBackground;
    
    if (self.isLive)
    {
        return;
    }
    if (!self.isPauseByUser && (self.playerState != StateStopped && self.playerState != StateFailed))
    {
        [_vodPlayer pause];
    }
}


//进入前台
- (void)appDidEnterPlayground:(NSNotification *)notify
{
    self.didEnterBackground = NO;
    
    if (self.isLive)
    {
        return;
    }
    else if (self.isPauseByUser)
    {
        return;
    }
    else if (playstate_beforeIntoBackground == StateStopped)
    {
        return;
    }
    else if(playstate_beforeIntoBackground == StateFailed)
    {
        return;
    }
    else
    {
        [_vodPlayer resume];
    }
}


//音量
-(void)volumeChanged:(NSNotification *)notification
{
    //正在拖动，不响应音量事件
    if (self.isDragging)
    {
        return;
    }
    
    //如果已经播放完成
    if (self.playerState== StateStopped)
    {
        return;
    }
    
    if (![[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"] isEqualToString:@"ExplicitVolumeChange"])
    {
        return;
    }
    
    float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    [self showVolumnFastview:SuperPlayerImage(@"sound_max") progress:volume];
    [self.fastView fadeOut:1];
}

//屏幕方向变化
-(void)onDeviceOrientationChange
{
    //全屏下，响应旋转事件
    if (self.controlView.isFullScreen)
    {
        [self MJChangeScreenOrient];
    }
    
}





#pragma mark - 手势回调
//单击手势
-(void)singleTapAction:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized)
    {
        //播放完成则不响应
        if (self.playDidEnd)
        {
            return;
        }
        
        //控制层样式
        if (self.controlView.hidden)
        {
            //非全屏，切无手势模式下，则不现实controlview
            if (self.disableInteraction && !self.controlView.isFullScreen)
            {
                SPDefaultControlView * controlv = (SPDefaultControlView*)self.controlView;
                controlv.externalSlider.hidden = !controlv.externalSlider.hidden;
                controlv.externalFullScreenBtn.hidden = !controlv.externalFullScreenBtn.hidden;
            }
            else
            {
                [[self.controlView fadeShow] fadeOut:3];
            }
        }
        
        else
        {
            [self.controlView fadeOut:0.1];
        }
    }
}


//双击手势
-(void)doubleTapAction:(UIGestureRecognizer *)gesture
{
    if (self.playDidEnd)
    {
        return;
    }
    
    
    //非全屏，切无手势模式下，则不现实controlview
    if (self.disableInteraction && !self.controlView.isFullScreen)
    {
        
    }
    else
    {
        [self.controlView fadeShow];
    }
    
    
    //暂停与续播
    if (self.isPauseByUser)
    {
        [self resume];
    }
    else
    {
        [self pause];
    }
}



//平移手势事件
-(void)panGestureAction:(UIPanGestureRecognizer *)pan
{
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [pan locationInView:self];
    
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self];
    
    if (self.playerState == StateStopped)
    {
        return;
    }
    
    // 判断是垂直移动还是水平移动
    switch (pan.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            //开始移动
            //使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            
            //水平移动
            if (x > y)
            {
                self.panDirection = PanDirectionHorizontalMoved;
                self.sumTime      = [self playCurrentTime];
            }
            
            //垂直移动
            else if (x < y)
            {
                self.panDirection = PanDirectionVerticalMoved;
                
                //滑动屏幕左边，为亮度，右边为音量
                if (locationPoint.x > self.bounds.size.width / 2)
                {
                    self.isVolume = YES;
                }
                else
                {
                    self.isVolume = NO;
                }
                
            }
            
            self.isDragging = YES;
            
            [self.controlView fadeOut:0.2];
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            // 正在移动
            switch (self.panDirection)
            {
                case PanDirectionHorizontalMoved:
                {
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case PanDirectionVerticalMoved:
                {
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            self.isDragging = YES;
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection)
            {
                case PanDirectionHorizontalMoved:
                {
                    self.isPauseByUser = NO;
                    [self seekToTime:self.sumTime];
                    // 把sumTime滞空，不然会越加越多
                    self.sumTime = 0;
                    break;
                }
                case PanDirectionVerticalMoved:
                {
                    // 垂直移动结束后，把状态改为不再控制音量
                    self.isVolume = NO;
                    break;
                }
                default:
                    break;
            }
            
            [self hideFastview];
            
            self.isDragging = NO;
            
            break;
        }
        case UIGestureRecognizerStateCancelled:
        {
            self.sumTime = 0;
            self.isVolume = NO;
            
            [self hideFastview];
            
            self.isDragging = NO;
        }
        default:
            break;
    }
}


-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        return YES;
    }

    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        if (!self.isLoaded)
        {
            return NO;
        }
        if (self.controlView.isLockScreen)
        {
            return NO;
        }
        
        //非全屏一律不响应滑动手势
        if (self.controlView.isFullScreen==NO)
        {
            return NO;
        }
        
        return YES;
    }
    
    return NO;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        if (self.playDidEnd)
        {
            return NO;
        }
    }

    if ([touch.view isKindOfClass:[UISlider class]] || [touch.view.superview isKindOfClass:[UISlider class]])
    {
        return NO;
    }

    return YES;
}




//垂直移动
-(void)verticalMoved:(CGFloat)value
{
   
    self.isVolume ? ([[self class] volumeViewSlider].value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);

    //判断是调节亮度还是调节音量
    if (self.isVolume)
    {
        [self showVolumnFastview:SuperPlayerImage(@"sound_max") progress:[[self class] volumeViewSlider].value];
    }
    else
    {
        [self showVolumnFastview:SuperPlayerImage(@"light_max") progress:[UIScreen mainScreen].brightness];
    }
}

//水平移动
-(void)horizontalMoved:(CGFloat)value
{
    //每次滑动需要叠加时间
    CGFloat totalMovieDuration = [self playDuration];
    self.sumTime += value / 10000 * totalMovieDuration;
    
    //最大等于总时长
    if (self.sumTime > totalMovieDuration)
    {
        self.sumTime = totalMovieDuration;
        
    }
    
    //最小等于0
    if (self.sumTime < 0)
    {
        self.sumTime = 0;
    }
    
    //显示快进视图
    [self showProgressFastview:self.sumTime];
}


//修改拖动状态
-(void)setDragging:(BOOL)dragging
{
    _isDragging = dragging;
}


#pragma mark - 设置子视图
//展示fastview--音量、亮度等
-(void)showVolumnFastview:(UIImage *)image progress:(CGFloat)draggedValue
{
    if (self.controlView.isShowSecondView)
    {
        return;
    }
    [self.fastView showImg:image withProgress:draggedValue];
    
    
    [self.fastView fadeShow];
    
    
}


//展示fastview--进度
-(void)showProgressFastview:(NSInteger)draggedTime
{
    NSInteger totalTime = [self playDuration];
    NSString *currentTimeStr = [StrUtils timeFormat:draggedTime];
    NSString *totalTimeStr   = [StrUtils timeFormat:totalTime];
    NSString *timeStr        = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totalTimeStr];
    if (self.isLive)
    {
        timeStr = [NSString stringWithFormat:@"%@", currentTimeStr];
    }
    
    UIImage * thumbnail;
    
    if (self.controlView.isFullScreen)
    {
        thumbnail = [self.imageSprite getThumbnail:draggedTime];
    }
    if (thumbnail)
    {
        self.fastView.videoRatio = self.videoRatio;
        [self.fastView showThumbnail:thumbnail withText:timeStr];
    }
    else
    {
        CGFloat sliderValue = 1;
        if (totalTime > 0)
        {
            sliderValue = (CGFloat)draggedTime/totalTime;
        }
        if (self.isLive && totalTime > MAX_SHIFT_TIME) {
            CGFloat base = totalTime - MAX_SHIFT_TIME;
            if (self.sumTime < base)
                self.sumTime = base;
            sliderValue = (self.sumTime - base) / MAX_SHIFT_TIME;
            NSLog(@"%f",sliderValue);
        }
        [self.fastView showText:timeStr withText:sliderValue];
    }
    [self.fastView fadeShow];
}


-(void)hideFastview
{
    [self.fastView fadeOut:0.1];
}


-(void)showMiddleBtnMsg:(NSString *)msg withAction:(ButtonAction)action
{
    [self.middleBlackBtn setTitle:msg forState:UIControlStateNormal];
    self.middleBlackBtn.titleLabel.text = msg;
    self.middleBlackBtnAction = action;
    CGFloat width = self.middleBlackBtn.titleLabel.attributedText.size.width;
    
    [self.middleBlackBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(width+10));
    }];
    [self.middleBlackBtn fadeShow];
}


-(void)openPhotos
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"photos-redirect://"]];
}

- (CGFloat)sliderPosToTime:(CGFloat)pos
{
    // 视频总时间长度
    CGFloat totalTime = [self playDuration];
    //计算出拖动的当前秒数
    CGFloat dragedSeconds = floorf(totalTime * pos);
    if (self.isLive && totalTime > MAX_SHIFT_TIME) {
        CGFloat base = totalTime - MAX_SHIFT_TIME;
        dragedSeconds = floor(MAX_SHIFT_TIME * pos) + base;
    }
    return dragedSeconds;
}


#pragma mark - 播放器 - 状态
//视频总时长
-(CGFloat)playDuration
{
    if (self.isLive)
    {
        return self.maxLiveProgressTime;
    }
    
    return self.vodPlayer.duration;
}

//当前视频播放时长
-(CGFloat)playCurrentTime
{
    if (self.isLive)
    {
        if (self.isShiftPlayback)
        {
            return self.liveProgressTime;
        }
        return self.maxLiveProgressTime;
    }
    
    return _playCurrentTime;
}

//获取直播流类型
-(int)checkLivePlayerType
{
    int playType = -1;
    NSString *videoURL = self.playerModel.playingDefinitionUrl;
    if ([videoURL hasPrefix:@"rtmp:"])
    {
        playType = PLAY_TYPE_LIVE_RTMP;
    }
    else if (([videoURL hasPrefix:@"https:"] || [videoURL hasPrefix:@"http:"]) && ([videoURL rangeOfString:@".flv"].length > 0))
    {
        playType = PLAY_TYPE_LIVE_FLV;
    }
    return playType;
}


#pragma mark - 设置内核
//对外的播放接口
-(void)playWithModel:(SuperPlayerModel *)playerModel
{
    //恢复初始状态
    self.isShiftPlayback = NO;
    self.imageSprite = nil;
    self.coverImageView.alpha = 1;
    self.repeatBtn.hidden = YES;
    self.liveProgressTime = 0;
    self.maxLiveProgressTime = 0;
    self.isReplay = NO;
    self.externalModel.isFinishPlay=NO;
    
    //控制层清零
    [self.controlView setProgressTime:0 totalTime:0 progressValue:0 playableValue:0];
    
    //保存
    _playerModel = playerModel;
    
    
    AFNetworkReachabilityStatus st = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    
    //检查URL是否为空
    if (playerModel.playingDefinitionUrl.length==0)
    {
        self.MJStatusView.hidden=YES;
        self.MJErrorMsgView.hidden=NO;
        NSString * videoUrl = self.playerModel.playingDefinitionUrl;
        NSString * errmsg = [NSString stringWithFormat:@"当前播放地址:%@ 是一个无效地址",videoUrl];
        [self.MJErrorMsgView showErrorMessage:errmsg];
        return;
    }
    
    //检查是否为移动网络
    else if (st == AFNetworkReachabilityStatusReachableViaWWAN && self.ignoreWWAN==NO)
    {
        self.MJStatusView.hidden=NO;
        self.MJErrorMsgView.hidden=YES;
        return;
    }
    else
    {
        self.MJStatusView.hidden=YES;
        self.MJErrorMsgView.hidden=YES;
    }
    

    //调用内核
    [self launchTXPlayer];
    
}


//配置播放器内核
-(void)launchTXPlayer
{
    //状态
    self.isLoaded = NO;
    
    //日志
    if (_playerConfig.enableLog)
    {
        [TXLiveBase setLogLevel:LOGLEVEL_DEBUG];
        [TXLiveBase sharedInstance].delegate = self;
        [TXLiveBase setConsoleEnabled:YES];
    }
    else
    {
        [TXLiveBase setLogLevel:LOGLEVEL_NULL];
        [TXLiveBase sharedInstance].delegate = self;
        [TXLiveBase setConsoleEnabled:NO];
    }
    
    //移除旧播放器
    [self.vodPlayer stopPlay];
    [self.vodPlayer removeVideoWidget];
    [self.livePlayer stopPlay];
    [self.livePlayer removeVideoWidget];
    
    
    //判断视频类型（RTMP协议，或FLV视频，都属于直播）
    int liveType = [self checkLivePlayerType];
    if (liveType >= 0)
    {
        self.isLive = YES;
    }
    else
    {
        self.isLive = NO;
    }
    
    
    //根据网络状态，选择视频URL（如果有多条视频线的话）
    self.netWatcher.playerModel = self.playerModel;
    if (self.playerModel.playingDefinition == nil)
    {
        self.playerModel.playingDefinition = self.netWatcher.adviseDefinition;
    }
    NSString *videoURL = self.playerModel.playingDefinitionUrl;
    
    
    //直播内核
    if (self.isLive)
    {
        if (!self.livePlayer)
        {
            self.livePlayer = [[TXLivePlayer alloc] init];
            self.livePlayer.delegate = self;
        }
        
        TXLivePlayConfig *config = [[TXLivePlayConfig alloc] init];
        config.bAutoAdjustCacheTime = NO;
        config.maxAutoAdjustCacheTime = 5.0f;
        config.minAutoAdjustCacheTime = 5.0f;
        config.headers = self.playerConfig.headers;
        [self.livePlayer setConfig:config];
        
        self.livePlayer.enableHWAcceleration = self.playerConfig.hwAcceleration;
        [self.livePlayer startPlay:videoURL type:liveType];
        
        [TXLiveBase setAppID:[NSString stringWithFormat:@"%ld", (long)_playerModel.videoId.appId]];
        TXCUrl *curl = [[TXCUrl alloc] initWithString:videoURL];
        [self.livePlayer prepareLiveSeek:self.playerConfig.playShiftDomain bizId:[curl bizid]];
        [self.livePlayer setMute:self.playerConfig.mute];
        [self.livePlayer setRenderMode:self.playerConfig.renderMode];
    }
    
    
    //点播内核
    else
    {
        if (!self.vodPlayer)
        {
            self.vodPlayer = [[TXVodPlayer alloc] init];
            self.vodPlayer.vodDelegate = self;
        }
        
        //内核播放器配置
        TXVodPlayConfig * vodconfig = [[TXVodPlayConfig alloc] init];
        
        //设置缓存
        if (self.playerConfig.maxCacheItem)
        {
            vodconfig.cacheFolderPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/CSVideoCache"];
            vodconfig.maxCacheItems = (int)self.playerConfig.maxCacheItem;
        }
        vodconfig.progressInterval = 0.02;
        vodconfig.headers = self.playerConfig.headers;
        [self.vodPlayer setConfig:vodconfig];
        
        //配置
        [self.vodPlayer setEnableHWAcceleration:self.playerConfig.hwAcceleration];
        [self.vodPlayer setStartTime:self.startTime]; self.startTime = 0;
        [self.vodPlayer setBitrateIndex:self.playerModel.playingDefinitionIndex];
        [self.vodPlayer setRate:self.playerConfig.playRate];
        [self.vodPlayer setMirror:self.playerConfig.mirror];
        [self.vodPlayer setMute:self.playerConfig.mute];
        [self.vodPlayer setRenderMode:self.playerConfig.renderMode];
        [self.vodPlayer setLoop:self.playerConfig.loop];
        [self.vodPlayer setToken:nil];
        
        //开始播放
        [self.vodPlayer startPlay:videoURL];
    }
    
    
    //配置网络检查器，网络不好的时候，弹窗报错
    [self.netWatcher startWatch];
    __weak SuperPlayerView *weakSelf = self;
    [self.netWatcher setNotifyTipsBlock:^(NSString *msg) {
        SuperPlayerView *strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf showMiddleBtnMsg:msg withAction:ActionSwitch];
            [strongSelf.middleBlackBtn fadeOut:2];
        }
    }];
    
    //开始loading
    self.playerState = StateLoading;
    
    //还原状态
    self.isPauseByUser = NO;
    [self.controlView playerBegin:self.playerModel isLive:self.isLive isTimeShifting:self.isShiftPlayback isAutoPlay:self.autoPlay];
    self.controlView.playerConfig = self.playerConfig;
    self.repeatBtn.hidden = YES;
    self.playDidEnd = NO;
    [self.middleBlackBtn fadeOut:0.1];

}



//加载失败重试
-(void)replayCurrentVideo
{
    SuperPlayerModel *model = _playerModel;
    if (model)
    {
        [self destroyCorePlayer];
        [self playWithModel:_playerModel];
    }
}



//重置player
-(void)destroyCorePlayer
{
    //重置点播播放器
    [self.vodPlayer stopPlay];
    [self.vodPlayer removeVideoWidget];
    self.vodPlayer = nil;
    
    //重置直播播放器
    [self.livePlayer stopPlay];
    [self.livePlayer removeVideoWidget];
    self.livePlayer = nil;
    
    //修改状态
    self.playerState = StateStopped;
}



//播放
-(void)resume
{
    [self.controlView setPlayState:YES];
    
    self.repeatBtn.hidden = YES;
    self.isPauseByUser = NO;
    
    if (self.isLive)
    {
        [_livePlayer resume];
    }
    else
    {
        [_vodPlayer resume];
    }
}



//暂停
-(void)pause
{
    if (!self.isLoaded)
    {
        return;
    }
    
    [self.controlView setPlayState:NO];
    
    self.isPauseByUser = YES;
    
    self.playerState = StatePause;
    
    if (self.isLive)
    {
        [_livePlayer pause];
    }
    else
    {
        [_vodPlayer pause];
    }
}


//快进
-(void)seekToTime:(NSInteger)dragedSeconds
{
    if (!self.isLoaded || self.playerState == StateStopped)
    {
        return;
    }
    if (self.isLive)
    {
        [DataReport report:@"timeshift" param:nil];
        int ret = [self.livePlayer seek:dragedSeconds];
        if (ret != 0)
        {
            [self showMiddleBtnMsg:kStrTimeShiftFailed withAction:ActionNone];
            [self.middleBlackBtn fadeOut:2];
            [self.controlView playerBegin:self.playerModel isLive:self.isLive isTimeShifting:self.isShiftPlayback isAutoPlay:YES];
        }
        else
        {
            if (!self.isShiftPlayback)
            {
                self.isLoaded = NO;
            }
                
            self.isShiftPlayback = YES;
            self.playerState = StateBuffering;
            [self.controlView playerBegin:self.playerModel isLive:YES isTimeShifting:self.isShiftPlayback isAutoPlay:YES];    //时移播放不能切码率
        }
    }
    else
    {
        [self.vodPlayer resume];
        [self.vodPlayer seek:dragedSeconds];
        [self.controlView setPlayState:YES];
    }
}


//移除渲染层
-(void)removeRenderView
{
    for (UIView * view in [self subviews])
    {
        if ([view isKindOfClass:NSClassFromString(@"TXCRenderView")])
            [view removeFromSuperview];
        if ([view isKindOfClass:NSClassFromString(@"TXIJKSDLGLView")])
            [view removeFromSuperview];
        if ([view isKindOfClass:NSClassFromString(@"TXCAVPlayerView")])
            [view removeFromSuperview];
    }
}




#pragma mark - 全屏切换
//修改全屏状态
-(void)switchToFullScreenMode:(BOOL)toFull
{
    //切换布局模式
    self.controlView.compact = !toFull;
    
    //关闭分享弹窗
    self.sharingView.hidden=YES;
    
    //改变 播放层的父视图
    [self makeLayersToKeyWindow:toFull];
    
    //改变 方向
    UIDeviceOrientation orient = [self getOrientationForFullScreen:toFull];
    [self makeRotationAnimation:orient];
}



//切换全屏和窗口
-(void)makeLayersToKeyWindow:(BOOL)toKeywindow
{
    //全屏
    if (toKeywindow)
    {
//        NSLog(@"---切换到KeyWindow---");
        
        //隐藏状态栏
        [self setNeedChangeStatusBarHidden:YES];
        
        //移除原来
        [self removeFromSuperview];
        
        
        UIWindow * keywindow = [UIApplication sharedApplication].keyWindow;
        
        //黑色遮罩
        [keywindow addSubview:self.fullScreenBlackView];
        [self.fullScreenBlackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(keywindow.mas_width);
            make.height.mas_equalTo(keywindow.mas_height);
            make.left.mas_equalTo(keywindow.mas_left);
            make.top.mas_equalTo(keywindow.mas_top);
        }];
        
        
        //贴在window上
        [[UIApplication sharedApplication].keyWindow addSubview:self];

    }
    else
    {
//        NSLog(@"---切换到窗口---");
        
        //隐藏控制层
        [self.controlView fadeOut:0.1];
        
        //改变状态栏
        [self setNeedChangeStatusBarHidden:NO];
        
        //移除遮罩
        [self.fullScreenBlackView removeFromSuperview];
        
        //改变父view
        [self addPlayerToFatherView:self.fatherView];
        
        //刷新布局
        [[UIApplication sharedApplication].keyWindow  layoutIfNeeded];
    }
     
}



//横屏/竖屏 切换动画
-(void)makeRotationAnimation:(UIDeviceOrientation)orientation
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    //刷新布局
    [self refreshLayersLayouts:orientation];
    
//    NSLog(@"---执行旋转动画---");
    
    self.transform = [self getRotationAngle:orientation];
    [UIView commitAnimations];
}

//获取目标方向
-(UIDeviceOrientation)getOrientationForFullScreen:(BOOL)fullScreen
{
    UIDeviceOrientation targetOrientation = [UIDevice currentDevice].orientation;
    
    //如果是全屏状态
    if (fullScreen)
    {
        if (targetOrientation == UIDeviceOrientationLandscapeRight)
        {
            return UIDeviceOrientationLandscapeRight;
        }
        
            return UIDeviceOrientationLandscapeLeft;
        
        
    }
    
    //小窗态
    else
    {
        return UIDeviceOrientationPortrait;
    }
}


-(void)MJChangeScreenOrient
{
    if (!self.isLoaded)
    {
        return;
    }
    if (self.controlView.isLockScreen)
    {
        return;
    }
    if (self.didEnterBackground)
    {
        return;
    }
    
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
    if (orient == UIDeviceOrientationLandscapeLeft || orient == UIDeviceOrientationLandscapeRight)
    {
        //执行动画
        [self makeRotationAnimation:orient];
    }
}


-(void)setNeedChangeStatusBarHidden:(BOOL)fullScreen
{
    BOOL need = fullScreen;
    NSNumber * value = [NSNumber numberWithBool:need];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MJNeedHideStatusBar" object:value];
}


//获取切换动画的旋转角度
- (CGAffineTransform)getRotationAngle:(UIDeviceOrientation)targetOrient
{
    
    // 根据要进行旋转的方向来计算旋转的角度
    if (targetOrient == UIInterfaceOrientationPortrait)
    {
        return CGAffineTransformIdentity;
    }
    else if (targetOrient == UIInterfaceOrientationLandscapeLeft)
    {
        return CGAffineTransformMakeRotation(-M_PI_2);
    }
    else if(targetOrient == UIInterfaceOrientationLandscapeRight)
    {
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    else
    {
        return CGAffineTransformIdentity;
    }
    
}


-(void)refreshLayersLayouts:(UIDeviceOrientation)targetOrient
{
    if (self.controlView.isFullScreen)
    {
        //刷新布局
        if (targetOrient == UIInterfaceOrientationPortrait || targetOrient == UIDeviceOrientationUnknown)
        {
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (IsIPhoneX)
                {
                    make.height.equalTo(@(ScreenHeight - self.mm_safeAreaTopGap * 2 +30));
                }
                else
                {
                    make.height.equalTo(@(ScreenHeight));
                }
                make.width.equalTo(@(ScreenWidth));
                make.center.equalTo([UIApplication sharedApplication].keyWindow);
            }];
        }
        else
        {
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (IsIPhoneX)
                {
                    make.width.equalTo(@(ScreenHeight - self.mm_safeAreaTopGap * 2));
                }
                else
                {
                    make.width.equalTo(@(ScreenHeight));
                }
                make.height.equalTo(@(ScreenWidth));
                make.center.equalTo([UIApplication sharedApplication].keyWindow);
            }];
        }
        
        [[UIApplication sharedApplication].keyWindow  layoutIfNeeded];
    }
}



#pragma mark - 控制层代理
-(void)controlViewDidClickShareBtn
{
    self.sharingView.hidden = NO;
}

- (void)controlViewPlay:(SuperPlayerControlView *)controlView
{
    [self resume];
}

- (void)controlViewPause:(SuperPlayerControlView *)controlView
{
    [self pause];
}

-(void)controlViewDidClickFullScreenBtn:(UIView *)controlView
{
    [self switchToFullScreenMode:YES];
}

-(void)controlViewDidClickQuitFullScreenBtn:(UIView *)controlView
{
    if (self.controlView.onlyFullscreenMode)
    {
        if ([self.delegate respondsToSelector:@selector(superPlayerDidClickBackAction:)])
        {
            [self.delegate superPlayerDidClickBackAction:self];
        }
        return;
    }
    
    //切换视图布局
    [self switchToFullScreenMode:NO];
}

- (void)controlViewDidLayoutSubviews:(UIView *)controlView
{
    if ([self.delegate respondsToSelector:@selector(superPlayerDidChangeFullScreenState:)])
    {
        [self.delegate superPlayerDidChangeFullScreenState:self];
    }
}

- (void)controlViewLockScreen:(SuperPlayerControlView *)controlView withLock:(BOOL)isLock
{

}

- (void)controlViewSwitch:(SuperPlayerControlView *)controlView withDefinition:(NSString *)definition
{
    if ([self.playerModel.playingDefinition isEqualToString:definition])
        return;
    
    self.playerModel.playingDefinition = definition;
    NSString *url = self.playerModel.playingDefinitionUrl;
    if (self.isLive)
    {
        [self.livePlayer switchStream:url];
        [self showMiddleBtnMsg:[NSString stringWithFormat:@"正在切换到%@...", definition] withAction:ActionNone];
    }
    else
    {
        if ([self.vodPlayer supportedBitrates].count > 1)
        {
            [self.vodPlayer setBitrateIndex:self.playerModel.playingDefinitionIndex];
        }
        else
        {
            CGFloat startTime = [self.vodPlayer currentPlaybackTime];
            [self.vodPlayer setStartTime:startTime];
            [self.vodPlayer startPlay:url];
        }
    }
}

- (void)controlViewDidUpdateConfig:(SuperPlayerView *)controlView withReload:(BOOL)reload
{
    if (self.isLive)
    {
        [self.livePlayer setMute:self.playerConfig.mute];
        [self.livePlayer setRenderMode:self.playerConfig.renderMode];
    }
    else
    {
        [self.vodPlayer setRate:self.playerConfig.playRate];
        [self.vodPlayer setMirror:self.playerConfig.mirror];
        [self.vodPlayer setMute:self.playerConfig.mute];
        [self.vodPlayer setRenderMode:self.playerConfig.renderMode];
    }
    
    
    if (reload)
    {
        if (!self.isLive)
        {
            self.startTime = [self.vodPlayer currentPlaybackTime];
        }
        
        [self launchTXPlayer];
    }
}


- (void)controlViewReload:(UIView *)controlView
{
    if (self.isLive)
    {
        self.isShiftPlayback = NO;
        self.isLoaded = NO;
        [self.livePlayer resumeLive];
        [self.controlView playerBegin:self.playerModel isLive:self.isLive isTimeShifting:self.isShiftPlayback isAutoPlay:YES];
    }
    else
    {
        self.startTime = [self.vodPlayer currentPlaybackTime];
        [self launchTXPlayer];
    }
}

- (void)controlViewSnapshot:(SuperPlayerControlView *)controlView
{
    void (^block)(UIImage *img) = ^(UIImage *img)
    {
        [self.fastView showSnapshot:img];
        
        if ([self.fastView.snapshotView gestureRecognizers].count == 0)
        {
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPhotos)];
            singleTap.numberOfTapsRequired = 1;
            [self.fastView.snapshotView setUserInteractionEnabled:YES];
            [self.fastView.snapshotView addGestureRecognizer:singleTap];
        }
        [self.fastView fadeShow];
        [self.fastView fadeOut:2];
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    };
    
    if (_isLive)
    {
        [_livePlayer snapshot:block];
    }
    else
    {
        [_vodPlayer snapshot:block];
    }
}

-(void)controlViewSeek:(SuperPlayerControlView *)controlView where:(CGFloat)pos
{
    CGFloat dragedSeconds = [self sliderPosToTime:pos];
    [self seekToTime:dragedSeconds];
    [self hideFastview];
}

-(void)controlViewPreview:(SuperPlayerControlView *)controlView where:(CGFloat)pos
{
    CGFloat dragedSeconds = [self sliderPosToTime:pos];
    if ([self playDuration] > 0)
    {
        // 当总时长 > 0时候才能拖动slider
        [self showProgressFastview:dragedSeconds];
    }
}


#pragma mark - 内核回调
//内核回调 - 点播
-(void)onPlayEvent:(TXVodPlayer *)player event:(int)EvtID withParam:(NSDictionary*)param
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
//        NSLog(@"eventId_%d",EvtID);
        
        
        //已读出视频的方向
        if (EvtID == PLAY_EVT_CHANGE_ROTATION)
        {
            NSLog(@"vodplayer_获取视频方向  ------------");
        }
        
        
        //已读出视频的宽高比
        else if (EvtID == PLAY_EVT_CHANGE_RESOLUTION)
        {
            NSLog(@"vodplayer_获取视频宽高");
            
            if (player.height != 0)
            {
                self.videoRatio = (GLfloat)player.width / player.height;
            }
        }
        
        
        //视频信息加载完毕
        else if (EvtID == PLAY_EVT_VOD_PLAY_PREPARED)
        {
            NSLog(@"vodplayer_视频加载完毕");
            
            if ([self.delegate respondsToSelector:@selector(superPlayerDidStartPlay:)])
            {
                [self.delegate superPlayerDidStartPlay:self];
            }
        }
                
        //渲染第一帧
        else if (EvtID == PLAY_EVT_RCV_FIRST_I_FRAME)
        {
            NSLog(@"vodplayer_播放视频第一帧");
            
            if (self.isReplay || self.isManualPlay)
            {
                //tracking
                [SZContentTracker trackContentEvent:@"cms_video_play" content:self.externalModel];
            }
            else
            {
                //tracking
                [SZContentTracker trackContentEvent:@"cms_video_play_auto" content:self.externalModel];
            }
            
            
            //行为埋点
            ContentModel * contentM = self.externalModel;
            NSMutableDictionary * param=[NSMutableDictionary dictionary];
            [param setValue:contentM.id forKey:@"content_id"];
            [param setValue:contentM.title forKey:@"content_name"];
            [param setValue:contentM.source forKey:@"content_source"];
            [param setValue:@"否" forKey:@"is_renew"];
            [param setValue:contentM.createBy forKey:@"creator_id"];
            [param setValue:contentM.thirdPartyId forKey:@"third_ID"];
            [param setValue:contentM.keywords forKey:@"content_key"];
            [param setValue:contentM.tags forKey:@"content_list"];
            [param setValue:contentM.classification forKey:@"content_classify"];
            [param setValue:contentM.startTime forKey:@"create_time"];
            [param setValue:contentM.issueTimeStamp forKey:@"publish_time"];
            [param setValue:contentM.type forKey:@"content_type"];
            [SZUserTracker trackingButtonEventName:@"content_video_play" param:param];
            
            
            self.isLoaded = YES;
            
            [self setNeedsLayout];
            
            [self layoutIfNeeded];
            
            [self removeRenderView];
            
            [self.vodPlayer setupVideoWidget:self insertIndex:0];
            
        }
        
        
        //开始播放
        else if (EvtID == PLAY_EVT_PLAY_BEGIN)
        {
            NSLog(@"vodplayer_开始播放视频");
            self.playerState = StatePlaying;
            
            [self layoutSubviews];
            
            //不使用vodPlayer.autoPlay的原因是暂停的时候会黑屏，影响体验
            if (!self.autoPlay)
            {
                self.autoPlay = YES; // 下次用户设置自动播放失效
                [self pause];
            }
        }
        
        
        
        //播放中
        else if (EvtID == PLAY_EVT_PLAY_PROGRESS)
        {
            if (self.playerState == StateStopped)
            {
                return;
            }
                
            self.playCurrentTime  = player.currentPlaybackTime;
            CGFloat totalTime     = player.duration;
            CGFloat value         = player.currentPlaybackTime / player.duration;
            [self.controlView setProgressTime:self.playCurrentTime totalTime:totalTime progressValue:value playableValue:player.playableDuration / player.duration];

        }
        
        
        //播放结束
        else if (EvtID == PLAY_EVT_PLAY_END)
        {
            NSLog(@"vodplayer_视频播放完成");
            [self.controlView setProgressTime:[self playDuration] totalTime:[self playDuration] progressValue:1.f playableValue:1.f];
            
            [self moviePlayDidEnd];
        }
        
        
        //播放失败
        else if (EvtID == PLAY_ERR_NET_DISCONNECT || EvtID == PLAY_ERR_FILE_NOT_FOUND || EvtID == PLAY_ERR_HLS_KEY /*|| EvtID == PLAY_ERR_VOD_LOAD_LICENSE_FAIL*/)
        {
            NSLog(@"vodplayer_视频播放失败");
            
            //网络断开问题
            if (EvtID == PLAY_ERR_NET_DISCONNECT)
            {
                [self showMiddleBtnMsg:kStrBadNetRetry withAction:ActionContinueReplay];
            }
            
            //资源获取问题
            else
            {
                [self showMiddleBtnMsg:kStrLoadFaildRetry withAction:ActionRetry];
            }
            
            self.playerState = StateFailed;
            
            [player stopPlay];
            
            if ([self.delegate respondsToSelector:@selector(superPlayerError:errCode:errMessage:)])
            {
                [self.delegate superPlayerError:self errCode:EvtID errMessage:param[EVT_MSG]];
            }
            
        }
        
        
        //缓冲中
        else if (EvtID == PLAY_EVT_PLAY_LOADING)
        {
            NSLog(@"vodplayer_缓冲中");
            // 当缓冲是空的时候
            self.playerState = StateBuffering;
        }
        
        
        //缓冲结束
        else if (EvtID == PLAY_EVT_VOD_LOADING_END)
        {
            NSLog(@"vodplayer_缓冲完成");
            
            [self.spinner stopAnimating];
        }
        
        
        
     });
}


//内核回调 - 直播
- (void)onPlayEvent:(int)EvtID withParam:(NSDictionary *)param
{
    NSDictionary* dict = param;
    
    dispatch_async(dispatch_get_main_queue(), ^{

//        if (EvtID != PLAY_EVT_PLAY_PROGRESS)
//        {
//            NSString *desc = [param description];
//            NSLog(@"%@", [NSString stringWithCString:[desc cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding]);
//        }
        
        if (EvtID == PLAY_EVT_PLAY_BEGIN || EvtID == PLAY_EVT_RCV_FIRST_I_FRAME)
        {
            if (!self.isLoaded)
            {
                [self setNeedsLayout];
                [self layoutIfNeeded];
                self.isLoaded = YES;
                [self removeRenderView];
                
                
                //内核会创建视频渲染层
                [self.livePlayer setupVideoWidget:CGRectZero containView:self insertIndex:0];
                [self layoutSubviews];  // 防止横屏状态下添加view显示不全
                self.playerState = StatePlaying;
                
                if ([self.delegate respondsToSelector:@selector(superPlayerDidStartPlay:)])
                {
                    [self.delegate superPlayerDidStartPlay:self];
                }
            }
            
            if (self.playerState == StateBuffering)
            {
                self.playerState = StatePlaying;
            }
                
            [self.netWatcher loadingEndEvent];
        }
        else if (EvtID == PLAY_EVT_PLAY_END)
        {
            [self moviePlayDidEnd];
        }
        else if (EvtID == PLAY_ERR_NET_DISCONNECT)
        {
            if (self.isShiftPlayback)
            {
                [self controlViewReload:self.controlView];
                [self showMiddleBtnMsg:kStrTimeShiftFailed withAction:ActionRetry];
                [self.middleBlackBtn fadeOut:2];
            }
            
            else
            {
                [self showMiddleBtnMsg:kStrBadNetRetry withAction:ActionRetry];
                self.playerState = StateFailed;
            }
            
            if ([self.delegate respondsToSelector:@selector(superPlayerError:errCode:errMessage:)])
            {
                [self.delegate superPlayerError:self errCode:EvtID errMessage:param[EVT_MSG]];
            }
        }
        else if (EvtID == PLAY_EVT_PLAY_LOADING)
        {
            // 当缓冲是空的时候
            self.playerState = StateBuffering;
            if (!self.isShiftPlayback)
            {
                [self.netWatcher loadingEvent];
            }
        }
        else if (EvtID == PLAY_EVT_STREAM_SWITCH_SUCC)
        {
            [self showMiddleBtnMsg:[@"已切换为" stringByAppendingString:self.playerModel.playingDefinition] withAction:ActionNone];
            [self.middleBlackBtn fadeOut:1];
        }
        else if (EvtID == PLAY_ERR_STREAM_SWITCH_FAIL)
        {
            [self showMiddleBtnMsg:kStrHDSwitchFailed withAction:ActionRetry];
            self.playerState = StateFailed;
        }
        else if (EvtID == PLAY_EVT_PLAY_PROGRESS)
        {
            if (self.playerState == StateStopped)
            {
                return;
            }
            
            NSInteger progress = [dict[EVT_PLAY_PROGRESS] intValue];
            self.liveProgressTime = progress;
            self.maxLiveProgressTime = MAX(self.maxLiveProgressTime, self.liveProgressTime);
            
            if (self.isShiftPlayback)
            {
                CGFloat sv = 0;
                if (self.maxLiveProgressTime > MAX_SHIFT_TIME)
                {
                    CGFloat base = self.maxLiveProgressTime - MAX_SHIFT_TIME;
                    sv = (self.liveProgressTime - base) / MAX_SHIFT_TIME;
                }
                else
                {
                    sv = self.liveProgressTime / (self.maxLiveProgressTime + 1);
                }
                [self.controlView setProgressTime:self.liveProgressTime totalTime:-1 progressValue:sv playableValue:0];
            }
            else
            {
                [self.controlView setProgressTime:self.maxLiveProgressTime totalTime:-1 progressValue:1 playableValue:0];
            }
        }
    });
}

//日志回调
-(void)onLog:(NSString*)log LogLevel:(int)level WhichModule:(NSString*)module
{
    
}

//播放结束
-(void)moviePlayDidEnd
{
    self.playerState = StatePrepareReplay;
    
    [self seekToTime:1];
    
    self.externalModel.isFinishPlay=YES;
    
//    //修改播放状态
//    self.playerState = StateStopped;
//    self.playDidEnd = YES;
//
//    //通知代理
//    if ([self.delegate respondsToSelector:@selector(superPlayerDidFinishPlay:)])
//    {
//        [self.delegate superPlayerDidFinishPlay:self];
//    }
    
    
    
//    //自动重播
//    [self repeatBtnClick:self.repeatBtn];
}


#pragma mark - 懒加载
//分享弹窗
-(UIView *)sharingView
{
    if (_sharingView==nil)
    {
        _sharingView = [[UIView alloc]init];
        _sharingView.backgroundColor=[UIColor clearColor];
        [self addSubview:_sharingView];
        [_sharingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        
        UIView * maskView = [[UIView alloc]init];
        maskView.backgroundColor=[UIColor blackColor];
        [_sharingView addSubview:maskView];
        maskView.alpha=0.3;
        [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(135);
        }];
        
        UIButton * gestview= [[UIButton alloc]init];
        [gestview addTarget:self action:@selector(hiddenSharingViewBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_sharingView addSubview:gestview];
        [gestview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(maskView.mas_top);
        }];
        
        
        //timeline
        MJButton * timelineBtn = [[MJButton alloc]init];
        [timelineBtn setImage:[UIImage getBundleImage:@"sz_wechatZone"] forState:UIControlStateNormal];
        timelineBtn.tag=1;
        [timelineBtn addTarget:self action:@selector(timelineBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_sharingView addSubview:timelineBtn];
        [timelineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_sharingView);
            make.centerY.mas_equalTo(maskView.mas_centerY);
            make.width.mas_equalTo(45);
            make.height.mas_equalTo(45);
        }];
        
        
        //wecaht
        MJButton * wechatBtn = [[MJButton alloc]init];
        [wechatBtn setImage:[UIImage getBundleImage:@"sz_wechat"] forState:UIControlStateNormal];
        wechatBtn.tag=0;
        [wechatBtn addTarget:self action:@selector(wechatBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_sharingView addSubview:wechatBtn];
        [wechatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_sharingView).offset(-75);
            make.centerY.mas_equalTo(maskView.mas_centerY);
            make.width.mas_equalTo(45);
            make.height.mas_equalTo(45);
        }];
        
        
        //qq
        MJButton * qqBtn = [[MJButton alloc]init];
        [qqBtn setImage:[UIImage getBundleImage:@"sz_qq"] forState:UIControlStateNormal];
        qqBtn.tag=2;
        [qqBtn addTarget:self action:@selector(qqBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_sharingView addSubview:qqBtn];
        [qqBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_sharingView).offset(75);
            make.centerY.mas_equalTo(maskView.mas_centerY);
            make.width.mas_equalTo(45);
            make.height.mas_equalTo(45);
        }];
    }
    return _sharingView;
}

//控制层
-(SuperPlayerControlView *)controlView
{
    if (_controlView == nil)
    {
        self.controlView = [[SPDefaultControlView alloc] initWithFrame:CGRectZero];
    }
    
    return _controlView;
}

//黑色遮罩
-(UIView *)fullScreenBlackView
{
    if (_fullScreenBlackView==nil)
    {
        _fullScreenBlackView = [[UIView alloc]init];
        _fullScreenBlackView.backgroundColor=[UIColor blackColor];
    }
    return _fullScreenBlackView;
}

//系统音量view里的滑动条
+(UISlider *)volumeViewSlider
{
    return _volumeSlider;
}

//黑底白字，可点击的HUD
-(UIButton *)middleBlackBtn
{
    if (_middleBlackBtn == nil)
    {
        _middleBlackBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_middleBlackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _middleBlackBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _middleBlackBtn.backgroundColor = RGBA(0, 0, 0, 0.7);
        [_middleBlackBtn addTarget:self action:@selector(middleBlackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_middleBlackBtn];
        [_middleBlackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.height.mas_equalTo(33);
        }];
    }
    return _middleBlackBtn;
}

//进度、音量、亮度HUD
-(SuperPlayerFastView *)fastView
{
    if (_fastView == nil)
    {
        _fastView = [[SuperPlayerFastView alloc] init];
        [self addSubview:_fastView];
        [_fastView mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return _fastView;
}

//重播按钮
-(UIButton *)repeatBtn
{
    if (!_repeatBtn)
    {
        _repeatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_repeatBtn setImage:SuperPlayerImage(@"repeat_video") forState:UIControlStateNormal];
        [_repeatBtn addTarget:self action:@selector(repeatBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_repeatBtn];
        [_repeatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return _repeatBtn;
}

//转圈Loading
-(MMMaterialDesignSpinner *)spinner
{
    if (!_spinner)
    {
        _spinner = [[MMMaterialDesignSpinner alloc] init];
        _spinner.lineWidth = 1;
        _spinner.duration  = 1;
        _spinner.hidden    = YES;
        _spinner.hidesWhenStopped = YES;
        _spinner.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        [self addSubview:_spinner];
        [_spinner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.with.height.mas_equalTo(45);
        }];
    }
    return _spinner;
}

//视频封面图
-(UIImageView *)coverImageView
{
    if (!_coverImageView)
    {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.alpha = 0;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.layer.masksToBounds=YES;
        [self insertSubview:_coverImageView belowSubview:self.controlView];
        [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return _coverImageView;
    return nil;
}

//错误信息提示
-(VideoErrorMessageView *)MJErrorMsgView
{
    if (!_MJErrorMsgView)
    {
        _MJErrorMsgView = [[VideoErrorMessageView alloc]init];
        [self addSubview:_MJErrorMsgView];
        [self.MJErrorMsgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(self.mas_width);
            make.height.mas_equalTo(self.mas_height);
        }];
    }
    
    return _MJErrorMsgView;
}

//移动网络提示
-(UIView *)MJStatusView
{
    if (!_MJStatusView)
    {
        _MJStatusView = [[UIView alloc]init];
        
        UIImageView * bg = [[UIImageView alloc]init];
        bg.backgroundColor=[UIColor blackColor];
        bg.contentMode=UIViewContentModeScaleAspectFill;
        bg.layer.masksToBounds=YES;
        [_MJStatusView addSubview:bg];
        [bg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(_MJStatusView.mas_width);
            make.height.mas_equalTo(_MJStatusView.mas_height);
        }];
        
        UILabel * desc=[[UILabel alloc]init];
        desc.text=@"正在使用非Wi-Fi网络，播放将产生流量费用";
        desc.textColor=[UIColor whiteColor];
        desc.textAlignment=NSTextAlignmentCenter;
        desc.font=[UIFont systemFontOfSize:12];;
        desc.alpha=0.5;
        [_MJStatusView addSubview:desc];
        [desc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_MJStatusView.mas_centerX);
            make.centerY.mas_equalTo(_MJStatusView.mas_centerY).offset(-20);
        }];
        
        UIButton * btn=[[UIButton alloc]init];
        [btn setTitle:@"使用流量播放" forState:UIControlStateNormal];
        btn.layer.cornerRadius=4;
        btn.layer.borderWidth=1;
        btn.layer.borderColor=[UIColor whiteColor].CGColor;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:14];
        [btn addTarget:self action:@selector(MJNetStatusBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_MJStatusView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_MJStatusView.mas_centerX);
            make.centerY.mas_equalTo(_MJStatusView.mas_centerY).offset(17);;
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(100);
        }];
        
        [self addSubview:_MJStatusView];
        [_MJStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(self.mas_width);
            make.height.mas_equalTo(self.mas_height);
        }];
    }
    
    return _MJStatusView;
}

//中间的播放按钮
-(UIImageView *)middlePlayBtn
{
    if (_middlePlayBtn==nil)
    {
        _middlePlayBtn = [[UIImageView alloc]init];
        _middlePlayBtn.image = [UIImage getBundleImage:@"sz_middle_play"];
        _middlePlayBtn.hidden=YES;
        _middlePlayBtn.userInteractionEnabled=YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resume)];
        [_middlePlayBtn addGestureRecognizer:tap];
        [self addSubview:_middlePlayBtn];
        [_middlePlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self);
            make.width.mas_equalTo(44);
            make.height.mas_equalTo(54);
        }];
    }
    return _middlePlayBtn;;
}

-(NSString*)playStateDesc:(NSInteger)state
{
    if (state==0)
    {
        return @"加载失败";
    }
    else if (state==1)
    {
        return @"加载中";
    }
    else if (state==2)
    {
        return @"播放中";
    }
    else if (state==3)
    {
        return @"停止";
    }
    else if (state==4)
    {
        return @"暂停";
    }
    else if (state ==5)
    {
        return @"进后台";
    }
    
    return @"unknow";
}

#pragma mark - Btn Actions
//重播按钮
-(void)repeatBtnClick:(UIButton *)sender
{
    self.isReplay = YES;
    
    [self launchTXPlayer];
    
}

//弹窗
-(void)middleBlackBtnClick:(UIButton *)btn
{
    switch (self.middleBlackBtnAction)
    {
        case ActionNone:
            break;
        case ActionContinueReplay:
        {
            if (!self.isLive)
            {
                self.startTime = self.playCurrentTime;
            }
            [self launchTXPlayer];
        }
            break;
        case ActionRetry:   //播放失败，如文件不存在
            [self replayCurrentVideo];
            break;
        case ActionSwitch:
            [self controlViewSwitch:self.controlView withDefinition:self.netWatcher.adviseDefinition];
            [self.controlView playerBegin:self.playerModel isLive:self.isLive isTimeShifting:self.isShiftPlayback isAutoPlay:YES];
            break;
        case ActionIgnore:
            return;
        default:
            break;
    }
    [btn fadeOut:0.2];
}

-(void)hiddenSharingViewBtnAction
{
    self.sharingView.hidden = YES;
}

-(void)wechatBtnAction
{
    
    [SZGlobalInfo mjshareToPlatform:WECHAT_PLATFORM content:self.externalModel source:@"视频详情分享"];
}

-(void)timelineBtnAction
{
    [SZGlobalInfo mjshareToPlatform:TIMELINE_PLATFORM content:self.externalModel source:@"视频详情分享"];
}

-(void)qqBtnAction
{
    [SZGlobalInfo mjshareToPlatform:QQ_PLATFORM content:self.externalModel source:@"视频详情分享"];
}

-(void)MJNetStatusBtnAction
{
    self.MJStatusView.hidden=YES;
    self.ignoreWWAN=YES;
    [self playWithModel:self.playerModel];
}


#pragma clang diagnostic pop

@end
