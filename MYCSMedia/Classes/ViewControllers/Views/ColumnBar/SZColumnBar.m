//
//  SZColumnBar.m
//  智慧长沙
//
//  Created by 马佳 on 2019/9/11.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import "SZColumnBar.h"
#import "UIView+MJCategory.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "MJButton.h"
#import "UIScrollView+MJCategory.h"
#import "Masonry.h"
#import "UIImage+MJCategory.h"

@interface SZColumnBar ()<UIScrollViewDelegate>
@property(weak,nonatomic)id <SZColumnBarDelegate> columnDelegate;
@end

@implementation SZColumnBar
{
    //按钮
    NSMutableArray * tabBtnArr;
    
    //UI
    UIScrollView * tabbarScrollBG;
    
    //下划线
    UIImageView * underline;
    
    //当前页
    NSInteger currentPage;
    
    //即将展示页
    NSInteger nextPage;
    
    //关联的scrollview
    UIScrollView * set_relateScrollview;
    
    //标题
    NSArray * set_titleArr;
    
    //间距
    NSInteger set_interspace;
    
    //缩紧
    NSInteger set_originX;
    
    //初始tab
    NSInteger set_initialIndex;
    
    //对齐方式
    SZColumnAlignment set_alignment;
    
    //普通颜色
    UIColor * set_txtColor;
    
    //选中颜色
    UIColor * set_selTxtcolor;
    
    //下划线颜色
    UIColor * set_lineColor;
}


#pragma mark - init
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //滑动BG
        tabbarScrollBG = [[UIScrollView alloc]init];
        tabbarScrollBG.backgroundColor=[UIColor clearColor];
        tabbarScrollBG.showsHorizontalScrollIndicator=NO;
        [self addSubview:tabbarScrollBG];
        [tabbarScrollBG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
        
        //底部线
        underline = [[UIImageView alloc]init];
        [tabbarScrollBG addSubview:underline];
        
        //按钮arr
        tabBtnArr = [NSMutableArray array];
        
    }
    return self;
}


-(instancetype)initWithTitles:(NSArray *)titles relateScrollView:(UIScrollView*)scrollview delegate:(id<SZColumnBarDelegate>)delegate  originX:(CGFloat)oriX itemMargin:(CGFloat)interSpace txtColor:(UIColor*)color selTxtColor:(UIColor*)selcolor lineColor:(UIColor*)linecolor initialIndex:(NSInteger)idx
{
    self = [super init];
    if (self)
    {
        self.columnDelegate=delegate;
        [self setTopicTitles:titles relateScrollView:scrollview originX:oriX itemMargin:interSpace txtColor:color selTxtColor:selcolor lineColor:linecolor initialIndex:idx];
    }
    return self;
}


#pragma mark - Public
-(void)setTopicTitles:(NSArray *)titles relateScrollView:(UIScrollView*)relatedScrollView originX:(CGFloat)oriX itemMargin:(CGFloat)interSpace txtColor:(UIColor*)color selTxtColor:(UIColor*)selcolor lineColor:(UIColor*)linecolor initialIndex:(NSInteger)initialIDX
{
    //保存数据
    set_relateScrollview = relatedScrollView;
    set_titleArr = titles;
    set_interspace = interSpace;
    set_originX = oriX;
    set_initialIndex = initialIDX;
    
    //设置delegate
    relatedScrollView.delegate=self;
    
    //下划线颜色
    underline.backgroundColor=linecolor;
    
    //状态归零
    currentPage=-1;
    nextPage=-1;
    
    //默认左对齐
    set_alignment = SZColumnAlignmentLeft;
    
    //清空之前的Btn
    for (MJButton * btn in tabBtnArr)
    {
        [btn removeFromSuperview];
    }
    [tabBtnArr removeAllObjects];
    
    //创建Btn
    for (int i=0; i<set_titleArr.count; i++)
    {
        //data
        NSString * str = set_titleArr[i];

        //按钮
        MJButton * tabBtn=[[MJButton alloc]init];
        tabBtn.tag=i;
        tabBtn.mj_text=str;
        tabBtn.mj_textColor=color;
        tabBtn.mj_textColor_sel=selcolor;
        tabBtn.mj_alpha_sel = 1;
        tabBtn.mj_font=[UIFont systemFontOfSize:15 weight:500];
        tabBtn.mj_font_sel=[UIFont systemFontOfSize:15 weight:600];;
        [tabBtn addTarget:self action:@selector(tabBtnActions:) forControlEvents:UIControlEventTouchUpInside];
        [tabbarScrollBG addSubview:tabBtn];
        [tabBtnArr addObject:tabBtn];
    }

}



