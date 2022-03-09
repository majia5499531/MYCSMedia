//
//  SZHomeVC.m
//  MYCSMedia-CSAssets
//
//  Created by 马佳 on 2021/6/19.
//

#import "SZHomeVC.h"
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
#import "MJLabel.h"
#import "IQDataBinding.h"
#import "NSString+MJCategory.h"
#import "SZGlobalInfo.h"
#import "SZHomeRootView1.h"
#import "SZHomeRootView2.h"
#import "SZHomeRootView3.h"
#import "SZColumnBar.h"
#import "SZData.h"
#import "PanelModel.h"
#import "SZUserTracker.h"
#import "CategoryListModel.h"
#import "CategoryModel.h"

@interface SZHomeVC ()<UIScrollViewDelegate,NewsColumnDelegate>
{
    CategoryListModel * cateList;
    UIScrollView * scrollBG;
    SZColumnBar * columnbar;
    NSArray * titleArr;
    
    SZHomeRootView1 * rootview1;
    SZHomeRootView2 * rootview2;
    SZHomeRootView3 * rootview3;
}
@property(assign,nonatomic)BOOL MJHideStatusbar;

@end

@implementation SZHomeVC


-(instancetype)init
{
    self = [super init];
    if (self)
    {
        self.initialIndex = 1;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self requestCategoryList];
}

