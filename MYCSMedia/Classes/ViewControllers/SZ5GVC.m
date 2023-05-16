//
//  SZMediaVC.m
//  MYCSMedia
//
//  Created by 马佳 on 2023/4/3.
//

#import "SZ5GVC.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "SZ5GLiveVC.h"
#import "SZ5GWebVC.h"
#import "Masonry.h"
#import "MJButton.h"
#import "UIImage+MJCategory.h"
#import "UIView+MJCategory.h"
#import "SZColumnBar.h"
#import "SZVideoDetailVC.h"
#import "SZ5GVideoListVC.h"
#import "CategoryListModel.h"
#import "SZGlobalInfo.h"
#import "CategoryModel.h"

@interface SZ5GVC ()<SZColumnBarDelegate,UIScrollViewDelegate>
{
    CategoryListModel * dataModel;
    
    MJButton * backBtn;
    
    MJButton * searchBtn;
    UIView * searchBtnBG;
    MJButton * profileBtn;
    UIScrollView * scrollBG;
    SZColumnBar * columnbar;
    
    UIViewController * currentVC;
}

@end

@implementation SZ5GVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self requestCategoryData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden=YES;
    
    [currentVC beginAppearanceTransition:YES animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden=NO;
    
    [currentVC beginAppearanceTransition:NO animated:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [currentVC endAppearanceTransition];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [currentVC endAppearanceTransition];
}

-(void)installSubviews
{
    self.view.backgroundColor=[UIColor whiteColor];
    
    //ScrollBG
    CGFloat scrollWidth = SCREEN_WIDTH;
    scrollBG = [[UIScrollView alloc]init];
    scrollBG.backgroundColor=[UIColor whiteColor];
    if (@available(iOS 11.0, *))
    {
        scrollBG.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    scrollBG.contentSize=CGSizeMake(scrollWidth*dataModel.dataArr.count, 0);
    scrollBG.pagingEnabled=YES;
    scrollBG.bounces=NO;
    scrollBG.showsHorizontalScrollIndicator=NO;
    [self.view addSubview:scrollBG];
    [scrollBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(scrollWidth);
        make.height.mas_equalTo(self.view);
    }];
    
    
    //创建SubControllers
    NSMutableArray * titles = [NSMutableArray array];
    for (int i = 0; i<dataModel.dataArr.count; i++)
    {
        UIViewController * targetvc = nil;
        CategoryModel * cateM  = dataModel.dataArr[i];
        [titles addObject:cateM.name];
        
        
        if ([cateM.code isEqualToString:LIVE_5G_CATEGORY_CODE])
        {
            SZ5GLiveVC * vc = [[SZ5GLiveVC alloc]init];
            vc.categoryCode = cateM.code;
            targetvc = vc;
            
        }
        else if ([cateM.code isEqualToString:VIDEO_5G_CATEGORY_CODE])
        {
            SZ5GVideoListVC * vc = [[SZ5GVideoListVC alloc]init];
            vc.categoryCode = cateM.code;
            vc.contentId=self.contentId;
            targetvc = vc;
        }
        else
        {
            SZ5GWebVC * vc = [[SZ5GWebVC alloc]init];
            vc.url = cateM.jumpUrl;
            vc.webtitle = cateM.name;
            vc.categoryCode = cateM.code;
            targetvc = vc;
        }
        
        [self addChildViewController:targetvc];
        [scrollBG addSubview:targetvc.view];
        [targetvc.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(i * scrollWidth);
            make.height.mas_equalTo(scrollBG);
            make.width.mas_equalTo(scrollBG.mas_width);
            make.top.mas_equalTo(0);
        }];
        
    }
    
    //返回
    backBtn = [[MJButton alloc]init];
    backBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_naviback_black"];
    backBtn.mj_imageObject_sel = [UIImage getBundleImage:@"sz_naviback"];
    [backBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(STATUS_BAR_HEIGHT-7.5);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    
    //搜索按钮bg
    searchBtnBG = [[UIView alloc]init];
    searchBtnBG.layer.cornerRadius=15;
    searchBtnBG.layer.masksToBounds=YES;
    searchBtnBG.layer.backgroundColor=HW_GRAY_BG_White.CGColor;
    [self.view addSubview:searchBtnBG];
    [searchBtnBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backBtn.mas_right).offset(10);
        make.centerY.mas_equalTo(backBtn.mas_centerY);
        make.right.mas_equalTo(-57);
        make.height.mas_equalTo(30);
    }];
    
    //搜索
    searchBtn = [[MJButton alloc]init];
    searchBtn.mj_bgColor=HW_CLEAR;
    searchBtn.mj_bgColor_sel=HW_CLEAR;
    searchBtn.mj_imageObjec=[UIImage getBundleImage:@"sz_5G_search_black"];
    searchBtn.mj_text=@"搜索";
    searchBtn.mj_textColor=HW_GRAY_BG_6;
    searchBtn.mj_imageObject_sel=[UIImage getBundleImage:@"sz_5G_search"];
    searchBtn.mj_textColor_sel = HW_WHITE;
    searchBtn.imageFrame = CGRectMake(9, 6.5, 17, 17);
    searchBtn.titleFrame = CGRectMake(32, 6.5, 100, 17);
    searchBtn.mj_font=FONT(13);
    [searchBtn addTarget:self action:@selector(searchBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backBtn.mas_right).offset(10);
        make.centerY.mas_equalTo(backBtn.mas_centerY);
        make.right.mas_equalTo(-57);
        make.height.mas_equalTo(30);
    }];
    
    //个人中心
    profileBtn = [[MJButton alloc]init];
    profileBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_5G_profile_black"];
    profileBtn.mj_imageObject_sel = [UIImage getBundleImage:@"sz_5G_profile"];
    [profileBtn addTarget:self action:@selector(profileBtnAction) forControlEvents:UIControlEventTouchUpInside];
    profileBtn.ScaleUpBounce=YES;
    [self.view addSubview:profileBtn];
    [profileBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(searchBtnBG.mas_right).offset(19);
        make.centerY.mas_equalTo(searchBtnBG.mas_centerY);
        make.width.mas_equalTo(17);
        make.height.mas_equalTo(17);
    }];
    
    
    [self.view layoutIfNeeded];
    
    //SZColumnBar
    columnbar = [[SZColumnBar alloc]initWithTitles:titles relateScrollView:scrollBG delegate:self originX:25 itemMargin:12  txtColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] selTxtColor:HW_BLACK lineColor:HW_CLEAR initialIndex:self.initialIndex];
    [self.view addSubview:columnbar];
    [columnbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(searchBtnBG.mas_bottom).offset(5);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(COLUMNBAR_HEIGHT);
    }];
    [columnbar setBackgroundColor:HW_CLEAR];
    [columnbar setAlignStyle:SZColumnAlignmentSpacebtween];
    [columnbar refreshView];
    
}

