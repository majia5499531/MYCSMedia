//
//  SZSideBar.m
//  MYCSMedia
//
//  Created by 马佳 on 2022/4/18.
//

#import "SZSideBar.h"
#import "SZDefines.h"
#import "UIView+MJCategory.h"
#import "UIColor+MJCategory.h"
#import <Masonry/Masonry.h>
#import "MJButton.h"
#import "UIImage+MJCategory.h"
#import "SZGlobalInfo.h"
#import "SZInputView.h"
#import "SZCommentList.h"
#import "CommentDataModel.h"
#import "CommentModel.h"
#import "MJHUD.h"
#import "StatusModel.h"
#import "ContentStateModel.h"
#import "IQDataBinding.h"
#import "SZData.h"
#import "ContentModel.h"
#import "SZManager.h"
#import "SZUserTracker.h"
#import "SZVideoUploadVC.h"
#import "UIResponder+MJCategory.h"
#import "SZUserTracker.h"
#import "SZHomeVC.h"
#import "UIResponder+MJCategory.h"


@interface SZSideBar ()
@end

@implementation SZSideBar
{
    SZCommentList * commentListView;
    
    UILabel * commentCount;
    
    MJButton * collectBtn;
    MJButton * zanBtn;
    MJButton * commentBtn;
    MJButton * shareBtn;
    MJButton * shotBtn;
    
    UILabel * collectLabel;
    UILabel * zanLabel;
    UILabel * shareLabel;
    UILabel * shotLabel;
}



-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupUI];
        
        [self addObserver];
    }
    return self;
}



#pragma mark - 数据绑定
-(void)addObserver
{
    //绑定数据
    [self bindModel:[SZData sharedSZData]];
    
    __weak typeof (self) weakSelf = self;
    self.observe(@"contentStateUpdateTime",^(id value){
        [weakSelf updateContentStateData];
    }).observe(@"contentZanTime",^(id value){
        [weakSelf updateContentStateData];
    }).observe(@"contentCollectTime",^(id value){
        [weakSelf updateContentStateData];
    }).observe(@"contentCommentsUpdateTime",^(id value){
        [weakSelf updateCommentData];
    });
}

-(void)clearAllData
{
    collectBtn.MJSelectState = NO;
    zanBtn.MJSelectState = NO;
    collectLabel.text = @"收藏";
    zanLabel.text = @"点赞";
    commentCount.text = @"评论";
}


-(void)setHidePublishBtn:(BOOL)b
{
    if(b)
    {
        [zanBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(33+27);
        }];
        
    }
    else
    {
        [zanBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
        }];
    }
    
    shotBtn.hidden=b;
    shotBtn.hidden=b;
    
}



#pragma mark - 界面&布局
-(void)setupUI
{
    CGFloat spaceY = 33;
    CGFloat fontsize = 13;
    
    
    //点赞
    zanBtn = [[MJButton alloc]init];
    zanBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_sidebar_zan"];
    zanBtn.mj_imageObject_sel = [UIImage getBundleImage:@"sz_sidebar_zan_sel"];
    [zanBtn addTarget:self action:@selector(zanBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:zanBtn];
    [zanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(27);
        make.height.mas_equalTo(27);
    }];

    //点赞数
    zanLabel = [[UILabel alloc]init];
    zanLabel.text=@"点赞";
    zanLabel.font=FONT(fontsize);
    zanLabel.textColor=HW_WHITE;
    zanLabel.alpha=0.5;
    zanLabel.textAlignment=NSTextAlignmentCenter;
    [self addSubview:zanLabel];
    [zanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(zanBtn.mas_centerX);
        make.top.mas_equalTo(zanBtn.mas_bottom).offset(3);
    }];

    
    //收藏
    collectBtn = [[MJButton alloc]init];
    collectBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_sidebar_collect"];
    collectBtn.mj_imageObject_sel = [UIImage getBundleImage:@"sz_sidebar_collect_sel"];
    [collectBtn addTarget:self action:@selector(collectBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:collectBtn];
    [collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(zanBtn.mas_bottom).offset(spaceY);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(26);
        make.height.mas_equalTo(25);
    }];

    //收藏数
    collectLabel = [[UILabel alloc]init];
    collectLabel.text=@"收藏";
    collectLabel.font=FONT(fontsize);
    collectLabel.textColor=HW_WHITE;
    collectLabel.alpha=0.5;
    collectLabel.textAlignment=NSTextAlignmentCenter;
    [self addSubview:collectLabel];
    [collectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(collectBtn.mas_centerX);
        make.top.mas_equalTo(collectBtn.mas_bottom).offset(3);
    }];
    
    
    //评论按钮
    commentBtn = [[MJButton alloc]init];
    commentBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_sidebar_comment"];
    [commentBtn addTarget:self action:@selector(commentTapAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:commentBtn];
    [commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(collectBtn.mas_bottom).offset(spaceY);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(27);
        make.height.mas_equalTo(27);
    }];
    
    
    //收藏数
    commentCount = [[UILabel alloc]init];
    commentCount.text=@"评论";
    commentCount.font=FONT(fontsize);
    commentCount.textColor=HW_WHITE;
    commentCount.alpha=0.5;
    commentCount.textAlignment=NSTextAlignmentCenter;
    [self addSubview:commentCount];
    [commentCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(commentBtn.mas_centerX);
        make.top.mas_equalTo(commentBtn.mas_bottom).offset(3);
    }];
    
    

    //分享按钮
    shareBtn = [[MJButton alloc]init];
    shareBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_sidebar_share"];
    [shareBtn addTarget:self action:@selector(shareBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shareBtn];
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(commentBtn.mas_bottom).offset(spaceY);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(27);
        make.height.mas_equalTo(27);
        
    }];

    //分享
    shareLabel = [[UILabel alloc]init];
    shareLabel.text=@"转发";
    shareLabel.font=FONT(fontsize);
    shareLabel.textColor=HW_WHITE;
    shareLabel.alpha=0.5;
    shareLabel.textAlignment=NSTextAlignmentCenter;
    [self addSubview:shareLabel];
    [shareLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(shareBtn.mas_centerX);
        make.top.mas_equalTo(shareBtn.mas_bottom).offset(3);
    }];

    //拍摄按钮
    shotBtn = [[MJButton alloc]init];
    shotBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_sidebar_publish"];
    [shotBtn addTarget:self action:@selector(shotBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shotBtn];
    [shotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(shareBtn.mas_bottom).offset(spaceY);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(27);
        make.height.mas_equalTo(27);
    }];

    //拍摄label
    shotLabel = [[UILabel alloc]init];
    shotLabel.text=@"发布";
    shotLabel.font=FONT(fontsize);
    shotLabel.textColor=HW_WHITE;
    shotLabel.alpha=0.5;
    shotLabel.textAlignment=NSTextAlignmentCenter;
    [self addSubview:shotLabel];
    [shotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(shotBtn.mas_centerX);
        make.top.mas_equalTo(shotBtn.mas_bottom).offset(3);
    }];
    
    
    //评论列表
    commentListView = [[SZCommentList alloc]init];
    [commentListView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
}

