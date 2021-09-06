//
//  SZLiveCell.m
//  Pods
//
//  Created by 马佳 on 2021/8/20.
//

#import "SZLiveCell.h"
#import "SZDefines.h"
#import "UIView+MJCategory.h"
#import <Masonry/Masonry.h>
#import "UIColor+MJCategory.h"
#import <SDWebImage/SDWebImage.h>
#import "ContentModel.h"
#import "UIImage+MJCategory.h"

@implementation SZLiveCell
{
    UIImageView * coverImageView;
    UILabel * titleLabel;
    UIImageView * stateLogo;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor=[UIColor blackColor];
        
        //封面
        CGFloat imgH = 0.562 * SCREEN_WIDTH;
        coverImageView = [[UIImageView alloc]init];
        coverImageView.contentMode=UIViewContentModeScaleAspectFill;
        [self addSubview:coverImageView];
        [coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.height.mas_equalTo(imgH);
        }];
        
        
        //标题
        titleLabel = [[UILabel alloc]init];
        titleLabel.font=FONT(16);
        titleLabel.numberOfLines=2;
        titleLabel.textColor=HW_WHITE;
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(imgH);
            make.width.mas_equalTo(SCREEN_WIDTH-30);
            make.height.mas_equalTo(60);
        }];
        
        
        //状态
        stateLogo = [[UIImageView alloc]init];
        [coverImageView addSubview:stateLogo];
        [stateLogo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
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



@end
