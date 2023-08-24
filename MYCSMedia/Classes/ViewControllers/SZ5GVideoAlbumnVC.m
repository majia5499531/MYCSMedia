//
//  SZ5GVideoAlbumnVC.m
//  MYCSMedia
//
//  Created by 马佳 on 2023/4/11.
//

#import "SZ5GVideoAlbumnVC.h"
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
#import "UIIMage+MJcategory.h"
#import "UIColor+MJCategory.h"
#import "ContentCollectionModel.h"
#import "VideoCollectModel.h"
#import "MJVideoManager.h"
#import "SuperPlayer.h"
#import "MJHUD.h"
#import "SZUserTracker.h"

#define test_pagesize @"10"


@interface SZ5GVideoAlbumnVC ()
{
    ContentCollectionModel * dataModel;
    
    NSMutableArray * videoAlbumnList;
    NSMutableArray * videoSpecialList;
    NSMutableArray * btnArr;
    
    ContentModel * currentContent;
    NSInteger currentIdx;
    
    BOOL MJHideStatusbar;
    NSInteger page;
    UIImageView * videoBG;
    UIScrollView * scrollbg;
    UILabel * albumnTitle;
    UILabel * descLabel;
    UIView * bottomSection;
    UILabel * totalCount;
    UILabel * iconlabel;
}
@end

@implementation SZ5GVideoAlbumnVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initdata];
    
    [self installSubview];
    
    [self addNotifications];
    
    [self requestVideoAlbum];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden=YES;
    
    //检查登录状态
    [SZGlobalInfo checkRMLoginStatus:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden=NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [MJVideoManager pauseWindowVideo];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)dealloc
{
    [self removeNotifications];
    
}


#pragma mark - Add Notoify
-(void)addNotifications
{
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

#pragma mark - Notification CallBack
-(void)videoViewDidEnterFullSreen:(NSNotification*)notify
{
    NSNumber * needHidden = notify.object;
    
    MJHideStatusbar = needHidden.boolValue;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)onDeviceOrientationChange:(NSNotification*)notify
{
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


#pragma mark - init data
-(void)initdata
{
    videoAlbumnList = [NSMutableArray array];
    videoSpecialList = [NSMutableArray array];
    btnArr = [NSMutableArray array];
}

#pragma mark - Subview

-(void)installSubview
{
    self.view.backgroundColor=[UIColor whiteColor];
    
    //naviback
    MJButton * btn = [[MJButton alloc]initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, 50, 50)];
    [btn setImage:[UIImage getBundleImage:@"sz_naviback_black"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    //标题
    UILabel * title=[[UILabel alloc]init];
    [title setFrame:CGRectMake(SCREEN_WIDTH/2-100, STATUS_BAR_HEIGHT, 200, NAVIBAR_HEIGHT)];
    title.text=@"视频详情";
    title.textColor=HW_BLACK;
    title.textAlignment=NSTextAlignmentCenter;
    title.font=[UIFont systemFontOfSize:18 weight:600];
    [self.view addSubview:title];
    
    //菜单按钮
    MJButton * share =[[MJButton alloc]init];
    [share setFrame:CGRectMake(SCREEN_WIDTH-40, STATUS_BAR_HEIGHT, 40, 44)];
    share.imageFrame=CGRectMake(0, 23, 20, 4);
    share.mj_imageObjec = [UIImage getBundleImage:@"sz_5G_navi_share"];
    [share addTarget:self action:@selector(menuBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:share];
    
    //视频bg
    videoBG = [[UIImageView alloc]initWithFrame:CGRectMake(0, NAVI_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH*0.562)];
    videoBG.backgroundColor=[UIColor blackColor];
    videoBG.userInteractionEnabled=YES;
    [self.view addSubview:videoBG];
    
    //scollbg
    scrollbg = [[UIScrollView alloc]init];
    scrollbg.backgroundColor=HW_GRAY_F7;
    [self.view addSubview:scrollbg];
    [scrollbg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(videoBG.mas_bottom);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
    
    //标题
    albumnTitle=[[UILabel alloc]init];
    albumnTitle.textColor=HW_BLACK;
    albumnTitle.font=FONT_WEIGHT(20, 600);
    [scrollbg addSubview:albumnTitle];
    [albumnTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(18);
        make.width.mas_equalTo(SCREEN_WIDTH-30);
    }];
    
    //简介
    descLabel=[[UILabel alloc]init];
    descLabel.textColor=HW_GRAY_BG_8;
    descLabel.numberOfLines=0;
    descLabel.font=FONT(14);
    [scrollbg addSubview:descLabel];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(albumnTitle.mas_left);
        make.right.mas_equalTo(albumnTitle.mas_right);
        make.top.mas_equalTo(albumnTitle.mas_bottom).offset(10);
        
    }];
    
    //上bg
    UIView * topsection = [[UIView alloc]init];
    topsection.backgroundColor=HW_WHITE;
    [scrollbg insertSubview:topsection belowSubview:albumnTitle];
    [topsection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.bottom.mas_equalTo(descLabel.mas_bottom).offset(5);
    }];
    
   
    //上半圆角
    UIView * cornerview1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 16)];
    cornerview1.backgroundColor=HW_WHITE;
    [scrollbg addSubview:cornerview1];
    [cornerview1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(topsection.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(16);
    }];
    [cornerview1 MJSetPartRadius:12 RoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight];
    
    //下半圆角
    UIView * cornerview2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 16)];
    cornerview2.backgroundColor=HW_WHITE;
    [scrollbg addSubview:cornerview2];
    [cornerview2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(cornerview1.mas_bottom).offset(12);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(16);
    }];
    [cornerview2 MJSetPartRadius:12 RoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight];
    
    //选集icon
    UIView * icon = [[UIView alloc]init];
    icon.backgroundColor=HW_RED_WORD_1;
    icon.layer.cornerRadius=2.5;
    [scrollbg addSubview:icon];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(cornerview2.mas_top).offset(26);
        make.width.mas_equalTo(5);
        make.height.mas_equalTo(15);
    }];
    
    //选集label
    iconlabel=[[UILabel alloc]init];
    iconlabel.textColor=HW_BLACK;
    iconlabel.font=FONT_WEIGHT(16, 600);
    [scrollbg addSubview:iconlabel];
    [iconlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(icon.mas_right).offset(8);
        make.centerY.mas_equalTo(icon);
    }];
    
    
    
    //总集数
    totalCount=[[UILabel alloc]init];
    totalCount.textColor=HW_BLACK;
    totalCount.font=FONT(16);
    [scrollbg addSubview:totalCount];
    [totalCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(albumnTitle.mas_right);
        make.centerY.mas_equalTo(icon);
    }];
    
    //底部
    bottomSection = [[UIView alloc]init];
    bottomSection.backgroundColor=HW_WHITE;
    [scrollbg insertSubview:bottomSection belowSubview:icon];
    [bottomSection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.top.mas_equalTo(cornerview2.mas_bottom);
        make.height.mas_equalTo(100);
        make.bottom.mas_equalTo(-10);
    }];
    
}


