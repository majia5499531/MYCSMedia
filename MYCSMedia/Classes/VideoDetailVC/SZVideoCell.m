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
#import "MJHUD.h"
#import "VideoModel.h"
#import "VideoCollectModel.h"
#import "MJLabel.h"
#import "UIScrollView+MJCategory.h"

@implementation SZVideoCell
{
    //data
    VideoModel * dataModel;
    
    VideoCollectModel * collectModel;
    NSMutableArray * videoBtns;
    
    //UI
    UILabel * titleLabel;
    UILabel * authorLabel;
    UIButton * videoBtn;
    MJLabel * descLabel;
    MJButton * selecBtn;
    UIView * descBG;
    UILabel * shareTitle;
    UIScrollView * tagScrollBG;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor=HW_BLACK;
        
        //标题
        titleLabel = [[UILabel alloc]init];
        titleLabel.font=BOLD_FONT(20);
        titleLabel.textColor=HW_WHITE;
        titleLabel.numberOfLines=2;
        titleLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        [self.contentView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
            make.top.mas_equalTo(STATUS_BAR_HEIGHT+60);
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
        
        
        //选集按钮
        selecBtn = [[MJButton alloc]init];
        selecBtn.mj_imageObjec=[UIImage getBundleImage:@"sz_videoFilter"];
        selecBtn.imageFrame=CGRectMake(12.5, 6.5, 13, 12);
        selecBtn.mj_text=@"选集";
        selecBtn.titleFrame=CGRectMake(30, 4, 24, 17);
        selecBtn.mj_textColor=HW_BLACK;
        selecBtn.mj_bgColor=HW_WHITE;
        selecBtn.mj_font=FONT(12);
        selecBtn.layer.cornerRadius=12.5;
        [selecBtn addTarget:self action:@selector(selectBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:selecBtn];
        [selecBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView).offset(-15);
            make.top.mas_equalTo(authorLabel.mas_bottom).offset(10);
            make.width.mas_equalTo(65);
            make.height.mas_equalTo(25);
        }];
        
        
        //视频标签
        [tagScrollBG MJRemoveAllSubviews];
        tagScrollBG = [[UIScrollView alloc]init];
        [self addSubview:tagScrollBG];
        [tagScrollBG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(titleLabel.mas_left);
            make.right.mas_equalTo(selecBtn.mas_left).offset(-15);
            make.height.mas_equalTo(30);
            make.centerY.mas_equalTo(selecBtn.mas_centerY);
        }];
        
        
        //视频
        CGFloat videoHeight = SCREEN_WIDTH*0.56;
        videoBtn = [[UIButton alloc]init];
        videoBtn.backgroundColor=HW_BLACK;
        [self.contentView addSubview:videoBtn];
        [videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(self.contentView.mas_right);
            make.centerY.mas_equalTo(self.mas_centerY).offset(-15);
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
        shareTitle = [[UILabel alloc]init];
        shareTitle.textColor=HW_WHITE;
        shareTitle.font=FONT(12);
        shareTitle.text=@"分享到";
        [self addSubview:shareTitle];
        [shareTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(self.mas_bottom).offset(-COMMENT_BAR_HEIGHT-65);
        }];
        
        
        //timeline
        MJButton * timelineBtn = [[MJButton alloc]init];
        [timelineBtn setImage:[UIImage getBundleImage:@"sz_timeline"] forState:UIControlStateNormal];
        [timelineBtn addTarget:self action:@selector(timelineBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:timelineBtn];
        [timelineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(shareTitle.mas_bottom).offset(5);
            make.width.mas_equalTo(44);
            make.height.mas_equalTo(38);
        }];
        
        
        //wechat
        MJButton * wechatBtn = [[MJButton alloc]init];
        [wechatBtn setImage:[UIImage getBundleImage:@"sz_wechat"] forState:UIControlStateNormal];
        [wechatBtn addTarget:self action:@selector(wechatBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:wechatBtn];
        [wechatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX).offset(-47);
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
            make.centerX.mas_equalTo(self.mas_centerX).offset(47);
            make.bottom.mas_equalTo(timelineBtn.mas_bottom);
            make.width.mas_equalTo(44);
            make.height.mas_equalTo(38);
        }];
        
        
        //简述
        descLabel = [[MJLabel alloc]init];
        descLabel.numberOfLines=0;
        descLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        descLabel.textColor=HW_GRAY_WORD_1;
        descLabel.backgroundColor=[UIColor clearColor];
        descLabel.font=FONT(11);
        descLabel.userInteractionEnabled=YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(descTapAction)];
        [descLabel addGestureRecognizer:tap];
        [self addSubview:descLabel];
        
        
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
        
        
        
        
    }
    return self;
}



