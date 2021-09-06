//
//  CategoryView.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/22.
//

#import "CategoryView.h"
#import "UIColor+MJCategory.h"
#import "IQDataBinding.h"
#import "SZManager.h"
#import "SZDefines.h"
#import "UIView+MJCategory.h"
#import "SZColumnBar.h"
#import "PannelListView.h"
#import "CategoryModel.h"
#import "MJProvider.h"
#import "PanelModel.h"
#import "PannelListView.h"
#import "SZGlobalInfo.h"

@interface CategoryView ()<NewsColumnDelegate>

@end

@implementation CategoryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor=[UIColor whiteColor];
    }
    return self;
}

-(void)fetchData
{
    //请求数据
    [self requestPanelList:self.categoryCode];
}

#pragma mark - Request
-(void)requestPanelList:(NSString*)cateCode
{
    CategoryModel * model = [CategoryModel model];
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:cateCode forKey:@"categoryCode"];
    
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:self WithUrl:APPEND_SUBURL(BASE_URL, API_URL_QUERYCATEGORY) Params:param Success:^(id responseObject) {
        
            [weakSelf requestPanelListDone:model];
        
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];

}


-(void)requestPanelListDone:(CategoryModel*)cateModel
{
    if (cateModel.dataArr.count==0)
    {
        return;
    }

    //如果最后一个面板，是类目面板
    PanelModel * panelModel = cateModel.dataArr.lastObject;
    if ([panelModel.typeCode isEqualToString:@"core.category"])
    {
        [self createSubcategoryView:panelModel];
    }

    //没有二级栏目，只有单层，显示列表
    else
    {
        [self createListView];
    }
}

#pragma mark - View
//创建二级类目view
-(void)createSubcategoryView:(PanelModel*)CatePanelModel
{
    //SZColumnBar
    SZColumnBar * cateBar = [[SZColumnBar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    cateBar.columnDelegate=self;
    [self addSubview:cateBar];
    
    //scrollBG
    UIScrollView * scrollBG = [[UIScrollView alloc]initWithFrame:CGRectMake(0, cateBar.bottom+4, SCREEN_WIDTH, self.height-cateBar.bottom-4)];
    scrollBG.backgroundColor=[UIColor lightGrayColor];
    scrollBG.bounces=NO;
    scrollBG.showsHorizontalScrollIndicator=NO;
    scrollBG.pagingEnabled=YES;
    [self addSubview:scrollBG];
    [scrollBG setContentSize:CGSizeMake((CatePanelModel.subCategories.count)*SCREEN_WIDTH, scrollBG.height)];
    
    //创建列表
    CGFloat originX = 0;
    for (int i =0; i<CatePanelModel.subCategories.count; i++)
    {
        CategoryModel * subModel = CatePanelModel.subCategories[i];
        PannelListView * subview = [[PannelListView alloc]initWithFrame:CGRectMake(originX, 0, scrollBG.width, scrollBG.height)];
        [scrollBG addSubview:subview];
        originX = subview.right;
        subview.subcateCode =subModel.code;
        [subview fetchData];

    }
    
    //data
    [cateBar setRelatedScrollView:scrollBG];
    [cateBar setTopicTitles:CatePanelModel.subCategories originX:10 minWidth:44 itemMargin:12];
    [cateBar setCenterAlignStyle];
    
}

-(void)createListView
{
    PannelListView * subview = [[PannelListView alloc]initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH, self.height-5)];
    [self addSubview:subview];
    subview.subcateCode = self.categoryCode;
    [subview fetchData];
}

#pragma mark - Column Delegate
-(void)mjview:(UIView *)view didSelectColumn:(CategoryModel*)model collectionviewIndex:(NSInteger)index
{
    
}


@end
