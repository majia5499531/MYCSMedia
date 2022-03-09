//
//  VideoRateView.m
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/26.
//

#import "VideoRateView.h"
#import <Masonry/Masonry.h>
#import "SuperPlayer.h"
#import "SZUserTracker.h"
#import "SZData.h"

#define TAG_1_SPEED 1001
#define TAG_2_SPEED 1002
#define TAG_3_SPEED 1003
#define TAG_4_SPEED 1004
#define TAG_5_SPEED 1005
#define TAG_6_SPEED 1006

@implementation VideoRateView
{
    NSMutableArray * btnArr;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    //标题
    UILabel *lable = [UILabel new];
    lable.text = @"清晰度";
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = [UIColor whiteColor];
    [self addSubview:lable];
    
    [lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.mas_width);
        make.height.mas_equalTo(30);
        make.left.equalTo(self.mas_left);
        make.top.equalTo(self.mas_top).mas_offset(20);
    }];
    
    
    //0.5
    UIButton *speedBtn1 = [[UIButton alloc]init];
    [speedBtn1 setTitle:@"0.5X" forState:UIControlStateNormal];
    speedBtn1.titleLabel.font=[UIFont systemFontOfSize:15];
    [speedBtn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [speedBtn1 setTitleColor:TintColor forState:UIControlStateSelected];
    speedBtn1.tag = TAG_1_SPEED;
    [speedBtn1 addTarget:self action:@selector(changeSpeed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:speedBtn1];
    
    [speedBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.mas_width);
        make.height.mas_equalTo(30);
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(self.mas_bottom).offset(-40);
    }];
    
    //0.75
    UIButton *speedBtn2 = [[UIButton alloc]init];
    [speedBtn2 setTitle:@"0.75X" forState:UIControlStateNormal];
    speedBtn2.titleLabel.font=[UIFont systemFontOfSize:15];
    [speedBtn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [speedBtn2 setTitleColor:TintColor forState:UIControlStateSelected];
    speedBtn2.tag = TAG_2_SPEED;
    [speedBtn2 addTarget:self action:@selector(changeSpeed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:speedBtn2];
    
    [speedBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.mas_width);
        make.height.mas_equalTo(30);
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(speedBtn1.mas_top).offset(-20);
    }];
    
    //1.0
    UIButton *speedBtn3 = [[UIButton alloc]init];
    [speedBtn3 setTitle:@"1.0X" forState:UIControlStateNormal];
    speedBtn3.titleLabel.font=[UIFont systemFontOfSize:15];
    [speedBtn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [speedBtn3 setTitleColor:TintColor forState:UIControlStateSelected];
    speedBtn3.tag = TAG_3_SPEED;
    [speedBtn3 addTarget:self action:@selector(changeSpeed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:speedBtn3];
    
    [speedBtn3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.mas_width);
        make.height.mas_equalTo(30);
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(speedBtn2.mas_top).offset(-20);
    }];
    
    //1.25
    UIButton *speedBtn4 = [[UIButton alloc]init];
    [speedBtn4 setTitle:@"1.25X" forState:UIControlStateNormal];
    speedBtn4.titleLabel.font=[UIFont systemFontOfSize:15];
    [speedBtn4 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [speedBtn4 setTitleColor:TintColor forState:UIControlStateSelected];
    speedBtn4.tag = TAG_4_SPEED;
    [speedBtn4 addTarget:self action:@selector(changeSpeed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:speedBtn4];
    
    [speedBtn4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.mas_width);
        make.height.mas_equalTo(30);
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(speedBtn3.mas_top).offset(-20);
    }];
    
    //1.5
    UIButton *speedBtn5 = [[UIButton alloc]init];
    [speedBtn5 setTitle:@"1.5X" forState:UIControlStateNormal];
    speedBtn5.titleLabel.font=[UIFont systemFontOfSize:15];
    [speedBtn5 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [speedBtn5 setTitleColor:TintColor forState:UIControlStateSelected];
    speedBtn5.tag = TAG_5_SPEED;
    [speedBtn5 addTarget:self action:@selector(changeSpeed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:speedBtn5];
    
    [speedBtn5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.mas_width);
        make.height.mas_equalTo(30);
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(speedBtn4.mas_top).offset(-20);
    }];
    
    //2.0
    UIButton *speedBtn6 = [[UIButton alloc]init];
    [speedBtn6 setTitle:@"2.0X" forState:UIControlStateNormal];
    speedBtn6.titleLabel.font=[UIFont systemFontOfSize:15];
    [speedBtn6 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [speedBtn6 setTitleColor:TintColor forState:UIControlStateSelected];
    speedBtn6.tag = TAG_6_SPEED;
    [speedBtn6 addTarget:self action:@selector(changeSpeed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:speedBtn6];
    
    [speedBtn6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.mas_width);
        make.height.mas_equalTo(30);
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(speedBtn5.mas_top).offset(-20);
    }];

    
    btnArr=[NSMutableArray array];
    [btnArr addObject:speedBtn1];
    [btnArr addObject:speedBtn2];
    [btnArr addObject:speedBtn3];
    [btnArr addObject:speedBtn4];
    [btnArr addObject:speedBtn5];
    [btnArr addObject:speedBtn6];
    
    return self;
}



-(void)changeSpeed:(UIButton*)btn
{
    
    
    for (int i = 0; i < btnArr.count; i++)
    {
        UIButton *b = btnArr[i];
        b.selected = NO;
    }
    btn.selected=YES;
    
    
    CGFloat rateValue = [btn.titleLabel.text floatValue];
    self.playerConfig.playRate = rateValue;
    [self.controlView.delegate controlViewDidUpdateConfig:self.controlView withReload:NO];
    
    
    //行为埋点
    ContentModel * contentM = [[SZData sharedSZData].contentDic valueForKey:[SZData sharedSZData].currentContentId];
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:contentM.id forKey:@"content_id"];
    [param setValue:contentM.title forKey:@"content_name"];
    [param setValue:contentM.source forKey:@"content_source"];
    [param setValue:[NSString stringWithFormat:@"%.1f",rateValue] forKey:@"speed_n"];
    [param setValue:contentM.keywords forKey:@"content_key"];
    [param setValue:contentM.tags forKey:@"content_list"];
    [param setValue:contentM.classification forKey:@"content_classify"];
    [param setValue:contentM.thirdPartyId forKey:@"third_ID"];
    [param setValue:contentM.startTime forKey:@"create_time"];
    [param setValue:contentM.issueTimeStamp forKey:@"publish_time"];
    [SZUserTracker trackingButtonEventName:@"video_click_speed" param:param];
    
}



-(void)updateState
{
    //设置选中状态
    for (int i = 0; i < btnArr.count; i++)
    {
        UIButton *b = btnArr[i];
        b.selected = NO;
    }
    
    //获取当前的播放速率
    CGFloat rate = self.playerConfig.playRate;
    
    if (rate == 0.5)
    {
        [btnArr[0] setSelected:YES];
    }
    if (rate == 0.75) {
        [btnArr[1] setSelected:YES];
    }
    if (rate == 1.0) {
        [btnArr[2] setSelected:YES];
    }
    if (rate == 1.25) {
        [btnArr[3] setSelected:YES];
    }
    if (rate == 1.5) {
        [btnArr[4] setSelected:YES];
    }
    if (rate == 2.0) {
        [btnArr[5] setSelected:YES];
    }
    
}


@end
