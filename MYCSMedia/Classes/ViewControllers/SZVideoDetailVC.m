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
#import "UIImage+MJCategory.h"
#import "MJButton.h"
#import "MJVideoManager.h"
#import <Masonry/Masonry.h>
#import "SZManager.h"
#import "UIView+MJCategory.h"
#import "SZInputView.h"
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
#import "VideoCollectModel.h"
#import "SZHomeVC.h"

@interface SZVideoDetailVC ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(assign,nonatomic)BOOL MJHideStatusbar;
@property(strong,nonatomic)NSMutableArray * dataArr;
@end



@implementation SZVideoDetailVC
{
    //UI
    UICollectionView * collectionView;
    
    //话题广场相关视频page
    NSInteger pageNum;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self MJInitData];
    
    [self MJInitSubviews];
    
    [self addNotifications];
    
    [self fetchVideoData];
}

-(void)dealloc
{
    [self removeNotifications];
    
    [[SZData sharedSZData]setCurrentContentId:@""];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden=YES;
    
    //检查登录
    [SZGlobalInfo checkRMLoginStatus:nil];
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
    
    [self checkCurrentContentId_force:YES];
}

-(NSIndexPath*)getCurrentRow
{
    //获取当前cell的index
    CGPoint pt = collectionView.contentOffset;
    pt.y = pt.y + collectionView.frame.size.height/2;
    NSIndexPath * idx = [collectionView indexPathForItemAtPoint:pt];
    return idx;
}

-(void)fetchVideoData
{
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
    [self checkCurrentContentId_force:YES];
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
//查询单条视频
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
        model.requestId = self.requestId;
        [list.dataArr addObject:model];
        [weakSelf requestSingleVideoDone:list.dataArr];
        
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];
}

//查询视频合集
-(void)requestVideosInCollection
{
    NSString * url = APPEND_SUBURL(BASE_URL, API_URL_VIDEOCOLLECT);
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:self.albumId forKey:@"classId"];
    [param setValue:@"3" forKey:@"pageSize"];
    [param setValue:@"1" forKey:@"pageIndex"];
    
    __weak typeof (self) weakSelf = self;
    VideoCollectModel * model = [VideoCollectModel model];
    [model GETRequestInView:self.view WithUrl:url Params:param Success:^(id responseObject) {
        [weakSelf requestCollectionVideosDone:model.dataArr];
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];
}


//从话题广场的视频进入
-(void)requestRelateVideos
{
    pageNum = 1;
    
    if(self.dataArr.count==0)
    {
        return;
    }
    ContentModel * singleModel = self.dataArr.firstObject;
    NSString * startTime = singleModel.startTime;
    
    NSString * url = APPEND_SUBURL(BASE_URL, API_URL_HUDONG_RELATE_VIDEO);
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:self.locationType forKey:@"locationType"];
    [param setValue:@"10" forKey:@"pageSize"];
    [param setValue:[NSString stringWithFormat:@"%ld",(long)pageNum] forKey:@"pageIndex"];
    [param setValue:self.topicId forKey:@"topicId"];
    [param setValue:self.groupId forKey:@"groupId"];
    [param setValue:self.userId forKey:@"userId"];
    [param setValue:startTime forKey:@"contentStartTime"];
    
    __weak typeof (self) weakSelf = self;
    VideoCollectModel * model = [VideoCollectModel model];
    model.isJSON=YES;
    [model PostRequestInView:self.view WithUrl:url Params:param Success:^(id responseObject) {
        [weakSelf requestHUATIRelateVideosDone:model.dataArr];
    } Error:^(id responseObject) {
        [weakSelf requestFailed];
    } Fail:^(NSError *error) {
        [weakSelf requestFailed];
    }];
}


