//
//  SZVideoDetailVC.m
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/27.
//

#import "SZVideoDetailVC.h"
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
#import "VideoListModel.h"
#import "ContentModel.h"
#import "TokenExchangeModel.h"

@interface SZVideoDetailVC ()<UICollectionViewDelegate, UICollectionViewDataSource,VideoCellDelegate>
@property(assign,nonatomic)BOOL MJHideStatusbar;
@end

@implementation SZVideoDetailVC
{
    //data
    NSMutableArray * dataArr;
    BOOL randomMode;
    
    //UI
    UICollectionView * collectionView;
    SZCommentBar * commentBar;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self MJInitData];
    
    [self MJInitSubviews];
    
    if (self.pannelId.length)
    {
        [self requestVideosInPannel];
    }
    else if(self.contentId.length)
    {
        [self requestSingleVideo];
    }
    else
    {
        [MJHUD_Alert showAlertViewWithTitle:@"Error" text:@"No contentId or panelId" sure:^(id objc) {
            [MJHUD_Alert hideAlertView];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    
    //监听全屏
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(videoViewDidEnterFullSreen:) name:@"MJNeedHideStatusBar" object:nil];
}

-(void)dealloc
{
    //移除监听
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //隐藏导航栏
    self.navigationController.navigationBar.hidden=YES;
    
    //检查登录
    [SZManager checkLoginStatus];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //显示导航栏
    self.navigationController.navigationBar.hidden=NO;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [MJVideoManager cancelPlayingWindowVideo];
}




#pragma mark - Notifycation
-(void)videoViewDidEnterFullSreen:(NSNotification*)notify
{
    NSNumber * needHidden = notify.object;
    
    self.MJHideStatusbar = needHidden.boolValue;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - Setter
-(void)setPannelId:(NSString *)pannelId
{
    if (pannelId.length)
    {
        _pannelId = pannelId;
    }
}
-(void)setContentId:(NSString *)contentId
{
    if (contentId.length)
    {
        _contentId = contentId;
    }
}

#pragma mark - Request
-(void)requestVideosInPannel
{
    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:self.pannelId forKey:@"panelId"];
    [param setValue:pagesize forKey:@"pageSize"];
    [param setValue:self.contentId forKey:@"contentId"];
    [param setValue:@"0" forKey:@"removeFirst"];
    
    
    VideoListModel * dataModel = [VideoListModel model];
    __weak typeof (self) weakSelf = self;
    [dataModel GETRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_URL_VIDEO_LIST) Params:param Success:^(id responseObject){
        [weakSelf requestDone:dataModel];
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];
}

-(void)requestSingleVideo
{
    NSString * url = APPEND_SUBURL(BASE_URL, API_URL_VIDEO);
    url = APPEND_SUBURL(url, self.contentId);
    
    ContentModel * model = [ContentModel model];
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:self.view WithUrl:url Params:nil Success:^(id responseObject) {
        
        VideoListModel * list = [VideoListModel model];
        [list.dataArr addObject:model];
        [weakSelf requestDone:list];
        
        //加载更多
        [weakSelf fetchMoreVideos];
        
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];
}

-(void)requestRandomVideos
{
    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:pagesize forKey:@"pageSize"];
    
    VideoListModel * dataModel = [VideoListModel model];
    __weak typeof (self) weakSelf = self;
    [dataModel GETRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_URL_RANDOM_VIDEO_LIST) Params:param Success:^(id responseObject){
        [weakSelf requestDone:dataModel];
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];
}

-(void)requestMoreRandomVideos
{
    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:pagesize forKey:@"pageSize"];
    
    VideoListModel * dataModel = [VideoListModel model];
    dataModel.hideLoading=YES;
    __weak typeof (self) weakSelf = self;
    [dataModel GETRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_URL_RANDOM_VIDEO_LIST) Params:param Success:^(id responseObject){
        [weakSelf requestMoreVideoDone:dataModel];
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];

}


-(void)requestMoreVideosInPannel
{
    //获取最后一条视频的ID
    ContentModel * lastModel = dataArr.lastObject;
    NSString * lastContentId =  lastModel.id;
    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:self.pannelId forKey:@"panelId"];
    [param setValue:lastContentId forKey:@"contentId"];
    [param setValue:pagesize forKey:@"pageSize"];
    [param setValue:@"1" forKey:@"removeFirst"];
    
    VideoListModel * model = [VideoListModel model];
    model.hideLoading=YES;
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_URL_VIDEO_LIST) Params:param Success:^(id responseObject){
        [weakSelf requestMoreVideoDone:model];
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];
}

