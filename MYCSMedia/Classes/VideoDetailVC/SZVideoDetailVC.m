//
//  SZVideoDetailVC.m
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/27.
//

#import "SZVideoDetailVC.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "CustomFooter.h"
#import "CustomAnimatedHeader.h"
#import "SZVideoCell.h"
#import "UIImage+MJCategory.h"
#import "MJButton.h"
#import "MJVideoManager.h"
#import <Masonry/Masonry.h>
#import "SZManger.h"
#import "UIView+MJCategory.h"
#import "SZInputView.h"
#import "SZCommentBar.h"

@interface SZVideoDetailVC ()<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation SZVideoDetailVC
{
    UICollectionView * collectionView;
    NSInteger currentRow;
    
    NSArray * dataArr ;
    
    
    UIStatusBarStyle originStatusStyle;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self MJInitSubviews];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden=YES;
    
    
    originStatusStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden=NO;
    
    [[UIApplication sharedApplication]setStatusBarStyle:originStatusStyle];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [MJVideoManager cancelPlayingWindowVideo];
}



#pragma mark - 界面&布局
-(void)MJInitSubviews
{
    self.view.backgroundColor=[UIColor whiteColor];
    
    dataArr = @[
                @"https://oss.changsha.cn/2021/20210520/V1116WangLiJun1116491080_1080.mp4",
                @"https://oss.changsha.cn/2020/20200730/V115620200730softRYShuPing115654.mp4",
                @"https://oss.changsha.cn/2021/20210428/V0915ShiPinXiaZai091510.mp4"
                ];
    
    
    //collectionview
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT) collectionViewLayout:flowLayout];
    if (@available(iOS 11.0, *))
    {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor=HW_BLACK;
    [collectionView registerClass:[SZVideoCell class] forCellWithReuseIdentifier:@"shortSZVideoCell"];
    collectionView.mj_header = [CustomAnimatedHeader headerWithRefreshingTarget:self refreshingAction:@selector(pulldownRefreshAction:)];
    collectionView.mj_footer = [CustomFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullupLoadAction:)];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled=YES;
    collectionView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:collectionView];
    
    
    //naviback
    MJButton * btn = [[MJButton alloc]initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, 50, 50)];
    [btn setImage:[UIImage getBundleImage:@"sz_naviback"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    //commentview
    SZCommentBar * bar = [[SZCommentBar alloc]init];
    [bar mjsetContentId:@"1234567890"];
    [self.view addSubview:bar];
    
    
}



#pragma mark - 下拉/上拉
-(void)pulldownRefreshAction:(MJRefreshHeader*)refreshHeader
{
    [collectionView.mj_header endRefreshing];
}


-(void)pullupLoadAction:(MJRefreshAutoFooter*)footer
{
    [collectionView.mj_footer endRefreshing];
}




#pragma mark - scrollview delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //获取当前cell的index
    CGPoint pt = collectionView.contentOffset;
    pt.y = pt.y + collectionView.frame.size.height/2;
    NSIndexPath * idx = [collectionView indexPathForItemAtPoint:pt];
    
    
    //播放视频
    SZVideoCell * cell = (SZVideoCell*)[collectionView cellForItemAtIndexPath:idx];
    [cell playingVideo];
}


#pragma mark - CollectionView Datasource & Delegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SZVideoCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"shortSZVideoCell" forIndexPath:indexPath];
    [cell setCellData:dataArr[indexPath.row]];
    return  cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return dataArr.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(SCREEN_WIDTH,SCREEN_HEIGHT);
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
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}


#pragma mark - Btn Action
-(void)backBtnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - StatusBar
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
