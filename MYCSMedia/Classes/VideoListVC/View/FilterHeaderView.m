//
//  FilterHeaderView.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/28.
//

#import "FilterHeaderView.h"
#import "PanelModel.h"
#import "UIView+MJCategory.h"
#import "SZDefines.h"
#import "MJButton.h"
#import "UIColor+MJCategory.h"
#import "UIScrollView+MJCategory.h"

@implementation FilterHeaderView
{
    UIScrollView * scrollBG;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor redColor];
        
        scrollBG = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,47)];                   scrollBG.backgroundColor=[UIColor whiteColor];
        [self addSubview:scrollBG];
        
        

    }
    return self;
}

-(void)setHeaderData:(PanelModel*)data
{
    [scrollBG MJRemoveAllSubviews];
    
    NSArray * filters = data.config.filterItems;
    CGFloat orignX = 15;
    for (int i = 0; i<filters.count; i++)
    {
        NSString * filterStr = filters[i];
        MJButton * btn = [[MJButton alloc]initWithFrame:CGRectMake(orignX, 8, 100, 27)];
        btn.mj_text=filterStr;
        btn.mj_font=FONT(13);
        btn.mj_textColor=HW_GRAY_WORD_1;
        btn.mj_textColor_sel=HW_BLACK;
        btn.mj_bgColor=HW_GRAY_BG_5;
        [scrollBG addSubview:btn];
        [btn sizeToFit];
        [btn setWidth:btn.width+26];

        orignX = btn.right+7;
    }

    [scrollBG MJAutoSetContentSizeX:20 Y:0];
}

@end
