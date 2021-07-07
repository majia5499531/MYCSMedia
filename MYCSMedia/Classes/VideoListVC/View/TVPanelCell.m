//
//  TVPanelCell.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/25.
//

#import "TVPanelCell.h"
#import "ContentModel.h"
#import "SZDefines.h"
#import <SDWebImage/SDWebImage.h>
#import <Masonry/Masonry.h>
#import "UIColor+MJCategory.h"
#import "UIScrollView+MJCategory.h"
#import "UIView+MJCategory.h"

@implementation TVPanelCell
{
    UIScrollView * scrollBG;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor=[UIColor whiteColor];
        
        
        scrollBG = [[UIScrollView alloc]init];
        scrollBG.backgroundColor=[UIColor yellowColor];
        [self addSubview:scrollBG];
        [scrollBG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.height.mas_equalTo(40);
            make.bottom.mas_equalTo(0);
        }];
    }
    return self;
}

-(void)setCellData:(id)data
{
    [scrollBG MJRemoveAllSubviews];
}


@end
