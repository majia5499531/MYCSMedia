//
//  SuperPlayerMoreView.m
//  TXLiteAVDemo
//
//  Created by annidyfeng on 2018/7/4.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "MoreContentView.h"
#import "UIView+MMLayout.h"
#import "SuperPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "SuperPlayerControlView.h"
#import "SuperPlayerView+Private.h"
#import "DataReport.h"



@interface MoreContentView()
@property (nonatomic) UIView *soundCell;
@property (nonatomic) UIView *ligthCell;
@property (nonatomic) UIView *mirrorCell;
@property (nonatomic) UIView *hwCell;
@property BOOL isVolume;
@property NSDate *volumeEndTime;
@end

@implementation MoreContentView {
    NSInteger  _contentHeight;
    NSInteger  _speedTag;
    
    UISwitch *_mirrorSwitch;
    UISwitch *_hwSwitch;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.mm_h = ScreenHeight;
    self.mm_w = MoreViewWidth;
    
    [self addSubview:[self soundCell]];
    [self addSubview:[self lightCell]];
    [self addSubview:[self mirrorCell]];
    [self addSubview:[self hwCell]];
    
    [self addNotifiers];
    
    return self;
}

- (void)dealloc
{
    [self removeNotifiers];
}


#pragma mark - 监听音量变化
-(void)addNotifiers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:)         name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];
}

