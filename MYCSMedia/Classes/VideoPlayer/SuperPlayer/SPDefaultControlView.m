#import "SuperPlayerControlView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MJVideoManager.h"
#import "MoreContentView.h"
#import "DataReport.h"
#import "SuperPlayerFastView.h"
#import "PlayerSlider.h"
#import "UIView+MMLayout.h"
#import "SuperPlayerView+Private.h"
#import "StrUtils.h"
#import "SPDefaultControlView.h"
#import "UIView+Fade.h"
#import "VideoRateView.h"
#import "SZData.h"
#import "IQDataBinding.h"
#import "ContentStateModel.h"
#import "ContentModel.h"
#import "UIImage+MJCategory.h"
#import "SZGlobalInfo.h"
#import "SZData.h"
#import "SZContentTracker.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

#define MODEL_TAG_BEGIN 20
#define BOTTOM_IMAGE_VIEW_HEIGHT 50

@interface SPDefaultControlView () <UIGestureRecognizerDelegate, PlayerSliderDelegate>

@end

@implementation SPDefaultControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //设置底部视图
        [self.bottomImageView addSubview:self.startBtn];
        [self.bottomImageView addSubview:self.currentTimeLabel];
        [self.bottomImageView addSubview:self.videoSlider];
        [self.bottomImageView addSubview:self.MJRateBtn];
        [self.bottomImageView addSubview:self.fullScreenBtn];
        [self.bottomImageView addSubview:self.totalTimeLabel];
        [self addSubview:self.bottomImageView];
        
        //设置顶部视图
        [self.topImageView addSubview:self.captureBtn];
        [self.topImageView addSubview:self.danmakuBtn];
        [self.topImageView addSubview:self.moreBtn];
        [self.topImageView addSubview:self.backBtn];
        [self.topImageView addSubview:self.titleLabel];
        [self.topImageView addSubview:self.zanBtn];
        [self.topImageView addSubview:self.collectBtn];
        [self.topImageView addSubview:self.shareBtn];
        [self addSubview:self.topImageView];
        
        //旋转锁定按钮
        [self addSubview:self.lockBtn];
        
        //返回直播
        [self addSubview:self.backLiveBtn];
        
        //添加约束
        [self makeSubViewsConstraints];
        
        //初始化时重置controlView
        [self initViewData];
        
        //notify
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(MJMediaRemoteEvent:)
                                                     name:@"MJRemoteEnterFullScreen"
                                                   object:nil];
        
        //数据绑定
        [self addDataBinding];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 初始化
- (void)makeSubViewsConstraints
{
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self.mas_top).offset(0);
        make.height.mas_equalTo(50);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.topImageView.mas_leading).offset(5);
        make.top.equalTo(self.topImageView.mas_top).offset(3);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(60);
    }];
    
//    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(40);
//        make.height.mas_equalTo(49);
//        make.trailing.equalTo(self.topImageView.mas_trailing).offset(-10);
//        make.centerY.equalTo(self.backBtn.mas_centerY);
//    }];
    
    [self.captureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(49);
        make.trailing.equalTo(self.topImageView.mas_trailing).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(49);
        make.trailing.equalTo(self.captureBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(49);
        make.trailing.equalTo(self.shareBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.zanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(49);
        make.trailing.equalTo(self.collectBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.danmakuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(49);
        make.trailing.equalTo(self.captureBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backBtn.mas_right);
        make.centerY.equalTo(self.backBtn.mas_centerY);
        make.right.mas_equalTo(self.zanBtn.mas_left).offset(-20);
    }];
    
    [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(0);
        make.height.mas_equalTo(BOTTOM_IMAGE_VIEW_HEIGHT);
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bottomImageView.mas_leading).offset(5);
        make.top.equalTo(self.bottomImageView.mas_top).offset(10);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(50);
    }];
    

    
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.trailing.equalTo(self.bottomImageView.mas_trailing).offset(-8);
        make.centerY.equalTo(self.startBtn.mas_centerY);
    }];
    
    [self.MJRateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.width.mas_greaterThanOrEqualTo(60);
        make.trailing.equalTo(self.bottomImageView.mas_trailing).offset(-8);
        make.centerY.equalTo(self.startBtn.mas_centerY);
    }];
    

    
    [self.videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.trailing.equalTo(self.bottomImageView.mas_trailing).offset(-20);
        make.bottom.equalTo(self.startBtn.mas_top).offset(-10);
    }];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.videoSlider.mas_left).offset(-11);
        make.bottom.equalTo(self.videoSlider.mas_top);
        make.width.mas_equalTo(60);
    }];
    
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.videoSlider.mas_right).offset(10);
        make.top.mas_equalTo(self.currentTimeLabel.mas_top);
        make.width.mas_equalTo(60);
    }];
    
    [self.lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(15);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(32);
    }];
    
    
    [self.backLiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.startBtn.mas_top).mas_offset(-15);
        make.width.mas_equalTo(70);
        make.centerX.equalTo(self);
    }];
    
    
}


