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
#import "SZVideoDetailSimpleCell.h"
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
#import "SZVideoCell.h"
#import <MJRefresh/MJRefresh.h>
#import "TopicListModel.h"
#import "SZHomeVC.h"

@interface SZVideoDetailVC ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(assign,nonatomic)BOOL MJHideStatusbar;
@property(strong,nonatomic)NSMutableArray * dataArr;
@end



@implementation SZVideoDetailVC
{
    //data
    BOOL isRandomMode;
    
    //UI
    UICollectionView * collectionView;
    SZCommentBar * commentBar;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self MJInitData];
    
    [self MJInitSubviews];
    
    [self addNotifications];
    
    
    //根据类型请求数据
    if (self.detailType==0)
    {
        [self requestSingleVideo];
    }
    else if (self.detailType==1)
    {
        [self requestVideosInCollection];
    }
}

-(void)dealloc
{
    [self removeNotifications];
    

    [[SZData sharedSZData]setCurrentContentId:@""];
//    [MJVideoManager destroyVideoPlayer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden=YES;
    
    //检查登录
    [SZGlobalInfo checkLoginStatus:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden=NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [MJVideoManager pauseWindowVideo];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self needUpdateCurrentContentId_now:YES];
}

-(NSIndexPath*)getCurrentRow
{
    //获取当前cell的index
    CGPoint pt = collectionView.contentOffset;
    pt.y = pt.y + collectionView.frame.size.height/2;
    NSIndexPath * idx = [collectionView indexPathForItemAtPoint:pt];
    return idx;
}


#pragma mark - Add Notoify
-(void)addNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(videoViewDidEnterFullSreen:) name:@"MJNeedHideStatusBar" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SZRMTokenExchangeDone:) name:@"SZRMTokenExchangeDone" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}
-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Notification CallBack
-(void)videoViewDidEnterFullSreen:(NSNotification*)notify
{
    NSNumber * needHidden = notify.object;
    
    self.MJHideStatusbar = needHidden.boolValue;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)SZRMTokenExchangeDone:(NSNotification*)notify
{
    [self needUpdateCurrentContentId_now:YES];
}

-(void)onDeviceOrientationChange:(NSNotification*)notify
{
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
    if (orient == UIDeviceOrientationLandscapeLeft || orient == UIDeviceOrientationLandscapeRight)
    {
        NSNumber * num = [NSNumber numberWithBool:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"MJRemoteEnterFullScreen" object:num];
    }
    
    else if(orient == UIDeviceOrientationPortrait)
    {
        NSNumber * num = [NSNumber numberWithBool:NO];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"MJRemoteEnterFullScreen" object:num];
    }
}


#pragma mark - Setter
-(void)setContentId:(NSString *)contentId
{
    if (contentId.length)
    {
        _contentId = contentId;
    }
}


#pragma mark - Request
-(void)requestVideosInCollection
{
    NSString * url = APPEND_SUBURL(BASE_URL, API_URL_VIDEOCOLLECT);
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:self.albumId forKey:@"classId"];
    [param setValue:@"9999" forKey:@"pageSize"];
    [param setValue:@"1" forKey:@"pageIndex"];
    
    __weak typeof (self) weakSelf = self;
    TopicListModel * model = [TopicListModel model];
    [model GETRequestInView:self.view WithUrl:url Params:param Success:^(id responseObject) {
        [weakSelf requestDone:model.dataArr];
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
        
        ContentListModel * list = [ContentListModel model];
        model.isManualPlay = YES;
        model.volcCategory = self.category_name;
        [list.dataArr addObject:model];
        [weakSelf requestDone:list.dataArr];
        
        //加载更多
//        [weakSelf fetchMoreVideos];
        
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];
}

-(void)requestRandomVideos
{
//    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
//
//    NSMutableDictionary * param=[NSMutableDictionary dictionary];
//    [param setValue:pagesize forKey:@"pageSize"];
//
//    ContentListModel * dataModel = [ContentListModel model];
//    __weak typeof (self) weakSelf = self;
//    [dataModel GETRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_URL_RANDOM_VIDEO_LIST) Params:param Success:^(id responseObject){
//        [weakSelf requestDone:dataModel];
//        } Error:^(id responseObject) {
//            [weakSelf requestFailed];
//        } Fail:^(NSError *error) {
//            [weakSelf requestFailed];
//        }];
}

-(void)requestMoreRandomVideos
{
//    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
//
//    NSMutableDictionary * param=[NSMutableDictionary dictionary];
//    [param setValue:pagesize forKey:@"pageSize"];
//
//    ContentListModel * dataModel = [ContentListModel model];
//    dataModel.hideLoading=YES;
//    __weak typeof (self) weakSelf = self;
//    [dataModel GETRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_URL_RANDOM_VIDEO_LIST) Params:param Success:^(id responseObject){
//        [weakSelf requestMoreVideoDone:dataModel];
//        } Error:^(id responseObject) {
//            [weakSelf requestFailed];
//        } Fail:^(NSError *error) {
//            [weakSelf requestFailed];
//        }];
}

-(void)requestMoreVideosInPannel
{
//    //获取最后一条视频的ID
//    ContentModel * lastModel = dataArr.lastObject;
//    NSString * lastContentId =  lastModel.id;
//    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
//
//    NSMutableDictionary * param=[NSMutableDictionary dictionary];
//    [param setValue:self.pannelId forKey:@"panelId"];
//    [param setValue:lastContentId forKey:@"contentId"];
//    [param setValue:pagesize forKey:@"pageSize"];
//    [param setValue:@"1" forKey:@"removeFirst"];
//
//    ContentListModel * model = [ContentListModel model];
//    model.hideLoading=YES;
//    __weak typeof (self) weakSelf = self;
//    [model GETRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_URL_VIDEO_LIST) Params:param Success:^(id responseObject){
//        [weakSelf requestMoreVideoDone:model];
//        } Error:^(id responseObject) {
//            [weakSelf requestFailed];
//        } Fail:^(NSError *error) {
//            [weakSelf requestFailed];
//        }];
}


