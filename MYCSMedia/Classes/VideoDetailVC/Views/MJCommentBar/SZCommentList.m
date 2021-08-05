//
//  SZCommentList.m
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/29.
//

#import "SZCommentList.h"
#import "SZDefines.h"
#import "UIView+MJCategory.h"
#import "UIColor+MJCategory.h"
#import <Masonry/Masonry.h>
#import "MJButton.h"
#import "UIImage+MJCategory.h"
#import "SZGlobalInfo.h"
#import "SZInputView.h"
#import "SZCommentCell.h"
#import "CustomFooter.h"
#import "CustomAnimatedHeader.h"
#import "CommentDataModel.h"
#import "CommentModel.h"
#import "MJHUD.h"
#import "SZData.h"
#import "ContentStateModel.h"
#import "ContentModel.h"
#import "SZManager.h"

@interface SZCommentList ()<UICollectionViewDataSource,UICollectionViewDelegate>

@end

@implementation SZCommentList
{
    //data
    CommentDataModel * dataModel;
    
    CGFloat topspace;
    
    UILabel * countLabel;
    UIView * BG;
    
    UICollectionView * collectionView;
    
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
        [self MJSetupLayouts];
        
        [self addDataBinding];
    }
    return self;
}


#pragma mark - 界面&布局
-(void)MJSetupLayouts
{
    topspace = SCREEN_HEIGHT * 0.3;
    
    //view
    self.backgroundColor=HW_CLEAR;
    
    
    //手势
    UIView * gestview =[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topspace)];
    [self addSubview:gestview];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(listViewBGTapAction)];
    [gestview addGestureRecognizer:tap];
    
    //BG
    BG = [[UIView alloc]init];
    [BG setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-self->topspace)];
    BG.backgroundColor=HW_WHITE;
    [self addSubview:BG];
    [BG MJSetPartRadius:8 RoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight];
    
    //评论
    UILabel * titleLabel = [[UILabel alloc]init];
    titleLabel.text=@"最新评论";
    titleLabel.font= [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    titleLabel.textColor=HW_BLACK;
    [BG addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(22);
        make.top.mas_equalTo(13);
    }];

    //评论数
    countLabel = [[UILabel alloc]init];
    countLabel.font=FONT(11);
    countLabel.textColor=HW_BLACK;
    [BG addSubview:countLabel];
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_right).offset(5);
        make.bottom.mas_equalTo(titleLabel.mas_bottom);
    }];
    
    
    //关闭按钮
    MJButton * closeBtn = [[MJButton alloc]init];
    closeBtn.mj_imageObjec=[UIImage getBundleImage:@"sz_close"];
    [closeBtn addTarget:self action:@selector(listViewBGTapAction) forControlEvents:UIControlEventTouchUpInside];
    [BG addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    //line
    UIView * sepeline = [[UIView alloc]init];
    sepeline.backgroundColor=HW_GRAY_BG_5;
    [BG addSubview:sepeline];
    [sepeline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.bottom.mas_equalTo(-44-BOTTOM_SAFEAREA_HEIGHT);
    }];
    
    
    //发送
    sendBtn = [[MJButton alloc]init];
    [sendBtn setImage:[UIImage getBundleImage:@"sz_write_black"] forState:UIControlStateNormal];
    sendBtn.imageFrame=CGRectMake(13, 9, 12.5, 13);
    sendBtn.titleFrame=CGRectMake(32, 8, 100, 15);
    sendBtn.mj_text=@"写评论...";
    sendBtn.mj_font=FONT(13);
    sendBtn.mj_textColor=HW_BLACK;
    sendBtn.backgroundColor=HW_GRAY_BG_5;
    sendBtn.layer.cornerRadius=16;
    [sendBtn addTarget:self action:@selector(sendCommentAction) forControlEvents:UIControlEventTouchUpInside];
    [BG addSubview:sendBtn];
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(sepeline.mas_bottom).offset(5);
        make.height.mas_equalTo(32);
        make.right.mas_equalTo(BG).offset(-145);
    }];

    //收藏
    collectBtn = [[MJButton alloc]init];
    collectBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_collect_black"];
    collectBtn.mj_imageObject_sel = [UIImage getBundleImage:@"sz_collect_sel"];
    [collectBtn addTarget:self action:@selector(collectBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [BG addSubview:collectBtn];
    [collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sendBtn.mas_right).offset(5);
        make.centerY.mas_equalTo(sendBtn.mas_centerY);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];


    //点赞
    zanBtn = [[MJButton alloc]init];
    zanBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_zan_black"];
    zanBtn.mj_imageObject_sel = [UIImage getBundleImage:@"sz_zan_sel"];
    [zanBtn addTarget:self action:@selector(zanBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [BG addSubview:zanBtn];
    [zanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(collectBtn.mas_right).offset(-1);
        make.centerY.mas_equalTo(sendBtn.mas_centerY);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    
    //分享按钮
    shareBtn = [[MJButton alloc]init];
    shareBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_share_black"];
    [shareBtn addTarget:self action:@selector(shareBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [BG addSubview:shareBtn];
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(zanBtn.mas_right).offset(1);
        make.centerY.mas_equalTo(sendBtn.mas_centerY);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    

    
    //没有评论image
    UIImageView * nocommentImg = [[UIImageView alloc]init];
    nocommentImg.image = [UIImage getBundleImage:@"sz_nocomment"];
    [BG addSubview:nocommentImg];
    [nocommentImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(BG.mas_centerX);
        make.centerY.mas_equalTo(BG.mas_centerY).offset(-45);
        make.width.mas_equalTo(111);
        make.height.mas_equalTo(68);
    }];
    
    
    //没有评论
    UILabel * nocommentLabel = [[UILabel alloc]init];
    nocommentLabel.text=@"暂无任何评论，快来抢沙发吧!";
    nocommentLabel.textColor=HW_GRAY_WORD_1;
    nocommentLabel.font = FONT(12);
    nocommentLabel.textAlignment=NSTextAlignmentCenter;
    [BG addSubview:nocommentLabel];
    [nocommentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(BG.mas_centerX);
        make.top.mas_equalTo(nocommentImg.mas_bottom).offset(12);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(15);
    }];
    
    
    //collectionview
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.estimatedItemSize = CGSizeMake(SCREEN_WIDTH, 100);
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT) collectionViewLayout:flowLayout];
    if (@available(iOS 11.0, *))
    {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor=HW_WHITE;
    [collectionView registerClass:[SZCommentCell class] forCellWithReuseIdentifier:@"commentCell"];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [BG addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(countLabel.mas_bottom).offset(7);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.bottom.mas_equalTo(sepeline.mas_top);
    }];
    
}




#pragma mark - 展开/收起
-(void)showCommentList:(BOOL)show
{
    if (show)
    {
        BG.hidden=NO;
        [UIView animateWithDuration:0.1 animations:^{
            [self->BG setFrame:CGRectMake(0, self->topspace, SCREEN_WIDTH, SCREEN_HEIGHT-self->topspace)];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.1 animations:^{
            [self->BG setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-self->topspace)];
                } completion:^(BOOL finished) {
                    self->BG.hidden=YES;
                    
                    [self removeFromSuperview];
        }];
    }
}


#pragma mark - 数据绑定
-(void)addDataBinding
{
    [self bindModel:[SZData sharedSZData]];
    
    __weak typeof (self) weakSelf = self;
    self.observe(@"currentContentId",^(id value){
        weakSelf.contentId = value;
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


#pragma mark - 数据绑定回调
-(void)updateContentStateData
{
    //取数据
    ContentStateModel * stateM = [[SZData sharedSZData].contentStateDic valueForKey:self.contentId];
    
    //更新UI
    collectBtn.MJSelectState = stateM.whetherFavor;
    
    zanBtn.MJSelectState = stateM.whetherLike;
    
    [zanBtn setBadgeNum:[NSString stringWithFormat:@"%ld",stateM.likeCountShow] style:2];
    
}

-(void)updateCommentData
{
    //取数据
    CommentDataModel * commentM = [[SZData sharedSZData].contentCommentDic valueForKey:self.contentId];
    
    //更新UI
    countLabel.text = [NSString stringWithFormat:@"(%ld)",commentM.total];
    dataModel = commentM;
    
    [collectionView reloadData];
    
    if (commentM.dataArr.count)
    {
        collectionView.hidden=NO;
    }
    else
    {
        collectionView.hidden=YES;
    }
}




#pragma mark - CollectionView Datasource & Delegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CommentModel * model = dataModel.dataArr [indexPath.row];
    SZCommentCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"commentCell" forIndexPath:indexPath];
    [cell setCellData:model];
    return  cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return dataModel.dataArr.count;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}









#pragma mark - btn action
-(void)listViewBGTapAction
{
    [self showCommentList:NO];
}

-(void)sendCommentAction
{
    ContentModel * model = [[SZData sharedSZData].contentDic valueForKey:self.contentId];
    
    //禁止评论
    if (model.disableComment.boolValue)
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
