//
//  GYNoticeCell.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/4.
//

#import "GYNoticeCell.h"
#import "Masonry.h"
#import "SZDefines.h"
#import "MJButton.h"
#import "UIImage+MJCategory.h"
#import "UIColor+MJCategory.h"
#import "VideoRelateModel.h"
#import <SDWebImage/SDWebImage.h>
#import "SZManager.h"

@implementation GYNoticeCell
{
    //data
    VideoRelateModel * model;
    
    UIImageView * icon;
    UILabel * label;
    UIButton * closeBtn;
    UIView * bgview;
}


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        //bg
        self.backgroundColor=[UIColor clearColor];
        
        //icon
        icon = [[UIImageView alloc]init];
        [self addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.centerY.mas_equalTo(self);
            make.width.mas_equalTo(14);
            make.height.mas_equalTo(14);
        }];
        
        //label
        CGFloat maxW = SCREEN_WIDTH-110;
        label = [[UILabel alloc]init];
        label.font=[UIFont systemFontOfSize:14];
        label.textColor=[UIColor whiteColor];
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(icon.mas_right).offset(10);
            make.centerY.mas_equalTo(icon);
            make.width.lessThanOrEqualTo([NSNumber numberWithFloat:maxW]);
        }];
        
        //close
        MJButton * close = [[MJButton alloc]init];
        close.mj_imageObjec = [UIImage getBundleImage:@"notice_close"];
        close.imageFrame=CGRectMake(8, 9, 9, 9 );
        [close addTarget:self action:@selector(closeNoticeBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:close];
        [close mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(label.mas_right);
            make.width.mas_equalTo(30);
            make.height.mas_equalTo(27);
            make.centerY.mas_equalTo(self);
        }];
        
        //bgview
        bgview = [[UIView alloc]init];
        bgview.layer.cornerRadius = 18;
        bgview.backgroundColor = HW_GRAY_BG_3;
        [self insertSubview:bgview belowSubview:icon];
        [bgview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(close.mas_right);
        }];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickNotice)];
        [bgview addGestureRecognizer:tap];
        
    }
    return self;
}



-(void)setCellData:(id)data
{
    model = data;
    
    label.text = model.title;
    
    [icon sd_setImageWithURL:[NSURL URLWithString:model.thumbnailUrl]];
}


-(void)closeNoticeBtnAction
{
    [self.superview removeFromSuperview];
}



#pragma mark - Tap
-(void)didClickNotice
{
    [[SZManager sharedManager].delegate onOpenWebview:model.url param:nil];
}


@end