#pragma mark - Request Done
-(void)requestDone:(NSArray*)modelArr
{
    [collectionView.mj_footer endRefreshing];
    [collectionView.mj_header endRefreshing];
    
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:modelArr];
    
    
    [collectionView reloadData];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [self needUpdateCurrentContentId_now:NO];
    });
    
}


-(void)requestMoreVideoDone:(ContentListModel*)model
{
//    [collectionView.mj_footer endRefreshing];
//    [collectionView.mj_header endRefreshing];
//
//    if (model.dataArr.count==0 && [self getCurrentRow].row==self.dataArr.count-1)
//    {
//        [MJHUD_Notice showNoticeView:@"没有更多视频了" inView:self.view hideAfterDelay:2];
//        return;
//    }
//
//
//    NSInteger startIdx = self.dataArr.count;
//
//
//    NSMutableArray * idxArr = [NSMutableArray array];
//    for (int i = 0; i<model.dataArr.count; i++)
//    {
//        NSInteger idx = startIdx++;
//        NSIndexPath * idpath = [NSIndexPath indexPathForRow:idx inSection:0];
//        [idxArr addObject:idpath];
//    }
//
//
//
//    [self.dataArr addObjectsFromArray:model.dataArr];
//
//    //追加collectionview数量
//    [collectionView performBatchUpdates:^{
//            [collectionView insertItemsAtIndexPaths:idxArr];
//        } completion:^(BOOL finished) {
//
//        }];
    
}


-(void)requestFailed
{
    [collectionView.mj_footer endRefreshing];
    [collectionView.mj_header endRefreshing];
}



#pragma mark - Init
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
    [collectionView registerClass:[SZVideoDetailSimpleCell class] forCellWithReuseIdentifier:@"simpleVideoCell"];
    [collectionView registerClass:[SZVideoCell class] forCellWithReuseIdentifier:@"fullVideoCell"];
//    collectionView.mj_header = [CustomAnimatedHeader headerWithRefreshingTarget:self refreshingAction:@selector(pulldownRefreshAction:)];
//    collectionView.mj_footer = [CustomFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullupLoadAction:)];
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
    
    
    //console
    UIView * consoleBtn = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-50, STATUS_BAR_HEIGHT, 50, 50)];
    consoleBtn.backgroundColor=[UIColor clearColor];
    UILongPressGestureRecognizer * gest = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(consoleBtnAction:)];
    gest.minimumPressDuration = 3;
    [consoleBtn addGestureRecognizer:gest];
    [self.view addSubview:consoleBtn];
    
    
    
    if (!_isPreview)
    {
        //commentview
        commentBar = [[SZCommentBar alloc]init];
        [commentBar setCommentBarStyle:0 type:1];
        [self.view addSubview:commentBar];
    }
    
}


-(void)MJInitData
{
    //清空状态
    [[SZData sharedSZData]setCurrentContentId:@""];
    [MJVideoManager destroyVideoPlayer];
    
//    if (self.pannelId.length==0)
//    {
        isRandomMode = YES;
//    }
}


#pragma mark - 下拉/上拉
-(void)pulldownRefreshAction:(MJRefreshHeader*)refreshHeader
{
    isRandomMode = YES;
    [self requestRandomVideos];
}

-(void)pullupLoadAction:(MJRefreshFooter*)footer
{
    [self fetchMoreVideos];
}

-(void)fetchMoreVideos
{
    if (isRandomMode==YES)
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
    
    [self needUpdateCurrentContentId_now:NO];
    
    //如果是倒数第二个则加载更多
    if (indexpath.row==self.dataArr.count-2)
    {
        [self fetchMoreVideos];
    }
}



#pragma mark - 更新currentId
-(void)needUpdateCurrentContentId_now:(BOOL)force
{
    //model
    NSIndexPath * path = [self getCurrentRow];
    if (path==nil)
    {
        return;
    }
    
    //contentId
    ContentModel * contentModel = self.dataArr[path.row];
    NSString * contentid = contentModel.id;
    
    //更新数据
    if(![[SZData sharedSZData].currentContentId isEqualToString:contentid] || force)
    {
        [[SZData sharedSZData].contentDic setValue:contentModel forKey:contentid];
        [[SZData sharedSZData]setCurrentContentId:contentid];
    }
}



#pragma mark - CollectionView Datasource & Delegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isPreview)
    {
        SZVideoDetailSimpleCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"simpleVideoCell" forIndexPath:indexPath];
        [cell setCellData:self.dataArr[indexPath.row] enableFollow:NO];
        return  cell;
    }
    else
    {
        SZVideoCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fullVideoCell" forIndexPath:indexPath];
        [cell setCellData:self.dataArr[indexPath.row] enableFollow:NO albumnName:self.albumName];
        return  cell;
    }
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
    return self.dataArr.count;
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
-(void)consoleBtnAction:(UILongPressGestureRecognizer *)longGes
{
    if (longGes.state == UIGestureRecognizerStateBegan)
    {
        ConsoleVC * vc = [[ConsoleVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - Lazy Load
-(NSMutableArray *)dataArr
{
    if (_dataArr==nil)
    {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
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
