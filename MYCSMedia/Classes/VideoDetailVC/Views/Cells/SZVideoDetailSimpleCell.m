//
//  SZVideoDetailSimpleCell.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/30.
//

#import "SZVideoDetailSimpleCell.h"
#import "UIResponder+MJCategory.h"
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
#import "MyLayout.h"
#import "YYText.h"
#import "NSAttributedString+YYText.h"
#import "StrUtils.h"
#import "MJProgressView.h"
#import "SPDefaultControlView.h"
#import "ContentStateModel.h"


@interface SZVideoDetailSimpleCell ()<GYRollingNoticeViewDelegate,GYRollingNoticeViewDataSource>

@end

@implementation SZVideoDetailSimpleCell
{
    //data
    ContentModel * dataModel;
    VideoRelateModel * relateModel;
    VideoCollectModel * collectModel;
    NSInteger renderMode;
    
    //UI
    UIImageView * videoCoverImage;
    YYLabel * descLabel;
    MJButton * selecBtn;
    UILabel * authorName;
    
    UIView * authorBG;
    UIImageView * avatar;
    UIImageView * levelIcon;
    MJButton * followBtn;
    
    MJProgressView * videoSlider;
    
    NSMutableArray * videoBtns;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor=[UIColor blackColor];
        
        //视频
        CGFloat videoHeight = SCREEN_WIDTH*0.56;
        videoCoverImage = [[UIImageView alloc]init];
        videoCoverImage.userInteractionEnabled=YES;
        videoCoverImage.backgroundColor=HW_BLACK;
        [self.contentView addSubview:videoCoverImage];
        [videoCoverImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(self.contentView.mas_right);
            make.centerY.mas_equalTo(self.mas_centerY).offset(-15);
            make.height.mas_equalTo(videoHeight);
        }];
        
        
        //视频
        MJButton * playBtn = [[MJButton alloc]init];
        [playBtn addTarget:self action:@selector(videoBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [playBtn setImage:[UIImage getBundleImage:@"sz_middle_play"] forState:UIControlStateNormal];
        [videoCoverImage addSubview:playBtn];
        [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(videoCoverImage.mas_centerX);
            make.centerY.mas_equalTo(videoCoverImage.mas_centerY);
            make.width.mas_equalTo(44);
            make.height.mas_equalTo(44);
        }];
        
        
        //简述(包含话题)
        descLabel = [[YYLabel alloc]init];
        descLabel.numberOfLines=2;
        descLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        descLabel.textColor=HW_GRAY_WORD_1;
        descLabel.userInteractionEnabled=YES;
        descLabel.preferredMaxLayoutWidth = SCREEN_WIDTH-42;
        [self addSubview:descLabel];
        [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(21);
            make.width.mas_equalTo(SCREEN_WIDTH-42);
            make.bottom.mas_equalTo(-BOTTOM_SAFEAREA_HEIGHT-10);
        }];
        
        //作者bg
        authorBG = [[UIView alloc]init];
        authorBG.backgroundColor=[UIColor blackColor];
        authorBG.layer.cornerRadius=14;
        [authorBG MJSetIndividualAlpha:0.3];
        [self addSubview:authorBG];
        
        //作者头像
        avatar = [[UIImageView alloc]init];
        avatar.userInteractionEnabled=YES;
        avatar.layer.cornerRadius=16;
        avatar.layer.masksToBounds=YES;
        [self addSubview:avatar];
        avatar.backgroundColor=[UIColor whiteColor];
        UITapGestureRecognizer * tap0 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(authorDetailBtnAction)];
        [avatar addGestureRecognizer:tap0];
        [avatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(authorBG.mas_left);
            make.centerY.mas_equalTo(authorBG);
            make.width.height.mas_equalTo(32);
        }];
        
        
        //作者名
        authorName = [[UILabel alloc]init];
        authorName.font = FONT(16);
        authorName.textColor=HW_WHITE;
        authorName.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(authorDetailBtnAction)];
        [authorName addGestureRecognizer:tap1];
        [self addSubview:authorName];
        [authorName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(avatar.mas_right).offset(5);
            make.centerY.mas_equalTo(authorBG);
        }];
        
        
        //用户星级
        levelIcon = [[UIImageView alloc]init];
        [self addSubview:levelIcon];
        [levelIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(authorName.mas_right).offset(7);
            make.centerY.mas_equalTo(authorName);
            make.width.height.mas_equalTo(13);
        }];
        
        
        //关注按钮
        followBtn = [[MJButton alloc]init];
        followBtn.mj_bgColor = HW_RED_WORD_1;
        followBtn.mj_text = @"关注";
        followBtn.mj_text_sel = @"已关注";
        followBtn.mj_textColor=HW_WHITE;
        followBtn.mj_bgColor_sel=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
        followBtn.mj_font = FONT(12);
        followBtn.layer.cornerRadius = 11;
        [followBtn addTarget:self action:@selector(followBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:followBtn];
        [followBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(levelIcon.mas_right).offset(7);
            make.height.mas_equalTo(22);
            make.centerY.mas_equalTo(levelIcon);
            make.width.mas_equalTo(40);
        }];
        
        
        
        //数据监听
        [self addDataBinding];
        
    }
    return self;
}




