//
//  SZ5GLiveVC.m
//  MYCSMedia
//
//  Created by 马佳 on 2023/4/4.
//

#import "SZ5GLiveVC.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "SZ5GLiveVC.h"
#import "Masonry.h"
#import "MJButton.h"
#import "UIImage+MJCategory.h"
#import "UIView+MJCategory.h"
#import "UIScrollView+MJCategory.h"
#import "ContentModel.h"
#import "ContentListModel.h"
#import "SZGlobalInfo.h"
#import "CustomFooter.h"
#import "CustomAnimatedHeader.h"
#import "MJRefresh.h"
#import "SZ5GLiveCell.h"
#import "NSString+MJCategory.h"
#import "PanelModel.h"
#import "CategoryModel.h"
#import "SDWebImage.h"
#import "SZUserTracker.h"

@interface SZ5GLiveVC ()<UITableViewDelegate,UITableViewDataSource>
{
    CategoryModel * cateModel;
    ContentListModel * liveListModel;
    UITableView * tableview;
}
@end

@implementation SZ5GLiveVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self installSubviews];
    
    [self requestPanelsInCategory];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //检查登录状态
    [SZGlobalInfo checkRMLoginStatus:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
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
-(void)installSubviews
{
    self.view.backgroundColor=HW_GRAY_BG_White;
    
    //顶部BG
    UIView * topsection = [[UIView alloc]init];
    topsection.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:topsection];
    [topsection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(STATUS_BAR_HEIGHT+78);
    }];
    
    //bg
    UIImageView * imgbg = [[UIImageView alloc]init];
    imgbg.image = [UIImage getBundleImage:@"sz_5g_live_bg"];
    [self.view addSubview:imgbg];
    [imgbg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
    
    //直播列表
    tableview=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
    tableview.dataSource=self;
    [tableview setNoContentInset];
    tableview.backgroundColor=HW_CLEAR;
    tableview.mj_header = [CustomAnimatedHeader headerWithRefreshingTarget:self refreshingAction:@selector(pulldownRefreshAction:)];
    tableview.mj_footer = [CustomFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullupLoadAction:)];
    tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
    tableview.delegate=self;
    [self.view addSubview:tableview];
    [tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(topsection.mas_bottom);
    }];
    
}