-(void)removeNotifiers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)volumeChanged:(NSNotification *)notify
{
    if (!self.isVolume) {
        if (self.volumeEndTime != nil && -[self.volumeEndTime timeIntervalSinceNow] < 2.f)
            return;
        float volume = [[[notify userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
        self.soundSlider.value = volume;
    }
}

- (void)sizeToFit
{
    _contentHeight = 20;
    
    _soundCell.mm_top(_contentHeight);
    _contentHeight += _soundCell.mm_h;
    
    _ligthCell.mm_top(_contentHeight);
    _contentHeight += _ligthCell.mm_h;

    
    if (!self.isLive)
    {
        
        
        
        _mirrorCell.mm_top(_contentHeight);
        _contentHeight += _mirrorCell.mm_h;
        
        
        _mirrorCell.hidden = NO;
    }
    else
    {
        
        _mirrorCell.hidden = YES;
    }
    
    _hwCell.mm_top(_contentHeight);
    _contentHeight += _hwCell.mm_h;
}

- (UIView *)soundCell
{
    if (_soundCell == nil) {
        _soundCell = [[UIView alloc] initWithFrame:CGRectZero];
        _soundCell.mm_width(MoreViewWidth).mm_height(50).mm_left(10);
        
        // 声音
        UILabel *sound = [UILabel new];
        sound.text = @"声音";
        sound.textColor = [UIColor whiteColor];
        [sound sizeToFit];
        [_soundCell addSubview:sound];
        sound.mm__centerY(_soundCell.mm_h/2);

        
        UIImageView *soundImage1 = [[UIImageView alloc] initWithImage:SuperPlayerImage(@"sound_min")];
        [_soundCell addSubview:soundImage1];
        soundImage1.mm_left(sound.mm_maxX+10).mm__centerY(_soundCell.mm_h/2);

        UIImageView *soundImage2 = [[UIImageView alloc] initWithImage:SuperPlayerImage(@"sound_max")];
        [_soundCell addSubview:soundImage2];
        soundImage2.mm_right(50).mm__centerY(_soundCell.mm_h/2);
        
        
        UISlider *soundSlider                       = [[UISlider alloc] init];
        [soundSlider setThumbImage:SuperPlayerImage(@"slider_thumb") forState:UIControlStateNormal];
        
        soundSlider.maximumValue          = 1;
        soundSlider.minimumTrackTintColor = TintColor;
        soundSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        
        // slider开始滑动事件
        [soundSlider addTarget:self action:@selector(soundSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        // slider滑动中事件
        [soundSlider addTarget:self action:@selector(soundSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [soundSlider addTarget:self action:@selector(soundSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        [_soundCell addSubview:soundSlider];
        soundSlider.mm__centerY(_soundCell.mm_centerY).mm_left(soundImage1.mm_maxX).mm_width(soundImage2.mm_minX-soundImage1.mm_maxX);
        
        self.soundSlider = soundSlider;
    }
    return _soundCell;
}

- (UIView *)lightCell
{
    if (_ligthCell == nil) {
        _ligthCell = [[UIView alloc] initWithFrame:CGRectZero];
        _ligthCell.mm_width(MoreViewWidth).mm_height(50).mm_left(10);
        
        // 亮度
        UILabel *ligth = [UILabel new];
        ligth.text = @"亮度";
        ligth.textColor = [UIColor whiteColor];
        [ligth sizeToFit];
        [_ligthCell addSubview:ligth];
        ligth.mm__centerY(_ligthCell.mm_h/2);
        
        UIImageView *ligthImage1 = [[UIImageView alloc] initWithImage:SuperPlayerImage(@"light_min")];
        [_ligthCell addSubview:ligthImage1];
        ligthImage1.mm_left(ligth.mm_maxX+10).mm__centerY(_ligthCell.mm_h/2);
        
        UIImageView *ligthImage2 = [[UIImageView alloc] initWithImage:SuperPlayerImage(@"light_max")];
        [_ligthCell addSubview:ligthImage2];
        ligthImage2.mm_right(50).mm__centerY(_ligthCell.mm_h/2);
        
        
        UISlider *lightSlider                       = [[UISlider alloc] init];
        
        [lightSlider setThumbImage:SuperPlayerImage(@"slider_thumb") forState:UIControlStateNormal];
        
        lightSlider.maximumValue          = 1;
        lightSlider.minimumTrackTintColor = TintColor;
        lightSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        
        // slider开始滑动事件
        [lightSlider addTarget:self action:@selector(lightSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        // slider滑动中事件
        [lightSlider addTarget:self action:@selector(lightSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [lightSlider addTarget:self action:@selector(lightSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        
        [_ligthCell addSubview:lightSlider];
        lightSlider.mm__centerY(_ligthCell.mm_h/2).mm_left(ligthImage1.mm_maxX).mm_width(ligthImage2.mm_minX-ligthImage1.mm_maxX);
        
        self.lightSlider = lightSlider;
    }

    
    return _ligthCell;
}



- (UIView *)mirrorCell
{
    if (!_mirrorCell) {
        _mirrorCell = [UIView new];
        _mirrorCell.mm_width(MoreViewWidth).mm_height(50).mm_left(10);
        
        
        UILabel *mirror = [UILabel new];
        mirror.text = @"镜像";
        mirror.textColor = [UIColor whiteColor];
        [mirror sizeToFit];
        [_mirrorCell addSubview:mirror];
        mirror.mm__centerY(_mirrorCell.mm_h/2);

        UISwitch *switcher = [UISwitch new];
        _mirrorSwitch = switcher;
        [switcher addTarget:self action:@selector(changeMirror:) forControlEvents:UIControlEventValueChanged];
        [_mirrorCell addSubview:switcher];
        switcher.mm_right(30).mm__centerY(_mirrorCell.mm_h/2);
    }
    return _mirrorCell;
}

- (UIView *)hwCell
{
    if (!_hwCell) {
        _hwCell = [UIView new];
        _hwCell.mm_width(MoreViewWidth).mm_height(50).mm_left(10);
        
        
        UILabel *hd = [UILabel new];
        hd.text = @"硬件加速";
        
        hd.textColor = [UIColor whiteColor];
        [hd sizeToFit];
        [_hwCell addSubview:hd];
        hd.mm__centerY(_hwCell.mm_centerY);
        
        UISwitch *switcher = [UISwitch new];
        _hwSwitch = switcher;
        [switcher addTarget:self action:@selector(changeHW:) forControlEvents:UIControlEventValueChanged];
        [_hwCell addSubview:switcher];
        switcher.mm_right(30).mm__centerY(_hwCell.mm_h/2);
    }
    return _hwCell;
}



#pragma mark - 声音亮度条 调整
- (void)soundSliderTouchBegan:(UISlider *)sender {
    self.isVolume = YES;
}

- (void)soundSliderValueChanged:(UISlider *)sender {
    if (self.isVolume)
        [SuperPlayerView volumeViewSlider].value = sender.value;
}

- (void)soundSliderTouchEnded:(UISlider *)sender {
    self.isVolume = NO;
    self.volumeEndTime = [NSDate date];
}

- (void)lightSliderTouchBegan:(UISlider *)sender {
    
}

- (void)lightSliderValueChanged:(UISlider *)sender {
    [UIScreen mainScreen].brightness = sender.value;
}

- (void)lightSliderTouchEnded:(UISlider *)sender {
    
}


#pragma mark - 按钮事件

- (void)changeMirror:(UISwitch *)sender {
    self.playerConfig.mirror = sender.on;
    [self.controlView.delegate controlViewDidUpdateConfig:self.controlView withReload:NO];
    if (sender.on) {
        [DataReport report:@"mirror" param:nil];
    }
}

- (void)changeHW:(UISwitch *)sender {
    self.playerConfig.hwAcceleration = sender.on;
    [self.controlView.delegate controlViewDidUpdateConfig:self.controlView withReload:YES];
    [DataReport report:sender.on?@"hw_decode":@"soft_decode" param:nil];
}


#pragma mark - 更新状态
- (void)update
{
    //获取亮度和音量
    self.soundSlider.value = [SuperPlayerView volumeViewSlider].value;
    self.lightSlider.value = [UIScreen mainScreen].brightness;
    
    
    
    _mirrorSwitch.on = self.playerConfig.mirror;
    _hwSwitch.on = self.playerConfig.hwAcceleration;
    
    [self sizeToFit];
}

@end