#pragma mark - SetCellData
-(void)setCellData:(ContentModel*)objc enableFollow:(BOOL)enable
{
    //model
    dataModel = objc;
    
    //视频宽高比
    CGFloat imageWidth = objc.width.floatValue > 0 ? objc.width.floatValue : 1920;
    CGFloat imageHeight = objc.height.floatValue > 0 ? objc.height.floatValue : 1080;
    CGFloat WHRate = imageWidth / imageHeight;
    
    
    //0.562左右
    if (WHRate<0.57 && WHRate>0.55)
    {
        renderMode = 0;
        
        //如果是刘海屏，则平铺，裁剪
        if ([UIApplication sharedApplication].statusBarFrame.size.height>20)
        {
            [videoCoverImage mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
                make.top.mas_equalTo(0);
                make.width.mas_equalTo(SCREEN_WIDTH);
                make.bottom.mas_equalTo(-COMMENT_BAR_HEIGHT);
            }];
        }
        else
        {
            
            [videoCoverImage mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
                make.top.mas_equalTo(0);
                make.width.mas_equalTo(SCREEN_WIDTH);
                make.bottom.mas_equalTo(0);
            }];
        }
        
    }
    else
    {
        renderMode = 1;
        
        CGFloat videoH = SCREEN_WIDTH / WHRate;
        [videoCoverImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.centerY.mas_equalTo(self).offset(-15);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.height.mas_equalTo(videoH);
        }];
        
    }
    
    

    //话题 与 简述
    NSString * finalDesc = @"";
    NSString * topicStr = @"";
    if (dataModel.belongTopicName.length)
    {
        topicStr = [NSString stringWithFormat:@"#%@",dataModel.belongTopicName];
        NSString * descStr = dataModel.brief.length>0 ? dataModel.brief:dataModel.title;
        finalDesc = [NSString stringWithFormat:@"%@ %@",topicStr,descStr];
    }
    else
    {
        NSString * descStr = dataModel.brief.length>0 ? dataModel.brief:dataModel.title;
        finalDesc = [NSString stringWithFormat:@"%@",descStr];
    }
    
    
    //富文本简述
    __weak typeof (self) weakSelf = self;
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:finalDesc];
    
    
    
    [mutableString yy_setTextHighlightRange:NSMakeRange(0, topicStr.length) color:[UIColor whiteColor] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        [weakSelf topicClickAction];
    }];
    [mutableString yy_setFont:[UIFont systemFontOfSize:15] range:NSMakeRange(0, topicStr.length)];
    
    
    [mutableString yy_setTextHighlightRange:NSMakeRange(topicStr.length, finalDesc.length - topicStr.length) color:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        [weakSelf descClickAction];
    }];
    [mutableString yy_setFont:[UIFont systemFontOfSize:13] range:NSMakeRange(topicStr.length, finalDesc.length - topicStr.length)];
    [mutableString yy_setLineSpacing:4 range:NSMakeRange(0,finalDesc.length)];
    
    descLabel.attributedText = mutableString;
    descLabel.lineBreakMode=NSLineBreakByTruncatingTail;
    
    
    //作者名
    authorName.text = dataModel.creatorNickname;
    
    //作者头像
    [avatar sd_setImageWithURL:[NSURL URLWithString:dataModel.creatorHead]];
    
    //作者等级(黄V，蓝V，普通用户)
    if ([dataModel.creatorCertMark isEqualToString:@"blue-v"])
    {
        levelIcon.image = [UIImage getBundleImage:@"sz_level_blue"];
        levelIcon.hidden=NO;
        [followBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(levelIcon.mas_right).offset(7);
            make.height.mas_equalTo(22);
            make.centerY.mas_equalTo(levelIcon);
            make.width.mas_equalTo(40);
        }];
    }
    else if ([dataModel.creatorCertMark isEqualToString:@"yellow-v"])
    {
        levelIcon.image = [UIImage getBundleImage:@"sz_level_yellow"];
        levelIcon.hidden=NO;
        [followBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(levelIcon.mas_right).offset(7);
            make.height.mas_equalTo(22);
            make.centerY.mas_equalTo(levelIcon);
            make.width.mas_equalTo(40);
        }];
    }
    else
    {
        levelIcon.image = nil;
        levelIcon.hidden=YES;
        [followBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(authorName.mas_right).offset(7);
            make.height.mas_equalTo(22);
            make.centerY.mas_equalTo(authorName);
            make.width.mas_equalTo(40);
        }];
    }
    
    
    //默认隐藏通知条
    [authorBG mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(descLabel.mas_top).offset(-13);
        make.left.mas_equalTo(descLabel.mas_left);
        make.height.mas_equalTo(28);
        make.width.greaterThanOrEqualTo(@55);
    }];
    
    
    //是否有用户系统
    if (enable)
    {
        //如果当前登录用户是自己
        if ([[SZGlobalInfo sharedManager].userId isEqualToString:dataModel.createBy])
        {
            levelIcon.hidden = NO;
            followBtn.hidden=YES;
            avatar.userInteractionEnabled = YES;
            authorName.userInteractionEnabled = YES;
            
            [authorBG mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(descLabel.mas_top).offset(-13);
                make.left.mas_equalTo(descLabel.mas_left);
                make.height.mas_equalTo(28);
                make.right.mas_equalTo(levelIcon.mas_right).offset(8);
            }];
        }
        else
        {
            levelIcon.hidden = NO;
            followBtn.hidden = NO;
            avatar.userInteractionEnabled = YES;
            authorName.userInteractionEnabled = YES;
            
            [authorBG mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(descLabel.mas_top).offset(-13);
                make.left.mas_equalTo(descLabel.mas_left);
                make.height.mas_equalTo(28);
                make.right.mas_equalTo(followBtn.mas_right).offset(5);
            }];
        }
    }
    else
    {
        levelIcon.hidden = YES;
        followBtn.hidden = YES;
        
        avatar.userInteractionEnabled = NO;
        authorName.userInteractionEnabled = NO;
        
        [authorBG mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(descLabel.mas_top).offset(-13);
            make.left.mas_equalTo(descLabel.mas_left);
            make.height.mas_equalTo(28);
            make.right.mas_equalTo(authorName.mas_right).offset(10);
        }];
    }
    


}




