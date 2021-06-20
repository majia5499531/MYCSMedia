//
//  ColumnBar.m
//  智慧长沙
//
//  Created by 马佳 on 2019/9/11.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import "ColumnBar.h"
#import "UIView+MJCategory.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "MJButton.h"
#import "UIScrollView+MJCategory.h"

@interface ColumnBar ()<UIScrollViewDelegate>

@property(weak,nonatomic)UIScrollView * relateScrollview;

@end

@implementation ColumnBar
{
    //栏目数据
    NSArray * columnDataArr;
    
    //按钮
    NSMutableArray * ColumnBtnArr;
    
    //UI
    UIScrollView * scrollbar;
    
    //下划线
    UIView * line;
    
    //当前页
    NSInteger currentPage;
}


#pragma mark - init
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //滑动条
        scrollbar = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.width-40, self.height)];
        scrollbar.showsHorizontalScrollIndicator=NO;
        scrollbar.backgroundColor=HW_WHITE;
        [self addSubview:scrollbar];
        
        //下划线
        line = [[UIView alloc]initWithFrame:CGRectMake(0, self.height-3, 12, 3)];
        line.backgroundColor=HW_RED_WORD_1;
        line.layer.cornerRadius=1.5;
        line.hidden=YES;
        [scrollbar addSubview:line];
        
        //按钮集合
        ColumnBtnArr = [NSMutableArray array];
        
    }
    return self;
}


#pragma mark - Public Method
-(void)setTopicTitles:(NSArray *)columnArr originX:(CGFloat)oriX minWidth:(CGFloat)minWidth itemMargin:(CGFloat)interSpace
{
    //保存数据
    columnDataArr = columnArr;
    
    //清空之前的Btn
    for (MJButton * btn in ColumnBtnArr)
    {
        [btn removeFromSuperview];
    }
    [ColumnBtnArr removeAllObjects];
    
    //创建Btn
    CGFloat x = oriX;
    for (int i=0; i<columnArr.count; i++)
    {
        
        
//        //data
//        ColumnModel * columnInfo = columnArr[i];
//
//        //按钮
//        BaseButton * newsbtn=[[BaseButton alloc]init];
//        newsbtn.tag=i;
//        newsbtn.mj_text=columnInfo.columnName;
//        newsbtn.mj_textColor=HW_GRAY_WORD_1;
//        newsbtn.mj_textColor_sel=HW_BLACK_WORD_1;
//        newsbtn.mj_font=FONT(16);
//        newsbtn.mj_font_sel=BOLD_FONT(16);
//        [newsbtn sizeToFit];
//        newsbtn.width += 10;
//
//        //设置按钮Frame
//        CGFloat tgtW = 0;
//        tgtW = minWidth > newsbtn.width ? minWidth : newsbtn.width;
//        [newsbtn setFrame:CGRectMake(x, 0, tgtW, scrollbar.height-1)];
//        x = newsbtn.right + interSpace;
//        [newsbtn addTarget:self action:@selector(newsBtnActions:) forControlEvents:UIControlEventTouchUpInside];
//        [scrollbar addSubview:newsbtn];
//        [ColumnBtnArr addObject:newsbtn];
    }
    
    //配置Bar
    [scrollbar MJAutoSetContentSize];
    
    //状态归零
    currentPage=99999;
    if (_relateScrollview)
    {
        [self scrollViewDidScroll:_relateScrollview];
    }
}


-(void)setCenterAlignStyle
{
    //如果是奇数
    if (ColumnBtnArr.count%2==1)
    {
        NSInteger idx = ColumnBtnArr.count/2;
        MJButton * btn = ColumnBtnArr[idx];
        CGFloat offset = self.width/2-btn.centerX;
        
        
        for (int i = 0; i<columnDataArr.count; i++)
        {
            MJButton * item = ColumnBtnArr[i];
            [item setCenterX:(item.centerX+offset)];
        }
    }
    
    //下划线移动
    MJButton * selBtn = ColumnBtnArr[currentPage];
    line.hidden=NO;
    [line setCenterX:selBtn.centerX];
}


//设置关联的scrollview
-(void)setRelatedScrollView:(UIScrollView *)scrollview
{
    scrollview.delegate=self;
    _relateScrollview = scrollview;
}





#pragma mark - 按钮事件
-(void)newsBtnActions:(UIButton*)selBtn
{
    //index
    NSInteger index = selBtn.tag;
    
    //同步滑动
    if (_relateScrollview)
    {
        [_relateScrollview setContentOffset:CGPointMake(_relateScrollview.width*index, 0) animated:NO];
    }
}


#pragma mark - 滑动代理
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //获取当前关联的滑动视图的页数
    NSInteger page = [self currentScrollViewPage:scrollView];
    
    //页数不同时触发
    if (currentPage!=page)
    {
        currentPage = page;
        [self makeEventWithIndex:currentPage];
    }
}


#pragma mark - 当前页数
-(NSInteger)currentScrollViewPage:(UIScrollView*)scrollview;
{
    NSInteger n1 = scrollview.contentOffset.x/scrollview.width;
    CGFloat n2 = scrollview.contentOffset.x/scrollview.width;
    
    //计算页数
    CGFloat offsetRate = n2-n1;
    NSInteger page = 0;
    if (offsetRate>0.6)
    {
        page=n1+1;
    }
    else
    {
        page=n1;
    }
    
    return page;
}


#pragma mark - 选中
-(void)makeEventWithIndex:(NSInteger)index
{
    //bugfix
    if (!ColumnBtnArr.count)
    {
        return;
    }
    
    MJButton * selBtn = ColumnBtnArr[index];
    
    
    //改变Btn状态
    for (MJButton * button in ColumnBtnArr)
    {
        button.MJSelectState=NO;
    }
    selBtn.MJSelectState=YES;
    
    
    //下划线移动
    line.hidden=NO;
    [line setCenterX:selBtn.centerX];
    
    
    //滑动bar
    if (scrollbar.contentSize.width>scrollbar.width &&  selBtn.left>scrollbar.width/2)
    {
        if (scrollbar.contentSize.width - selBtn.centerX < scrollbar.width/2)
        {
            [scrollbar setContentOffset:CGPointMake(scrollbar.contentSize.width-scrollbar.width, 0 ) animated:YES];
        }
        else
        {
            [scrollbar setContentOffset:CGPointMake(selBtn.left - scrollbar.width/2 + selBtn.width/2 , 0 ) animated:YES];
        }
    }
    else
    {
        [scrollbar setContentOffset:CGPointMake(0,0 ) animated:YES];
    }
    
    
    //通知代理刷新列表
//    if (self.columnDelegate && [self.columnDelegate respondsToSelector:@selector(mjview:didSelectColumn:subColumn:bookMark:collectionviewIndex:)])
//    {
//        [self.columnDelegate mjview:self didSelectColumn:columnDataArr[index] subColumn:nil bookMark:nil collectionviewIndex:index];
//    }
}




@end
