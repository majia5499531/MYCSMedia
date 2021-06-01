//
//  SZCommentBar.m
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/29.
//

#import "SZCommentBar.h"
#import "SZDefines.h"
#import "UIView+MJCategory.h"
#import "UIColor+MJCategory.h"
#import <Masonry/Masonry.h>
#import "MJButton.h"
#import "UIImage+MJCategory.h"
#import "SZManger.h"
#import "SZInputView.h"
#import "SZCommentList.h"

@interface SZCommentBar ()
@property(strong,nonatomic)SZCommentList * listViewBG;
@end

@implementation SZCommentBar
{
    UILabel * titleLabel;
    UILabel * countLabel;
    MJButton * sendBtn;
    MJButton * collectBtn;
    MJButton * zanBtn;
    
    
    
    
    
    NSString * contentId;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        self.backgroundColor=HW_GRAY_BG_1;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentTapAction)];
        [self addGestureRecognizer:tap];
        
        [self setFrame:CGRectMake(0, SCREEN_HEIGHT-COMMENT_BAR_HEIGHT, SCREEN_WIDTH, COMMENT_BAR_HEIGHT)];
        
        [self MJInitSubviews];
    }
    return self;
}

#pragma mark - 界面&布局
-(void)MJInitSubviews
{
    [self MJSetPartRadius:8 RoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight];
    
    titleLabel = [[UILabel alloc]init];
    titleLabel.text=@"最新评论";
    titleLabel.font=FONT(12);
    titleLabel.textColor=HW_WHITE;
    [self addSubview:titleLabel];


    countLabel = [[UILabel alloc]init];
    countLabel.text=@"(711)";
    countLabel.font=FONT(11);
    countLabel.textColor=HW_WHITE;
    [self addSubview:countLabel];


    sendBtn = [[MJButton alloc]init];
    [sendBtn setImage:[UIImage getBundleImage:@"sz_write"] forState:UIControlStateNormal];
    sendBtn.imageFrame=CGRectMake(13, 9, 12.5, 13);
    sendBtn.titleFrame=CGRectMake(32, 8, 100, 15);
    sendBtn.mj_text=@"写评论...";
    sendBtn.mj_font=FONT(13);
    sendBtn.mj_textColor=HW_GRAY_WORD_1;
    sendBtn.backgroundColor=HW_GRAY_BG_2;
    sendBtn.layer.cornerRadius=16;
    [sendBtn addTarget:self action:@selector(sendCommentAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendBtn];



    //收藏
    collectBtn = [[MJButton alloc]init];
    collectBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_collect"];
    collectBtn.mj_imageObject_sel = [UIImage getBundleImage:@"sz_collect_sel"];
    [collectBtn addTarget:self action:@selector(collectBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:collectBtn];


    //点赞
    zanBtn = [[MJButton alloc]init];
    zanBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_zan"];
    zanBtn.mj_imageObject_sel = [UIImage getBundleImage:@"sz_zan_sel"];
    [zanBtn setBadgeNum:@"999" style:2];
    [zanBtn addTarget:self action:@selector(zanBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:zanBtn];
    
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(22);
        make.top.mas_equalTo(12);
    }];

    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_right).offset(5);
        make.bottom.mas_equalTo(titleLabel.mas_bottom);
    }];

    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(40);
        make.height.mas_equalTo(32);
        make.right.mas_equalTo(self).offset(-110);
    }];

    [collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sendBtn.mas_right).offset(10);
        make.centerY.mas_equalTo(sendBtn.mas_centerY);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];

    [zanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(collectBtn.mas_right).offset(1);
        make.centerY.mas_equalTo(sendBtn.mas_centerY);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
}




- (void)mjsetContentId:(NSString *)ID
{
    contentId = ID;
}




#pragma mark - Getter
-(UIView *)listViewBG
{
    if (!_listViewBG)
    {
        _listViewBG = [[SZCommentList alloc]init];
    }
    return _listViewBG;;
}


#pragma mark - Btn Action
-(void)commentTapAction
{
    [self.superview addSubview:self.listViewBG];
    [self.listViewBG setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    [self.listViewBG show:YES];
}



//
//-(void)changeBarColor:(NSInteger)type
//{
//    //白色
//    if (type==1)
//    {
//        self.backgroundColor=HW_WHITE;
//        sendBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_write_black"];
//        sendBtn.mj_textColor=HW_BLACK;
//        sendBtn.backgroundColor=HW_GRAY_BG_5;
//        collectBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_collect_black"];
//        zanBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_zan_black"];
//    }
//    //黑色
//    else
//    {
//        self.backgroundColor=HW_GRAY_BG_1;
//        sendBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_write"];
//        sendBtn.mj_textColor=HW_GRAY_WORD_1;
//        sendBtn.backgroundColor=HW_GRAY_BG_2;
//        collectBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_collect"];
//        zanBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_zan"];
//    }
//}






-(void)sendCommentAction
{
    [SZInputView callInputView:0 newsID:@"" placeHolder:@"发表您的评论" completion:^(id responseObject) {
        NSLog(@"completion callback");
    }];
    
}

-(void)zanBtnAction
{
    zanBtn.MJSelectState = !zanBtn.MJSelectState;
    
    if ([SZManger sharedManager].delegate) {
        NSLog(@"query token:%@",[[SZManger sharedManager].delegate getAccessToken]);
    }
    
}

-(void)collectBtnAction
{
    collectBtn.MJSelectState = !collectBtn.MJSelectState;
    
    
    if ([SZManger sharedManager].delegate) {
        [[SZManger sharedManager].delegate gotoLoginPage];
    }
}


@end
