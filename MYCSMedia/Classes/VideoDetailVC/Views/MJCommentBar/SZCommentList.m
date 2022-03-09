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
#import "SZCommentHeader.h"
#import "SZCommentFooter.h"
#import "ReplyModel.h"

@interface SZCommentList ()<UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate>

@end

@implementation SZCommentList
{
    //data
    CommentDataModel * dataModel;
    
    CGFloat topspace;
    
    UILabel * countLabel;
    UIView * BGView;
    
    UICollectionView * collectionView;
    
    MJButton * sendBtn;
    
    BOOL isDragging;
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
    
    //关闭手势
    UIView * gestview =[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topspace)];
    [self addSubview:gestview];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(listViewBGTapAction)];
    [gestview addGestureRecognizer:tap];
    
    //BG
    BGView = [[UIView alloc]init];
    [BGView setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-self->topspace)];
    BGView.backgroundColor=HW_WHITE;
    [self addSubview:BGView];
    [BGView MJSetPartRadius:8 RoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight];
    
    //平移手势
    UIPanGestureRecognizer * pangest = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    [BGView addGestureRecognizer:pangest];
    
    //评论
    UILabel * titleLabel = [[UILabel alloc]init];
    titleLabel.text=@"最新评论";
    titleLabel.font= [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    titleLabel.textColor=HW_BLACK;
    [BGView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(22);
        make.top.mas_equalTo(13);
    }];

    //评论数
    countLabel = [[UILabel alloc]init];
    countLabel.font=FONT(11);
    countLabel.textColor=HW_BLACK;
    [BGView addSubview:countLabel];
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_right).offset(5);
        make.bottom.mas_equalTo(titleLabel.mas_bottom);
    }];
    
    
    //关闭按钮
    MJButton * closeBtn = [[MJButton alloc]init];
    closeBtn.mj_imageObjec=[UIImage getBundleImage:@"sz_close"];
    [closeBtn addTarget:self action:@selector(listViewBGTapAction) forControlEvents:UIControlEventTouchUpInside];
    [BGView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    //line
    UIView * sepeline = [[UIView alloc]init];
    sepeline.backgroundColor=HW_GRAY_BG_White;
    [BGView addSubview:sepeline];
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
    sendBtn.backgroundColor=HW_GRAY_BG_White;
    sendBtn.layer.cornerRadius=16;
    [sendBtn addTarget:self action:@selector(sendCommentAction) forControlEvents:UIControlEventTouchUpInside];
    [BGView addSubview:sendBtn];
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(sepeline.mas_bottom).offset(5);
        make.height.mas_equalTo(32);
        make.right.mas_equalTo(BGView).offset(-20);
    }];

    //没有评论image
    UIImageView * nocommentImg = [[UIImageView alloc]init];
    nocommentImg.image = [UIImage getBundleImage:@"sz_nocomment"];
    [BGView addSubview:nocommentImg];
    [nocommentImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(BGView.mas_centerX);
        make.centerY.mas_equalTo(BGView.mas_centerY).offset(-45);
        make.width.mas_equalTo(111);
        make.height.mas_equalTo(68);
    }];
    
    
    //没有评论
    UILabel * nocommentLabel = [[UILabel alloc]init];
    nocommentLabel.text=@"暂无任何评论，快来抢沙发吧!";
    nocommentLabel.textColor=HW_GRAY_WORD_1;
    nocommentLabel.font = FONT(12);
    nocommentLabel.textAlignment=NSTextAlignmentCenter;
    [BGView addSubview:nocommentLabel];
    [nocommentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(BGView.mas_centerX);
        make.top.mas_equalTo(nocommentImg.mas_bottom).offset(12);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(15);
    }];
    
    
    //collectionview
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT) collectionViewLayout:flowLayout];
    if (@available(iOS 11.0, *))
    {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor=HW_WHITE;
    [collectionView registerClass:[SZCommentCell class] forCellWithReuseIdentifier:@"commentCell"];
    [collectionView registerClass:[SZCommentHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"szcommentheader"];
    [collectionView registerClass:[SZCommentFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"szcommentfooter"];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [BGView addSubview:collectionView];
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
        BGView.hidden=NO;
        [UIView animateWithDuration:0.1 animations:^{
            [self->BGView setFrame:CGRectMake(0, self->topspace, SCREEN_WIDTH, SCREEN_HEIGHT-self->topspace)];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.1 animations:^{
            [self->BGView setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-self->topspace)];
                } completion:^(BOOL finished) {
                    self->BGView.hidden=YES;
                    
                    [self removeFromSuperview];
        }];
    }
}


-(void)commentListBGMoved:(CGFloat)offsetY
{
    CGFloat newtop = BGView.top+offsetY;
    if (newtop<topspace)
    {
        return;
    }
    else
    {
        [BGView setFrame:CGRectMake(BGView.left,newtop, BGView.width, BGView.height)];
    }
    
    isDragging = YES;
}

-(void)commentListBGMoveDone
{
    if (BGView.top > SCREEN_HEIGHT*0.45)
    {
        [self showCommentList:NO];
    }
    else
    {
        [self showCommentList:YES];
    }
    
    isDragging = NO;
}


#pragma mark - 数据绑定
-(void)addDataBinding
{
    [self bindModel:[SZData sharedSZData]];
    
    __weak typeof (self) weakSelf = self;
    self.observe(@"currentContentId",^(id value){
        weakSelf.contentId = value;
        [weakSelf updateContentInfo];
    }).observe(@"contentCommentsUpdateTime",^(id value){
        [weakSelf updateCommentData];
    });
}


#pragma mark - 数据绑定回调
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



#pragma mark - CollectionView Datasource & Delegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CommentModel * model = dataModel.dataArr[indexPath.section];
    ReplyModel * reply = model.dataArr[indexPath.row];
    
    SZCommentCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"commentCell" forIndexPath:indexPath];
    [cell setCellData:reply];
    return  cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CommentModel * model = dataModel.dataArr[indexPath.section];
    if (kind==UICollectionElementKindSectionHeader)
    {
        SZCommentHeader * header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"szcommentheader" forIndexPath:indexPath];
        [header setCellData:model];
        return header;
    }
    else
    {
        SZCommentHeader * footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"szcommentfooter" forIndexPath:indexPath];
        [footer setCellData:model];
        return footer;
    }
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return dataModel.dataArr.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    CommentModel * model = dataModel.dataArr[section];
    return model.replyShowCount;
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
    CommentModel * model = dataModel.dataArr[section];
    SZCommentHeader * header = [[SZCommentHeader alloc]initWithFrame:CGRectZero];
    [header setCellData:model];
    CGSize size = [header getHeaderSize];
    
    return size;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CommentModel * model = dataModel.dataArr[section];
    SZCommentFooter * header = [[SZCommentFooter alloc]initWithFrame:CGRectZero];
    [header setCellData:model];
    CGSize size = [header getHeaderSize];
    
    return size;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SZCommentCell * cell = [[SZCommentCell alloc]initWithFrame:CGRectZero];
    CommentModel * model = dataModel.dataArr[indexPath.section];
    ReplyModel * reply = model.dataArr[indexPath.row];
    [cell setCellData:reply];
    CGSize cellsize = [cell getCellSize];
    return cellsize;
}


