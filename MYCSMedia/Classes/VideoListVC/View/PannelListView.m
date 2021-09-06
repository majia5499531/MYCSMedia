//
//  PannelListView.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/22.
//

#import "PannelListView.h"
#import "UIColor+MJCategory.h"
#import "IQDataBinding.h"
#import "SZGlobalInfo.h"
#import "SZDefines.h"
#import "UIView+MJCategory.h"
#import "SZColumnBar.h"
#import "PannelListView.h"
#import "PanelModel.h"
#import "PanelConfigModel.h"
#import "UIScrollView+MJCategory.h"
#import <Masonry/Masonry.h>
#import "MJButton.h"
#import "ContentPanelManager.h"
#import "VideoPanelCell.h"
#import "MJProvider.h"
#import <MJRefresh/MJRefresh.h>
#import "CustomFooter.h"
#import "CustomAnimatedHeader.h"
#import "ContentListModel.h"
#import "ContentModel.h"

@interface PannelListView ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    UICollectionView * collectionView;
}
@end

@implementation PannelListView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self installSubviews];
    }
    return self;
}

-(void)fetchData
{
    [self requestPanelList];
}


#pragma mark - View
-(void)installSubviews
{

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.estimatedItemSize = CGSizeMake(SCREEN_WIDTH, 55);
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.width,self.height) collectionViewLayout:flowLayout];
    [collectionView setNoContentInset];
    [ContentPanelManager regeisterPanelCell:collectionView];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor=HW_GRAY_BG_White;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.mj_header = [CustomAnimatedHeader headerWithRefreshingTarget:self refreshingAction:@selector(pulldownRefreshAction:)];
    collectionView.mj_footer = [CustomFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullupLoadAction:)];
    [self addSubview:collectionView];
    
}




#pragma mark - Pulldown & Pullup
-(void)pulldownRefreshAction:(MJRefreshHeader*)refreshHeader
{
    //重新请求栏目数据
    [self requestPanelList];
}


-(void)pullupLoadAction:(MJRefreshFooter*)footer
{
    //最后一个面板，必须是列表面板，才能加载更多
    if (self.subcateModel.dataArr.lastObject)
    {
        PanelModel * panel = self.subcateModel.dataArr.lastObject;
        if (panel.dataArr.count>0 && [panel.typeCode isEqualToString:@"core.list.content"])
        {
            ContentModel * model = panel.dataArr.lastObject;
            [self requestMoreContent:panel.id lastContentId:model.id];
        }
    }
    else
    {
        [footer endRefreshing];
    }
    
}



#pragma mark - CollectionView Datasource & Delegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PanelModel * panelModel = self.subcateModel.dataArr[indexPath.section];
    return [ContentPanelManager dequeueCellFrom:collectionView indexPath:indexPath PanelModel:panelModel];
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        PanelModel * panelModel = self.subcateModel.dataArr[indexPath.section];
        UICollectionReusableView * header = [ContentPanelManager dequeueHeaderFrom:collectionView indexPath:indexPath panelModel:panelModel];
        return header;
    }
    else
    {
        return nil;
    }
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.subcateModel.dataArr.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    PanelModel * panel = self.subcateModel.dataArr[section];
    return [ContentPanelManager getRowCountFromPanel:panel];
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section>0)
    {
        return UIEdgeInsetsMake(12, 0, 0, 0);
    }
    else
    {
        return UIEdgeInsetsZero;
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    PanelModel * panelModel = self.subcateModel.dataArr[section];
    return [ContentPanelManager getHeaderViewSize:panelModel];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}



#pragma mark - Request
-(void)requestPanelList
{
    CategoryModel * model = [CategoryModel model];
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:_subcateCode forKey:@"categoryCode"];
    
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:self.superview WithUrl:APPEND_SUBURL(BASE_URL, API_URL_QUERYCATEGORY) Params:param Success:^(id responseObject) {
            [weakSelf requestPanelListDone:model];
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];
}

-(void)requestMoreContent:(NSString*)panelId lastContentId:(NSString*)contentId
{
    NSString * pagesize = [NSString stringWithFormat:@"%d",VIDEO_PAGE_SIZE];
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:panelId forKey:@"panelId"];
    [param setValue:pagesize forKey:@"pageSize"];
    [param setValue:@"1" forKey:@"removeFirst"];
    [param setValue:contentId forKey:@"contentId"];
    
    ContentListModel * model = [ContentListModel model];
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:self WithUrl:APPEND_SUBURL(BASE_URL, API_URL_VIDEO_LIST) Params:param Success:^(id responseObject){
        [weakSelf requestMoreContentDone:model];
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];
}



#pragma mark - Request Done
-(void)requestPanelListDone:(CategoryModel*)subcateM
{
    [collectionView.mj_header endRefreshing];
    
    self.subcateModel = subcateM;
    
    [collectionView reloadData];
}

-(void)requestFailed
{
    [collectionView.mj_header endRefreshing];
    [collectionView.mj_footer endRefreshing];
}

-(void)requestMoreContentDone:(ContentListModel*)model
{
    [collectionView.mj_footer endRefreshing];
    
    PanelModel * lastPanel = self.subcateModel.dataArr.lastObject;
    [lastPanel.dataArr addObjectsFromArray:model.dataArr];
    [collectionView reloadData];
}



@end