#pragma mark - Set Data
-(void)setCellData:(VideoModel*)objc
{
    //model
    dataModel = objc;
    
    //author
    authorLabel.text = [NSString stringWithFormat:@"%@ %@",dataModel.source,dataModel.startTime];
    
    //title
    titleLabel.attributedText = [NSString makeTitleStr:dataModel.title lineSpacing:5 indent:0];
    
    //标签
    
    NSString * tagsStr = dataModel.keywords;
    if (tagsStr.length)
    {
        NSArray * tagArr = [tagsStr componentsSeparatedByString:@","];
        if (tagArr.count)
        {
            CGFloat orginX = 0;
            for (int i = 0; i<tagArr.count; i++)
            {
                NSString * tagStr = tagArr[i];
                
                MJLabel * tagLabel=[[MJLabel alloc]init];
                tagLabel.text=tagStr;
                tagLabel.textColor=HW_GRAY_WORD_2;
                tagLabel.font=FONT(12);
                [tagLabel sizeToFit];
                [tagLabel setFrame:CGRectMake(orginX, 2.5, tagLabel.width+22, 25)];
                tagLabel.textAlignment=NSTextAlignmentCenter;
                tagLabel.layer.borderColor=HW_GRAY_BORDER_2.CGColor;
                tagLabel.layer.borderWidth=1;
                tagLabel.layer.cornerRadius=12.5;
                [tagScrollBG addSubview:tagLabel];
                orginX = tagLabel.right+10;
            }
            [tagScrollBG MJAutoSetContentSize];
        }
        
    }
    
    
    
    
    //desc
    descLabel.attributedText = [NSString makeTitleStr:dataModel.brief lineSpacing:5 indent:0];
    
    //是否可以展开简介
    [self layoutIfNeeded];
    
    //计算最大尺寸和预估尺寸
    [descLabel setFrame:CGRectMake(titleLabel.left, videoBtn.bottom+30, titleLabel.width, 0)];
    CGFloat maxHeight = shareTitle.top - videoBtn.bottom-30-22;
    CGFloat estimateHeight = [descLabel estimatedHeight];
    
    //如果预估尺寸大，则可点击展开
    if (estimateHeight>maxHeight)
    {
        [descLabel setFrame:CGRectMake(titleLabel.left, videoBtn.bottom+30, titleLabel.width, maxHeight)];
        descLabel.userInteractionEnabled=YES;
    }
    else
    {
        [descLabel setFrame:CGRectMake(titleLabel.left, videoBtn.bottom+30, titleLabel.width, estimateHeight)];
        descLabel.userInteractionEnabled=NO;
    }
    descLabel.lineBreakMode=NSLineBreakByTruncatingTail;
    
    //是否显示合集
    if (dataModel.pid.length)
    {
        selecBtn.hidden=NO;
    }
    else
    {
        selecBtn.hidden=YES;
    }
}


-(void)playingVideo
{
    [MJVideoManager cancelPlayingWindowVideo];
    [MJVideoManager playWindowVideoAtView:videoBtn url:dataModel.playUrl coverImage:dataModel.thumbnailUrl silent:NO repeat:NO controlStyle:0];
}