-(void)requestMoreRelateVideos
{
    if(self.dataArr.count==0)
    {
        return;
    }
    
    pageNum = pageNum+1;
    
    ContentModel * singleModel = self.dataArr.firstObject;
    NSString * startTime = singleModel.startTime;
    
    NSString * url = APPEND_SUBURL(BASE_URL, API_URL_HUDONG_RELATE_VIDEO);
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:self.locationType forKey:@"locationType"];
    [param setValue:@"10" forKey:@"pageSize"];
    [param setValue:[NSString stringWithFormat:@"%ld",(long)pageNum] forKey:@"pageIndex"];
    [param setValue:self.topicId forKey:@"topicId"];
    [param setValue:self.groupId forKey:@"troupId"];
    [param setValue:self.userId forKey:@"userId"];
    [param setValue:startTime forKey:@"contentStartTime"];
    
    __weak typeof (self) weakSelf = self;
    VideoCollectModel * model = [VideoCollectModel model];
    model.isJSON=YES;
    [model PostRequestInView:self.view WithUrl:url Params:param Success:^(id responseObject) {
        [weakSelf requestMoreHuaTiRelateVideosDone:model.dataArr];
    } Error:^(id responseObject) {
        [weakSelf requestFailed];
    } Fail:^(NSError *error) {
        [weakSelf requestFailed];
    }];
}


#pragma mark - Request Done
-(void)requestSingleVideoDone:(NSArray*)modelArr
{
    //结束刷新
    [collectionView.mj_footer endRefreshing];
    [collectionView.mj_header endRefreshing];
    
    //刷新列表，检查播放
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:modelArr];
    
    [collectionView reloadData];
    [collectionView layoutIfNeeded];
    [self checkCurrentContentId_force:NO];
    
    //如果是从话题广场进入
    if(self.locationType>0)
    {
        [self requestRelateVideos];
    }
    
}

-(void)requestCollectionVideosDone:(NSArray*)modelArr
{
    [collectionView.mj_footer endRefreshing];
    [collectionView.mj_header endRefreshing];
    
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:modelArr];
    
    
    [collectionView reloadData];
    [collectionView layoutIfNeeded];
    [self checkCurrentContentId_force:NO];
    
}

-(void)requestHUATIRelateVideosDone:(NSArray*)modelArr
{
    [self.dataArr addObjectsFromArray:modelArr];
    
    [collectionView reloadData];
    [collectionView layoutIfNeeded];
}


-(void)requestMoreHuaTiRelateVideosDone:(NSArray*)modelArr
{
    [collectionView.mj_footer endRefreshing];
    [collectionView.mj_header endRefreshing];
    
    if (modelArr.count==0)
    {
        [MJHUD_Notice showNoticeView:@"没有更多视频了" inView:self.view hideAfterDelay:2];
        return;
    }
    
    
    NSInteger startIdx = self.dataArr.count;
    
    
    NSMutableArray * idxArr = [NSMutableArray array];
    for (int i = 0; i<modelArr.count; i++)
    {
        NSInteger idx = startIdx++;
        NSIndexPath * idpath = [NSIndexPath indexPathForRow:idx inSection:0];
        [idxArr addObject:idpath];
    }
    
    
    
    [self.dataArr addObjectsFromArray:modelArr];
    
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

#pragma mark - 下拉/上拉
-(void)pulldownRefreshAction:(MJRefreshHeader*)refreshHeader
{
    [self fetchVideoData];
}

-(void)pullupLoadAction:(MJRefreshFooter*)footer
{
    if(self.locationType>0)
    {
        [self requestMoreRelateVideos];
    }
    else
    {
        [collectionView.mj_footer endRefreshing];
    }
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
    [collectionView registerClass:[SZVideoCell class] forCellWithReuseIdentifier:@"fullVideoCell"];
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
    
    
    //console
    UIView * consoleBtn = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-50, STATUS_BAR_HEIGHT, 50, 50)];
    consoleBtn.backgroundColor=[UIColor clearColor];
    UILongPressGestureRecognizer * gest = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(consoleBtnAction:)];
    gest.minimumPressDuration = 3;
    [consoleBtn addGestureRecognizer:gest];
    [self.view addSubview:consoleBtn];
    
}


-(void)MJInitData
{
    //清空状态
    [[SZData sharedSZData]setCurrentContentId:@""];
    [MJVideoManager destroyVideoPlayer];
    
}









#pragma mark - Scroll delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self checkCurrentContentId_force:NO];
}



#pragma mark - 更新currentId
-(void)checkCurrentContentId_force:(BOOL)force
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
    SZVideoCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fullVideoCell" forIndexPath:indexPath];
    [cell setVideoCellData:self.dataArr[indexPath.row] albumnName:self.albumName simpleMode:self.isPreview];
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