-(void)setAlignStyle:(SZColumnAlignment)style
{
    set_alignment = style;
}

-(void)setTxtColor:(UIColor*)color selectedColor:(UIColor*)selcolor lineColor:(UIColor*)linecolor
{
    set_txtColor = color;
    set_selTxtcolor = selcolor;
    set_lineColor = linecolor;
    
    for (MJButton * btn in tabBtnArr)
    {
        btn.mj_textColor = set_txtColor;
        btn.mj_textColor_sel = set_selTxtcolor;
        underline.backgroundColor = set_lineColor;
        
        if (btn.MJSelectState)
        {
            btn.MJSelectState = btn.MJSelectState;
        }
    }
}


-(void)refreshView
{
    //确定layout
    [self layoutIfNeeded];
    
    //如果是space btween
    if (set_alignment==SZColumnAlignmentSpacebtween)
    {
        CGFloat totalBtnWidht = 0;
        for (MJButton * btn in tabBtnArr)
        {
            [btn sizeToFit];
            
            totalBtnWidht += btn.width;
        }
        
        CGFloat totalSpace = tabbarScrollBG.width - totalBtnWidht - set_originX - set_originX;
        CGFloat interspace = totalSpace/(tabBtnArr.count-1);
        
        //更新btn layout
        for (int i=0; i<tabBtnArr.count; i++)
        {
            //按钮
            MJButton * newsbtn=tabBtnArr[i];
            
            if (i==0)
            {
                [newsbtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(set_originX);
                    make.centerY.mas_equalTo(0);
                    make.height.mas_equalTo(tabbarScrollBG.mas_height).offset(-6);
                }];
            }
            else if (i<set_titleArr.count-1)
            {
                MJButton * prebtn = tabBtnArr[i-1];
                [newsbtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(prebtn.mas_right).offset(interspace);
                    make.centerY.mas_equalTo(0);
                    make.height.mas_equalTo(tabbarScrollBG.mas_height).offset(-6);
                }];
            }
            else
            {
                MJButton * prebtn = tabBtnArr[i-1];
                [newsbtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(prebtn.mas_right).offset(interspace);
                    make.right.mas_equalTo(-set_originX);
                    make.centerY.mas_equalTo(0);
                    make.height.mas_equalTo(tabbarScrollBG.mas_height).offset(-6);
                }];
            }
        }
    }
    
    
    //居中对齐
    else if (set_alignment == SZColumnAlignmentCenter)
    {
        //如果是奇数个
        if (tabBtnArr.count%2==1)
        {
            //从中间的按钮开始设置
            NSInteger mididx = tabBtnArr.count/2;
            MJButton * midBtn = tabBtnArr[mididx];
            [midBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(0);
                make.centerY.mas_equalTo(0);
                make.height.mas_equalTo(tabbarScrollBG.mas_height).offset(-6);
            }];
            
            //前向
            for (int i = (int)mididx -1; i>=0; i--)
            {
                MJButton * currentBtn = tabBtnArr[i];
                MJButton * prebtn = tabBtnArr[i+1];
                [currentBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(prebtn.mas_left).offset(-set_interspace);
                    make.centerY.mas_equalTo(0);
                    make.height.mas_equalTo(tabbarScrollBG.mas_height).offset(-6);
                }];
            }
            
            //向后
            for (int i = (int)mididx+1; i<tabBtnArr.count; i++)
            {
                MJButton * currentBtn = tabBtnArr[i];
                MJButton * prebtn = tabBtnArr[i-1];
                [currentBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(prebtn.mas_right).offset(set_interspace);
                    make.centerY.mas_equalTo(0);
                    make.height.mas_equalTo(tabbarScrollBG.mas_height).offset(-6);
                }];
            }
            
        }
        
        //如果是偶数个
        else
        {
            //从中间的按钮开始设置
            NSInteger mididx = tabBtnArr.count/2;
            MJButton * midBtn = tabBtnArr[mididx];
            CGFloat startX = (tabbarScrollBG.width/2) + (set_interspace/2);
            [midBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(startX);
                make.centerY.mas_equalTo(0);
                make.height.mas_equalTo(tabbarScrollBG.mas_height).offset(-6);
            }];
            
            //前向
            for (int i = (int)mididx -1; i>=0; i--)
            {
                MJButton * currentBtn = tabBtnArr[i];
                MJButton * prebtn = tabBtnArr[i+1];
                [currentBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(prebtn.mas_left).offset(-set_interspace);
                    make.centerY.mas_equalTo(0);
                    make.height.mas_equalTo(tabbarScrollBG.mas_height).offset(-6);
                }];
            }
            
            //向后
            for (int i = (int)mididx+1; i<tabBtnArr.count; i++)
            {
                MJButton * currentBtn = tabBtnArr[i];
                MJButton * prebtn = tabBtnArr[i-1];
                [currentBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(prebtn.mas_right).offset(set_interspace);
                    make.centerY.mas_equalTo(0);
                    make.height.mas_equalTo(tabbarScrollBG.mas_height).offset(-6);
                }];
            }
        }
    }
    
    //(默认)左对齐
    else
    {
        for (int i=0; i<tabBtnArr.count; i++)
        {
            MJButton * btn = tabBtnArr[i];
            
            if (i==0)
            {
                [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(set_originX);
                    make.centerY.mas_equalTo(0);
                    make.height.mas_equalTo(tabbarScrollBG.mas_height).offset(-6);
                }];
            }
            else if (i<set_titleArr.count-1)
            {
                MJButton * prebtn = tabBtnArr[i-1];
                [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(prebtn.mas_right).offset(set_interspace);
                    make.centerY.mas_equalTo(0);
                    make.height.mas_equalTo(tabbarScrollBG.mas_height).offset(-6);
                }];
            }
            else
            {
                MJButton * prebtn = tabBtnArr[i-1];
                [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(prebtn.mas_right).offset(set_interspace);
                    make.centerY.mas_equalTo(0);
                    make.height.mas_equalTo(tabbarScrollBG.mas_height).offset(-6);
                    make.right.mas_equalTo(-set_originX);
                }];
            }
        }
    }
    
    
    
    
    //触发一次回调事件
    if (set_relateScrollview)
    {
        CGFloat offsetX = set_relateScrollview.width*set_initialIndex - 1;
        [set_relateScrollview setContentOffset:CGPointMake(offsetX, 0) animated:NO];
        [self scrollViewDidEndDecelerating:set_relateScrollview];
    }
}