#pragma mark - 数据绑定 与 回调
-(void)addDataBinding
{
    //绑定数据
    [self bindModel:[SZData sharedSZData]];
    
    __weak typeof (self) weakSelf = self;
    self.observe(@"contentRelateUpdateTime",^(id value){
        
    }).observe(@"currentContentId",^(id value){
        [weakSelf currentContentIdDidChange:value];
    }).observe(@"contentCreateFollowTime",^(id value){
        [weakSelf currentFollowStateDidChange];
    }).observe(@"contentStateUpdateTime",^(id value){
        [weakSelf currentFollowStateDidChange];
    });
}


//contentId有更新
-(void)currentContentIdDidChange:(NSString*)currentId
{
    //如果当前ID与cell持有的内容ID相同，则表示播放该视频
    if ([dataModel.id isEqualToString:currentId])
    {
        //判断是否当前VC在顶层
        UIViewController * vc = [self getCurrentViewController];
        UINavigationController * nav = [self getCurrentNavigationController];
        if ([nav.topViewController isEqual:vc])
        {
            [self playingVideo];
        }
        [self playingVideo];
    }
}


//关注状态变化
-(void)currentFollowStateDidChange
{
    NSString * contentId = [SZData sharedSZData].currentContentId;
    if ([dataModel.id isEqualToString:contentId])
    {
        //是否已关注
        ContentStateModel * stateM = [[SZData sharedSZData].contentStateDic valueForKey:contentId];
        if (stateM.whetherFollow)
        {
            followBtn.MJSelectState=YES;
            [followBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(50);
            }];
        }
        else
        {
            followBtn.MJSelectState=NO;
            [followBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(40);
            }];
        }
    }
}