#pragma mark - 数据绑定回调
//点赞收藏状态
-(void)updateContentStateData
{
    NSString * currentVideoId = [SZData sharedSZData].currentContentId;
    if(![self.contentId isEqualToString:currentVideoId])
    {
        return;
    }
    
    
    //取数据
    ContentStateModel * stateM = [[SZData sharedSZData].contentStateDic valueForKey:self.contentId];
    
    collectBtn.MJSelectState = stateM.whetherFavor;
    
    zanBtn.MJSelectState = stateM.whetherLike;
    
    
    if (stateM.favorCountShow>0)
    {
        collectLabel.text = [NSString stringWithFormat:@"%ld",(long)stateM.favorCountShow];
    }
    else
    {
        collectLabel.text = @"收藏";
    }
    
    if (stateM.likeCountShow>0)
    {
        zanLabel.text = [NSString stringWithFormat:@"%ld",(long)stateM.likeCountShow];
    }
    else
    {
        zanLabel.text = @"点赞";
    }
}


//评论数
-(void)updateCommentData
{
    NSString * currentVideoId = [SZData sharedSZData].currentContentId;
    if(![self.contentId isEqualToString:currentVideoId])
    {
        return;
    }
    
    CommentDataModel * commentM = [[SZData sharedSZData].contentCommentDic valueForKey:self.contentId];
    if (commentM.total==0)
    {
        commentCount.text = @"评论";
    }
    else
    {
        commentCount.text = [NSString stringWithFormat:@"%ld",commentM.total];
    }
    
}




#pragma mark - Btn Action
-(void)commentTapAction
{
    if (commentListView.superview==nil)
    {
        //listview
        [self.window addSubview:commentListView];
        
        [commentListView showCommentList:YES];
    }
}


-(void)zanBtnAction
{
    //未登录则跳转登录
    if (![SZGlobalInfo sharedManager].SZRMToken.length)
    {
        [SZGlobalInfo mjshowLoginAlert];
        return;
    }
    
    [[SZData sharedSZData]requestZan:self.contentId];
}


-(void)collectBtnAction
{
    //未登录则跳转登录
    if (![SZGlobalInfo sharedManager].SZRMToken.length)
    {
        [SZGlobalInfo mjshowLoginAlert];
        return;
    }
    
    [[SZData sharedSZData]requestCollect:self.contentId];
}


-(void)shareBtnAction
{
    [MJHUD_Selection showShareView:^(id objc) {
        NSNumber * number = objc;
        SZ_SHARE_PLATFORM plat = number.integerValue;
        ContentModel * contentModel = [[SZData sharedSZData].contentDic valueForKey:self.contentId];
        [SZGlobalInfo mjshareToPlatform:plat content:contentModel source:@"底部分享"];
    }];
    
}


-(void)shotBtnAction
{
    //行为埋点
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:[SZData sharedSZData].currentVideoTab forKey:@"module_title"];
    [param setValue:[SZData sharedSZData].currentVideoTab forKey:@"module_source"];
    
    
    [SZUserTracker trackingButtonEventName:@"short_video_start_make" param:param];
    
    
    //未登录则跳转登录
    if (![SZGlobalInfo sharedManager].SZRMToken.length)
    {
        [SZGlobalInfo mjshowLoginAlert];
        return;
    }
    
    
    NSString * h5url = APPEND_SUBURL(BASE_H5_URL, @"fuse/htgcV2/#/addDynamic?source=app");
    [[SZManager sharedManager].delegate onOpenWebview:h5url param:nil];

}



@end