-(void)dealloc
{
    [self removeNotifications];
    
    [[SZData sharedSZData]setCurrentContentId:@""];
    
    [MJVideoManager destroyVideoPlayer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden=YES;
    
    //检查登录状态
    [SZGlobalInfo checkLoginStatus:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden=NO;
    
    [MJVideoManager pauseWindowVideo];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self subviewDidAppear];
}

-(void)subviewDidAppear
{
    if (_currentSelectIdx==0)
    {
        [rootview1 needUpdateCurrentContentId_now:YES];
    }
    else if (_currentSelectIdx==1)
    {
        [rootview2 needUpdateCurrentContentId_now:YES];
    }
    else
    {
        
    }
}





#pragma mark - 界面&布局
-(void)MJInitSubviews
{
    //整体滑动
    scrollBG = [[UIScrollView alloc]init];
    scrollBG.backgroundColor=[UIColor blackColor];
    if (@available(iOS 11.0, *))
    {
        scrollBG.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    scrollBG.delegate=self;
    [scrollBG setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    scrollBG.contentSize=CGSizeMake(SCREEN_WIDTH*3, 0);
    scrollBG.pagingEnabled=YES;
    scrollBG.bounces=NO;
    scrollBG.showsHorizontalScrollIndicator=NO;
    [self.view addSubview:scrollBG];
    
    //小康生活
    rootview1 = [[SZHomeRootView1 alloc]initWithFrame:CGRectMake(0, 0, scrollBG.width, scrollBG.height)];
    [scrollBG addSubview:rootview1];
    
    //视频
    rootview2 = [[SZHomeRootView2 alloc]initWithFrame:CGRectMake(scrollBG.width, 0, scrollBG.width, scrollBG.height)];
    rootview2.contentId = self.contentId;
    [scrollBG addSubview:rootview2];
    
    //直播
    rootview3 = [[SZHomeRootView3 alloc]initWithFrame:CGRectMake(scrollBG.width*2, NAVI_HEIGHT, scrollBG.width, scrollBG.height-NAVI_HEIGHT)];
    [scrollBG addSubview:rootview3];
    
    
    NSString * str = @"我的小康生活";
    for (int i =0; i<cateList.dataArr.count; i++)
    {
        CategoryModel * model = cateList.dataArr[i];
        if ([model.code isEqualToString:@"mycs.xksh"])
        {
            str = model.name;
        }
    }
    
    //SZColumnBar
    columnbar = [[SZColumnBar alloc]initWithFrame:CGRectMake(70, STATUS_BAR_HEIGHT, 235, 36)];
    columnbar.columnDelegate=self;
    [self.view addSubview:columnbar];
    titleArr = @[str,@"视频",@"直播"];
    [columnbar setTopicTitles:titleArr relateScrollView:scrollBG originX:10 minWidth:50 itemMargin:12 initialIndex:self.initialIndex];
    [self.view addSubview:columnbar];
    [columnbar setCenterX:self.view.width/2];
    
    //backbtn
    MJButton * backBtn = [[MJButton alloc]init];
    [backBtn setImage:[UIImage getBundleImage:@"sz_naviback"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(STATUS_BAR_HEIGHT-7.5);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    
    //profile
    MJButton * profileBtn = [[MJButton alloc]initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT-7, 50, 50)];
    [profileBtn setImage:[UIImage getBundleImage:@"sz_home_profile"] forState:UIControlStateNormal];
    [profileBtn addTarget:self action:@selector(profileBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:profileBtn];
    [profileBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(backBtn);
        make.width.mas_equalTo(45);
        make.height.mas_equalTo(50);
    }];
    
    //search
    MJButton * searchBtn = [[MJButton alloc]initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT-7, 50, 50)];
    [searchBtn setImage:[UIImage getBundleImage:@"sz_home_search"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(profileBtn.mas_left);
        make.top.mas_equalTo(profileBtn);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(50);
    }];
}



#pragma mark - Request
-(void)requestCategoryList
{
    CategoryListModel * list = [CategoryListModel model];
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:@"mycs.video" forKey:@"categoryCode"];
    
    __weak typeof (self) weakSelf = self;
    [list GETRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_URL_CATEGORY_LIST) Params:param Success:^(id responseObject) {
        [weakSelf requestCategoryListDone:list];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}


-(void)requestXKSH_Activity
{
    PanelModel * model = [PanelModel model];
    model.hideLoading=YES;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:@"activity.xksh.link" forKey:@"panelCode"];
    
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:nil WithUrl:APPEND_SUBURL(BASE_URL, API_URL_PANEL_ACTIVITY) Params:param Success:^(id responseObject) {
        [weakSelf requestXKSH_ActivityDone:model.config];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}

-(void)requestVideoColumnInfo
{
    PanelModel * model = [PanelModel model];
    model.hideLoading=YES;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:@"activity.video.link" forKey:@"panelCode"];
    
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:nil WithUrl:APPEND_SUBURL(BASE_URL, API_URL_PANEL_ACTIVITY) Params:param Success:^(id responseObject) {
        [weakSelf requestVideoColumnInfoDone:model.config];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}


#pragma mark - Request Done
-(void)requestCategoryListDone:(CategoryListModel*)list
{
    cateList = list;
    
    [self MJInitSubviews];
    
    [self addNotifications];
    
    [self requestXKSH_Activity];
    
    [self requestVideoColumnInfo];
}
-(void)requestXKSH_ActivityDone:(PanelConfigModel*)panelConfig
{
    NSString * img1 = panelConfig.imageUrl;
    NSString * img2 = panelConfig.backgroundImageUrl;
    NSString * linkUrl  = panelConfig.jumpUrl;
    
    if (linkUrl.length)
    {
        [columnbar setBadgeStr:@"活动" atIndex:0];
        [rootview1 setActivityImg:img1 simpleImg:img2 linkUrl:linkUrl];
    }
    
}


-(void)requestVideoColumnInfoDone:(PanelConfigModel*)panelConfig
{
    NSString * img1 = panelConfig.imageUrl;
    NSString * img2 = panelConfig.backgroundImageUrl;
    NSString * linkUrl  = panelConfig.jumpUrl;
    
    if (linkUrl.length)
    {
        [columnbar setBadgeStr:@"活动" atIndex:1];
        [rootview2 setActivityImg:img1 simpleImg:img2 linkUrl:linkUrl];
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
    if (_currentSelectIdx==0)
    {
        [rootview1 needUpdateCurrentContentId_now:YES];
    }
    else
    {
        [rootview2 needUpdateCurrentContentId_now:YES];
    }
}

-(void)onDeviceOrientationChange:(NSNotification*)notify
{
    //如果当前是topVC，并且栏目是视频或小康生活
    if (![self.navigationController.topViewController isEqual:self] || _currentSelectIdx==2)
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



#pragma mark - Delegate
- (void)mjview:(UIView *)view didSelectColumn:(id)model collectionviewIndex:(NSInteger)index
{
    //行为埋点
    [SZUserTracker trackingVideoTab:titleArr[index]];
    
    if (index==0)
    {
        rootview1.selected=YES;
        rootview2.selected=NO;
        
        [rootview1 viewWillAppear];
        _currentSelectIdx = 0;
        
        
        
    }
    else if (index==1)
    {
        rootview1.selected=NO;
        rootview2.selected=YES;
        
        [rootview2 viewWillAppear];
        _currentSelectIdx = 1;
        
    }
    else
    {
        rootview1.selected=NO;
        rootview2.selected=NO;
        
        [rootview3 viewWillAppear];
        _currentSelectIdx = 2;
        
    }
}





#pragma mark - Btn Action
-(void)backBtnAction
{
    [self.navigationController popViewControllerAnimated:YES];
    
    //行为埋点
    [SZUserTracker trackingButtonEventName:@"short_video_page_click" param:@{@"button_name":@"页面关闭"}];
}

-(void)profileBtnAction
{
    //行为埋点
    [SZUserTracker trackingButtonEventName:@"short_video_page_click" param:@{@"button_name":@"视频个人中心"}];
    
    //未登录则跳转登录
    if (![SZGlobalInfo sharedManager].SZRMToken.length)
    {
        [SZGlobalInfo mjshowLoginAlert];
        return;
    }
    
    NSString * h5url = APPEND_SUBURL(BASE_H5_URL, @"act/xksh/#/me");
    [[SZManager sharedManager].delegate onOpenWebview:h5url param:nil];
}

-(void)searchBtnAction
{
    //行为埋点
    [SZUserTracker trackingButtonEventName:@"short_video_page_click" param:@{@"button_name":@"搜索"}];
    
    NSString * h5ur = APPEND_SUBURL(BASE_H5_URL, @"fuse/news/#/searchPlus");
    [[SZManager sharedManager].delegate onOpenWebview:h5ur param:nil];
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
