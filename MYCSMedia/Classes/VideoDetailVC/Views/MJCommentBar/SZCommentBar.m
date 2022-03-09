//
//  SZCommentBar.m
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/29.
//

#import "SZCommentBar.h"
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
#import "SZUploadingVC.h"
#import "UIResponder+MJCategory.h"
#import "SZUserTracker.h"
#import "SZHomeVC.h"

@interface SZCommentBar ()

@end

@implementation SZCommentBar
{
    UIView * bgview;
    
    SZCommentList * commentListView;
    
    UILabel * titleLabel;
    UILabel * countLabel;
    MJButton * sendBtn;
    UIView * sendBtnBG;
    
    MJButton * collectBtn;
    MJButton * zanBtn;
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
    self.observe(@"currentContentId",^(id value){
        weakSelf.contentId = value;
        [weakSelf updateContentInfo];
    }).observe(@"contentStateUpdateTime",^(id value){
        [weakSelf updateContentStateData];
    }).observe(@"contentZanTime",^(id value){
        [weakSelf updateContentStateData];
    }).observe(@"contentCollectTime",^(id value){
        [weakSelf updateContentStateData];
    }).observe(@"contentCommentsUpdateTime",^(id value){
        [weakSelf updateCommentData];
    });
}



#pragma mark - Public
-(void)setCommentBarStyle:(NSInteger)style type:(NSInteger)type
{
    if (style==0)
    {
        bgview.backgroundColor=[UIColor blackColor];
        bgview.alpha = 0.2;
        
        sendBtnBG.backgroundColor=[UIColor whiteColor];
        sendBtnBG.alpha = 0.2;
    }
    else
    {
        bgview.backgroundColor=[UIColor blackColor];
        bgview.alpha = 0.8;
        
        sendBtnBG.backgroundColor=HW_GRAY_BG_3;
        sendBtnBG.alpha = 1;
    }
    
    
    
    //含发布按钮
    if (type==0)
    {
        [sendBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.top.mas_equalTo(40);
            make.height.mas_equalTo(32);
            make.right.mas_equalTo(self).offset(-208);
        }];
        
        shotBtn.hidden=NO;
        shotLabel.hidden=NO;
    }
    else
    {
        [sendBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(17);
            make.top.mas_equalTo(40);
            make.height.mas_equalTo(32);
            make.right.mas_equalTo(self).offset(-158);
        }];
        
        shotBtn.hidden=YES;
        shotLabel.hidden=YES;
    }
}


