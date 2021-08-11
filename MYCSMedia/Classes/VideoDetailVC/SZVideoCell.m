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
#import "SZGlobalInfo.h"
#import "UIView+MJCategory.h"
#import "MJHUD.h"
#import "ContentModel.h"
#import "VideoCollectModel.h"
#import "MJLabel.h"
#import "UIScrollView+MJCategory.h"
#import "GYRollingNoticeView.h"
#import "GYNoticeCell.h"
#import "SZData.h"
#import "VideoRelateModel.h"

@interface SZVideoCell ()<GYRollingNoticeViewDelegate,GYRollingNoticeViewDataSource>

@end

@implementation SZVideoCell
{
    //data
    ContentModel * dataModel;
    VideoRelateModel * relateModel;
    VideoCollectModel * collectModel;
    
    
    //UI
    UILabel * titleLabel;
    UILabel * authorLabel;
    UIButton * videoBtn;
    MJLabel * descLabel;
    MJButton * selecBtn;
    GYRollingNoticeView * noticeView;
    
    UIScrollView * tagScrollBG;
    NSMutableArray * videoBtns;
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
        
        
        //简述
        descLabel = [[MJLabel alloc]init];
        descLabel.numberOfLines=3;
        descLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        descLabel.textColor=HW_GRAY_WORD_1;
        descLabel.font=FONT(11);
        descLabel.userInteractionEnabled=YES;
        [self addSubview:descLabel];
        [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(titleLabel.mas_left);
            make.right.mas_equalTo(titleLabel.mas_right);
            make.bottom.mas_equalTo(-COMMENT_BAR_HEIGHT-12);
        }];
        
        if (IS_IPHONE_5)
        {
            descLabel.numberOfLines=2;
        }
        
        
        //滚动通知
        noticeView = [[GYRollingNoticeView alloc]init];
        noticeView.delegate = self;
        noticeView.dataSource = self;
        [self addSubview:noticeView];
        [noticeView registerClass:[GYNoticeCell class] forCellReuseIdentifier:@"gynoticecellid"];
        [noticeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(descLabel.mas_left).offset(-3);
            make.bottom.mas_equalTo(descLabel.mas_top).offset(-18);
            make.right.mas_equalTo(-20);
            make.height.mas_equalTo(46);//36
        }];
        
        //数据监听
        [self addDataBinding];
        
    }
    return self;
}




#pragma mark - 数据绑定 与 回调
-(void)addDataBinding
{
    //绑定数据
    [self bindModel:[SZData sharedSZData]];
    
    __weak typeof (self) weakSelf = self;
    self.observe(@"contentRelateUpdateTime",^(id value){
        [weakSelf updateVideoRelate];
    }).observe(@"currentContentId",^(id value){
        [weakSelf currentContentIdDidChange:value];
    });
}

//视频相关新闻
-(void)updateVideoRelate
{
    NSString * contentId = [SZData sharedSZData].currentContentId;
    if ([dataModel.id isEqualToString:contentId])
    {
        
       relateModel = [[SZData sharedSZData].contentRelateContentDic valueForKey:contentId];
       [noticeView reloadDataAndStartRoll];
    }
}

-(void)currentContentIdDidChange:(NSString*)currentId
{
    //如果当前ID与cell持有的内容ID相同，则表示播放该视频
    if ([dataModel.id isEqualToString:currentId])
    {
        [self playingVideo];
    }
}


#pragma mark - 播放视频
-(void)playingVideo
{
    [MJVideoManager playWindowVideoAtView:videoBtn url:dataModel.playUrl coverImage:dataModel.thumbnailUrl silent:NO repeat:NO controlStyle:0];
}


#pragma mark - GYScroll Delegate
- (NSInteger)numberOfRowsForRollingNoticeView:(GYRollingNoticeView *)rollingView
{
    return relateModel.dataArr.count;
}

- (__kindof GYNoticeViewCell *)rollingNoticeView:(GYRollingNoticeView *)rollingView cellAtIndex:(NSUInteger)index
{
    GYNoticeCell *cell = [rollingView dequeueReusableCellWithIdentifier:@"gynoticecellid"];
    
    VideoRelateModel * relateM = relateModel.dataArr[index];
    [cell setCellData:relateM];
    return cell;
}


#pragma mark - Set Data
-(void)setCellData:(ContentModel*)objc
{
    //model
    dataModel = objc;
    
    //title
    titleLabel.attributedText = [NSString makeTitleStr:dataModel.title lineSpacing:5 indent:0];
    
    //author
    NSString * dateStr = [NSString converUTCDateStr:dataModel.startTime];
    authorLabel.text = [NSString stringWithFormat:@"%@ %@",dataModel.source,dateStr];
    
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
    
    
    //简介
    descLabel.attributedText = [NSString makeTitleStr:dataModel.brief lineSpacing:5 indent:0];
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



-(void)selectBtnAction
{
    if (collectModel==nil)
    {
        [self requestVideoCollection];
        return;
    }
    
    [self showSelectionView];
}






#pragma mark - Other
-(void)showSelectionView
{
    //show
    __weak typeof (self) weakSelf = self;
    
    NSInteger idx = -1;
    for (int i = 0; i<collectModel.dataArr.count; i++)
    {
        ContentModel * model = collectModel.dataArr[i];
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
    ContentModel * newContentModel = collectModel.dataArr[idx];
    [self setCellData:newContentModel];
    [self.delegate didSelectVideo:newContentModel];
    [self playingVideo];
}



@end