-(void)setBadgeStr:(NSString*)str atIndex:(NSInteger)idx
{
    MJButton * btn = tabBtnArr[idx];
    [btn setBadgeStr:str];
}


-(void)selectIndex:(NSInteger)idx
{
    MJButton * btn = tabBtnArr[idx];
    [self tabBtnActions:btn];
}

-(void)setUnderlingImage:(NSString*)imgstr
{
    underline.image = [UIImage getBundleImage:imgstr];
}

-(void)debugMode
{
    underline.backgroundColor=[UIColor redColor];
    tabbarScrollBG.backgroundColor=[UIColor greenColor];
    for (MJButton * btn in tabBtnArr)
    {
        btn.backgroundColor=[UIColor yellowColor];
    }
}

#pragma mark - Callback 四种触发方式
//测试四种方式（首次、tab点击、滑动、外部调用）
-(void)callbackDidSelectedEvent
{
//    NSLog(@"page_didshow_%ld",(long)currentPage);
    
    //通知代理刷新列表
    if (self.columnDelegate && [self.columnDelegate respondsToSelector:@selector(mjview:didSelectColumnIndex:)])
    {
        [self.columnDelegate mjview:self didSelectColumnIndex:currentPage];
    }
}

-(void)callbackWillSelectEvent
{
    [self tabbarAnimations:nextPage];
    
//    NSLog(@"page_willshow_%ld",(long)nextPage);
    
    if (self.columnDelegate && [self.columnDelegate respondsToSelector:@selector(mjview:willSelectTab:)])
    {
        [self.columnDelegate mjview:self willSelectTab:nextPage];
    }
}


