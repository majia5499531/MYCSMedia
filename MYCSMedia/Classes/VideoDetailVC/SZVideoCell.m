//
//  SZVideoCell.m
//  智慧长沙
//
//  Created by 马佳 on 2019/11/13.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import "SZVideoCell.h"
#import <Masonry/Masonry.h>
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "MJVideoManager.h"
#import "MJButton.h"
#import "UIImage+MJCategory.h"
#import "NSString+MJCategory.h"
#import <SDWebImage/SDWebImage.h>
#import "SZManager.h"
#import "UIView+MJCategory.h"

@implementation SZVideoCell
{
    //data
    NSString * videoUrl;
    NSString * imageUrl;
    NSString * descStr;
    
    NSMutableArray * videoBtns;
    
    //UI
    UILabel * titleLabel;
    UILabel * authorLabel;
    UIButton * videoBtn;
    UILabel * descLabel;
    MJButton * foldBtn;
    UIView * descBG;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor=HW_BLACK;
        
        //标题
        titleLabel = [[UILabel alloc]init];
        titleLabel.font=BOLD_FONT(21);
        titleLabel.textColor=HW_WHITE;
        titleLabel.numberOfLines=2;
        titleLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        [self.contentView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
            make.top.mas_equalTo(STATUS_BAR_HEIGHT+70);
        }];
        
        
        
        //来源
        authorLabel = [[UILabel alloc]init];
        authorLabel.font = FONT(12);
        authorLabel.textColor=HW_GRAY_WORD_1;
        authorLabel.numberOfLines=2;
        authorLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        [self.contentView addSubview:authorLabel];
        [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
            make.top.mas_equalTo(titleLabel.mas_bottom).offset(10);
            
        }];
        
        
        
        
        //视频
        CGFloat videoHeight = SCREEN_WIDTH*0.56;
        videoBtn = [[UIButton alloc]init];
        videoBtn.backgroundColor=HW_GRAY_BG_3;
        [self.contentView addSubview:videoBtn];
        [videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(self.contentView.mas_right);
            make.top.mas_equalTo(authorLabel.mas_bottom).offset(45);
            make.height.mas_equalTo(videoHeight);
        }];
        
        
        
        //视频
        MJButton * playBtn = [[MJButton alloc]init];
        [playBtn addTarget:self action:@selector(videoBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [playBtn setImage:[UIImage getBundleImage:@"sz_playBtn"] forState:UIControlStateNormal];
        [videoBtn addSubview:playBtn];
        [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(videoBtn.mas_centerX);
            make.centerY.mas_equalTo(videoBtn.mas_centerY);
            make.width.mas_equalTo(44);
            make.height.mas_equalTo(44);
        }];
        
        
        
        //分享
        UILabel * label = [[UILabel alloc]init];
        label.textColor=HW_WHITE;
        label.font=FONT(12);
        label.text=@"分享到";
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-COMMENT_BAR_HEIGHT-65);
        }];
        
        
        
        //timeline
        MJButton * timelineBtn = [[MJButton alloc]init];
        [timelineBtn setImage:[UIImage getBundleImage:@"sz_timeline"] forState:UIControlStateNormal];
        [timelineBtn addTarget:self action:@selector(timelineBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:timelineBtn];
        [timelineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(label.mas_bottom).offset(5);
            make.width.mas_equalTo(44);
            make.height.mas_equalTo(38);
        }];
        
        //wechat
        MJButton * wechatBtn = [[MJButton alloc]init];
        [wechatBtn setImage:[UIImage getBundleImage:@"sz_wechat"] forState:UIControlStateNormal];
        [wechatBtn addTarget:self action:@selector(wechatBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:wechatBtn];
        [wechatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX).offset(-60);
            make.bottom.mas_equalTo(timelineBtn.mas_bottom);
            make.width.mas_equalTo(44);
            make.height.mas_equalTo(38);
        }];
        
        //qq
        MJButton * qqBtn = [[MJButton alloc]init];
        [qqBtn setImage:[UIImage getBundleImage:@"sz_qq"] forState:UIControlStateNormal];
        [qqBtn addTarget:self action:@selector(qqBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:qqBtn];
        [qqBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX).offset(60);
            make.bottom.mas_equalTo(timelineBtn.mas_bottom);
            make.width.mas_equalTo(44);
            make.height.mas_equalTo(38);
        }];
        
        
        
        //简述
        descLabel = [[UILabel alloc]init];
        descLabel.numberOfLines=3;
        descLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        descLabel.textColor=HW_GRAY_WORD_1;
        descLabel.backgroundColor=HW_CLEAR;
        descLabel.font=FONT(11);
        descLabel.userInteractionEnabled=YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(descTapAction)];
        [descLabel addGestureRecognizer:tap];
        [self addSubview:descLabel];
        [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(titleLabel.mas_left);
            make.right.mas_equalTo(titleLabel.mas_right);
            make.top.mas_equalTo(videoBtn.mas_bottom).offset(30);
        }];
        
        
        
        //文字BG
        descBG = [[UIView alloc]init];
        descBG.backgroundColor=HW_BLACK;
        [self addSubview:descBG];
        [self bringSubviewToFront:descLabel];
        [descBG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(descLabel.mas_left);
            make.top.mas_equalTo(descLabel.mas_top);
            make.width.mas_equalTo(descLabel.mas_width);
            make.bottom.mas_equalTo(descLabel.mas_bottom);
        }];
        
        
        //折叠按钮
        foldBtn = [[MJButton alloc]init];
        foldBtn.backgroundColor=HW_BLACK;
        foldBtn.mj_text=@"展开";
        foldBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_fold_down"];
        foldBtn.imageFrame=CGRectMake(9, 6, 4, 3);
        foldBtn.mj_font=FONT(12);
        foldBtn.titleFrame=CGRectMake(18.5, 0, 40, 15);
        foldBtn.mj_textColor=HW_WHITE;
        [foldBtn addTarget:self action:@selector(foldBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:foldBtn];
        [foldBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(48);
            make.height.mas_offset(35);
            make.right.mas_equalTo(descLabel.mas_right);
            make.top.mas_equalTo(descBG.mas_bottom).offset(-15);
        }];
        
        
        
        //选集按钮
        MJButton * selecBtn = [[MJButton alloc]init];
        selecBtn.mj_text=@"选集";
        selecBtn.mj_textColor=HW_WHITE;
        selecBtn.mj_font=FONT(14);
        [selecBtn addTarget:self action:@selector(selectBtnAction) forControlEvents:UIControlEventTouchUpInside];
        selecBtn.backgroundColor=HW_GRAY_BG_1;
        selecBtn.layer.cornerRadius=4;
        [self addSubview:selecBtn];
        [selecBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(32);
            make.top.mas_equalTo(videoBtn.mas_bottom);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(30);
        }];
        
        
        
        


        
    }
    return self;
}