-(UIView*)createHeaderview
{
    UIView * header = [[UIView alloc]init];
    
    if (cateModel.dataArr.count==0)
    {
        return header;
    }
    
    PanelModel * tvPanel = cateModel.dataArr[0];
    PanelModel * audioPanel = cateModel.dataArr[1];
    PanelModel * livePanel = cateModel.dataArr[2];
    
    CGFloat sectionY = 17;
    //如果有tv数据
    if(tvPanel.dataArr.count)
    {
        UIView * tvIcon = [[UIView alloc]init];
        tvIcon.layer.cornerRadius=2.5;
        tvIcon.layer.backgroundColor=HW_RED_WORD_1.CGColor;
        [header addSubview:tvIcon];
        [tvIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.top.mas_equalTo(sectionY);
            make.width.mas_equalTo(5);
            make.height.mas_equalTo(15);
        }];
        
        sectionY = 139;
        
        UILabel * tvlabel=[[UILabel alloc]init];
        tvlabel.text=tvPanel.name;
        tvlabel.textColor=HW_BLACK;
        tvlabel.font=[UIFont systemFontOfSize:16 weight:600];
        [header addSubview:tvlabel];
        [tvlabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(tvIcon.mas_right).offset(8);
            make.centerY.mas_equalTo(tvIcon);
        }];
        
        
        CGFloat btnw = (SCREEN_WIDTH-(12*5))/4;
        CGFloat btnH = btnw * 0.78;
        CGFloat dataCount = tvPanel.dataArr.count;
        if(dataCount>4)
        {
            dataCount = 4;
        }
        
        for (int i = 0; i<dataCount; i++)
        {
            ContentModel * model = tvPanel.dataArr[i];
            MJButton * tvbtn = [[MJButton alloc]init];
            tvbtn.tag=i;
            [tvbtn addTarget:self action:@selector(tvBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [tvbtn sd_setImageWithURL:[NSURL URLWithString:model.thumbnailUrl] forState:UIControlStateNormal];
            [header addSubview:tvbtn];
            [tvbtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(12 + i*(btnw + 12));
                make.top.mas_equalTo(tvIcon.mas_bottom).offset(14);
                make.width.mas_equalTo(btnw);
                make.height.mas_equalTo(btnH);
            }];
        }
        
        
    }
    
    
    
    //如果有电台数据
    if(audioPanel.dataArr.count)
    {
        UIView * audioIcon = [[UIView alloc]init];
        audioIcon.layer.cornerRadius=2.5;
        audioIcon.layer.backgroundColor=HW_RED_WORD_1.CGColor;
        [header addSubview:audioIcon];
        [audioIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.top.mas_equalTo(sectionY);
            make.width.mas_equalTo(5);
            make.height.mas_equalTo(15);
        }];
        
        
        if(tvPanel.dataArr.count)
        {
            sectionY = 287;
        }
        else
        {
            sectionY = 160;
        }
        
        
        UILabel * audiolabel=[[UILabel alloc]init];
        audiolabel.text=audioPanel.name;
        audiolabel.textColor=HW_BLACK;
        audiolabel.font=[UIFont systemFontOfSize:16 weight:600];
        [header addSubview:audiolabel];
        [audiolabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(audioIcon.mas_right).offset(8);
            make.centerY.mas_equalTo(audioIcon);
        }];
        
        
        CGFloat audioMargin = 27;
        CGFloat audioBtnW = (SCREEN_WIDTH-(audioMargin*5))/4;
        CGFloat audioBtnH = audioBtnW * 1;
        
        CGFloat dataCount = audioPanel.dataArr.count;
        if(dataCount>4)
        {
            dataCount = 4;
        }
        
        for (int i = 0; i<dataCount; i++)
        {
            ContentModel * model = audioPanel.dataArr[i];
            
            MJButton * radiobtn = [[MJButton alloc]init];
            radiobtn.tag=i;
            [radiobtn addTarget:self action:@selector(radioBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [radiobtn sd_setImageWithURL:[NSURL URLWithString:model.thumbnailUrl] forState:UIControlStateNormal];
            
            [header addSubview:radiobtn];
            [radiobtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(audioMargin + i*(audioBtnW + audioMargin));
                make.top.mas_equalTo(audioIcon.mas_bottom).offset(14);
                make.width.mas_equalTo(audioBtnW);
                make.height.mas_equalTo(audioBtnH);
            }];
            
            UILabel * title=[[UILabel alloc]init];
            title.text=model.title;
            title.textColor=HW_BLACK;
            title.font=FONT(13);
            [header addSubview:title];
            [title mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(radiobtn.mas_bottom).offset(9);
                make.centerX.mas_equalTo(radiobtn);
                make.height.mas_equalTo(16);
            }];
        }
    }
    
    
    
    
    
    UIView * liveIcon = [[UIView alloc]init];
    liveIcon.layer.cornerRadius=2.5;
    liveIcon.layer.backgroundColor=HW_RED_WORD_1.CGColor;
    [header addSubview:liveIcon];
    [liveIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.top.mas_equalTo(sectionY);
        make.width.mas_equalTo(5);
        make.height.mas_equalTo(15);
    }];
    
    UILabel * liveLabel=[[UILabel alloc]init];
    liveLabel.text=livePanel.name;
    liveLabel.textColor=HW_BLACK;
    liveLabel.font=[UIFont systemFontOfSize:16 weight:600];
    [header addSubview:liveLabel];
    [liveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(liveIcon.mas_right).offset(8);
        make.centerY.mas_equalTo(liveIcon);
    }];
    
    
    
    [header layoutIfNeeded];
    CGFloat height = [header getBottomY];
    [header setFrame:CGRectMake(0, 0, SCREEN_WIDTH, height+12)];
    
    return header;
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
-(void)requestPanelsInCategory
{
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:@"open" forKey:@"refreshType"];
    [param setValue:@"1" forKey:@"personalRec"];
    [param setValue:self.categoryCode forKey:@"categoryCode"];
    [param setValue:@"10" forKey:@"pageSize"];
    
    __weak typeof (self) weakSelf = self;
    CategoryModel * model = [CategoryModel model];
    [model GETRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_WANDA_GET_TOP_VIDEO) Params:param Success:^(id responseObject) {
        [weakSelf requestPanelDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}



-(void)requestContentList
{
    PanelModel * pannel = cateModel.dataArr[2];
       
    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:pannel.code forKey:@"panelCode"];
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
    PanelModel * pannel = cateModel.dataArr[2];
    //获取最后一条视频的ID
    ContentModel * lastModel = liveListModel.dataArr.lastObject;
    NSString * lastContentId =  lastModel.id;
    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:pannel.code forKey:@"panelCode"];
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
-(void)requestPanelDone:(CategoryModel * )categoryModel
{
    if (categoryModel.dataArr.count==3)
    {
        //电视、电台
        cateModel = categoryModel;
        
        //创建header
        UIView * topblock = [self createHeaderview];
        tableview.tableHeaderView = topblock;
        
        [tableview reloadData];
        
        //请求直播数据
        [self requestContentList];
    }
}

