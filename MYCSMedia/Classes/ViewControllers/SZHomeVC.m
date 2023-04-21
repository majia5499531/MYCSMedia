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
#import "MJHUD.h"
#import "BaseModel.h"
#import "ContentListModel.h"
#import "ContentModel.h"
#import "TokenExchangeModel.h"
#import "MJLabel.h"
#import "IQDataBinding.h"
#import "NSString+MJCategory.h"
#import "SZGlobalInfo.h"
#import "SZColumnBar.h"
#import "SZData.h"
#import "PanelModel.h"
#import "SZUserTracker.h"
#import "CategoryListModel.h"
#import "CategoryModel.h"
#import "UIResponder+MJCategory.h"
#import "SZLiveVC.h"
#import "SZVideoListVC.h"


@interface SZHomeVC ()<UIScrollViewDelegate,SZColumnBarDelegate>
{
    BOOL isTabbarRootVC;
    
    UIScrollView * scrollBG;
    SZColumnBar * columnbar;
    MJButton * backBtn;
    MJButton * profileBtn;
    MJButton * searchBtn;
    NSArray * titleArr;
    
    UIViewController * currentVC;
}

@end

@implementation SZHomeVC


-(instancetype)init
{
    self = [super init];
    if (self)
    {
        //默认选中视频
        self.initialIndex = 1;
    }
    return self;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self installSubviews];
    
    //查询tab的广告
    [self requestPanelInfo_XKSH];
    
    //查询tab的广告
    [self requestPanelInfo_Video];
    
    //查询tab标题
    [self requestCategoryList];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [currentVC beginAppearanceTransition:YES animated:animated];
    
    self.navigationController.navigationBar.hidden=YES;
    
    //检查登录状态
    [SZGlobalInfo checkRMLoginStatus:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [currentVC endAppearanceTransition];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [currentVC beginAppearanceTransition:NO animated:animated];
    
    self.navigationController.navigationBar.hidden=NO;
    
    [MJVideoManager pauseWindowVideo];
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [currentVC endAppearanceTransition];
    
    //如果是嵌入tabbar里，则需要销毁播放
    if (isTabbarRootVC)
    {
        [MJVideoManager destroyVideoPlayer];

        [[SZData sharedSZData]setCurrentContentId:@""];
    }

}

-(void)dealloc
{
    
}




#pragma mark - Subviews
-(void)installSubviews
{
    //BG Color
    self.view.backgroundColor=[UIColor whiteColor];
    
    //判断是否是嵌在tabbar里
    if (self==self.navigationController.viewControllers.firstObject)
    {
        isTabbarRootVC=YES;
    }
    
    //scollBG
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
    scrollBG.contentSize=CGSizeMake(SCREEN_WIDTH*3, 0);
    scrollBG.pagingEnabled=YES;
    scrollBG.bounces=NO;
    scrollBG.showsHorizontalScrollIndicator=NO;
    [self.view addSubview:scrollBG];
    if (isTabbarRootVC)
    {
        [scrollBG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.height.mas_equalTo(SCREEN_HEIGHT-self.navigationController.tabBarController.tabBar.height);
        }];
    }
    else
    {
        [scrollBG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.height.mas_equalTo(SCREEN_HEIGHT);
        }];
    }
    
    //这里是长沙
    SZVideoListVC * vc1 = [[SZVideoListVC alloc]init];
    vc1.panelCode = XKSH_LIST_PANEL_CODE;
    [scrollBG addSubview:vc1.view];
    [self addChildViewController:vc1];
    [vc1.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(scrollBG.mas_width);
        make.height.mas_equalTo(scrollBG.mas_height);
    }];
    
    //视频
    SZVideoListVC * vc2 = [[SZVideoListVC alloc]init];
    vc2.panelCode = VIDEO_LIST_PANEL_CODE;
    [scrollBG addSubview:vc2.view];
    [self addChildViewController:vc2];
    [vc2.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(vc1.view.mas_right);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(scrollBG.mas_width);
        make.height.mas_equalTo(scrollBG.mas_height);
    }];
    
    //直播
    SZLiveVC * live = [[SZLiveVC alloc]init];
    [scrollBG addSubview:live.view];
    [self addChildViewController:live];
    [live.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(vc2.view.mas_right);
        make.top.mas_equalTo(NAVI_HEIGHT);
        make.width.mas_equalTo(scrollBG.mas_width);
        make.height.mas_equalTo(scrollBG.mas_height).offset(-NAVI_HEIGHT);
    }];
    
    
    //传递初始视频ID
    if (self.contentId.length)
    {
        if (self.initialIndex==0)
        {
            vc1.contentId=self.contentId;
        }
        else
        {
            vc2.contentId=self.contentId;
        }
    }
    
    //backbtn
    if (isTabbarRootVC==NO)
    {
        backBtn = [[MJButton alloc]init];
        [backBtn setImage:[UIImage getBundleImage:@"sz_naviback"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backBtn];
        [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(STATUS_BAR_HEIGHT-7.5);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(50);
        }];
    }
    
    //profile
    profileBtn = [[MJButton alloc]initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT-7, 50, 50)];
    [profileBtn setImage:[UIImage getBundleImage:@"sz_home_profile"] forState:UIControlStateNormal];
    [profileBtn addTarget:self action:@selector(profileBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:profileBtn];
    [profileBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(STATUS_BAR_HEIGHT-7.5);
        make.width.mas_equalTo(45);
        make.height.mas_equalTo(50);
    }];
    
    //search
    searchBtn = [[MJButton alloc]initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT-7, 50, 50)];
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