/** 重置ControlView */
- (void)initViewData
{
    self.videoSlider.value           = 0;
    self.videoSlider.progressView.progress = 0;
    self.currentTimeLabel.text       = @"00:00";
    self.totalTimeLabel.text         = @"00:00";
    self.videoRateView.hidden       = YES;
    self.backgroundColor             = [UIColor clearColor];
    self.moreBtn.enabled         = YES;
    self.lockBtn.hidden              = !self.isFullScreen;
    
    self.danmakuBtn.enabled = YES;
    self.captureBtn.enabled = YES;
    self.moreBtn.enabled = YES;
    self.backLiveBtn.hidden              = YES;
    
}





//更新横屏布局
-(void)setUncompactConstraint
{
    self.backBtn.hidden = !self.fullScreenState;
    self.lockBtn.hidden         = NO;
    self.fullScreenBtn.selected = self.isLockScreen;
    self.fullScreenBtn.hidden   = YES;
    self.MJRateBtn.hidden   = NO;
    self.moreBtn.hidden         = YES;
    self.captureBtn.hidden      = NO;
    self.danmakuBtn.hidden      = YES;
    self.zanBtn.hidden = NO;
    self.collectBtn.hidden = NO;
    self.shareBtn.hidden = NO;
    self.videoSlider.hiddenPoints = NO;
    self.titleLabel.hidden=NO;
    
    [self.backBtn setImage:SuperPlayerImage(@"back_full") forState:UIControlStateNormal];
    
    [self.bottomImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(BOTTOM_IMAGE_VIEW_HEIGHT);
    }];
    
    
    [self.videoSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.trailing.equalTo(self.bottomImageView.mas_trailing).offset(-20);
        make.bottom.equalTo(self.startBtn.mas_top).offset(0);
    }];
    
    [self.currentTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.videoSlider.mas_left).offset(-11);
        make.bottom.equalTo(self.videoSlider.mas_top);
        make.width.mas_equalTo(60);
    }];
    
    [self.totalTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.videoSlider.mas_right).offset(10);
        make.top.mas_equalTo(self.currentTimeLabel.mas_top);
        make.width.mas_equalTo(60);
    }];
}



//更新竖屏布局
-(void)setCompactConstraint
{
    self.backBtn.hidden = !self.fullScreenState;
    self.lockBtn.hidden         = YES;
    self.fullScreenBtn.selected = NO;
    self.fullScreenBtn.hidden   = self.fullScreenState;
    self.MJRateBtn.hidden   = YES;
    self.moreBtn.hidden         = YES;
    self.captureBtn.hidden      = YES;
    self.danmakuBtn.hidden      = YES;
    self.moreContentView.hidden = YES;
    self.videoRateView.hidden  = YES;
    self.zanBtn.hidden = YES;
    self.collectBtn.hidden = YES;
    self.shareBtn.hidden = YES;
    self.videoSlider.hiddenPoints = YES;
    self.pointJumpBtn.hidden = YES;
    self.titleLabel.hidden=YES;
    
    [self.bottomImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(BOTTOM_IMAGE_VIEW_HEIGHT);
    }];
    
    
    
    [self.currentTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.startBtn.mas_right).offset(-10);
        make.centerY.mas_equalTo(self.startBtn);
        make.width.mas_equalTo(60);
    }];
    
    [self.totalTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.fullScreenBtn.mas_left);
        make.centerY.mas_equalTo(self.startBtn);
        make.width.mas_equalTo(60);
    }];
    
    [self.videoSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.currentTimeLabel.mas_right);
        make.right.mas_equalTo(self.totalTimeLabel.mas_left);
        make.centerY.mas_equalTo(self.startBtn);
    }];
    
    
}




