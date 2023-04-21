//
//  SZLiveVC.m
//  MYCSMedia
//
//  Created by 马佳 on 2023/4/8.
//

#import "SZLiveVC.h"
#import "SZDefines.h"
#import "ContentListModel.h"
#import "SZGlobalInfo.h"
#import "UIView+MJCategory.h"
#import "UIScrollView+MJCategory.h"
#import "CustomFooter.h"
#import "CustomAnimatedHeader.h"
#import "SZLiveCell.h"
#import "MJVideoManager.h"
#import "NSString+MJCategory.h"
#import "SZData.h"
#import <MJRefresh/MJRefresh.h>
#import "Masonry.h"

@interface SZLiveVC ()<UITableViewDelegate,UITableViewDataSource>
{
    ContentListModel * dataModel;
    UITableView * tableview;
}
@end

@implementation SZLiveVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubviews];
    
    [self requestContentList];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"childvc_直播_%s",__FUNCTION__);
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"childvc_直播_%s",__FUNCTION__);
    
    
    
    //强制停止播放
    [MJVideoManager destroyVideoPlayer];
    [[SZData sharedSZData]setCurrentContentId:@""];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSLog(@"childvc_直播_%s",__FUNCTION__);
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSLog(@"childvc_直播_%s",__FUNCTION__);
}

-(void)dealloc
{
    NSLog(@"childvc_直播_%s",__FUNCTION__);
    
    [[SZData sharedSZData]setCurrentContentId:@""];
    
    [MJVideoManager destroyVideoPlayer];
}


#pragma mark - Subview
-(void)initSubviews
{
    self.view.backgroundColor=[UIColor blackColor];

    tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
    tableview.dataSource=self;
    [tableview setNoContentInset];
    tableview.backgroundColor=HW_CLEAR;
    tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
    tableview.delegate=self;
    tableview.mj_header = [CustomAnimatedHeader headerWithRefreshingTarget:self refreshingAction:@selector(pulldownRefreshAction:)];
    tableview.mj_footer = [CustomFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullupLoadAction:)];
    [self.view addSubview:tableview];
    [tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(self.view);
    }];
    
}






#pragma mark - Tableview delegate & datasource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellid=@"livelivecell";
    
    SZLiveCell * cell=[tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell)
    {
        cell=[[SZLiveCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    ContentModel * model = dataModel.dataArr[indexPath.row];
    [cell setCellData:model];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataModel.dataArr.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.562 * SCREEN_WIDTH;
    return height+60;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof (self) weakSelf = self;
    ContentModel * model =  dataModel.dataArr[indexPath.row];
    [SZGlobalInfo checkLoginStatus:^(BOOL suc) {
        if (suc)
        {
            [weakSelf routeToLiveWebview:model];
        }
        else
        {
            [SZGlobalInfo mjshowLoginAlert];
        }
    }];
    
}


#pragma mark - 下拉上拉
-(void)pulldownRefreshAction:(MJRefreshHeader*)header
{
    [self requestContentList];
}
-(void)pullupLoadAction:(MJRefreshFooter*)footer
{
    [self requestMoreContents];
}


#pragma mark - Route
-(void)routeToLiveWebview:(ContentModel*)model
{
    NSString * H5URL = model.shareUrl;
    
    
    //附加广电云token
    if ([H5URL containsString:@"guangdianyun"])
    {
        if ([SZGlobalInfo sharedManager].gdyToken.length)
        {
            H5URL = [H5URL appenURLParam:@"token" value:[SZGlobalInfo sharedManager].gdyToken];
        }
        else
        {
            H5URL = [H5URL appenURLParam:@"token" value:@"default"];
        }
    }
    
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:model.shareImageUrl forKey:@"shareImageUrl"];
    [param setValue:model.shareBrief forKey:@"shareBrief"];
    [param setValue:model.shareUrl forKey:@"shareUrl"];
    [param setValue:model.shareTitle forKey:@"shareTitle"];
    
    
    [[SZManager sharedManager].delegate onOpenWebview:H5URL param:param];
}


#pragma mark - Request
-(void)requestContentList
{

    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:LIVE_LIST_PANEL_CODE forKey:@"panelCode"];
    [param setValue:pagesize forKey:@"pageSize"];
    [param setValue:@"0" forKey:@"removeFirst"];
    
    
    ContentListModel * model = [ContentListModel model];
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_URL_VIDEO_LIST) Params:param Success:^(id responseObject){
        [weakSelf requestDone:model];
        } Error:^(id responseObject) {
                [weakSelf requestFaild];
        } Fail:^(NSError *error) {
                [weakSelf requestFaild];
        }];
    
}


-(void)requestMoreContents
{
    //获取最后一条视频的ID
    ContentModel * lastModel = dataModel.dataArr.lastObject;
    NSString * lastContentId =  lastModel.id;
    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:LIVE_LIST_PANEL_CODE forKey:@"panelCode"];
    [param setValue:lastContentId forKey:@"contentId"];
    [param setValue:pagesize forKey:@"pageSize"];
    [param setValue:@"1" forKey:@"removeFirst"];
    
    ContentListModel * model = [ContentListModel model];
    model.hideLoading=YES;
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_URL_VIDEO_LIST) Params:param Success:^(id responseObject){
        [weakSelf requestMoreContentDone:model];
        } Error:^(id responseObject) {
            [weakSelf requestFaild];
        } Fail:^(NSError *error) {
            [weakSelf requestFaild];
        }];
}

#pragma mark - Request Done
-(void)requestDone:(ContentListModel*)listM
{
    dataModel = listM;
    [tableview reloadData];
    
    [tableview.mj_header endRefreshing];
    [tableview.mj_footer endRefreshing];
}

-(void)requestMoreContentDone:(ContentListModel*)listM
{
    [dataModel.dataArr addObjectsFromArray:listM.dataArr];
    
    [tableview reloadData];
    
    [tableview.mj_header endRefreshing];
    [tableview.mj_footer endRefreshing];
}

-(void)requestFaild
{
    [tableview.mj_header endRefreshing];
    [tableview.mj_footer endRefreshing];
}

#pragma mark - StatusBar
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(BOOL)prefersStatusBarHidden
{
    return NO;
}



@end