-(void)installColumndBar:(CategoryListModel*)catelistModel
{
    NSString * title1 = @"长沙";
    NSString * title2 = @"视频";
    NSString * title3 = @"直播";
    
    
    for (int i =0; i<catelistModel.dataArr.count; i++)
    {
        CategoryModel * model = catelistModel.dataArr[i];
        if ([model.code isEqualToString:XKSH_CATEGORY_CODE])
        {
            title1 = model.name;
            SZVideoListVC * vc = self.childViewControllers[0];
            vc.cateModel = model;
        }
        else if ([model.code isEqualToString:VIDEO_CATEGORY_CODE])
        {
            title2 = model.name;
            SZVideoListVC * vc = self.childViewControllers[1];
            vc.cateModel = model;
        }
        else if ([model.code isEqualToString:LIVE_CATEGORY_CODE])
        {
            title3 = model.name;
            SZLiveVC * vc = self.childViewControllers[0];
            vc.cateModel = model;
        }
    }
    
    
    //SZColumnBar
    CGFloat scaleSize = 0;
    if (SCREEN_WIDTH<375)
    {
        scaleSize = 0;
    }
    else if (SCREEN_WIDTH<414)
    {
        scaleSize = 10;
    }
    else
    {
        scaleSize = SCREEN_WIDTH* (30.00/414.00);
    }
    
    
    titleArr = @[title1,title2,title3];
    columnbar = [[SZColumnBar alloc]initWithTitles:titleArr relateScrollView:scrollBG delegate:self originX:scaleSize itemMargin:25 txtColor:[UIColor colorWithWhite:1 alpha:0.5] selTxtColor:HW_WHITE lineColor:HW_WHITE initialIndex:self.initialIndex];
    [self.view addSubview:columnbar];
    [columnbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(80);
        make.top.mas_equalTo(STATUS_BAR_HEIGHT);
        make.right.mas_equalTo(searchBtn.mas_left).offset(-10);
        make.height.mas_equalTo(36);
    }];
    [columnbar setAlignStyle:SZColumnAlignmentSpacebtween];
    [columnbar refreshView];
}



#pragma mark - Request
//请求三个栏目的信息
-(void)requestCategoryList
{
    CategoryListModel * list = [CategoryListModel model];
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:HOME_CATEGORY_CODE forKey:@"categoryCode"];
    
    __weak typeof (self) weakSelf = self;
    [list GETRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_URL_CATEGORY_LIST) Params:param Success:^(id responseObject) {
        [weakSelf requestCategoryListDone:list];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}

//请求外部面板信息
-(void)requestPanelInfo_XKSH
{
    PanelModel * model = [PanelModel model];
    model.hideLoading=YES;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:XKSH_ACTIVITY_CODE forKey:@"panelCode"];
    
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:nil WithUrl:APPEND_SUBURL(BASE_URL, API_URL_PANEL_ACTIVITY) Params:param Success:^(id responseObject) {
        [weakSelf requestXKSH_ActivityDone:model.config];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}

//请求HOME_CATEGORY_CODE面板信息
-(void)requestPanelInfo_Video
{
    PanelModel * model = [PanelModel model];
    model.hideLoading=YES;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:VIDEO_ACTIVITY_CODE forKey:@"panelCode"];
    
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
    [self installColumndBar:list];
}


-(void)requestXKSH_ActivityDone:(PanelConfigModel*)panelConfig
{
    NSString * img1 = panelConfig.imageUrl;
    NSString * img2 = panelConfig.backgroundImageUrl;
    NSString * linkUrl  = panelConfig.jumpUrl;
    
    if (linkUrl.length)
    {
        [columnbar setBadgeStr:@"活动" atIndex:0];
        SZVideoListVC * vc = self.childViewControllers[0];
        [vc setActivityImg:img1 simpleImg:img2 linkUrl:linkUrl];
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
        SZVideoListVC * vc = self.childViewControllers[1];
        [vc setActivityImg:img1 simpleImg:img2 linkUrl:linkUrl];
    }
}


#pragma mark - ColumndBar Delegate
-(void)mjview:(UIView *)view willSelectTab:(NSInteger)index
{
    static NSInteger preIndex = -1;
    
    //通知上一个willDisappear
    if (preIndex>=0)
    {
        UIViewController * prevc = self.childViewControllers[preIndex];
        [prevc beginAppearanceTransition:NO animated:YES];
        [prevc endAppearanceTransition];
    }
    
    //添加新的VC，并通知willAppear
    UIViewController * newVC = self.childViewControllers[index];
    [newVC beginAppearanceTransition:YES animated:YES];
    preIndex=index;
}
-(void)mjview:(UIView*)view didSelectColumnIndex:(NSInteger)index
{
    //行为埋点
    [SZUserTracker trackingVideoTab:titleArr[index]];
    
    UIViewController * newVC = self.childViewControllers[index];
    currentVC =  newVC;
    [newVC endAppearanceTransition];
    
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
    [SZUserTracker trackingButtonEventName:@"short_video_page_click" param:@{@"button_name":@"个人作品中心"}];
    
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
    return [currentVC preferredStatusBarStyle];
}
-(BOOL)prefersStatusBarHidden
{
    return [currentVC prefersStatusBarHidden];
}


#pragma mark - 手动管理子容器
-(BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}


@end