//视频专题新闻
-(void)installSpecial_Videoview
{
    ContentModel * specialtabM = dataModel.dataArr[0];
    iconlabel.text = specialtabM.title;
    albumnTitle.text = dataModel.collectionModel.title;
    descLabel.text = dataModel.collectionModel.brief;
    
    //清除所有
    [bottomSection MJRemoveAllSubviews];
    
    [btnArr removeAllObjects];
    
    CGFloat originX = 15;
    CGFloat originY = 60;
    CGFloat interX = 11;
    CGFloat btnw = (SCREEN_WIDTH-(originX*2) - (interX*1))/2;
    CGFloat btnH = 44;
    for (int i= 0; i<videoSpecialList.count; i++)
    {
        ContentModel * itemcontent = videoSpecialList[i];
        
        MJButton * btn = [[MJButton alloc]init];
        btn.mj_text = [NSString stringWithFormat:@"%@",itemcontent.title];
        btn.tag=i;
        [btn addTarget:self action:@selector(videoSpecialBtnActions:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor=HW_GRAY_F7;
        btn.layer.cornerRadius=4;
        btn.mj_textColor=HW_BLACK;
        btn.mj_textColor_sel=HW_RED_WORD_1;
        btn.mj_font=FONT(14);
        [bottomSection addSubview:btn];
        
        [btnArr addObject:btn];
        
        
        [btn setFrame:CGRectMake(originX + (btnw+interX) * (i%2), originY + (btnH + interX)*(i/2), btnw, btnH)];
    }
    
    MJButton * lastbtn = btnArr.lastObject;
    [bottomSection mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(lastbtn.bottom+20);
    }];
    
}

//视频合集
-(void)installVideoAlbumview
{
    albumnTitle.text = dataModel.collectionModel.title;
    descLabel.text = dataModel.collectionModel.brief;
    totalCount.text = [NSString stringWithFormat:@"共%ld集",videoAlbumnList.count];
    iconlabel.text = @"选集";
    
    if (btnArr==nil)
    {
        btnArr = [NSMutableArray array];
    }
    [btnArr removeAllObjects];
    
    
    CGFloat originX = 15;
    CGFloat originY = 60;
    CGFloat interX = 11;
    CGFloat btnw = (SCREEN_WIDTH-(originX*2) - (interX*4))/5;
    for (int i= 0; i<videoAlbumnList.count; i++)
    {
        MJButton * btn = [[MJButton alloc]init];
        btn.mj_text = [NSString stringWithFormat:@"%d",i+1];
        btn.tag=i;
        [btn addTarget:self action:@selector(videoAlbumnBtnActions:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor=HW_GRAY_F7;
        btn.layer.cornerRadius=4;
        btn.mj_textColor=HW_BLACK;
        btn.mj_textColor_sel=HW_RED_WORD_1;
        btn.mj_font=FONT(15);
        [bottomSection addSubview:btn];
        
        [btnArr addObject:btn];
        
        
        [btn setFrame:CGRectMake(originX + (btnw+interX) * (i%5), originY + (btnw + interX)*(i/5), btnw, btnw)];
    }
    
    MJButton * lastbtn = btnArr.lastObject;
    [bottomSection mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(lastbtn.bottom+20);
    }];
}




#pragma mark - 下拉/上拉
-(void)pulldownRefreshAction:(MJRefreshHeader*)refreshHeader
{
    [self requestVideoSpecialList];
}

-(void)pullupLoadAction:(MJRefreshFooter*)footer
{
    [self requestMoreVideoSpecialList];
}






#pragma mark - Request
-(void)requestVideoAlbum
{
    ContentCollectionModel * model = [ContentCollectionModel model];
    
    NSString * url = APPEND_SUBURL(BASE_URL, API_URL_VIDEO_COLLECTION);
    url = APPEND_SUBURL(url, self.contentId);
    
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:self.view WithUrl:url Params:nil Success:^(id responseObject) {
        [weakSelf requestVideoAlbumnDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}

-(void)requestVideoSpecialList
{
    if (dataModel.dataArr.count==0)
    {
        return;
    }
    
    page = 1;
    
    ContentModel * specialTab = dataModel.dataArr[0];
    NSString * specialId = specialTab.id;
    
    NSString * url = APPEND_SUBURL(BASE_URL, API_URL_VIDEOCOLLECT);
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:specialId forKey:@"classId"];
    [param setValue:test_pagesize forKey:@"pageSize"];
    [param setValue:[NSNumber numberWithInteger:page] forKey:@"pageIndex"];
    
    __weak typeof (self) weakSelf = self;
    VideoCollectModel * model = [VideoCollectModel model];
    [model GETRequestInView:self.view WithUrl:url Params:param Success:^(id responseObject) {
        [weakSelf requestVideoSepcialListDone:model.dataArr];
        
        } Error:^(id responseObject) {
            [weakSelf requestFail];
        } Fail:^(NSError *error) {
            [weakSelf requestFail];
        }];
}

-(void)requestMoreVideoSpecialList
{
    page = page+1;
    
    ContentModel * specialTab = dataModel.dataArr[0];
    NSString * specialId = specialTab.id;
    
    NSString * url = APPEND_SUBURL(BASE_URL, API_URL_VIDEOCOLLECT);
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:specialId forKey:@"classId"];
    [param setValue:test_pagesize forKey:@"pageSize"];
    [param setValue:[NSNumber numberWithInteger:page] forKey:@"pageIndex"];
    
    __weak typeof (self) weakSelf = self;
    VideoCollectModel * model = [VideoCollectModel model];
    [model GETRequestInView:self.view WithUrl:url Params:param Success:^(id responseObject) {
            [weakSelf requestMoreVideoSpecialListDone:model.dataArr];
        } Error:^(id responseObject) {
            [weakSelf requestFail];
        } Fail:^(NSError *error) {
            [weakSelf requestFail];
        }];
}


#pragma mark - Request Done
-(void)requestVideoAlbumnDone:(ContentCollectionModel*)model
{
    dataModel = model;
    
    //埋点
    NSMutableDictionary * trackparam=[NSMutableDictionary dictionary];
    [trackparam setValue:dataModel.collectionModel.id forKey:@"contentId"];
    [trackparam setValue:dataModel.collectionModel.title forKey:@"contentName"];
    [SZUserTracker trackingButtonEventName:@"5GChannel_Subpage_view" param:trackparam];
    
    //电视剧
    if ([dataModel.collectionModel.type isEqualToString:@"video_com"])
    {
        videoAlbumnList = model.dataArr;
        
        [self installVideoAlbumview];
        
        if(videoAlbumnList.count > 0)
        {
            [self videoAlbumnBtnActions:btnArr[0]];
        }
        
    }
    
    
    //视频合集
    else
    {
        scrollbg.mj_header = [CustomAnimatedHeader headerWithRefreshingTarget:self refreshingAction:@selector(pulldownRefreshAction:)];
        scrollbg.mj_footer = [CustomFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullupLoadAction:)];
        
        [self requestVideoSpecialList];
        
        
    }
    
}

//查询视频专题列表
-(void)requestVideoSepcialListDone:(NSArray*)listarr
{
    [videoSpecialList removeAllObjects];
    [videoSpecialList addObjectsFromArray:listarr];
    
    [self installSpecial_Videoview];
    
    [scrollbg.mj_header endRefreshing];
    
    [self videoSpecialBtnActions:btnArr[0]];
}

//查询更多视频专题列表
-(void)requestMoreVideoSpecialListDone:(NSArray*)listarr
{
    [videoSpecialList addObjectsFromArray:listarr];
    
    [self installSpecial_Videoview];
    
    [scrollbg.mj_footer endRefreshing];
    
    [self videoSpecialBtnActions:btnArr[currentIdx]];
}

//请求失败
-(void)requestFail
{
    [scrollbg.mj_header endRefreshing];
    [scrollbg.mj_footer endRefreshing];
}


#pragma mark - BtnAction
-(void)backBtnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)menuBtnAction
{
    [MJHUD_Selection showWhiteShareView:^(id objc) {
        NSNumber * number = objc;
        SZ_SHARE_PLATFORM plat = number.integerValue;
        [SZGlobalInfo mjshareToPlatform:plat content:self->currentContent source:@"底部分享"];
    }];
}