#pragma mark - 界面&布局
-(void)setupUI
{
    self.backgroundColor=[UIColor clearColor];
    
    //背景色
    bgview = [[UIView alloc]init];
    bgview.backgroundColor=[UIColor blackColor];
    [self addSubview:bgview];
    [bgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    //radius
    [self setFrame:CGRectMake(0, SCREEN_HEIGHT-COMMENT_BAR_HEIGHT, SCREEN_WIDTH, COMMENT_BAR_HEIGHT)];
    [self MJSetPartRadius:8 RoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight];

    
    //标题
    titleLabel = [[UILabel alloc]init];
    titleLabel.text=@"最新评论";
    titleLabel.font=FONT(13);
    titleLabel.textColor=HW_WHITE;
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17.5);
        make.top.mas_equalTo(12);
    }];
    
    
    //评论数
    countLabel = [[UILabel alloc]init];
    countLabel.font=FONT(11);
    countLabel.textColor=HW_WHITE;
    [self addSubview:countLabel];
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_right).offset(5);
        make.bottom.mas_equalTo(titleLabel.mas_bottom);
    }];
    
    
    //发送按钮
    sendBtn = [[MJButton alloc]init];
    [sendBtn setImage:[UIImage getBundleImage:@"sz_commentbar_write"] forState:UIControlStateNormal];
    sendBtn.imageFrame=CGRectMake(13, 9, 12.5, 13);
    sendBtn.titleFrame=CGRectMake(32, 8, 155, 15);
    sendBtn.mj_text=@"写评论...";
    sendBtn.mj_font=FONT(13);
    sendBtn.mj_textColor=HW_WHITE;
    sendBtn.titleLabel.alpha=0.7;
    sendBtn.backgroundColor=HW_CLEAR;
    sendBtn.layer.cornerRadius=16;
    [sendBtn addTarget:self action:@selector(sendCommentAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendBtn];
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(17);
        make.top.mas_equalTo(40);
        make.height.mas_equalTo(32);
        make.right.mas_equalTo(self).offset(-208);
    }];
    
    //查看评论
    UIView * gestview = [[UIView alloc]init];
    gestview.backgroundColor=[UIColor clearColor];
    [self addSubview:gestview];
    [gestview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.right.mas_equalTo(sendBtn.mas_right);
        make.bottom.mas_equalTo(sendBtn.mas_top);
    }];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentTapAction)];
    [gestview addGestureRecognizer:tap];
    
    
    //发送按钮BG
    sendBtnBG = [[UIView alloc]init];
    sendBtnBG.layer.cornerRadius = sendBtn.layer.cornerRadius;
    [self insertSubview:sendBtnBG belowSubview:sendBtn];
    [sendBtnBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.height.mas_equalTo(sendBtn);
    }];
    
    
    //收藏
    collectBtn = [[MJButton alloc]init];
    collectBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_commentbar_collect"];
    collectBtn.mj_imageObject_sel = [UIImage getBundleImage:@"sz_commentbar_collect_sel"];
    [collectBtn addTarget:self action:@selector(collectBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:collectBtn];
    [collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sendBtn.mas_right).offset(10);
        make.centerY.mas_equalTo(sendBtn.mas_centerY).offset(-8);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    //收藏数
    collectLabel = [[UILabel alloc]init];
    collectLabel.text=@"收藏";
    collectLabel.font=FONT(11);
    collectLabel.textColor=HW_WHITE;
    collectLabel.alpha=0.5;
    collectLabel.textAlignment=NSTextAlignmentCenter;
    [self addSubview:collectLabel];
    [collectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(collectBtn.mas_centerX);
        make.top.mas_equalTo(collectBtn.mas_bottom).offset(-8.5);
    }];
    
    
    //点赞
    zanBtn = [[MJButton alloc]init];
    zanBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_commentbar_zan"];
    zanBtn.mj_imageObject_sel = [UIImage getBundleImage:@"sz_commentbar_zan_sel"];
    [zanBtn addTarget:self action:@selector(zanBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:zanBtn];
    [zanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(collectBtn.mas_right).offset(3);
        make.centerY.mas_equalTo(collectBtn.mas_centerY);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    //点赞数
    zanLabel = [[UILabel alloc]init];
    zanLabel.text=@"赞";
    zanLabel.font=FONT(11);
    zanLabel.textColor=HW_WHITE;
    zanLabel.alpha=0.5;
    zanLabel.textAlignment=NSTextAlignmentCenter;
    [self addSubview:zanLabel];
    [zanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(zanBtn.mas_centerX);
        make.top.mas_equalTo(zanBtn.mas_bottom).offset(-8.5);
    }];
    
    
    //分享按钮
    shareBtn = [[MJButton alloc]init];
    shareBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_commentbar_share"];
    [shareBtn addTarget:self action:@selector(shareBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shareBtn];
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(zanBtn.mas_right).offset(3);
        make.centerY.mas_equalTo(collectBtn.mas_centerY);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    //分享
    shareLabel = [[UILabel alloc]init];
    shareLabel.text=@"转发";
    shareLabel.font=FONT(11);
    shareLabel.textColor=HW_WHITE;
    shareLabel.alpha=0.5;
    shareLabel.textAlignment=NSTextAlignmentCenter;
    [self addSubview:shareLabel];
    [shareLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(shareBtn.mas_centerX);
        make.top.mas_equalTo(shareBtn.mas_bottom).offset(-8.5);
    }];
    
    
    //拍摄按钮
    shotBtn = [[MJButton alloc]init];
    shotBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_commentbar_publish"];
    [shotBtn addTarget:self action:@selector(shotBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shotBtn];
    [shotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(shareBtn.mas_right).offset(4);
        make.centerY.mas_equalTo(collectBtn.mas_centerY);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    //拍摄按钮
    shotLabel = [[UILabel alloc]init];
    shotLabel.text=@"上传视频";
    shotLabel.font=FONT(11);
    shotLabel.textColor=HW_WHITE;
    shotLabel.alpha=0.5;
    shotLabel.textAlignment=NSTextAlignmentCenter;
    [self addSubview:shotLabel];
    [shotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(shotBtn.mas_centerX);
        make.top.mas_equalTo(shotBtn.mas_bottom).offset(-8.5);
    }];
    
    
    //评论列表
    commentListView = [[SZCommentList alloc]init];
    [commentListView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
}






#pragma mark - 数据绑定回调
-(void)updateContentStateData
{
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
        zanLabel.text = @"赞";
    }
    
    
}

-(void)updateCommentData
{
    CommentDataModel * commentM = [[SZData sharedSZData].contentCommentDic valueForKey:self.contentId];
    countLabel.text = [NSString stringWithFormat:@"(%ld)",commentM.total];
}

-(void)updateContentInfo
{
    //评论数据清零
    
    
    
    //判断是否禁止评论
    ContentModel * contenM = [[SZData sharedSZData].contentDic valueForKey:self.contentId];
    if(contenM.disableComment.boolValue)
    {
        sendBtn.mj_text=@"该内容禁止评论";
    }
    else
    {
        sendBtn.mj_text=@"写评论...";
    }
}





#pragma mark - Btn Action
-(void)commentTapAction
{
    if (commentListView.superview==nil)
    {
        //listview
        [self.superview addSubview:commentListView];
        
        [commentListView showCommentList:YES];
    }
}


-(void)sendCommentAction
{
    ContentModel * contentModel = [[SZData sharedSZData].contentDic valueForKey:self.contentId];
    
    //禁止评论
    if (contentModel.disableComment.boolValue)
    {
        return;
    }
    
    __weak typeof (self) weakSelf = self;
    [SZInputView callInputView:TypeSendComment contentModel:contentModel replyId:nil placeHolder:@"发表您的评论" completion:^(id responseObject) {
        [MJHUD_Notice showSuccessView:@"评论已提交，请等待审核通过！" inView:weakSelf.window hideAfterDelay:2];
        
        [weakSelf commentTapAction];
    }];
}


-(void)zanBtnAction
{
    //未登录则跳转登录
    if (![SZGlobalInfo sharedManager].SZRMToken.length)
    {
        [SZGlobalInfo mjshowLoginAlert];
        return;
    }
    
    [[SZData sharedSZData]requestZan];
}


-(void)collectBtnAction
{
    //未登录则跳转登录
    if (![SZGlobalInfo sharedManager].SZRMToken.length)
    {
        [SZGlobalInfo mjshowLoginAlert];
        return;
    }
    
    
    [[SZData sharedSZData]requestCollect];
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
    [SZUserTracker trackingButtonEventName:@"short_video_start_make" param:nil];
    
    
    //未登录则跳转登录
    if (![SZGlobalInfo sharedManager].SZRMToken.length)
    {
        [SZGlobalInfo mjshowLoginAlert];
        return;
    }
    
    UINavigationController * nav = [self getCurrentNavigationController];
    SZUploadingVC * vc = [SZUploadingVC new];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [nav presentViewController:vc animated:YES completion:nil];
}



@end
