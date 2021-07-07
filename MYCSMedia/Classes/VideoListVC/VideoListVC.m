//
//  VideoListVC.m
//  MYCSMedia-CSAssets
//
//  Created by 马佳 on 2021/6/19.
//

#import "VideoListVC.h"
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
#import "MJLabel.h"
#import "CategoryView.h"
#import "MJProvider.h"
#import "IQDataBinding.h"
#import "NSString+MJCategory.h"

@interface VideoListVC ()

@end

@implementation VideoListVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self MJInitSubviews];
    
    [NSString converUTCDateStr:@""];
    
    
}

#pragma mark - 界面&布局
-(void)MJInitSubviews
{
    self.view.backgroundColor=HW_WHITE;
    
    //naviback
    MJButton * btn = [[MJButton alloc]initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, 50, 50)];
    [btn setImage:[UIImage getBundleImage:@"sz_naviback_black"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    //title
    MJLabel * naviTitle=[[MJLabel alloc]init];
    [naviTitle setFrame:CGRectMake(SCREEN_WIDTH/2-50, 0, 100, 22)];
    naviTitle.centerY = btn.centerY;
    naviTitle.text=@"视频";
    naviTitle.textColor=HW_BLACK;
    naviTitle.textAlignment=NSTextAlignmentCenter;
    naviTitle.font=BOLD_FONT(20);
    [self.view addSubview:naviTitle];
    
    //searchBar
    MJButton * searchBtn = [[MJButton alloc]init];
    [searchBtn setFrame:CGRectMake(20, naviTitle.bottom+15, SCREEN_WIDTH-110-20, 34)];
    searchBtn.backgroundColor=HW_GRAY_BG_5;
    searchBtn.layer.cornerRadius=5;
    searchBtn.mj_imageObjec=[UIImage getBundleImage:@"mysearch"];
    searchBtn.mj_text=@"守护解放西12";
    searchBtn.mj_textColor=HW_GRAY_WORD_3;
    searchBtn.mj_font=FONT(13);
    searchBtn.imageFrame=CGRectMake(15, 10.5, 14, 13.5);
    searchBtn.titleFrame=CGRectMake(39, 10, searchBtn.width-55, 14);
    [searchBtn addTarget:self action:@selector(searchBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
    
    //collect
    MJButton * collectBtn = [[MJButton alloc]init];
    [collectBtn setFrame:CGRectMake(searchBtn.right+15, searchBtn.top, 85, searchBtn.height)];
    collectBtn.layer.cornerRadius=6;
    collectBtn.layer.borderWidth=1;
    collectBtn.layer.borderColor=HW_GRAY_BG_5.CGColor;
    collectBtn.mj_imageObjec=[UIImage getBundleImage:@"mycollect"];
    collectBtn.mj_text=@"我的收藏";
    [collectBtn addTarget:self action:@selector(collectBtnAction) forControlEvents:UIControlEventTouchUpInside];
    collectBtn.mj_font=FONT(11);
    collectBtn.mj_textColor=HW_GRAY_WORD_3;
    collectBtn.imageFrame=CGRectMake(11, 10.5, 14, 13);
    collectBtn.titleFrame=CGRectMake(30, 9.5, 55, 15.5);
    [self.view addSubview:collectBtn];
    
    //categoryview
    CategoryView * cateView = [[CategoryView alloc]init];
    [cateView setFrame:CGRectMake(0, searchBtn.bottom+5, SCREEN_WIDTH, SCREEN_HEIGHT-searchBtn.bottom-5)];
    [self.view addSubview:cateView];
    cateView.categoryCode = @"mycs.video";
    [cateView fetchData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden=YES;
    
    //检查登录状态
    [SZManager checkLoginStatus];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden=NO;
}










#pragma mark - Btn Action
-(void)backBtnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)searchBtnAction
{
    [MJHUD_Notice showNoticeView:@"to search page" inView:self.view hideAfterDelay:1];
}
-(void)collectBtnAction
{
    [MJHUD_Notice showNoticeView:@"to collect page" inView:self.view hideAfterDelay:1];
}


@end