#pragma mark - 播放视频
-(void)playingVideo
{
    //播放视频
    [MJVideoManager playWindowVideoAtView:videoCoverImage url:dataModel.playUrl contentModel:dataModel renderModel:renderMode];
    
    //获取进度条
    SPDefaultControlView * controlView =  (SPDefaultControlView*)[MJVideoManager videoPlayer].controlView;
    videoSlider = controlView.externalSlider;
    
    [self insertSubview:videoSlider belowSubview:descLabel];
    [videoSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(30);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(avatar.mas_top).offset(-3);
    }];
    
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

-(void)followBtnAction
{
    //未登录则跳转登录
    if (![SZGlobalInfo sharedManager].SZRMToken.length)
    {
        [SZGlobalInfo mjshowLoginAlert];
        return;
    }
    
    if (followBtn.MJSelectState)
    {
        [[SZData sharedSZData]requestUnFollowUser:dataModel.createBy];
    }
    else
    {
        [[SZData sharedSZData]requestFollowUser:dataModel.createBy];
    }
}

-(void)authorDetailBtnAction
{
    [[SZManager sharedManager].delegate onOpenWebview:@"https://www.zhipin.com" param:nil];
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

-(void)descClickAction
{
    YYLabel * label =  descLabel;
    if (label.numberOfLines < 2)
    {
        label.numberOfLines = 2;
    }
    else
    {
        label.numberOfLines = 0;
    }
}

-(void)topicClickAction
{
    [[SZManager sharedManager].delegate onOpenWebview:@"https://www.zhipin.com" param:nil];
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
//    ContentModel * newContentModel = collectModel.dataArr[idx];
//    [self setCellData:newContentModel enableFollow:NO];
//    [self.delegate didSelectVideo:newContentModel];
//    [self playingVideo];
}


#pragma mark - GYScroll Delegate
-(NSInteger)numberOfRowsForRollingNoticeView:(GYRollingNoticeView *)rollingView
{
    return relateModel.dataArr.count;
}

-(__kindof GYNoticeViewCell *)rollingNoticeView:(GYRollingNoticeView *)rollingView cellAtIndex:(NSUInteger)index
{
    GYNoticeCell *cell = [rollingView dequeueReusableCellWithIdentifier:@"gynoticecellid"];
    
    VideoRelateModel * relateM = relateModel.dataArr[index];
    [cell setCellData:relateM];
    return cell;
}



@end