-(void)setCellData:(NSObject*)news
{
    
    videoUrl = news;
    
    //video
    imageUrl = @"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.mp.sohu.com%2Fupload%2F20170718%2F917887432c1b4f96a40e0ab28fdbe1e3_th.png&refer=http%3A%2F%2Fimg.mp.sohu.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1625057654&t=9e3d1dda25d561813098c329a8f9ec5e";
    [videoBtn sd_setImageWithURL:[NSURL URLWithString:imageUrl] forState:UIControlStateNormal];
    
    
    //author
    authorLabel.text = @"智慧长沙  2021-05-21 11:30:46";
    
    //title
    NSString * titlestr = @"长沙实景交响诗MV丨红色经典激荡起“一身挂满音符的河,红色经典激荡起“一身挂满音符的河,红色经典激荡起“一身挂满音符的河";
    titleLabel.attributedText = [NSString makeTitleStr:titlestr lineSpacing:5 indent:0];
    
    
    //desc
    descStr = @"用一曲《浏阳河》唱响一条浏阳河，以一首首红色经典旋律激荡起这“一身挂满音符的河”，并沿着她的水路行走，一路唱响我们党一百年的历史长卷和新时代》唱响一条浏阳河，以一首首红色经典旋律激荡起这“一身挂满音符的河”，并沿着她的水路行走，一路唱响我们党一百年的历史长卷和新时代画卷，重温我们党一百年的光辉历程和伟大成就。以一首首红色经典旋律激荡起这“一身挂满音符的河”，并沿着她挂满音符的河”，并沿着她的的水路行走，一路唱响我们党一百年的历史长卷和新时代画卷，重温我们党一百年的光辉历程和伟大成就。";
    descLabel.attributedText = [NSString makeTitleStr:descStr lineSpacing:5 indent:0];
    
    
    
    
}


-(void)playingVideo
{
    NSLog(@"playingVideo %@",imageUrl);
    
    [MJVideoManager playWindowVideoAtView:videoBtn url:videoUrl coverImage:nil silent:NO repeat:NO controlStyle:0];
    
}




#pragma mark - Btn Action
-(void)videoBtnAction
{
    [self playingVideo];
}
-(void)wechatBtnAction
{
    [[SZManager sharedManager].delegate onShareAction:@"" image:@"" desc:@"" URL:@""];
}
-(void)timelineBtnAction
{
    [[SZManager sharedManager].delegate onShareAction:@"" image:@"" desc:@"" URL:@""];
}
-(void)qqBtnAction
{
    [[SZManager sharedManager].delegate onShareAction:@"" image:@"" desc:@"" URL:@""];
}
-(void)selectBtnAction
{
    [self.delegate didSelectCell:nil];
}


-(void)descTapAction
{
    [self foldBtnAction];
}

-(void)foldBtnAction
{
    NSInteger maxrow = 6;
    if (descLabel.numberOfLines < maxrow)
    {
        [descBG mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(descLabel.mas_top);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.bottom.mas_equalTo(self).offset(-COMMENT_BAR_HEIGHT);
        }];
        
        [foldBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(48);
            make.height.mas_offset(35);
            make.right.mas_equalTo(descLabel.mas_right);
            make.top.mas_equalTo(descBG.mas_bottom).offset(-22);
        }];
        
        
        foldBtn.mj_text=@"收起";
        foldBtn.mj_imageObjec=[UIImage getBundleImage:@"sz_fold_up"];
        descLabel.numberOfLines=maxrow;

    }
    else
    {
        [descBG mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(descLabel.mas_left);
            make.top.mas_equalTo(descLabel.mas_top);
            make.width.mas_equalTo(descLabel.mas_width);
            make.bottom.mas_equalTo(descLabel.mas_bottom);
        }];
        
        [foldBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(48);
            make.height.mas_offset(35);
            make.right.mas_equalTo(descLabel.mas_right);
            make.top.mas_equalTo(descBG.mas_bottom).offset(-15);
        }];
        
        foldBtn.mj_text=@"展开";
        foldBtn.mj_imageObjec=[UIImage getBundleImage:@"sz_fold_down"];
        descLabel.numberOfLines=3;
    }
}
    

@end
