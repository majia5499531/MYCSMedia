//
//  SZVideoListVC.m
//  MYCSMedia
//
//  Created by 马佳 on 2023/4/8.
//

#import "SZVideoListVC.h"
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
#import "MJHUD.h"
#import "BaseModel.h"
#import "ContentListModel.h"
#import "ContentModel.h"
#import "TokenExchangeModel.h"
#import "ConsoleVC.h"
#import "SZData.h"
#import "SZGlobalInfo.h"
#import "UIScrollView+MJCategory.h"
#import "UIResponder+MJCategory.h"
#import "SDWebImage.h"
#import <MJRefresh/MJRefresh.h>

@interface SZVideoListVC ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    //data
    ContentModel * singleVideo;
    
    NSString * acitivity_link;
    
    //UI
    UICollectionView * collectionView;
    UIImageView * activityIcon_simple;
    UIImageView * activityIcon_full;
    
    //statusbar
    BOOL shouldStatusBarHidden;
}
@end

@implementation SZVideoListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addObeserving];
    
    [self MJInitSubviews];
    
    //如果没有数据，则请求数据
    if (_dataModel==nil)
    {
        //如果是单条视频，则先请求单条视频
        if (self.contentId)
        {
            [self requestSingleVideo];
        }
        else
        {
            [self requestVideoList];
        }
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.isFocusedVC = YES;
    
    //更新statusbar
    [self setNeedsStatusBarAppearanceUpdate];
    
    //强制切换contentId
    [self checkCurrentContentId_force:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.isFocusedVC = NO;
}

-(void)dealloc
{
    [[SZData sharedSZData]setCurrentContentId:@""];
    
    [MJVideoManager destroyVideoPlayer];
    
    [self removeNotifications];
}


#pragma mark - Observings
-(void)addObeserving
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SZRMTokenExchangeDone:) name:@"SZRMTokenExchangeDone" object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(videoViewDidEnterFullSreen:) name:@"MJNeedHideStatusBar" object:nil];
    
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

-(void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Observing Callback
-(void)videoViewDidEnterFullSreen:(NSNotification*)notify
{
    NSNumber * needHidden = notify.object;
    
    shouldStatusBarHidden = needHidden.boolValue;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)onDeviceOrientationChange:(NSNotification*)notify
{
    
    NSArray * navArr = self.navigationController.viewControllers;
    UIViewController * lastvc = navArr.lastObject;
    UINavigationController * currentNav = self.tabBarController.selectedViewController;
    
    //当前VC不是焦点
    if (!self.isFocusedVC)
    {
        return;
    }
    
    //nav不是tab焦点
    else if (![self.navigationController isEqual:currentNav])
    {
        return;
    }
    
    //self不是nav最顶层
    else if (lastvc != self.parentViewController)
    {
            return;
    }
    
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


-(void)SZRMTokenExchangeDone:(NSNotification*)notify
{
    //因为需要更新点赞收藏状态，需要强制更新
    [self checkCurrentContentId_force:YES];
}


#pragma mark - Subview
-(void)MJInitSubviews
{
    //collectionview
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0 ,0) collectionViewLayout:flowLayout];
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
    [self.view addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(self.view);
    }];
    
}


#pragma mark - Private
-(NSIndexPath*)getCurrentRow
{
    //获取当前cell的index
    CGPoint pt = collectionView.contentOffset;
    pt.y = pt.y + collectionView.frame.size.height/2;
    NSIndexPath * idx = [collectionView indexPathForItemAtPoint:pt];
    return idx;
}

#pragma mark - Public
-(void)setActivityImg:(NSString *)img1 simpleImg:(NSString *)img2 linkUrl:(NSString *)url
{
    acitivity_link = url;
    
    //活动按钮
    activityIcon_simple = [[UIImageView alloc]init];
    activityIcon_simple.userInteractionEnabled =YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(activityUnfoldBtnAction)];
    [activityIcon_simple addGestureRecognizer:tap];
    [activityIcon_simple sd_setImageWithURL:[NSURL URLWithString:img2]];
    activityIcon_simple.hidden=YES;
    [self.view addSubview:activityIcon_simple];
    [activityIcon_simple mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(STATUS_BAR_HEIGHT+44+84);
        make.width.mas_equalTo(31);
        make.height.mas_equalTo(36);
    }];
    
    //活动按钮
    activityIcon_full = [[UIImageView alloc]init];
    activityIcon_full.userInteractionEnabled =YES;
    [activityIcon_full sd_setImageWithURL:[NSURL URLWithString:img1]];
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(activityTapAction)];
    [activityIcon_full addGestureRecognizer:tap2];
    [self.view addSubview:activityIcon_full];
    [activityIcon_full mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(STATUS_BAR_HEIGHT+44+84);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(50);
    }];
    
    //活动按钮关闭按钮
    MJButton * closebtn = [[MJButton alloc]initWithFrame:CGRectMake(70, 0, 30, 30)];
    [closebtn addTarget:self action:@selector(activityCloseBtnAction) forControlEvents:UIControlEventTouchUpInside];
    closebtn.backgroundColor=[UIColor clearColor];
    [activityIcon_full addSubview:closebtn];
    [closebtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(70);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
}


#pragma mark - Request
-(void)requestVideoList
{
    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
    NSString * ssid = [[SZManager sharedManager].delegate onGetUserDevice];
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:self.panelCode forKey:@"panelCode"];
    [param setValue:pagesize forKey:@"pageSize"];
    [param setValue:@"0" forKey:@"removeFirst"];
    [param setValue:ssid forKey:@"ssid"];
    [param setValue:@"refresh" forKey:@"refreshType"];
    
    ContentListModel * dataModel = [ContentListModel model];
    __weak typeof (self) weakSelf = self;
    [dataModel GETRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_URL_VIDEO_LIST) Params:param Success:^(id responseObject){
        [weakSelf requestVideoListDone:dataModel];
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];
}


