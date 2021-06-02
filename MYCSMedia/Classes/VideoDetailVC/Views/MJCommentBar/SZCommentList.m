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
#import "SZManager.h"
#import "SZInputView.h"
#import "SZCommentCell.h"
#import "CustomFooter.h"
#import "CustomAnimatedHeader.h"


@interface SZCommentList ()<UICollectionViewDataSource,UICollectionViewDelegate>

@end

@implementation SZCommentList
{
    CGFloat gestvH;
    
    UILabel * countLabel;
    UIView * BG;
    
    UICollectionView * collectionView;
    
    MJButton * sendBtn;
    MJButton * collectBtn;
    MJButton * zanBtn;
    
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor=HW_CLEAR;
        
        gestvH = SCREEN_HEIGHT * 0.3;
        [self MJInitSubviews];
        
    }
    return self;
}


-(void)show:(BOOL)show
{
    if (show)
    {
        BG.hidden=NO;
        [UIView animateWithDuration:0.2 animations:^{
            [self->BG setFrame:CGRectMake(0, self->gestvH, SCREEN_WIDTH, SCREEN_HEIGHT-self->gestvH)];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.1 animations:^{
            [self->BG setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-self->gestvH)];
                } completion:^(BOOL finished) {
                    self->BG.hidden=YES;
                    
                    [self removeFromSuperview];
        }];
    }
}


#pragma mark - 界面&布局
-(void)MJInitSubviews
{
    //手势
    UIView * gestview =[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, gestvH)];
    [self addSubview:gestview];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(listViewBGTapAction)];
    [gestview addGestureRecognizer:tap];
    
    //BG
    BG = [[UIView alloc]init];
    [BG setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-self->gestvH)];
    BG.backgroundColor=HW_WHITE;
    [self addSubview:BG];
    [BG MJSetPartRadius:8 RoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight];
    
    //评论
    UILabel * titleLabel = [[UILabel alloc]init];
    titleLabel.text=@"最新评论";
    titleLabel.font=BOLD_FONT(13);
    titleLabel.textColor=HW_BLACK;
    [BG addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(22);
        make.top.mas_equalTo(12);
    }];

    //评论数
    countLabel = [[UILabel alloc]init];
    countLabel.text=@"(711)";
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

    //收藏
    collectBtn = [[MJButton alloc]init];
    collectBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_collect_black"];
    collectBtn.mj_imageObject_sel = [UIImage getBundleImage:@"sz_collect_sel"];
    [collectBtn addTarget:self action:@selector(collectBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [BG addSubview:collectBtn];


    //点赞
    zanBtn = [[MJButton alloc]init];
    zanBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_zan_black"];
    zanBtn.mj_imageObject_sel = [UIImage getBundleImage:@"sz_zan_sel"];
    [zanBtn setBadgeNum:@"999" style:2];
    [zanBtn addTarget:self action:@selector(zanBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [BG addSubview:zanBtn];
    

    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(sepeline.mas_bottom).offset(4.5);
        make.height.mas_equalTo(32);
        make.right.mas_equalTo(BG).offset(-110);
    }];

    [collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sendBtn.mas_right).offset(10);
        make.centerY.mas_equalTo(sendBtn.mas_centerY);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];

    [zanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(collectBtn.mas_right).offset(1);
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
    collectionView.mj_header = [CustomAnimatedHeader headerWithRefreshingTarget:self refreshingAction:@selector(pulldownRefreshAction:)];
    collectionView.mj_footer = [CustomFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullupLoadAction:)];
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


#pragma mark - CollectionView Datasource & Delegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SZCommentCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"commentCell" forIndexPath:indexPath];
    [cell setCellData:nil];
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
    return 20;
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




#pragma mark - 下拉/上拉
-(void)pulldownRefreshAction:(MJRefreshHeader*)refreshHeader
{
    [collectionView.mj_header endRefreshing];
}


-(void)pullupLoadAction:(MJRefreshAutoFooter*)footer
{
    [collectionView.mj_footer endRefreshing];
}



#pragma mark - btn action
-(void)listViewBGTapAction
{
    
    [self show:NO];
}


-(void)sendCommentAction
{
    [SZInputView callInputView:0 newsID:@"" placeHolder:@"发表您的评论" completion:^(id responseObject) {
        NSLog(@"completion callback");
    }];
}

-(void)zanBtnAction
{
    zanBtn.MJSelectState = !zanBtn.MJSelectState;
    
    if ([SZManager sharedManager].delegate) {
        NSLog(@"query token:%@",[[SZManager sharedManager].delegate getAccessToken]);
    }
    
}

-(void)collectBtnAction
{
    collectBtn.MJSelectState = !collectBtn.MJSelectState;
    
    
    if ([SZManager sharedManager].delegate) {
        [[SZManager sharedManager].delegate gotoLoginPage];
    }
}


@end
