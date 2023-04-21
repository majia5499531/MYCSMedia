//
//  SZ5GWebVC.m
//  MYCSMedia
//
//  Created by 马佳 on 2023/4/4.
//

#import "SZ5GWebVC.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "SZ5GLiveVC.h"
#import "SZ5GWebVC.h"
#import "Masonry.h"
#import "MJButton.h"
#import "UIImage+MJCategory.h"
#import "UIView+MJCategory.h"
#import "SZData.h"
#import "MJVideoManager.h"
#import "CategoryListModel.h"
#import "SZGlobalInfo.h"
#import "CategoryModel.h"
#import <WebKit/WebKit.h>

@interface SZ5GWebVC ()
{
    UIScrollView * scrollbg;
    NSArray * subcategorys;
    NSMutableArray * webviewArr;
    NSMutableArray * tabBtnArr;
}
@end

@implementation SZ5GWebVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    
    //如果是互动栏目则请求接口查询子tab
    if([self.categoryCode isEqualToString:HUDONG_5G_CATEGORY_CODE])
    {
        [self requestCategoryData];
    }
    else
    {
        [self installSubviews];
    }
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //更新statusbar
    [self setNeedsStatusBarAppearanceUpdate];
    
    //强制停止播放
    [MJVideoManager destroyVideoPlayer];
    [[SZData sharedSZData]setCurrentContentId:@""];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

-(void)dealloc
{
    
}




#pragma mark - Subviews
-(void)installMutiWebviews
{
    //顶部BG
    UIView * topsection = [[UIView alloc]init];
    topsection.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:topsection];
    [topsection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(STATUS_BAR_HEIGHT+78);
    }];
    
    
    //segmentBG
    UIView * segmentbg = [[UIView alloc]init];
    segmentbg.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:segmentbg];
    [segmentbg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topsection.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    //segmentBG2
    UIView * segmentBtnbg = [[UIView alloc]init];
    segmentBtnbg.backgroundColor=HW_GRAY_F7;
    segmentBtnbg.layer.cornerRadius=5;
    [segmentbg addSubview:segmentBtnbg];
    [segmentBtnbg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(7);
        make.left.mas_equalTo(12);
        make.right.mas_equalTo(-12);
        make.bottom.mas_equalTo(-7);
    }];
    
    
    [self.view layoutIfNeeded];
    CGFloat marginX = 6;
    CGFloat btnw = (segmentBtnbg.width - 2*marginX - ((subcategorys.count-1)*marginX))/3;
    
    //tab btn
    tabBtnArr = [NSMutableArray array];
    webviewArr = [NSMutableArray array];
    for (int i = 0; i<subcategorys.count; i++)
    {
        CategoryModel * cateModel = subcategorys[i];
        MJButton * btn = [[MJButton alloc]init];
        
        btn.mj_bgColor = HW_CLEAR;
        btn.mj_bgColor_sel = HW_WHITE;
        btn.mj_textColor_sel=HW_BLACK;
        btn.mj_textColor = HW_GRAY_BG_8;
        btn.mj_text = cateModel.name;
        btn.mj_font=FONT(13);
        btn.layer.cornerRadius=4;
        btn.tag=i;
        [btn addTarget:self action:@selector(tabBtnActions:) forControlEvents:UIControlEventTouchUpInside];
        [btn setFrame:CGRectMake(marginX + (btnw + marginX)*i, 3, btnw, 24)];
        [segmentBtnbg addSubview:btn];
        [tabBtnArr addObject:btn];
        
        if(i==0)
        {
            btn.MJSelectState=YES;
        }
        
        
    }
    
    
    //scrollbg
    scrollbg = [[UIScrollView alloc]init];
    scrollbg.backgroundColor=[UIColor greenColor];
    [self.view addSubview:scrollbg];
    [scrollbg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(segmentbg.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.bottom.mas_equalTo(0);
    }];
    
    
    for (int i= 0 ; i<subcategorys.count; i++)
    {
        CategoryModel * cateModel = subcategorys[i];
        //webview
        Class cls = NSClassFromString(@"SMYWebProvide");
        
        if (cls!=nil)
        {
            
            NSString * urlstr = cateModel.jumpUrl;
            id resvc = [cls performSelector:@selector(getWebControllerWithURLStr:) withObject:urlstr];
            if ([resvc isKindOfClass:[UIViewController class]])
            {
                UIViewController * webvc = (UIViewController*)resvc;
                webvc.view.backgroundColor=MJRandomColor;
                [scrollbg addSubview:webvc.view];
                [webvc.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(SCREEN_WIDTH*i);
                    make.top.mas_equalTo(0);
                    make.width.mas_equalTo(SCREEN_WIDTH);
                    make.height.mas_equalTo(scrollbg.mas_height);
                }];


                id webobjc = [resvc performSelector:@selector(webView) withObject:nil];
                UIView * webview = (UIView*)webobjc;
                [webview mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.top.right.bottom.mas_equalTo(0);
                }];

                [self addChildViewController:webvc];
                [webvc didMoveToParentViewController:self];


                [webviewArr addObject: webview];
            }
        }
    }
}



