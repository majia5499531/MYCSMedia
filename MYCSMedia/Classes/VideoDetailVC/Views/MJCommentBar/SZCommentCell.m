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
#import "CommentModel.h"

@implementation SZCommentCell
{
    CommentModel * commentModel;
    ReplyModel * dataModel;
    
    YYLabel * contentLabel;
    UILabel * date;
    MJButton * replyBtn;
    
    UILabel * istopLabel;
    UILabel * ispendingLabel;
    
    MJButton * zanBtn;
    UILabel * zanCount;
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
        
        //点赞按钮
        zanCount = [[UILabel alloc]init];
        zanCount.font=FONT(11);
        zanCount.textColor=HW_GRAY_WORD_1;
        [self addSubview:zanCount];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentZanBtnAction)];
        zanCount.userInteractionEnabled=YES;
        [zanCount addGestureRecognizer:tap];
        [zanCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-20);
            make.centerY.mas_equalTo(replyBtn);
        }];
        
        //点赞数
        zanBtn = [[MJButton alloc]init];
        zanBtn.mj_imageObjec=[UIImage getBundleImage:@"comment_zan"];
        zanBtn.mj_imageObject_sel = [UIImage getBundleImage:@"comment_zan_sel"];
        zanBtn.imageFrame=CGRectMake(30, 2.5, 15, 15);
        zanBtn.ScaleUpBounce=YES;
        [zanBtn addTarget:self action:@selector(commentZanBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:zanBtn];
        [zanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(zanCount.mas_left).offset(0);
            make.centerY.mas_equalTo(zanCount);
            make.width.mas_equalTo(50);
        }];
        
        
    }
    return self;
}


-(void)setCommentData:(CommentModel*)commentM replyData:(ReplyModel*)replyM
{
    dataModel = replyM;
    commentModel = commentM;
        
    date.text = [NSString converUTCDateStr:dataModel.createTime];
    
    //点赞数
    if (dataModel.likeCount>0)
    {
        zanCount.text = [NSString stringWithFormat:@"%d",(int)dataModel.likeCount];
    }
    else
    {
        zanCount.text = @"";
    }
    
    
    //是否点赞
    zanBtn.MJSelectState=dataModel.whetherLike;
    if (dataModel.whetherLike)
    {
        zanCount.textColor=HW_RED_WORD_1;
        zanBtn.MJSelectState=YES;
    }
    else
    {
        zanCount.textColor=HW_GRAY_WORD_1;
        zanBtn.MJSelectState=NO;
    }
    
    //如果是对话
    if (dataModel.rnikeName.length)
    {
        NSString * content = [NSString stringWithFormat:@"%@ 回复 %@: %@",dataModel.nickname,dataModel.rnikeName,dataModel.content];
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:content];
        
        [attString yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, dataModel.nickname.length)];
        [attString yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(dataModel.nickname.length+4, dataModel.rnikeName.length+1)];
        
        contentLabel.attributedText = attString;
    }
    
    //如果是回复
    else
    {
        //如果是官方回复
        if (dataModel.official)
        {
            NSString * content = [NSString stringWithFormat:@"%@: %@",dataModel.nickname,dataModel.content];
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:content];
            [attString yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, dataModel.nickname.length+1)];
            [attString yy_setColor:HW_RED_WORD_1 range:NSMakeRange(0, dataModel.nickname.length+1)];
            contentLabel.attributedText = attString;
        }
        
        else
        {
            NSString * content = [NSString stringWithFormat:@"%@: %@",dataModel.nickname,dataModel.content];
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:content];
            [attString yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, dataModel.nickname.length+1)];
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

-(void)commentZanBtnAction
{
    [[SZData sharedSZData]requestCommentZan:commentModel.id replyId:dataModel.id];
}

@end