#pragma mark - Notification
//远程全屏
-(void)MJMediaRemoteEvent:(NSNotification*)notify
{
    NSNumber * num = notify.object;
    
    if (self.isLockScreen)
    {
        return;
    }
    
    if (self.playerConfig.renderMode!=1)
    {
        return;
    }
    
    //远程通知进全屏
    if (num.boolValue && self.isFullScreen==NO)
    {
        [self fullScreenBtnClick:_fullScreenBtn];
    }
    
    //退出全屏
    else if(self.isFullScreen && num.boolValue==NO)
    {
        [self backBtnClick:_backBtn];
    }
    
}


#pragma mark - 数据绑定
-(void)addDataBinding
{

    //绑定数据
    [self bindModel:[SZData sharedSZData]];
    
    __weak typeof (self) weakSelf = self;
    self.observe(@"currentContentId",^(id value){
        weakSelf.contentId = value;
    }).observe(@"contentStateUpdateTime",^(id value){
        [weakSelf updateContentStateData];
    }).observe(@"contentZanTime",^(id value){
        [weakSelf updateContentStateData];
    }).observe(@"contentCollectTime",^(id value){
        [weakSelf updateContentStateData];
    });
    
}

-(void)updateContentStateData
{
    //取数据
    ContentStateModel * stateM = [[SZData sharedSZData].contentStateDic valueForKey:self.contentId];
    ContentModel * contentM = [[SZData sharedSZData].contentDic valueForKey:self.contentId];
    
    self.collectBtn.MJSelectState = stateM.whetherFavor;
    
    self.zanBtn.MJSelectState = stateM.whetherLike;
    
    [self.zanBtn setBadgeNum:[NSString stringWithFormat:@"%ld",stateM.likeCountShow] style:2];
    
    self.titleLabel.text = contentM.title;
}



#pragma mark - Btn Actions
//返回按钮
-(void)backBtnClick:(UIButton *)sender
{
    if (!self.onlyFullscreenMode)
    {
        self.fullScreenState = NO;
    }
    
    
    if ([self.delegate respondsToSelector:@selector(controlViewDidClickQuitFullScreenBtn:)])
    {
        [self.delegate controlViewDidClickQuitFullScreenBtn:self];
    }
}


//锁定旋屏
-(void)lockScreenBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.isLockScreen = sender.selected;
    self.topImageView.hidden    = self.isLockScreen;
    self.bottomImageView.hidden = self.isLockScreen;
    if (self.isLive)
    {
        self.backLiveBtn.hidden = self.isLockScreen;
    }
    [self.delegate controlViewLockScreen:self withLock:self.isLockScreen];
    [self fadeOut:3];
}

//播放按钮
-(void)playBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        [self.delegate controlViewPlay:self];
    }
    else
    {
        [self.delegate controlViewPause:self];
    }
    [self cancelFadeOut];
}

//全屏按钮
- (void)fullScreenBtnClick:(UIButton *)sender
{
    //修改状态
    sender.selected = !sender.selected;
    self.fullScreenState = YES;
    
    //通知代理
    [self.delegate controlViewDidClickFullScreenBtn:self];
    
    //渐隐控制层
    [self fadeOut:3];
}

//截屏按钮
- (void)captureBtnClick:(UIButton *)sender
{
    [self.delegate controlViewSnapshot:self];
    [self fadeOut:3];
}

//弹幕按钮
- (void)danmakuBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self fadeOut:3];
}

//更多设置按钮
- (void)moreBtnClick:(UIButton *)sender
{
    self.topImageView.hidden = YES;
    self.bottomImageView.hidden = YES;
    self.lockBtn.hidden = YES;
    
    self.moreContentView.playerConfig = self.playerConfig;
    [self.moreContentView update];
    self.moreContentView.hidden = NO;
    
    [self cancelFadeOut];
    self.isShowSecondView = YES;
}

//播放倍速
- (void)MJRateBtnClick:(UIButton *)sender
{
    self.topImageView.hidden = YES;
    self.bottomImageView.hidden = YES;
    self.lockBtn.hidden = YES;
    
    //倍速view
    self.videoRateView.playerConfig = self.playerConfig;
    [self.videoRateView updateState];
    self.videoRateView.hidden = NO;
    
    [self cancelFadeOut];
    self.isShowSecondView = YES;
}

//进度条
- (void)progressSliderTouchBegan:(UISlider *)sender
{
    self.isDragging = YES;
    [self cancelFadeOut];
}

//进度条
- (void)progressSliderValueChanged:(UISlider *)sender
{
    [self.delegate controlViewPreview:self where:sender.value];
}

//进度条
- (void)progressSliderTouchEnded:(UISlider *)sender
{
    [self.delegate controlViewSeek:self where:sender.value];
    self.isDragging = NO;
    [self fadeOut:5];
}

