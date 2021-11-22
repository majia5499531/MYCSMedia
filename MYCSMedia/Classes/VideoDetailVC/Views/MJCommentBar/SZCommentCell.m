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
#import "SZManager.h"
#import "CommentModel.h"
#import "NSString+MJCategory.h"
#import "NSAttributedString+MJCategory.h"

@implementation SZCommentCell
{
    CommentModel * dataModel;
    
    UIImageView * avatar;
    UILabel * name;
    UILabel * date;
    UILabel * desc;
    UIView * line;
    UIView * replyBG;
    UILabel * replyContent;
    UILabel * replyDate;
    
    UILabel * istopLabel;
    UILabel * ispendingLabel;
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
        [self addSubview:name];
        [name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(avatar.mas_right).offset(6);
            make.top.mas_equalTo(avatar.mas_top).offset(2);
        }];
        
        //时间
        date = [[UILabel alloc]init];
        date.textColor=HW_GRAY_WORD_1;
        date.font=FONT(11);
        [self addSubview:date];
        [date mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(name.mas_left).offset(0);
            make.top.mas_equalTo(name.mas_bottom).offset(3);
        }];
        
        //文字
        desc = [[UILabel alloc]init];
        desc.font=FONT(12);
        desc.numberOfLines=0;
        desc.textColor=HW_BLACK;
        [self addSubview:desc];
        [desc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(date.mas_left);
            make.top.mas_equalTo(avatar.mas_bottom).offset(14);
            make.width.mas_equalTo(SCREEN_WIDTH-100);
        }];
        
        //置顶tag
        istopLabel = [[UILabel alloc]init];
        istopLabel.text = @"置顶";
        istopLabel.font = [UIFont systemFontOfSize:10];
        istopLabel.textColor = HW_RED_WORD_1;
        istopLabel.layer.backgroundColor=[UIColor colorWithRed:0.86 green:0.0 blue:0.15 alpha:0.1].CGColor;
        istopLabel.clipsToBounds = YES;
        istopLabel.layer.cornerRadius = 3;
        istopLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:istopLabel];
        [istopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(name.mas_right).offset(5);
            make.centerY.mas_equalTo(name);
            make.width.mas_equalTo(25);
            make.height.mas_equalTo(15);
        }];
        
        //审核中label
        ispendingLabel = [[UILabel alloc]init];
        ispendingLabel.text = @"（审核中）";
        ispendingLabel.textColor=[UIColor colorWithHexString:@"3E85ED"];
        ispendingLabel.font=name.font;
        [self addSubview:ispendingLabel];
        [ispendingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(name.mas_right).offset(0);
            make.centerY.mas_equalTo(name);
        }];
        
        //编辑回复
        replyBG = [[UIView alloc]init];
        [self addSubview:replyBG];
        [replyBG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(desc.mas_bottom);
            make.left.mas_equalTo(desc.mas_left);
            make.width.mas_equalTo(desc.mas_width);
        }];
        
        //编辑回复
        UILabel * replylabel = [[UILabel alloc]init];
        replylabel = [[UILabel alloc]init];
        replylabel.textColor=HW_BLACK;
        replylabel.text=@"编辑回复:";
        replylabel.font=BOLD_FONT(12);
        [replyBG addSubview:replylabel];
        [replylabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(16);
            make.left.mas_equalTo(0);
        }];
        
        //编辑回复时间
        replyDate = [[UILabel alloc]init];
        replyDate.textColor=HW_GRAY_WORD_1;
        replyDate.font=FONT(11);
        [replyBG addSubview:replyDate];
        [replyDate mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(replylabel.mas_bottom).offset(3);
            make.left.mas_equalTo(replylabel.mas_left);
        }];
        
        //文字
        replyContent = [[UILabel alloc]init];
        replyContent.font=FONT(12);
        replyContent.numberOfLines=0;
        replyContent.textColor=HW_BLACK;
        [replyBG addSubview:replyContent];
        [replyContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(replyDate.mas_bottom).offset(14);
            make.width.mas_equalTo(replyBG.mas_width);
            make.bottom.mas_equalTo(2);
        }];
        
        
        //line
        line = [[UIView alloc]init];
        line.backgroundColor=HW_GRAY_BORDER;
        [self addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(avatar.mas_left);
            make.top.mas_equalTo(replyBG.mas_bottom).offset(18.5);
            make.height.mas_equalTo(0.5);
            make.right.mas_equalTo(desc.mas_right);
            make.bottom.mas_equalTo(0);
        }];
    }
    return self;
}


-(void)setCellData:(CommentModel*)data
{
    dataModel = data;
    
    [avatar sd_setImageWithURL:[NSURL URLWithString:dataModel.head]];
    
    name.text = data.nickname;
    
    //如果是置顶
    if (data.isTop)
    {
        istopLabel.hidden=NO;
        ispendingLabel.hidden=YES;
    }
    
    //未上架
    else if (!data.onShelve)
    {
        istopLabel.hidden=YES;
        ispendingLabel.hidden=NO;
    }
    else
    {
        istopLabel.hidden=YES;
        ispendingLabel.hidden=YES;
    }
    
    
    
    date.text = [NSString converUTCDateStr:dataModel.createTime];
    
    desc.text = dataModel.content;
    
    if (data.dataArr.count)
    {
        CommentModel * replyModel = data.dataArr[0];
        replyDate.text = [NSString converUTCDateStr:replyModel.createTime];
        replyContent.text = replyModel.content;
        
        replyBG.hidden=NO;
        
        [replyBG mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(desc.mas_bottom);
            make.left.mas_equalTo(desc.mas_left);
            make.width.mas_equalTo(desc.mas_width);
        }];
    }
    else
    {
        replyBG.hidden=YES;
        [replyBG mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(desc.mas_bottom);
            make.left.mas_equalTo(desc.mas_left);
            make.width.mas_equalTo(desc.mas_width);
            make.height.mas_equalTo(0);
        }];
    }
    
}


@end

