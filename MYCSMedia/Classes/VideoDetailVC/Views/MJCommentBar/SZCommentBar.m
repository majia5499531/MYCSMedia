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
#import "SZManager.h"
#import "SZInputView.h"
#import "SZCommentList.h"
#import "CommentDataModel.h"
#import "CommentModel.h"
#import "MJHUD.h"
#import "StatusModel.h"
#import "ContentStateModel.h"

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
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor=HW_GRAY_BG_1;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentTapAction)];
        [self addGestureRecognizer:tap];
        
        [self setFrame:CGRectMake(0, SCREEN_HEIGHT-COMMENT_BAR_HEIGHT, SCREEN_WIDTH, COMMENT_BAR_HEIGHT)];
        
        [self MJInitSubviews];
        
        [self addObserver];
    }
    return self;
}
-(void)dealloc
{
    NSLog(@"MJDEALLOC_COMMENTBAR");
    [self removeObserver];
}


#pragma mark - 监听
-(void)addObserver
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(commentInfoDidChange:) name:NOTIFY_NAME_COMMENT object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shouldRequestNewData:) name:NOTIFY_NAME_NEW_COMMENT object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(zanStateChange:) name:NOTIFY_NAME_ZAN object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(collectStateChange:) name:NOTIFY_NAME_COLLECT object:nil];
}
-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

//评论数据变化
-(void)commentInfoDidChange:(NSNotification*)notify
{
    CommentDataModel * model = notify.object;
    countLabel.text = [NSString stringWithFormat:@"(%ld)",model.total];
    
    [commentListView updateCommentData:model];
}

//刷新评论列表
-(void)shouldRequestNewData:(NSNotification*)notify
{
    [self requestCommentListData];
}

//点赞变化
-(void)zanStateChange:(NSNotification*)notify
{
    NSString * str = notify.object;
    zanBtn.MJSelectState = str.boolValue;
    
    //点赞数
    NSInteger count = zanBtn.badgeCount;
    if (str.boolValue)
    {
        count++;
    }
    else
    {
        count--;
    }
    [zanBtn setBadgeNum:[NSString stringWithFormat:@"%ld",count] style:2];
    
    [commentListView updateZanState:str.boolValue count:-1];
}

//收藏变化
-(void)collectStateChange:(NSNotification*)notify
{
    NSString * str = notify.object;
    collectBtn.MJSelectState = str.boolValue;
    
    [commentListView updateCollectState:str.boolValue];
}

#pragma mark - 界面&布局
-(void)MJInitSubviews
{
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
    sendBtn.titleFrame=CGRectMake(32, 8, 100, 15);
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
        make.right.mas_equalTo(self).offset(-110);
    }];



    //收藏
    collectBtn = [[MJButton alloc]init];
    collectBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_collect"];
    collectBtn.mj_imageObject_sel = [UIImage getBundleImage:@"sz_collect_sel"];
    [collectBtn addTarget:self action:@selector(collectBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:collectBtn];
    [collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sendBtn.mas_right).offset(10);
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
        make.left.mas_equalTo(collectBtn.mas_right).offset(1);
        make.centerY.mas_equalTo(sendBtn.mas_centerY);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    
    //评论列表
    commentListView = [[SZCommentList alloc]init];
    commentListView.commentbar = self;
    [commentListView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
}



#pragma mark - update
-(void)updateCommentBarData:(NSString *)ID
{
    if (![_contentId isEqualToString:ID])
    {
        _contentId = ID;
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_NAME_COMMENT object:nil];
        
        [self requestCommentListData];
        
        [self requestContentState];
    }
    
}


#pragma mark - Request
-(void)requestCommentListData
{
    CommentDataModel * model = [CommentDataModel model];
    model.isJSON = YES;
    model.hideLoading = YES;
    model.hideErrorMsg = YES;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:_contentId forKey:@"contentId"];
    [param setValue:@"9999" forKey:@"pageSize"];
    [param setValue:@"1" forKey:@"pageNum"];
    
    __weak typeof (self) weakSelf = self;
    [model PostRequestInView:self WithUrl:APPEND_SUBURL(BASE_URL, API_URL_GET_COMMENT_LIST) Params:param Success:^(id responseObject) {
        [weakSelf requestCommentListDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}


-(void)requestCollect
{
    StatusModel * model = [StatusModel model];
    model.isJSON=YES;
    model.hideLoading=YES;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:self.contentId forKey:@"contentId"];
    [param setValue:@"short_video" forKey:@"type"];
    __weak typeof (self) weakSelf = self;
    [model PostRequestInView:self.superview WithUrl:APPEND_SUBURL(BASE_URL, API_URL_FAVOR) Params:param Success:^(id responseObject) {
        [weakSelf requestCollectDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}



-(void)requestContentState
{
    ContentStateModel * model = [ContentStateModel model];
    model.hideLoading=YES;
    model.hideErrorMsg=YES;
    __weak typeof (self) weakSelf = self;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:_contentId forKey:@"contentId"];
    [model GETRequestInView:self.superview WithUrl:APPEND_SUBURL(BASE_URL, API_URL_GET_CONTENT_STATE) Params:param Success:^(id responseObject) {
        [weakSelf requestContentStateDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}


-(void)requestZan
{
    StatusModel * model = [StatusModel model];
    model.hideLoading=YES;
    model.isJSON=YES;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:_contentId forKey:@"targetId"];
    [param setValue:@"content" forKey:@"type"];
    
    __weak typeof (self) weakSelf = self;
    [model PostRequestInView:self.superview WithUrl:APPEND_SUBURL(BASE_URL, API_URL_ZAN) Params:param Success:^(id responseObject) {
            [weakSelf requestZanDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}

#pragma mark - Request Done
-(void)requestCommentListDone:(CommentDataModel*)model
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_NAME_COMMENT object:model];
}
-(void)requestContentStateDone:(ContentStateModel*)model
{
    collectBtn.MJSelectState = model.whetherFavor;
    zanBtn.MJSelectState = model.whetherLike;
    [zanBtn setBadgeNum:[NSString stringWithFormat:@"%ld",model.likeCountShow] style:2];
    
    [commentListView updateCollectState:model.whetherFavor];
    [commentListView updateZanState:model.whetherLike count:model.likeCountShow];
}
-(void)requestCollectDone:(StatusModel*)model
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_NAME_COLLECT object:model.data];
    
}
-(void)requestZanDone:(StatusModel*)model
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_NAME_ZAN object:model.data];
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
    __weak typeof (self) weakSelf = self;
    [SZInputView callInputView:0 contentId:_contentId placeHolder:@"发表您的评论" completion:^(id responseObject) {
        [weakSelf sendCommentSuccess];
    }];
}

-(void)sendCommentSuccess
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_NAME_NEW_COMMENT object:nil];
    [MJHUD_Notice showSuccessView:@"评论成功" inView:self.window hideAfterDelay:0.7];
    [self performSelector:@selector(commentTapAction) withObject:nil afterDelay:0.3];
}

-(void)zanBtnAction
{
    [self requestZan];
}

-(void)collectBtnAction
{
    [self requestCollect];
}


@end