-(void)requestMoreVideos
{
    //获取最后一条视频的ID
    ContentModel * lastModel = _dataModel.dataArr.lastObject;
    NSString * lastContentId =  lastModel.id;
    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
    NSString * ssid = [[SZManager sharedManager].delegate onGetUserDevice];
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:self.panelCode forKey:@"panelCode"];
    [param setValue:lastContentId forKey:@"contentId"];
    [param setValue:pagesize forKey:@"pageSize"];
    [param setValue:@"1" forKey:@"removeFirst"];
    [param setValue:ssid forKey:@"ssid"];
    [param setValue:@"loadmore" forKey:@"refreshType"];
    
    ContentListModel * model = [ContentListModel model];
    model.hideLoading=YES;
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:nil WithUrl:APPEND_SUBURL(BASE_URL, API_URL_VIDEO_LIST) Params:param Success:^(id responseObject){
        [weakSelf requestMoreVideoDone:model];
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
    
    ContentModel * contentM = [ContentModel model];
    __weak typeof (self) weakSelf = self;
    [contentM GETRequestInView:nil WithUrl:url Params:nil Success:^(id responseObject) {
        
        [weakSelf requestSingleVideoDone:contentM];
        
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];
}


#pragma mark - Request Done
-(void)requestSingleVideoDone:(ContentModel*)model
{
    singleVideo = model;
    model.isManualPlay=YES;
    model.volcCategory = self.category_name;
    model.requestId = self.requestId;
    [self requestVideoList];
}

-(void)requestVideoListDone:(ContentListModel*)model
{
    [collectionView.mj_footer endRefreshing];
    [collectionView.mj_header endRefreshing];
    
    _dataModel = model;
    
    if (singleVideo)
    {
        [_dataModel.dataArr insertObject:singleVideo atIndex:0];
    }
    
    
    [collectionView reloadData];
    
    [collectionView layoutIfNeeded];
    
    //请求完数据，更新一次contentId
    [self checkCurrentContentId_force:NO];
    
//    //立即切到主线程执行
//    dispatch_async(dispatch_get_main_queue(),^{
//        [self checkCurrentContentId_force:NO];
//    });
    
    
//    //延时执行
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self checkCurrentContentId_force: NO];
//    });
    
}


-(void)requestMoreVideoDone:(ContentListModel*)model
{
    [collectionView.mj_footer endRefreshing];
    [collectionView.mj_header endRefreshing];
    
    if (model.dataArr.count==0 && [self getCurrentRow].row==_dataModel.dataArr.count-1)
    {
        [MJHUD_Notice showNoticeView:@"没有更多视频了" inView:self.view hideAfterDelay:2];
        return;
    }
    
    
    NSInteger startIdx = _dataModel.dataArr.count;
    
    
    NSMutableArray * idxArr = [NSMutableArray array];
    for (int i = 0; i<model.dataArr.count; i++)
    {
        NSInteger idx = startIdx++;
        NSIndexPath * idpath = [NSIndexPath indexPathForRow:idx inSection:0];
        [idxArr addObject:idpath];
    }
    
    
    
    [_dataModel.dataArr addObjectsFromArray:model.dataArr];
    
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


#pragma mark - Btn Action
-(void)activityTapAction
{
    [[SZManager sharedManager].delegate onOpenWebview:acitivity_link param:nil];
}

-(void)activityUnfoldBtnAction
{
    self->activityIcon_simple.hidden=YES;
    self->activityIcon_full.hidden=NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self->activityIcon_full setFrame:CGRectMake(0, self->activityIcon_full.top, self->activityIcon_full.width, self->activityIcon_full.height)];
        } completion:^(BOOL finished) {
        }];
}

-(void)activityCloseBtnAction
{
    [UIView animateWithDuration:0.3 animations:^{
        [self->activityIcon_full setFrame:CGRectMake(-100, self->activityIcon_full.top, self->activityIcon_full.width, self->activityIcon_full.height)];
        } completion:^(BOOL finished) {
            self->activityIcon_full.hidden=YES;
            self->activityIcon_simple.hidden=NO;
        }];
}


#pragma mark - 下拉/上拉
-(void)pulldownRefreshAction:(MJRefreshHeader*)refreshHeader
{
    [self requestVideoList];
}

-(void)pullupLoadAction:(MJRefreshFooter*)footer
{
    [self requestMoreVideos];
}






#pragma mark - Scroll delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSIndexPath * indexpath = [self getCurrentRow];
    
    [self checkCurrentContentId_force:NO];
    
    //如果是倒数第二个则加载更多
    if (indexpath.row==_dataModel.dataArr.count-2)
    {
        [self requestMoreVideos];
    }
}



#pragma mark - 更新currentId
-(void)checkCurrentContentId_force:(BOOL)force
{
    //如果不是当前栏目
    if (!self.isFocusedVC)
    {
        return;
    }
    
    //如果当前没有数据
    if(_dataModel==nil || _dataModel.dataArr.count==0)
    {
        return;
    }
    
    //获取当前正在展示的视频
    NSIndexPath * path = [self getCurrentRow];
    if (path==nil)
    {
        return;
    }
    
    //contentId
    ContentModel * contentModel = _dataModel.dataArr[path.row];
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
    SZVideoCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"shortSZVideoCell" forIndexPath:indexPath];
    [cell setVideoCellData:_dataModel.dataArr[indexPath.row] albumnName:nil simpleMode:NO];
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
    return _dataModel.dataArr.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.width,collectionView.height);
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


#pragma mark - StatusBar
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(BOOL)prefersStatusBarHidden
{
    return shouldStatusBarHidden;
}

@end