#pragma mark - Scrollview Delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self panGestureAction:scrollView.panGestureRecognizer];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y<0)
    {
        [scrollView setContentOffset:CGPointMake(0, 0)];
        [self panGestureAction:scrollView.panGestureRecognizer];
    }
    else
    {
        static CGFloat lastOffsetY = 0;
        if (isDragging==YES)
        {
            [scrollView setContentOffset:CGPointMake(0, lastOffsetY)];
            [self panGestureAction:scrollView.panGestureRecognizer];
        }
        else
        {
            lastOffsetY = scrollView.contentOffset.y;
        }
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self panGestureAction:scrollView.panGestureRecognizer];
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
    [SZInputView callInputView:TypeSendComment contentModel:model replyId:nil placeHolder:@"发表您的评论" completion:^(id responseObject) {
        [MJHUD_Notice showSuccessView:@"评论已提交，请等待审核通过！" inView:weakSelf.window hideAfterDelay:2];
    }];
    
}

-(void)panGestureAction:(UIPanGestureRecognizer*)pan
{
    CGPoint locationPoint = [pan locationInView:BGView];
        
    static CGFloat originy = 0;
    if (pan.state==UIGestureRecognizerStateBegan)
    {
        originy = locationPoint.y;
    }
    else if (pan.state==UIGestureRecognizerStateChanged)
    {
        CGFloat offsetY = locationPoint.y-originy;
        
        [self commentListBGMoved:offsetY];
    }
    else
    {
        [self commentListBGMoveDone];
    }
}






@end