#pragma mark - Request Done
-(void)requestDone:(VideoListModel*)model
{
    [collectionView.mj_footer endRefreshing];
    [collectionView.mj_header endRefreshing];
    
    [dataArr removeAllObjects];
    [dataArr addObjectsFromArray:model.dataArr];
    
    [collectionView reloadData];
    [collectionView layoutIfNeeded];
    dispatch_async(dispatch_get_main_queue(),^{
        [self playCurrentRow];
    });
    
}

-(void)requestMoreVideoDone:(VideoListModel*)model
{
    [collectionView.mj_footer endRefreshing];
    [collectionView.mj_header endRefreshing];
    
    if (model.dataArr.count==0 && [self getCurrentRow].row==dataArr.count-1)
    {
        [MJHUD_Notice showNoticeView:@"没有更多视频了" inView:self.view hideAfterDelay:2];
        return;
    }
    
    [dataArr addObjectsFromArray:model.dataArr];
    
    [collectionView reloadData];
    [collectionView layoutIfNeeded];
    dispatch_async(dispatch_get_main_queue(),^{
        [self playCurrentRow];
    });
}

-(void)requestFailed
{
    [collectionView.mj_footer endRefreshing];
    [collectionView.mj_header endRefreshing];
}




#pragma mark - init
-(void)MJInitSubviews
{
    self.view.backgroundColor=HW_BLACK;
    
    
    //collectionview
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT) collectionViewLayout:flowLayout];
    if (@available(iOS 11.0, *))
    {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor=HW_BLACK;
    [collectionView registerClass:[SZVideoCell class] forCellWithReuseIdentifier:@"shortSZVideoCell"];
    collectionView.mj_header = [CustomAnimatedHeader headerWithRefreshingTarget:self refreshingAction:@selector(pulldownRefreshAction:)];
    collectionView.mj_footer = [CustomFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullupLoadAction:)];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled=YES;
    collectionView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:collectionView];
    
    
    //naviback
    MJButton * btn = [[MJButton alloc]initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, 50, 50)];
    [btn setImage:[UIImage getBundleImage:@"sz_naviback"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    //commentview
    commentBar = [[SZCommentBar alloc]init];
    [self.view addSubview:commentBar];
}

-(void)MJInitData
{
    dataArr = [NSMutableArray array];
    
    if (self.pannelId.length==0)
    {
        randomMode = YES;
    }
}


#pragma mark - 下拉/上拉
-(void)pulldownRefreshAction:(MJRefreshHeader*)refreshHeader
{
    randomMode = YES;
    [self requestRandomVideos];
}


-(void)pullupLoadAction:(MJRefreshFooter*)footer
{
    [self fetchMoreVideos];
}
-(void)fetchMoreVideos
{
    if (randomMode==YES)
    {
        [self requestMoreRandomVideos];
    }
    else
    {
        [self requestMoreVideosInPannel];
    }
}




#pragma mark - Scroll delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSIndexPath * indexpath = [self getCurrentRow];
    
    [self playCurrentRow];
    
    //如果是倒数第二个则加载更多
    if (indexpath.row==dataArr.count-2)
    {
        [self fetchMoreVideos];
    }
    
}

#pragma mark - Cell Delegate
- (void)didSelectVideo:(ContentModel*)model
{
    NSString * contentid = model.id;
    [commentBar updateCommentBarData:contentid cannotComent:model.disableComment.boolValue];
}



#pragma mark - 播放
-(NSIndexPath*)getCurrentRow
{
    //获取当前cell的index
    CGPoint pt = collectionView.contentOffset;
    pt.y = pt.y + collectionView.frame.size.height/2;
    NSIndexPath * idx = [collectionView indexPathForItemAtPoint:pt];
    return idx;
}

-(void)playCurrentRow
{
    //model
    NSIndexPath * path = [self getCurrentRow];
    if (path==nil)
    {
        return;
    }
    ContentModel * videoM = dataArr[path.row];
    
    //commenbar
    NSString * contentid = videoM.id;
    [commentBar updateCommentBarData:contentid cannotComent:videoM.disableComment.boolValue];
    
    //playvideo
    SZVideoCell * cell = (SZVideoCell*)[collectionView cellForItemAtIndexPath:path];
    [cell playingVideo];
}

#pragma mark - CollectionView Datasource & Delegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SZVideoCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"shortSZVideoCell" forIndexPath:indexPath];
    cell.delegate=self;
    [cell setCellData:dataArr[indexPath.row]];
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
    return dataArr.count;
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


#pragma mark - Btn Action
-(void)backBtnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - StatusBar
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(BOOL)prefersStatusBarHidden
{
    return self.MJHideStatusbar;
}


@end