-(void)installSubviews
{
    //顶部BG
    UIView * topsection = [[UIView alloc]init];
    topsection.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:topsection];
    [topsection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(STATUS_BAR_HEIGHT+78);
    }];
    
    
    webviewArr = [NSMutableArray array];
    //webview
    Class cls = NSClassFromString(@"SMYWebProvide");
    if (cls!=nil)
    {
        id resvc = [cls performSelector:@selector(getWebControllerWithURLStr:) withObject:self.url];
        if ([resvc isKindOfClass:[UIViewController class]])
        {
            UIViewController * webvc = (UIViewController*)resvc;
            [self.view addSubview:webvc.view];
            [webvc.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(0);
                make.top.mas_equalTo(topsection.mas_bottom);
            }];
            
            id webobjc = [resvc performSelector:@selector(webView) withObject:nil];
            UIView * webview = (UIView*)webobjc;
            [webview mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.bottom.mas_equalTo(0);
            }];
            
            [self addChildViewController:webvc];
            [webvc didMoveToParentViewController:self];
            
            [webviewArr addObject:webview];
            
        }
    }
}


#pragma mark - Btn Action
-(void)naviBackAction
{
    NSInteger currentPage = scrollbg.contentOffset.x / scrollbg.width;
    
    UIView * commonWebview = webviewArr[currentPage];
    
    if([commonWebview isKindOfClass:[WKWebView class]])
    {
        WKWebView * wkweb = (WKWebView*)commonWebview;
        
        if([wkweb canGoBack])
        {
            [wkweb goBack];
        }
        else
        {
            [self.parentViewController.navigationController popViewControllerAnimated:YES];
        }
    }
    else if ([commonWebview isKindOfClass:[UIWebView class]])
    {
        UIWebView * uiweb = (UIWebView*)commonWebview;
        
        if([uiweb canGoBack])
        {
            [uiweb goBack];
        }
        else
        {
            [self.parentViewController.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        [self.parentViewController.navigationController popViewControllerAnimated:YES];
    }
    
}


-(void)tabBtnActions:(MJButton*)sender
{
    for (MJButton * btn  in tabBtnArr)
    {
        btn.MJSelectState=NO;
    }
    
    sender.MJSelectState = YES;
    
    
    NSInteger page = sender.tag;
    [scrollbg setContentOffset:CGPointMake(SCREEN_WIDTH*page, 0)];
    
}





#pragma mark - Request
-(void)requestCategoryData
{
    NSString * ssid = [[SZManager sharedManager].delegate onGetUserDevice];
    
    CategoryListModel * model = [CategoryListModel model];
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:self.categoryCode forKey:@"categoryCode"];
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
    subcategorys = model.dataArr;
    
    [self installMutiWebviews];
}



#pragma mark - StatusBar
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
-(BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