#pragma mark - Animation
-(void)columnBarAnimations:(NSInteger)index
{
    if (index==5)
    {
        backBtn.MJSelectState=YES;
        searchBtn.MJSelectState=YES;
        profileBtn.MJSelectState=YES;
        searchBtnBG.layer.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
        [columnbar setTxtColor:[UIColor colorWithWhite:1 alpha:0.5] selectedColor:HW_WHITE lineColor:HW_CLEAR];
        [columnbar setUnderlingImage:@"sz_columnbar_line_white"];
    }
    else
    {
        backBtn.MJSelectState=NO;
        searchBtn.MJSelectState=NO;
        profileBtn.MJSelectState=NO;
        searchBtnBG.layer.backgroundColor=HW_GRAY_BG_White.CGColor;
        [columnbar setTxtColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] selectedColor:HW_BLACK lineColor:HW_CLEAR];
        [columnbar setUnderlingImage:@"sz_columnbar_line"];
    }
}


#pragma mark - Request
-(void)requestCategoryData
{
    NSString * ssid = [[SZManager sharedManager].delegate onGetUserDevice];
    
    CategoryListModel * model = [CategoryListModel model];
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:@"5G.channel.hose" forKey:@"categoryCode"];
    [param setValue:ssid forKey:@"ssid"];
    
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_WANDA_GET_CATEGORY) Params:param Success:^(id responseObject) {
        [weakSelf requestCategoryDone:model];
        
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}


-(void)requestCategoryDone:(CategoryListModel*)model
{
    dataModel = model;
    
    //创建tab
    [self installSubviews];
}





#pragma mark - Btn Actions
-(void)backBtnAction
{
    if([currentVC isKindOfClass:[SZ5GWebVC class]])
    {
        SZ5GWebVC * webvc = (SZ5GWebVC*)currentVC;
        [webvc naviBackAction];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)profileBtnAction
{
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
    NSString * h5ur = APPEND_SUBURL(BASE_H5_URL, @"fuse/news/#/searchPlus");
    [[SZManager sharedManager].delegate onOpenWebview:h5ur param:nil];
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

-(void)mjview:(UIView *)view didSelectColumnIndex:(NSInteger)index
{
    //columnbar动画
    [self columnBarAnimations:index];
    
    //触发didAppear
    UIViewController * newVC = self.childViewControllers[index];
    currentVC =  newVC;
    [newVC endAppearanceTransition];
}

#pragma mark - 手动管理ChildVC生命周期
-(BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

#pragma mark - StatusBar
-(UIStatusBarStyle)preferredStatusBarStyle
{
    if (currentVC)
    {
        return [currentVC preferredStatusBarStyle];
    }
    else
    {
        return UIStatusBarStyleDefault;
    }
    
}
-(BOOL)prefersStatusBarHidden
{
    return [currentVC prefersStatusBarHidden];;
}


@end
