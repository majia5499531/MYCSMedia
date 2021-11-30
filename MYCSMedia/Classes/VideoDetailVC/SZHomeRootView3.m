//
//  SZHomeRootView3.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/19.
//

#import "SZHomeRootView3.h"
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

@interface SZHomeRootView3 ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation SZHomeRootView3
{
    NSString * panelCode;
    ContentListModel * dataModel;
    UITableView * tableview;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor=[UIColor blackColor];
        
        panelCode = @"mycs.live.livelist";
        
        [self initSubviews];
    }
    return self;
}


-(void)viewWillAppear
{
    [MJVideoManager destroyVideoPlayer];
    
    [[SZData sharedSZData]setCurrentContentId:@""];
    
    if (dataModel.dataArr.count==0)
    {
        [self requestContentList];
    }
}




#pragma mark - Subview
-(void)initSubviews
{

    tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height) style:UITableViewStyleGrouped];
    tableview.dataSource=self;
    [tableview setNoContentInset];
    tableview.backgroundColor=HW_CLEAR;
    tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
    tableview.delegate=self;
    tableview.mj_header = [CustomAnimatedHeader headerWithRefreshingTarget:self refreshingAction:@selector(pulldownRefreshAction:)];
    tableview.mj_footer = [CustomFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullupLoadAction:)];
    [self addSubview:tableview];
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
    //未登录则跳转登录
    if (![SZGlobalInfo sharedManager].SZRMToken.length)
    {
        [SZGlobalInfo mjshowLoginAlert];
        return;
    }
    
    ContentModel * model = dataModel.dataArr[indexPath.row];
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


#pragma mark - 下拉上拉
-(void)pulldownRefreshAction:(MJRefreshHeader*)header
{
    [self requestContentList];
}
-(void)pullupLoadAction:(MJRefreshFooter*)footer
{
    [self requestMoreContents];
}




#pragma mark - Request
-(void)requestContentList
{

    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:panelCode forKey:@"panelCode"];
    [param setValue:pagesize forKey:@"pageSize"];
    [param setValue:@"0" forKey:@"removeFirst"];
    
    
    ContentListModel * model = [ContentListModel model];
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:self WithUrl:APPEND_SUBURL(BASE_URL, API_URL_VIDEO_LIST) Params:param Success:^(id responseObject){
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
    [param setValue:panelCode forKey:@"panelCode"];
    [param setValue:lastContentId forKey:@"contentId"];
    [param setValue:pagesize forKey:@"pageSize"];
    [param setValue:@"1" forKey:@"removeFirst"];
    
    ContentListModel * model = [ContentListModel model];
    model.hideLoading=YES;
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:self WithUrl:APPEND_SUBURL(BASE_URL, API_URL_VIDEO_LIST) Params:param Success:^(id responseObject){
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
    [tableview.mj_header endRefreshing];
    [tableview.mj_footer endRefreshing];
    
    dataModel = listM;
    
    [tableview reloadData];
}

-(void)requestMoreContentDone:(ContentListModel*)listM
{
    [tableview.mj_header endRefreshing];
    [tableview.mj_footer endRefreshing];
    
    [dataModel.dataArr addObjectsFromArray:listM.dataArr];
    
    [tableview reloadData];
}

-(void)requestFaild
{
    [tableview.mj_header endRefreshing];
    [tableview.mj_footer endRefreshing];
}


@end