-(void)requestDone:(ContentListModel*)listM
{
    liveListModel = listM;
    [tableview reloadData];
    
    [tableview.mj_header endRefreshing];
    [tableview.mj_footer endRefreshing];
}

-(void)requestMoreContentDone:(ContentListModel*)listM
{
    [liveListModel.dataArr addObjectsFromArray:listM.dataArr];
    
    [tableview reloadData];
    
    [tableview.mj_header endRefreshing];
    [tableview.mj_footer endRefreshing];
}

-(void)requestFaild
{
    [tableview.mj_header endRefreshing];
    [tableview.mj_footer endRefreshing];
}

#pragma mark - Btn Actions
-(void)tvBtnAction:(MJButton*)btn
{
    PanelModel * panelM = cateModel.dataArr[0];
    ContentModel * tvContent = panelM.dataArr[btn.tag];
    [[SZManager sharedManager].delegate onOpenWebview:tvContent.externalUrl param:nil];
    
    //5G埋点
    NSMutableDictionary * trackparam=[NSMutableDictionary dictionary];
    [trackparam setValue:tvContent.id forKey:@"contentId"];
    [trackparam setValue:tvContent.title forKey:@"content_name"];
    [trackparam setValue:@"5G频道" forKey:@"module_source"];
    [SZUserTracker trackingButtonEventName:@"5GChannel_Subpage_click" param:trackparam];
}

-(void)radioBtnAction:(MJButton*)btn
{
    PanelModel * panelM = cateModel.dataArr[1];
    ContentModel * tvContent = panelM.dataArr[btn.tag];
    [[SZManager sharedManager].delegate onOpenWebview:tvContent.externalUrl param:nil];
    
    //5G埋点
    NSMutableDictionary * trackparam=[NSMutableDictionary dictionary];
    [trackparam setValue:tvContent.id forKey:@"contentId"];
    [trackparam setValue:tvContent.title forKey:@"content_name"];
    [trackparam setValue:@"5G频道" forKey:@"module_source"];
    [SZUserTracker trackingButtonEventName:@"5GChannel_Subpage_click" param:trackparam];
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


#pragma mark - Tableview delegate & datasource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellid=@"5glivecell";
    
    SZ5GliveCell * cell=[tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell)
    {
        cell=[[SZ5GliveCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    ContentModel * model = liveListModel.dataArr[indexPath.row];
    [cell setCellData:model];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return liveListModel.dataArr.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SZ5GliveCell * cell=[[SZ5GliveCell alloc]init];
    ContentModel * model = liveListModel.dataArr[indexPath.row];
    [cell setCellData:model];
    return [cell cellHeigh];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    return [self createHeaderview];;
    return nil;
    
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    UIView * head = [self createHeaderview];
//    [head layoutIfNeeded];
//    return head.height;
    return 0.01;;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    __weak typeof (self) weakSelf = self;
    ContentModel * model =  liveListModel.dataArr[indexPath.row];
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
    
    //5G埋点
    NSMutableDictionary * trackparam=[NSMutableDictionary dictionary];
    [trackparam setValue:model.id forKey:@"contentId"];
    [trackparam setValue:model.title forKey:@"content_name"];
    [trackparam setValue:@"5G频道" forKey:@"module_source"];
    [SZUserTracker trackingButtonEventName:@"5GChannel_Subpage_click" param:trackparam];
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
