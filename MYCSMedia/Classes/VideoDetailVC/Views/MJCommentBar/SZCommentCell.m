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
#import "ReplyModel.h"
#import "NSString+MJCategory.h"
#import "NSAttributedString+MJCategory.h"
#import "YYText.h"
#import "UIView+MJCategory.h"
#import "SZInputView.h"
#import "SZData.h"

@implementation SZCommentCell
{
    ReplyModel * dataModel;
    
    YYLabel * contentLabel;
    UILabel * date;
    MJButton * replyBtn;
    
    UILabel * istopLabel;
    UILabel * ispendingLabel;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        //昵称
        contentLabel = [[YYLabel alloc]init];
        contentLabel.textColor=HW_BLACK;
        contentLabel.numberOfLines=0;
        contentLabel.font=FONT(13);
        contentLabel.preferredMaxLayoutWidth = (SCREEN_WIDTH-135);
        [self addSubview:contentLabel];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(65);
            make.top.mas_equalTo(12);
        }];
        
        //时间
        date = [[UILabel alloc]init];
        date.textColor=HW_GRAY_WORD_1;
        date.font=FONT(11);
        [self addSubview:date];
        [date mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(contentLabel.mas_left).offset(0);
            make.top.mas_equalTo(contentLabel.mas_bottom).offset(3);
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
        
        
        
        
    }
    return self;
}


-(void)setCellData:(ReplyModel*)data
{
    dataModel = data;
        
    date.text = [NSString converUTCDateStr:dataModel.createTime];
    
    //如果是对话
    if (data.rnikeName.length)
    {
        NSString * content = [NSString stringWithFormat:@"%@ 回复 %@: %@",data.nickname,data.rnikeName,data.content];
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:content];
        
        [attString yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, data.nickname.length)];
        [attString yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(data.nickname.length+4, data.rnikeName.length+1)];
        
        contentLabel.attributedText = attString;
    }
    
    //如果是回复
    else
    {
        //如果是官方回复
        if (data.official)
        {
            NSString * content = [NSString stringWithFormat:@"%@: %@",data.nickname,data.content];
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:content];
            [attString yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, data.nickname.length+1)];
            [attString yy_setColor:HW_RED_WORD_1 range:NSMakeRange(0, data.nickname.length+1)];
            contentLabel.attributedText = attString;
        }
        
        else
        {
            NSString * content = [NSString stringWithFormat:@"%@: %@",data.nickname,data.content];
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:content];
            [attString yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, data.nickname.length+1)];
            contentLabel.attributedText = attString;
        }
        
        
        
        
    }
}


-(void)replyBtnAction
{
    ContentModel * model = [[SZData sharedSZData].contentDic valueForKey:[SZData sharedSZData].currentContentId];
    [SZInputView callInputView:TypeSendMail contentModel:model replyId:dataModel.id placeHolder:[NSString stringWithFormat:@"回复@%@",dataModel.nickname] completion:^(id responseObject) {
        
    }];
}


-(CGSize)getCellSize
{
    [self layoutIfNeeded];
    CGFloat bottom = date.bottom;
    return CGSizeMake(SCREEN_WIDTH, bottom);
}


@end

