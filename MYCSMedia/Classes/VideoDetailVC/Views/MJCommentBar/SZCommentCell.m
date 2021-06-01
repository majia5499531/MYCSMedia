//
//  SZCommentCell.m
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/31.
//

#import "SZCommentCell.h"
#import <Masonry/Masonry.h>
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "MJVideoManager.h"
#import "MJButton.h"
#import "UIImage+MJCategory.h"
#import <SDWebImage/SDWebImage.h>
#import "SZManger.h"

@implementation SZCommentCell
{
    UIImageView * avatar;
    UILabel * name;
    UILabel * date;
    UILabel * desc;
    UIView * line;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        //头像
        avatar = [[UIImageView alloc]init];
        avatar.backgroundColor= [UIColor blackColor];
        avatar.layer.cornerRadius=18;
        avatar.layer.masksToBounds=YES;
        [self addSubview:avatar];
        [avatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(22);
            make.top.mas_equalTo(17);
            make.width.mas_equalTo(36);
            make.height.mas_equalTo(36);
        }];
        
        //昵称
        name = [[UILabel alloc]init];
        name.textColor=HW_BLACK;
        name.font=BOLD_FONT(12);
        name.text=@"我是名字子子子子子子子字";
        [self addSubview:name];
        [name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(avatar.mas_right).offset(6);
            make.top.mas_equalTo(avatar.mas_top).offset(3);
        }];
        
        //时间
        date = [[UILabel alloc]init];
        date.textColor=HW_GRAY_WORD_1;
        date.font=FONT(11);
        date.text=@"13分钟前";
        [self addSubview:date];
        [date mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(name.mas_left);
            make.top.mas_equalTo(name.mas_bottom).offset(3);
        }];
        
        //文字
        desc = [[UILabel alloc]init];
        desc.text=@"这种纪录片完美的满足了我，不出被窝就可以凑热闹，而且又不会给影响执法，给警察叔叔添乱的心情。😃😃😃\n友友们早上好！，我是大家的老朋友贺兰岳。今天早上我看到排行榜的时候，着实吓了自己一跳，昨天岳岳又真真切切地突破了一把。昨天收益163.89，比之前的最好成绩，整整高出了40呢！创作收益排行也刷新了自己的新纪录，排到了第26位。这种纪录片完美的满足了我，不出被窝就可以凑热闹，而且又不会给影响执法，给警察叔叔添乱的心情。😃😃😃\n友友们早上好！，我是大家的老朋友贺兰岳。今天早上我看到排行榜的时候，着实吓了自己一跳，昨天岳岳又真真切切地突破了一把。昨天收益163.89，比之前的最好成绩，整整高出了40呢！创作收益排行也刷新了自己的新纪录，排到了第26位。这种纪录片完美的满足了我，不出被窝就可以凑热闹，而且又不会给影响执法，给警察叔叔添乱的心情。😃😃😃\n友友们早上好！，我是大家的老朋友贺兰岳。今天早上我看到排行榜的时候，着实吓了自己一跳，昨天岳岳又真真切切地突破了一把。昨天收益163.89，比之前的最好成绩，整整高出了40呢！创作收益排行也刷新了自己的新纪录，排到了第26位。";
        desc.font=FONT(12);
        desc.numberOfLines=0;
        desc.textColor=HW_BLACK;
        [self addSubview:desc];
        [desc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(name.mas_left);
            make.top.mas_equalTo(avatar.mas_bottom).offset(16);
            make.width.mas_equalTo(SCREEN_WIDTH-100);
        }];
        
        //line
        line = [[UIView alloc]init];
        line.backgroundColor=HW_GRAY_BORDER;
        [self addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(avatar.mas_left);
            make.top.mas_equalTo(desc.mas_bottom).offset(18.5);
            make.height.mas_equalTo(0.5);
            make.right.mas_equalTo(desc.mas_right);
            make.bottom.mas_equalTo(0);
        }];
    }
    return self;
}


-(void)setCellData:(id)data
{
    [avatar sd_setImageWithURL:[NSURL URLWithString:@"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fstatic.turbosquid.com%2FPreview%2F2015%2F12%2F23__05_28_12%2Fbrown_bear_OX_walk1.jpg638bfbac-1a43-461c-aca1-86f3a13a7567Original-1.jpg&refer=http%3A%2F%2Fstatic.turbosquid.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1625037470&t=25d59f67e6cc8c74c1ad54a990b0a2ca"]];
    
}

@end
