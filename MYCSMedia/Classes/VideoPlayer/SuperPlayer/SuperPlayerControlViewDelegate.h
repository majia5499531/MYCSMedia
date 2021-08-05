#ifndef SuperPlayerControlViewDelegate_h
#define SuperPlayerControlViewDelegate_h


@class SuperPlayerUrl;
@class SuperPlayerControlView;

@protocol SuperPlayerControlViewDelegate <NSObject>

/** 播放 */
- (void)controlViewPlay:(UIView *)controlView;
/** 暂停 */
- (void)controlViewPause:(UIView *)controlView;
/** 播放器全屏 */
- (void)controlViewDidClickFullScreenBtn:(UIView *)controlView;
/** 播放器退出全屏 */
- (void)controlViewDidClickQuitFullScreenBtn:(UIView *)controlView;
/** 播放器改变布局 */
- (void)controlViewDidLayoutSubviews:(UIView *)controlView;
/** 锁定屏幕方向 */
- (void)controlViewLockScreen:(UIView *)controlView withLock:(BOOL)islock;
/** 截屏事件 */
- (void)controlViewSnapshot:(UIView *)controlView;
/** 切换分辨率按钮事件 */
- (void)controlViewSwitch:(UIView *)controlView withDefinition:(NSString *)definition;
/** 修改配置 */
- (void)controlViewDidUpdateConfig:(SuperPlayerControlView *)controlView withReload:(BOOL)reload;
/** 重新播放 */
- (void)controlViewReload:(UIView *)controlView;
/** seek事件，pos 0~1 */
- (void)controlViewSeek:(UIView *)controlView where:(CGFloat)pos;
/** 滑动预览，pos 0~1 */
- (void)controlViewPreview:(UIView *)controlView where:(CGFloat)pos;



- (void)MJRealoadPlaying;

//点击分享按钮
- (void)controlViewDidClickShareBtn;

@end


#endif /* SuperPlayerControlViewDelegate_h */
