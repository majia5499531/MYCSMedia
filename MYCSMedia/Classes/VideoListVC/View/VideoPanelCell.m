//
//  VideoPanelCell.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/25.
//


#import "VideoPanelCell.h"
#import "ContentModel.h"
#import "SZDefines.h"
#import <SDWebImage/SDWebImage.h>
#import <Masonry/Masonry.h>
#import "UIColor+MJCategory.h"

@implementation VideoPanelCell
{
    ContentModel * dataModel;
    
    //UI
    UIImageView * cover;
    UILabel * titleLabel;
    
}


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor=HW_GRAY_BG_White;
        
        self.contentView.backgroundColor=[UIColor yellowColor];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(SCREEN_WIDTH);
        }];
        
        //cover
        cover = [[UIImageView alloc]init];
        cover.contentMode=UIViewContentModeScaleAspectFill;
        cover.backgroundColor=[UIColor blackColor];
        cover.layer.masksToBounds=YES;
        [self.contentView addSubview:cover];
        [cover mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.height.mas_equalTo(SCREEN_WIDTH*0.562);
        }];
        
        //title
        titleLabel = [[UILabel alloc]init];
        titleLabel.font=BOLD_FONT(18);
        titleLabel.textColor=HW_WHITE;
        titleLabel.numberOfLines=2;
        [cover addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.top.mas_equalTo(10);
            make.right.mas_equalTo(-16);
        }];

        //bar
        UIView * bar = [[UIView alloc]init];
        bar.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bar];
        [bar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(cover.mas_bottom);
            make.width.mas_equalTo(cover.mas_width);
            make.height.mas_equalTo(41);
            make.bottom.mas_equalTo(-25);
        }];
        
        
    }
    return self;
}



-(void)setCellData:(ContentModel*)data
{
    dataModel = data;
    
//    [cover sd_setImageWithURL:[NSURL URLWithString:data.thumbnailUrl]];
    
    titleLabel.text = data.title;
    
}



- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [self setNeedsLayout];
    
    [self layoutIfNeeded];
    
    CGSize size = [self.contentView systemLayoutSizeFittingSize:layoutAttributes.size];
    CGRect cellFrame = layoutAttributes.frame;
    cellFrame.size.height = size.height;
    layoutAttributes.frame = cellFrame;
    
    
    NSLog(@"%@",NSStringFromCGRect(layoutAttributes.frame));
    
    return layoutAttributes;
}




@end
