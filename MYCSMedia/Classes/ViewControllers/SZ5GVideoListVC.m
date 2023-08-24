//
//  SZ5GVideoListVC.m
//  MYCSMedia
//
//  Created by 马佳 on 2023/4/11.
//

#import "SZ5GVideoListVC.h"
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
#import "SZHomeVC.h"
#import "SDWebImage.h"
#import <MJRefresh/MJRefresh.h>
#import "CategoryModel.h"
#import "PanelModel.h"
#import "SZUserTracker.h"


@interface SZ5GVideoListVC ()

@end

@implementation SZ5GVideoListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self requestAdvertiseInfo];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MJVideoManager pauseWindowVideo];
}




#pragma mark - Override
-(void)requestVideoList
{
    //如果没有panelcode，先去查询panelCode
    if(self.panelCode.length)
    {
        [self requestVideoListWithPanelCode];

    }
    else
    {
        [self requestCurrentPanelCode:normal];
    }
    
    
}

-(void)requestMoreVideos
{
    if(self.panelCode.length)
    {
        [self requestMoreVideosWithPanelCode];
    }
    else
    {
        [self requestCurrentPanelCode:YES];
    }
}




#pragma mark - Request
//查询panelCode
-(void)requestCurrentPanelCode:(BOOL)loadmore
{
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:@"open" forKey:@"refreshType"];
    [param setValue:@"1" forKey:@"personalRec"];
    [param setValue:self.categoryCode forKey:@"categoryCode"];
    [param setValue:@"10" forKey:@"pageSize"];
    
    __weak typeof (self) weakSelf = self;
    CategoryModel * model = [CategoryModel model];
    [model GETRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_WANDA_GET_TOP_VIDEO) Params:param Success:^(id responseObject) {
        
        if(model.dataArr.count)
        {
            PanelModel * videopanel = model.dataArr.firstObject;
            self.panelCode = videopanel.code;
        }
        
        
        if(loadmore)
        {
            [weakSelf requestMoreVideosWithPanelCode];
        }
        else
        {
            [weakSelf requestVideoListWithPanelCode];
        }
        
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}

//通过panelCode查数据
-(void)requestVideoListWithPanelCode
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

-(void)requestMoreVideosWithPanelCode
{
    //获取最后一条视频的ID
    ContentModel * lastModel = self.dataModel.dataArr.lastObject;
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


#pragma mark - 查询广告
-(void)requestAdvertiseInfo
{
    PanelModel * model = [PanelModel model];
    model.hideLoading=YES;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:VIDEO_ACTIVITY_CODE forKey:@"panelCode"];
    
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:nil WithUrl:APPEND_SUBURL(BASE_URL, API_URL_PANEL_ACTIVITY) Params:param Success:^(id responseObject) {
        [weakSelf requestAdvertiseInfoDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}


-(void)requestAdvertiseInfoDone:(PanelModel*)model
{
    NSString * img1 = model.config.imageUrl;
    NSString * img2 = model.config.backgroundImageUrl;
    NSString * linkUrl  = model.config.jumpUrl;
    
    if (linkUrl.length)
    {
        [self setActivityImg:img1 simpleImg:img2 linkUrl:linkUrl];
    }
}

@end
