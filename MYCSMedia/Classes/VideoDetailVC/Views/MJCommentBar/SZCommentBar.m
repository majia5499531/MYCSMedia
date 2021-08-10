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

@interface SZCommentBar ()
@end

@implementation SZCommentBar
{
    SZCommentList * commentListView;
    UILabel * titleLabel;
    UILabel * countLabel;
    MJButton * sendBtn;
    MJButton * collectBtn;
    MJButton * zanBtn;
    MJButton * shareBtn;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupUI];
        
        [self addObserver];
    }
    return self;
}


#pragma mark - 监听
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



#pragma mark - 界面&布局
-(void)setupUI
{
    //view
    self.backgroundColor=HW_GRAY_BG_1;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentTapAction)];
    [self addGestureRecognizer:tap];
    
    [self setFrame:CGRectMake(0, SCREEN_HEIGHT-COMMENT_BAR_HEIGHT, SCREEN_WIDTH, COMMENT_BAR_HEIGHT)];
    [self MJSetPartRadius:8 RoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight];
    
    //标题
    titleLabel = [[UILabel alloc]init];
    titleLabel.text=@"最新评论";
    titleLabel.font=FONT(13);
    titleLabel.textColor=HW_WHITE;
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(22);
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
    [sendBtn setImage:[UIImage getBundleImage:@"sz_write"] forState:UIControlStateNormal];
    sendBtn.imageFrame=CGRectMake(13, 9, 12.5, 13);
    sendBtn.titleFrame=CGRectMake(32, 8, 155, 15);
    sendBtn.mj_text=@"写评论...";
    sendBtn.mj_font=FONT(13);
    sendBtn.mj_textColor=HW_GRAY_WORD_1;
    sendBtn.backgroundColor=HW_GRAY_BG_2;
    sendBtn.layer.cornerRadius=16;
    [sendBtn addTarget:self action:@selector(sendCommentAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendBtn];
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(40);
        make.height.mas_equalTo(32);
        make.right.mas_equalTo(self).offset(-145);
    }];



    //收藏
    collectBtn = [[MJButton alloc]init];
    collectBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_collect"];
    collectBtn.mj_imageObject_sel = [UIImage getBundleImage:@"sz_collect_sel"];
    [collectBtn addTarget:self action:@selector(collectBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:collectBtn];
    [collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sendBtn.mas_right).offset(5);
        make.centerY.mas_equalTo(sendBtn.mas_centerY);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];

    
    //点赞
    zanBtn = [[MJButton alloc]init];
    zanBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_zan"];
    zanBtn.mj_imageObject_sel = [UIImage getBundleImage:@"sz_zan_sel"];
    [zanBtn addTarget:self action:@selector(zanBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:zanBtn];
    [zanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(collectBtn.mas_right).offset(-1);
        make.centerY.mas_equalTo(sendBtn.mas_centerY);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    //分享按钮
    shareBtn = [[MJButton alloc]init];
    shareBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_share"];
    [shareBtn addTarget:self action:@selector(shareBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shareBtn];
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(zanBtn.mas_right).offset(1);
        make.centerY.mas_equalTo(sendBtn.mas_centerY);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
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
    
    [zanBtn setBadgeNum:[NSString stringWithFormat:@"%ld",stateM.likeCountShow] style:2];
    
}

-(void)updateCommentData
{
    CommentDataModel * commentM = [[SZData sharedSZData].contentCommentDic valueForKey:self.contentId];
    countLabel.text = [NSString stringWithFormat:@"(%ld)",commentM.total];
}

-(void)updateContentInfo
{
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
    ContentModel * contenM = [[SZData sharedSZData].contentDic valueForKey:self.contentId];
    
    if(contenM.disableComment.boolValue)
    {
        return;
    }
    
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
    [SZInputView callInputView:0 contentId:_contentId placeHolder:@"发表您的评论" completion:^(id responseObject) {
        [MJHUD_Notice showSuccessView:@"评论已提交，请等待审核通过！" inView:weakSelf.window hideAfterDelay:2];
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
        [SZGlobalInfo mjshareToPlatform:plat content:contentModel];
        
    }];
}





@end
