//
//  SZVideoRootView.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/19.
//

#import "SZVideoRootView.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "CustomFooter.h"
#import "CustomAnimatedHeader.h"
#import "SZVideoCell.h"
#import "UIImage+MJCategory.h"
#import "MJButton.h"
#import "MJVideoManager.h"
#import <Masonry/Masonry.h>
#import "SZManager.h"
#import "UIView+MJCategory.h"
#import "SZInputView.h"
#import "SZCommentBar.h"
#import "MJHUD.h"
#import "BaseModel.h"
#import "ContentListModel.h"
#import "ContentModel.h"
#import "TokenExchangeModel.h"
#import "ConsoleVC.h"
#import "SZData.h"
#import "SZGlobalInfo.h"
#import "UIScrollView+MJCategory.h"

@interface SZVideoRootView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation SZVideoRootView
{
    //data
    ContentListModel * dataModel;
    BOOL isRandomMode;
    NSString * panelCode;
    
    
    
    //UI
    UICollectionView * collectionView;
    SZCommentBar * commentBar;
}



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor=[UIColor whiteColor];
        
        panelCode = @"mycs.video.video";
        
        [self MJInitSubviews];
    }
    return self;
}


-(void)viewWillAppear
{
    //如果没有数据，则请求数据
    if (dataModel==nil)
    {
        [self requestVideos];
    }
    
    //如果有数据则play
    else
    {
        [self updateCurrentContentId:NO];
    }
}




-(NSIndexPath*)getCurrentRow
{
    //获取当前cell的index
    CGPoint pt = collectionView.contentOffset;
    pt.y = pt.y + collectionView.frame.size.height/2;
    NSIndexPath * idx = [collectionView indexPathForItemAtPoint:pt];
    return idx;
}



#pragma mark - Request
-(void)requestVideos
{
    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
    NSString * ssid = [[SZManager sharedManager].delegate onGetUserDevice];
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:panelCode forKey:@"panelCode"];
    [param setValue:pagesize forKey:@"pageSize"];
    [param setValue:@"0" forKey:@"removeFirst"];
    [param setValue:ssid forKey:@"ssid"];
    [param setValue:@"refresh" forKey:@"refreshType"];
    
    ContentListModel * dataModel = [ContentListModel model];
    __weak typeof (self) weakSelf = self;
    [dataModel GETRequestInView:self WithUrl:APPEND_SUBURL(BASE_URL, API_URL_VIDEO_LIST) Params:param Success:^(id responseObject){
        [weakSelf requestDone:dataModel];
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];
}





-(void)requestMoreVideos
{
    //获取最后一条视频的ID
    ContentModel * lastModel = dataModel.dataArr.lastObject;
    NSString * lastContentId =  lastModel.id;
    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
    NSString * ssid = [[SZManager sharedManager].delegate onGetUserDevice];
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:panelCode forKey:@"panelCode"];
    [param setValue:lastContentId forKey:@"contentId"];
    [param setValue:pagesize forKey:@"pageSize"];
    [param setValue:@"1" forKey:@"removeFirst"];
    [param setValue:ssid forKey:@"ssid"];
    [param setValue:@"loadmore" forKey:@"refreshType"];
    
    ContentListModel * model = [ContentListModel model];
    model.hideLoading=YES;
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:self WithUrl:APPEND_SUBURL(BASE_URL, API_URL_VIDEO_LIST) Params:param Success:^(id responseObject){
        [weakSelf requestMoreVideoDone:model];
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];
}


#pragma mark - Request Done
-(void)requestDone:(ContentListModel*)model
{
    [collectionView.mj_footer endRefreshing];
    [collectionView.mj_header endRefreshing];
    
    dataModel = model;
    
    [collectionView reloadData];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [self updateCurrentContentId:NO];
    });
    
}


-(void)requestMoreVideoDone:(ContentListModel*)model
{
    [collectionView.mj_footer endRefreshing];
    [collectionView.mj_header endRefreshing];
    
    if (model.dataArr.count==0 && [self getCurrentRow].row==dataModel.dataArr.count-1)
    {
        [MJHUD_Notice showNoticeView:@"没有更多视频了" inView:self hideAfterDelay:2];
        return;
    }
    
    
    NSInteger startIdx = dataModel.dataArr.count;
    
    
    NSMutableArray * idxArr = [NSMutableArray array];
    for (int i = 0; i<model.dataArr.count; i++)
    {
        NSInteger idx = startIdx++;
        NSIndexPath * idpath = [NSIndexPath indexPathForRow:idx inSection:0];
        [idxArr addObject:idpath];
    }
    
    
    
    [dataModel.dataArr addObjectsFromArray:model.dataArr];
    
    //追加collectionview数量
    [collectionView performBatchUpdates:^{
            [collectionView insertItemsAtIndexPaths:idxArr];
        } completion:^(BOOL finished) {
            
        }];
    
}


-(void)requestFailed
{
    [collectionView.mj_footer endRefreshing];
    [collectionView.mj_header endRefreshing];
}



#pragma mark - Init
-(void)MJInitSubviews
{
    //collectionview
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT) collectionViewLayout:flowLayout];
    [collectionView setNoContentInset];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor=HW_BLACK;
    [collectionView registerClass:[SZVideoCell class] forCellWithReuseIdentifier:@"shortSZVideoCell"];
    collectionView.mj_header = [CustomAnimatedHeader headerWithRefreshingTarget:self refreshingAction:@selector(pulldownRefreshAction:)];
    collectionView.mj_footer = [CustomFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullupLoadAction:)];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled=YES;
    collectionView.showsVerticalScrollIndicator=NO;
    [self addSubview:collectionView];
    
    
    //commentview
    commentBar = [[SZCommentBar alloc]init];
    [self addSubview:commentBar];
    [commentBar setCommentBarStyle:0 type:1];
}




#pragma mark - 下拉/上拉
-(void)pulldownRefreshAction:(MJRefreshHeader*)refreshHeader
{
    [self requestVideos];
}

-(void)pullupLoadAction:(MJRefreshFooter*)footer
{
    [self requestMoreVideos];
}






#pragma mark - Scroll delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSIndexPath * indexpath = [self getCurrentRow];
    
    [self updateCurrentContentId:NO];
    
    //如果是倒数第二个则加载更多
    if (indexpath.row==dataModel.dataArr.count-2)
    {
        [self requestMoreVideos];
    }
}



#pragma mark - 更新currentId
-(void)updateCurrentContentId:(BOOL)force
{
    //model
    NSIndexPath * path = [self getCurrentRow];
    if (path==nil)
    {
        return;
    }
    
    //contentId
    ContentModel * contentModel = dataModel.dataArr[path.row];
    NSString * contentid = contentModel.id;
    
    //更新数据
    if(![[SZData sharedSZData].currentContentId isEqualToString:contentid] || force)
    {
        [[SZData sharedSZData].contentDic setValue:contentModel forKey:contentid];
        [SZData sharedSZData].currentContentId = contentid;
    }
}



#pragma mark - CollectionView Datasource & Delegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SZVideoCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"shortSZVideoCell" forIndexPath:indexPath];
    [cell setCellData:dataModel.dataArr[indexPath.row] enableFollow:NO];
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
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(SCREEN_WIDTH,SCREEN_HEIGHT);
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





@end