-(void)backLiveClick:(UIButton *)sender
{
    [self.delegate controlViewReload:self];
}

-(void)pointJumpClick:(UIButton *)sender
{
    self.pointJumpBtn.hidden = YES;
    PlayerPoint *point = [self.videoSlider.pointArray objectAtIndex:self.pointJumpBtn.tag];
    [self.delegate controlViewSeek:self where:point.where];
    [self fadeOut:0.1];
}

-(void)zanBtnAction
{
    if (![SZGlobalInfo sharedManager].SZRMToken.length)
    {
        [self backBtnClick:_backBtn];
    }
    [[SZData sharedSZData]requestZan];
}
-(void)collectBtnAction
{
    if (![SZGlobalInfo sharedManager].SZRMToken.length)
    {
        [self backBtnClick:_backBtn];
    }
    [[SZData sharedSZData]requestCollect];
}
-(void)shareBtnAction
{
    if ([self.delegate respondsToSelector:@selector(controlViewDidClickShareBtn)])
    {
        [self.delegate controlViewDidClickShareBtn];
    }
    
}
-(void)externalFullScreenBtnAction
{
    //修改状态
    self.fullScreenState = YES;
    
    //通知代理
    [self.delegate controlViewDidClickFullScreenBtn:self];
}


#pragma mark - 子控件代理
-(void)onPlayerPointSelected:(PlayerPoint *)point
{
    NSString *text = [NSString stringWithFormat:@"  %@ %@  ", [StrUtils timeFormat:point.timeOffset],
                      point.content];
    
    [self.pointJumpBtn setTitle:text forState:UIControlStateNormal];
    [self.pointJumpBtn sizeToFit];
    CGFloat x = self.videoSlider.mm_x + self.videoSlider.mm_w * point.where - self.pointJumpBtn.mm_h/2;
    if (x < 0)
        x = 0;
    if (x + self.pointJumpBtn.mm_h/2 > ScreenWidth)
        x = ScreenWidth - self.pointJumpBtn.mm_h/2;
    self.pointJumpBtn.tag = [self.videoSlider.pointArray indexOfObject:point];
    self.pointJumpBtn.mm_left(x).mm_bottom(60);
    self.pointJumpBtn.hidden = NO;
    
    [DataReport report:@"player_point" param:nil];
}


#pragma mark - Getter
-(MJProgressView *)externalSlider
{
    if (!_externalSlider)
    {
        _externalSlider = [[MJProgressView alloc]init];
        _externalSlider.hidden=YES;
        [_externalSlider.slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        [_externalSlider.slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_externalSlider.slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        
    }
    return _externalSlider;
}

    
-(UIImageView *)externalFullScreenBtn
{
    if (_externalFullScreenBtn==nil)
    {
        _externalFullScreenBtn = [[UIImageView alloc]init];
        _externalFullScreenBtn.hidden=YES;
        _externalFullScreenBtn.userInteractionEnabled=YES;
        _externalFullScreenBtn.image=[UIImage getBundleImage:@"sz_videoCell_full"];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(externalFullScreenBtnAction)];
        [_externalFullScreenBtn addGestureRecognizer:tap];
    }
    
    return _externalFullScreenBtn;
}

- (UIView *)videoRateView
{
    if (!_videoRateView)
    {
        _videoRateView = [[VideoRateView alloc] initWithFrame:CGRectZero];
        _videoRateView.controlView=self;
        [self addSubview:_videoRateView];
        [_videoRateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(120);
            make.height.mas_equalTo(self.mas_height);
            make.trailing.equalTo(self.mas_trailing).offset(0);
            make.top.equalTo(self.mas_top).offset(0);
        }];
    }
    return _videoRateView;
}


- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _titleLabel;
}