#pragma mark - Relate Scrollview Delegate
//滑动过程
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat floatPage = (scrollView.contentOffset.x) / scrollView.width;
    
    int m = floatPage * 10000;
    
    //滑动结束（整数倍）
    if ( m % 10000 == 0)
    {
        return ;
    }
    
    //向左
    if (floatPage < currentPage)
    {
        double minus = floor(currentPage-floatPage);
        NSInteger nextIndex = currentPage - minus - 1;

        if (nextPage!=nextIndex)
        {
            nextPage = nextIndex;
            
            [self callbackWillSelectEvent];
        }
    }
    
    //如果比当前页大，则向右
    else if (floatPage>currentPage)
    {
        double minus = floor(floatPage-currentPage);
        NSInteger nextIndex = currentPage + minus + 1;

        if (nextPage!=nextIndex)
        {
            nextPage = nextIndex;
            
            [self callbackWillSelectEvent];
        }
    }
    
    else
    {
        
    }
}



//滑动完全停止
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //计算当前的页数
    NSInteger page = (scrollView.contentOffset.x + (scrollView.width/2) )/scrollView.width;
    
    //修正滑动又返回的问题
    currentPage = page;
    
    if (currentPage!=nextPage)
    {
        nextPage = page;
        [self callbackWillSelectEvent];
    }
    
    
    //tabbar animations
    [self tabbarAnimations:page];
    
    //回调
    [self callbackDidSelectedEvent];
}


#pragma mark - Private
-(void)tabBtnActions:(UIButton*)selBtn
{
    //index
    NSInteger index = selBtn.tag;
    
    //重复则return
    if (index==currentPage)
    {
        return;
    }
    
    //同步滑动
    if (set_relateScrollview)
    {
        //这里需要手动出发will
        if (nextPage!=index)
        {
            nextPage = index;
            
            [self callbackWillSelectEvent];
        }
        
        [set_relateScrollview setContentOffset:CGPointMake(set_relateScrollview.width*index, 0) animated:NO];
        [self scrollViewDidEndDecelerating:set_relateScrollview];
    }
}

-(void)tabbarAnimations:(NSInteger)index
{
    //容错
    if (tabBtnArr.count==0 || index>=tabBtnArr.count)
    {
        return;
    }
    
    //改变Btn选中状态
    for (MJButton * button in tabBtnArr)
    {
        button.MJSelectState=NO;
    }
    MJButton * selBtn = tabBtnArr[index];
    selBtn.MJSelectState=YES;
    
    
    //下划线移动
    [underline mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(selBtn.mas_centerX);
        make.width.mas_equalTo(15.5);
        make.top.mas_equalTo(self.height-5);
        make.height.mas_equalTo(5.5);
    }];
    
    
    //scrollview 滑动
    if (tabbarScrollBG.contentSize.width>tabbarScrollBG.width &&  selBtn.left>tabbarScrollBG.width/2)
    {
        if (tabbarScrollBG.contentSize.width - selBtn.centerX < tabbarScrollBG.width/2)
        {
            [tabbarScrollBG setContentOffset:CGPointMake(tabbarScrollBG.contentSize.width-tabbarScrollBG.width, 0 ) animated:YES];
        }
        else
        {
            [tabbarScrollBG setContentOffset:CGPointMake(selBtn.left - tabbarScrollBG.width/2 + selBtn.width/2 , 0 ) animated:YES];
        }
    }
    else
    {
        [tabbarScrollBG setContentOffset:CGPointMake(0,0 ) animated:YES];
    }
    
    
    
    
}




@end
