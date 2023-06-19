//
//  SZ5GliveCell.m
//  MYCSMedia
//
//  Created by 马佳 on 2023/4/11.
//

#import "SZ5GliveCell.h"
#import "SZDefines.h"
#import "UIView+MJCategory.h"
#import <Masonry/Masonry.h>
#import "UIColor+MJCategory.h"
#import <SDWebImage/SDWebImage.h>
#import "ContentModel.h"
#import "UIImage+MJCategory.h"


@implementation SZ5GliveCell
{
    UIView * bg;
    UIImageView * coverImageView;
    UILabel * titleLabel;
    UIImageView * stateLogo;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor=[UIColor clearColor];
        
        //bg
        CGFloat cellW = SCREEN_WIDTH-12-12;
        bg = [[UIView alloc]init];
        bg.backgroundColor=[UIColor whiteColor];
        bg.layer.cornerRadius=12;
        [self addSubview:bg];
        [bg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(cellW);
        }];
        
        //标题
        titleLabel = [[UILabel alloc]init];
        titleLabel.font=FONT(16);
        titleLabel.numberOfLines=2;
        titleLabel.textColor=HW_BLACK;
        [bg addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.top.mas_equalTo(16);
            make.right.mas_equalTo(-12);
        }];
        
        
        //封面
        CGFloat imgH = 0.562 * (SCREEN_WIDTH-48);
        coverImageView = [[UIImageView alloc]init];
        coverImageView.layer.cornerRadius=4;
        coverImageView.layer.masksToBounds=YES;
        coverImageView.contentMode=UIViewContentModeScaleAspectFill;
        [bg addSubview:coverImageView];
        [coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.top.mas_equalTo(titleLabel.mas_bottom).offset(10);
            make.right.mas_equalTo(-12);
            make.height.mas_equalTo(imgH);
            make.bottom.mas_equalTo(-18);
        }];
        
        //状态
        stateLogo = [[UIImageView alloc]init];
        [coverImageView addSubview:stateLogo];
        [stateLogo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.bottom.mas_equalTo(-10);
            make.width.mas_equalTo(58);
            make.height.mas_equalTo(18);
        }];
        
    }
    return self;
}



-(void)setCellData:(ContentModel*)model
{
    [coverImageView sd_setImageWithURL:[NSURL URLWithString:model.thumbnailUrl]];
    
    titleLabel.text = model.title;
    
    //直播状态
    if (model.liveStatus.intValue==1)
    {
        stateLogo.image = [UIImage getBundleImage:@"sz_livestate_now"];
    }
    else if(model.liveStatus.intValue==2)
    {
        stateLogo.image = [UIImage getBundleImage:@"sz_livestate_end"];
    }
    else
    {
        stateLogo.image = [UIImage getBundleImage:@"sz_livestate_pre"];
    }
}

-(CGFloat)cellHeigh
{
    [self layoutIfNeeded];
    
    return bg.bottom+10;
}


@end