#pragma mark - Request
-(void)requestVideoCollection
{
    VideoCollectModel * model = [VideoCollectModel model];
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:self.window WithUrl:APPEND_COMPONENT(BASE_URL, API_URL_VIDEO_COLLECTION, dataModel.pid) Params:nil Success:^(id responseObject) {
        [weakSelf requestDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}

-(void)requestDone:(VideoCollectModel*)model
{
    collectModel = model;
    
    [self showSelectionView];
}


#pragma mark - Btn Action
-(void)videoBtnAction
{
    [self playingVideo];
}

-(void)wechatBtnAction
{
    if ([self checkDelegate])
    {
        [[SZManager sharedManager].delegate onShareAction:WECHAT_PLATFORM title:dataModel.shareTitle image:dataModel.shareImageUrl desc:dataModel.shareBrief URL:dataModel.shareUrl];
    }
    
}
-(void)timelineBtnAction
{
    if ([self checkDelegate])
    {
        [[SZManager sharedManager].delegate onShareAction:TIMELINE_PLATFORM title:dataModel.shareTitle image:dataModel.shareImageUrl desc:dataModel.shareBrief URL:dataModel.shareUrl];
    }
    
}
-(void)qqBtnAction
{
    if ([self checkDelegate])
    {
        [[SZManager sharedManager].delegate onShareAction:QQ_PLATFORM title:dataModel.shareTitle image:dataModel.shareImageUrl desc:dataModel.shareBrief URL:dataModel.shareUrl];
    }
}
-(void)selectBtnAction
{
    if (collectModel==nil)
    {
        [self requestVideoCollection];
        return;
    }
    
    [self showSelectionView];

}





-(void)descTapAction
{
    //展开
    if (descLabel.unfold==NO)
    {
        [descBG mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(descLabel.mas_top);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.bottom.mas_equalTo(self).offset(-COMMENT_BAR_HEIGHT);
        }];
        
        
        //展开
        [descLabel setFrame:CGRectMake(titleLabel.left, videoBtn.bottom+30, titleLabel.width, 0)];
        CGFloat maxHeight = SCREEN_HEIGHT - videoBtn.bottom-30-COMMENT_BAR_HEIGHT;
        CGFloat estimateHeight = [descLabel estimatedHeight];
        CGFloat targetheight = estimateHeight>maxHeight? maxHeight:estimateHeight;
        [descLabel setFrame:CGRectMake(titleLabel.left, videoBtn.bottom+30, titleLabel.width, targetheight)];

        descLabel.unfold=YES;
    }
    
    
    //收起
    else
    {
        [descBG mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(descLabel.mas_left);
            make.top.mas_equalTo(descLabel.mas_top);
            make.width.mas_equalTo(descLabel.mas_width);
            make.bottom.mas_equalTo(descLabel.mas_bottom);
        }];
    
        
        //展开
        [descLabel setFrame:CGRectMake(titleLabel.left, videoBtn.bottom+30, titleLabel.width, 0)];
        CGFloat maxHeight = shareTitle.top - videoBtn.bottom-30-22;
        [descLabel setFrame:CGRectMake(titleLabel.left, videoBtn.bottom+30, titleLabel.width, maxHeight)];
        
        descLabel.unfold=NO;
    }
}


#pragma mark - other
-(void)showSelectionView
{
    //show
    __weak typeof (self) weakSelf = self;
    
    NSInteger idx = -1;
    for (int i = 0; i<collectModel.dataArr.count; i++)
    {
        VideoModel * model = collectModel.dataArr[i];
        if ([model.id isEqualToString: dataModel.id])
        {
            idx = i;
        }
    }
    
    [MJHUD_Selection showEpisodeSelectionView:self.superview currenIdx:idx episode:collectModel.dataArr.count clickAction:^(id objc) {
        NSNumber * idex = objc;
        [weakSelf reloadDataWithIndex:[idex integerValue]];
        
    }];
}

-(void)reloadDataWithIndex:(NSInteger)idx
{
    VideoModel * newVideoModel = collectModel.dataArr[idx];
    [self setCellData:newVideoModel];
    [self.delegate didSelectVideo:newVideoModel];
    [self playingVideo];
}

-(BOOL)checkDelegate
{
    id delegate = [SZManager sharedManager].delegate;
    if (delegate && [delegate respondsToSelector:@selector(onShareAction:title:image:desc:URL:)])
    {
        return YES;;
    }
    else
    {
        NSLog(@"请实现SZDelegate方法");
        return NO;;
    }
}

@end