-(void)videoAlbumnBtnActions:(MJButton*)sender
{
    ContentModel * content = videoAlbumnList[sender.tag];
    currentContent = content;
    currentIdx = sender.tag;
    
    for (MJButton * btn in btnArr)
    {
        btn.MJSelectState=NO;
    }
    sender.MJSelectState=YES;
    
    [self playVideo];
}


-(void)videoSpecialBtnActions:(MJButton*)sender
{
    ContentModel * content = videoSpecialList[sender.tag];
    currentContent = content;
    currentIdx = sender.tag;
    
    for (MJButton * btn in btnArr)
    {
        btn.MJSelectState=NO;
    }
    sender.MJSelectState=YES;
    
    [self playVideo];
}


#pragma mark - StatusBar
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
-(BOOL)prefersStatusBarHidden
{
    return MJHideStatusbar;
}


#pragma mark - Play
-(void)playVideo
{
    //埋点
    NSMutableDictionary * trackparam=[NSMutableDictionary dictionary];
    [trackparam setValue:currentContent.id forKey:@"contentId"];
    [trackparam setValue:currentContent.title forKey:@"content_name"];
    [trackparam setValue:@"5G频道" forKey:@"module_source"];
    [trackparam setValue:currentContent.keywords forKey:@"content_key"];
    [trackparam setValue:currentContent.source forKey:@"content_source"];
    [trackparam setValue:currentContent.thirdPartyId forKey:@"third_ID"];
    [trackparam setValue:currentContent.tags forKey:@"content_list"];
    [trackparam setValue:currentContent.classification forKey:@"content_classify"];
    [trackparam setValue:@"video_com" forKey:@"content_type"];
    [trackparam setValue:currentContent.createTime forKey:@"create_time"];
    [trackparam setValue:currentContent.issueTimeStamp forKey:@"publish_time"];
    [SZUserTracker trackingButtonEventName:@"5GChannel_Content_click" param:trackparam];
    
    [[SZData sharedSZData].contentDic setValue:currentContent forKey:currentContent.id];
    [[SZData sharedSZData]setCurrentContentId:currentContent.id];
    
    [MJVideoManager playWindowVideoAtView:videoBG url:currentContent.playUrl contentModel:currentContent renderModel:MJRENDER_MODE_FILL_EDGE controlMode:MJCONTROL_STYLE_NORMAL];
    ;
}

@end
