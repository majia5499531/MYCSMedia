//
//  SZCommentHeader.m
//  MYCSMedia
//
//  Created by 马佳 on 2022/1/4.
//

#import "SZCommentHeader.h"
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
#import "UIView+MJCategory.h"
#import "SZInputView.h"
#import "SZGlobalInfo.h"
#import "SZData.h"

@implementation SZCommentHeader
{
    CommentModel * dataModel;
    
    UIImageView * avatar;
    UILabel * name;
    UILabel * date;
    UILabel * contentLabel;
    UIView * line;
    MJButton * replyBtn;
    
    UILabel * istopLabel;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor=[UIColor whiteColor];
        
        //头像
        avatar = [[UIImageView alloc]init];
        avatar.backgroundColor= [UIColor blackColor];
        avatar.layer.cornerRadius=19;
        avatar.layer.masksToBounds=YES;
        [self addSubview:avatar];
        [avatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(21);
            make.top.mas_equalTo(17);
            make.width.mas_equalTo(38);
            make.height.mas_equalTo(38);
        }];
        
        //昵称
        name = [[UILabel alloc]init];
        name.textColor=HW_BLACK;
        name.font=BOLD_FONT(13);
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
        
        //回复按钮
        replyBtn = [[MJButton alloc]init];
        replyBtn.mj_text=@"回复";
        replyBtn.mj_font=FONT(11);
        replyBtn.mj_textColor=HW_GRAY_WORD_1;
        [replyBtn addTarget:self action:@selector(replyBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:replyBtn];
        [replyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(date.mas_right).offset(14);
            make.centerY.mas_equalTo(date);
        }];
        
        
        //文字
        contentLabel = [[UILabel alloc]init];
        contentLabel.font=FONT(13);
        contentLabel.numberOfLines=0;
        contentLabel.textColor=HW_BLACK;
        [self addSubview:contentLabel];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(date.mas_left);
            make.top.mas_equalTo(avatar.mas_bottom).offset(10);
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
        
    }
    return self;
}




-(void)setCellData:(CommentModel*)data
{
    dataModel = data;
    
    //头像
    [avatar sd_setImageWithURL:[NSURL URLWithString:dataModel.head]];
    
    //名称
    name.text = data.nickname;
    
    //日期
    date.text = [NSString converUTCDateStr:dataModel.createTime];
    
    //评论内容
    contentLabel.text = dataModel.content;
    
    //如果是置顶
    if (data.isTop)
    {
        istopLabel.hidden=NO;
    }
    else
    {
        istopLabel.hidden=YES;
    }
    
}


-(void)replyBtnAction
{
    ContentModel * model = [[SZData sharedSZData].contentDic valueForKey:[SZData sharedSZData].currentContentId];
    [SZInputView callInputView:TypeSendReply contentModel:model replyId:dataModel.id placeHolder:[NSString stringWithFormat:@"回复@%@",dataModel.nickname] completion:^(id responseObject) {
        
    }];
    
}


-(CGSize)getHeaderSize
{
    [self layoutIfNeeded];
    
    CGFloat bottom = contentLabel.bottom;
    
    return CGSizeMake(SCREEN_WIDTH, bottom);
}


@end

