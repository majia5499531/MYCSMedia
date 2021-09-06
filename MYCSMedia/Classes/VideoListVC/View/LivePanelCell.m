//
//  LivePanelCell.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/25.
//

#import "LivePanelCell.h"
#import "ContentModel.h"
#import "SZDefines.h"
#import <SDWebImage/SDWebImage.h>
#import <Masonry/Masonry.h>
#import "UIColor+MJCategory.h"

@implementation LivePanelCell
{
    ContentModel * dataModel;
    
    //ui
    UIImageView * cover;
    UILabel * titleLabel;
    UILabel * dateLabel;
    
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
     
        self.backgroundColor=HW_GRAY_BG_White;
        
//        //cover
//        cover = [[UIImageView alloc]init];
//        cover.contentMode=UIViewContentModeScaleAspectFill;
//        cover.backgroundColor=[UIColor blackColor];
//        cover.layer.masksToBounds=YES;
//        [self addSubview:cover];
//        [cover mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(0);
//            make.top.mas_equalTo(0);
//            make.width.mas_equalTo(SCREEN_WIDTH);
//            make.height.mas_equalTo(SCREEN_WIDTH*0.562);
//        }];
//
//        //date
//        dateLabel = [[UILabel alloc]init];
//        dateLabel.font=BOLD_FONT(11);
//        dateLabel.textColor=HW_WHITE;
//        dateLabel.numberOfLines=2;
//        [cover addSubview:dateLabel];
//        [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(15);
//            make.bottom.mas_equalTo(-5);
//        }];
//
//        //title
//        titleLabel = [[UILabel alloc]init];
//        titleLabel.font=BOLD_FONT(18);
//        titleLabel.textColor=HW_WHITE;
//        titleLabel.numberOfLines=2;
//        [cover addSubview:titleLabel];
//        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(dateLabel.mas_left);
//            make.bottom.mas_equalTo(dateLabel.mas_top).offset(-5);
//        }];
//
//        //bar
//        UIView * bar = [[UIView alloc]init];
//        bar.backgroundColor = [UIColor whiteColor];
//        [self addSubview:bar];
//        [bar mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(0);
//            make.top.mas_equalTo(cover.mas_bottom);
//            make.width.mas_equalTo(cover.mas_width);
//            make.height.mas_equalTo(41);
//            make.bottom.mas_equalTo(-5);
//        }];
    }
    return self;
}


-(void)setCellData:(ContentModel*)data
{
    dataModel = data;
    
    [cover sd_setImageWithURL:[NSURL URLWithString:data.thumbnailUrl]];
    
    dateLabel.text = data.liveStartTime;
    
    titleLabel.text = data.title;
}

@end