- (UIButton *)backBtn
{
    if (!_backBtn)
    {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:SuperPlayerImage(@"videoplayer_back") forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIImageView *)topImageView
{
    if (!_topImageView)
    {
        _topImageView                        = [[UIImageView alloc] init];
        _topImageView.userInteractionEnabled = YES;
        _topImageView.image                  = SuperPlayerImage(@"top_shadow");
    }
    return _topImageView;
}

- (UIImageView *)bottomImageView
{
    if (!_bottomImageView)
    {
        _bottomImageView                        = [[UIImageView alloc] init];
        _bottomImageView.userInteractionEnabled = YES;
        _bottomImageView.image                  = SuperPlayerImage(@"bottom_shadow");
    }
    return _bottomImageView;
}

- (UIButton *)lockBtn
{
    if (!_lockBtn)
    {
        _lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _lockBtn.exclusiveTouch = YES;
        [_lockBtn setImage:SuperPlayerImage(@"videoplayer_unlock") forState:UIControlStateNormal];
        [_lockBtn setImage:SuperPlayerImage(@"videoplayer_lock") forState:UIControlStateSelected];
        [_lockBtn addTarget:self action:@selector(lockScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _lockBtn;
}

- (UIButton *)startBtn
{
    if (!_startBtn)
    {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setImage:SuperPlayerImage(@"videoplayer_play") forState:UIControlStateNormal];
        [_startBtn setImage:SuperPlayerImage(@"videoplayer_pause") forState:UIControlStateSelected];
        [_startBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

- (UILabel *)currentTimeLabel
{
    if (!_currentTimeLabel)
    {
        _currentTimeLabel               = [[UILabel alloc] init];
        _currentTimeLabel.textColor     = [UIColor whiteColor];
        _currentTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (PlayerSlider *)videoSlider
{
    if (!_videoSlider)
    {
        _videoSlider                       = [[PlayerSlider alloc] init];
        [_videoSlider setThumbImage:SuperPlayerImage(@"slider_thumb") forState:UIControlStateNormal];
        _videoSlider.minimumTrackTintColor = TintColor;
        [_videoSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        [_videoSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_videoSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        _videoSlider.delegate = self;
    }
    return _videoSlider;
}

- (UILabel *)totalTimeLabel
{
    if (!_totalTimeLabel)
    {
        _totalTimeLabel               = [[UILabel alloc] init];
        _totalTimeLabel.textColor     = [UIColor whiteColor];
        _totalTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}

- (UIButton *)fullScreenBtn
{
    if (!_fullScreenBtn)
    {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:SuperPlayerImage(@"videoplayer_fullscreen") forState:UIControlStateNormal];
        [_fullScreenBtn addTarget:self action:@selector(fullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}

- (UIButton *)captureBtn
{
    if (!_captureBtn)
    {
        _captureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_captureBtn setImage:SuperPlayerImage(@"videoplayer_capture") forState:UIControlStateNormal];
        [_captureBtn addTarget:self action:@selector(captureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _captureBtn;
}

-(MJButton *)zanBtn
{
    if (!_zanBtn)
    {
        _zanBtn = [[MJButton alloc]init];
        _zanBtn.mj_imageObjec = SuperPlayerImage(@"videoplayer_zan");
        _zanBtn.mj_imageObject_sel = SuperPlayerImage(@"videoplayer_zan_sel");
        [_zanBtn addTarget:self action:@selector(zanBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _zanBtn;
}

-(MJButton *)collectBtn
{
    if (!_collectBtn)
    {
        _collectBtn = [[MJButton alloc]init];
        _collectBtn.mj_imageObjec = SuperPlayerImage(@"videoplayer_collect");
        _collectBtn.mj_imageObject_sel = SuperPlayerImage(@"videoplayer_collect_sel");
        [_collectBtn addTarget:self action:@selector(collectBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _collectBtn;
}

-(MJButton *)shareBtn
{
    if (!_shareBtn)
    {
        _shareBtn = [[MJButton alloc]init];
        _shareBtn.mj_imageObjec = SuperPlayerImage(@"videoplayer_share");
        [_shareBtn addTarget:self action:@selector(shareBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareBtn;
}

- (UIButton *)danmakuBtn
{
    if (!_danmakuBtn)
    {
        _danmakuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_danmakuBtn setImage:SuperPlayerImage(@"danmu") forState:UIControlStateNormal];
        [_danmakuBtn setImage:SuperPlayerImage(@"danmu_pressed") forState:UIControlStateSelected];
        [_danmakuBtn addTarget:self action:@selector(danmakuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _danmakuBtn;
}

- (UIButton *)moreBtn
{
    if (!_moreBtn)
    {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreBtn setImage:SuperPlayerImage(@"more") forState:UIControlStateNormal];
        [_moreBtn setImage:SuperPlayerImage(@"more_pressed") forState:UIControlStateSelected];
        [_moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

- (UIButton *)MJRateBtn
{
    if (!_MJRateBtn)
    {
        _MJRateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _MJRateBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_MJRateBtn setTitle:@"倍速" forState:UIControlStateNormal];
        [_MJRateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_MJRateBtn addTarget:self action:@selector(MJRateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _MJRateBtn;
}

- (UIButton *)backLiveBtn
{
    if (!_backLiveBtn)
    {
        _backLiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backLiveBtn setTitle:@"返回直播" forState:UIControlStateNormal];
        _backLiveBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        UIImage *image = SuperPlayerImage(@"qg_online_bg");
        
        UIImage *resizableImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(33 * 0.5, 33 * 0.5, 33 * 0.5, 33 * 0.5)];
        [_backLiveBtn setBackgroundImage:resizableImage forState:UIControlStateNormal];
        
        [_backLiveBtn addTarget:self action:@selector(backLiveClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backLiveBtn;
}

- (UIButton *)pointJumpBtn
{
    if (!_pointJumpBtn)
    {
        _pointJumpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = SuperPlayerImage(@"copywright_bg");
        UIImage *resizableImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20) resizingMode:UIImageResizingModeStretch];
        [_pointJumpBtn setBackgroundImage:resizableImage forState:UIControlStateNormal];
        _pointJumpBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_pointJumpBtn addTarget:self action:@selector(pointJumpClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_pointJumpBtn];
    }
    return _pointJumpBtn;
}

- (MoreContentView *)moreContentView
{
    if (!_moreContentView)
    {
        _moreContentView = [[MoreContentView alloc] initWithFrame:CGRectZero];
        _moreContentView.controlView = self;
        _moreContentView.hidden = YES;
        [self addSubview:_moreContentView];
        [_moreContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(330);
            make.height.mas_equalTo(self.mas_height);
            make.trailing.equalTo(self.mas_trailing).offset(0);
            make.top.equalTo(self.mas_top).offset(0);
        }];
        _moreContentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }
    return _moreContentView;
}



#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UISlider class]])
    {
        // 如果在滑块上点击就不响应pan手势
        return NO;
    }
    return YES;
}

#pragma mark - 播放状态更新
//播放中更新控件
-(void)setProgressTime:(NSInteger)currentTime
              totalTime:(NSInteger)totalTime
          progressValue:(CGFloat)progress
          playableValue:(CGFloat)playable
{
    if (!self.isDragging)
    {
        // 更新slider
        self.videoSlider.value           = progress;
    }
    
    // 更新当前播放时间
    self.currentTimeLabel.text = [StrUtils timeFormat:currentTime];
    
    // 更新总时间
    self.totalTimeLabel.text = [StrUtils timeFormat:totalTime];
    
    //缓冲时间
    [self.videoSlider.progressView setProgress:playable animated:NO];
    
    //设置外部slider
    [self.externalSlider setCurrentTime:currentTime totalTime:totalTime progress:progress isDragging:self.isDragging];
    
    //记录百分比
    SuperPlayerView * videoview = (SuperPlayerView*)self.delegate;
    [SZContentTracker recordPlayingProgress:progress content:videoview.externalModel];
}


-(void)playerBegin:(SuperPlayerModel *)model
             isLive:(BOOL)isLive
     isTimeShifting:(BOOL)isTimeShifting
         isAutoPlay:(BOOL)isAutoPlay
{
    [self setPlayState:isAutoPlay];
    
    self.backLiveBtn.hidden = !isTimeShifting;
    
    self.moreContentView.isLive = isLive;
    
    if (self.isLive != isLive)
    {
        self.isLive = isLive;
        [self setNeedsLayout];
    }
    
}



#pragma mark - 外部方法
- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    if (hidden)
    {
        self.videoRateView.hidden = YES;
        self.moreContentView.hidden = YES;
        
        //如果未锁屏
        if (!self.isLockScreen)
        {
            self.topImageView.hidden = NO;
            self.bottomImageView.hidden = NO;
        }
    }

    self.lockBtn.hidden = !self.isFullScreen;
    self.isShowSecondView = NO;
    self.pointJumpBtn.hidden = YES;
}


-(void)setPointArray:(NSArray *)pointArray
{
    [super setPointArray:pointArray];
    
    for (PlayerPoint *holder in self.videoSlider.pointArray)
    {
        [holder.holder removeFromSuperview];
    }
    [self.videoSlider.pointArray removeAllObjects];
    
    for (SuperPlayerVideoPoint *p in pointArray)
    {
        PlayerPoint *point = [self.videoSlider addPoint:p.where];
        point.content = p.text;
        point.timeOffset = p.time;
    }
}

/** 播放按钮状态 */
- (void)setPlayState:(BOOL)state
{
    self.startBtn.selected = state;
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    self.titleLabel.text = title;
}
-(void)setMJStatusViewContent:(NSInteger)type
{
    
}

@end
