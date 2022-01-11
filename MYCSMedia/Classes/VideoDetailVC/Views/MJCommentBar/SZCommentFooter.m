//
//  SZCommentFooter.m
//  MYCSMedia
//
//  Created by 马佳 on 2022/1/4.
//

#import "SZCommentFooter.h"
#import "YYlabel.h"
#import "SZDefines.h"
#import "Masonry.h"
#import "UIView+MJCategory.h"
#import "UIColor+MJCategory.h"
#import "YYText.h"
#import "SZData.h"
#import "ReplyListModel.h"
#import "SZDefines.h"
#import "SZGlobalInfo.h"

@implementation SZCommentFooter
{
    CommentModel * dataModel;
    
    UIView * line;
    YYLabel * descLabel;
    YYLabel * closeLabel;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {        
        descLabel = [[YYLabel alloc]init];
        descLabel.font=FONT(13);
        descLabel.textColor=HW_BLACK;
        descLabel.preferredMaxLayoutWidth = SCREEN_WIDTH-130;
        [self addSubview:descLabel];
        [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(65);
        }];
        
        line = [[UIView alloc]init];
        line.backgroundColor=HW_GRAY_BORDER;
        [self addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(30);
            make.width.mas_equalTo(SCREEN_WIDTH-60);
            make.height.mas_equalTo(MINIMUM_PX);
            make.top.mas_equalTo(descLabel.mas_bottom).offset(10);
        }];
    }
    return self;
}

-(void)setCellData:(CommentModel *)data
{
    dataModel = data;
    
    //大于两条回复，显示展开按钮
    if (data.totalReplyCount.integerValue>2)
    {
        descLabel.hidden=NO;
        [line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(30);
            make.width.mas_equalTo(SCREEN_WIDTH-60);
            make.height.mas_equalTo(MINIMUM_PX);
            make.top.mas_equalTo(descLabel.mas_bottom).offset(10);
        }];
        
        //已显示数小于总数
        if (data.replyShowCount == data.replyInitialCount)
        {
            NSString * str = [NSString stringWithFormat:@"%@ 等人共%@条回复  展开",data.lastReplyName,data.totalReplyCount];
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:str];
            [attString yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, data.lastReplyName.length)];
            
            __weak typeof (self) weakSelf = self;
            [attString yy_setTextHighlightRange:NSMakeRange(str.length-2, 2) color:HW_RED_WORD_1 backgroundColor:[UIColor whiteColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                [weakSelf unfoldReplys:YES];
            }];
            
            descLabel.attributedText = attString;
        }
        //展开过一次后，显示“继续展开”
        else if (data.replyShowCount<data.totalReplyCount.integerValue)
        {
            NSString * str = [NSString stringWithFormat:@"继续展开"];
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:str];
            __weak typeof (self) weakSelf = self;
            [attString yy_setTextHighlightRange:NSMakeRange(0, 4) color:HW_RED_WORD_1 backgroundColor:[UIColor whiteColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                [weakSelf unfoldReplys:YES];
            }];
            
            descLabel.attributedText = attString;
        }
        
        //全部已显示
        else
        {
            __weak typeof (self) weakSelf = self;
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"收起"];
            [attString yy_setTextHighlightRange:NSMakeRange(0, 2) color:HW_RED_WORD_1 backgroundColor:[UIColor whiteColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                [weakSelf unfoldReplys:NO];
            }];
            descLabel.attributedText = attString;
        }
        
        
        
    }
    else
    {
        descLabel.hidden=YES;
        
        [line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(30);
            make.width.mas_equalTo(SCREEN_WIDTH-60);
            make.height.mas_equalTo(MINIMUM_PX);
            make.top.mas_equalTo(12);
        }];
    }
}



-(void)unfoldReplys:(BOOL)b
{
    //展开
    if (b)
    {
        //如果已经从接口取完，则新增显示五条
        if (dataModel.dataArr.count == dataModel.totalReplyCount.integerValue)
        {
            
            NSInteger targetCount = dataModel.replyShowCount + 5;
            
            //如果展开五条超范围了，则按照数据总量全部展开
            if (targetCount>dataModel.dataArr.count)
            {
                targetCount = dataModel.dataArr.count;
            }
            
            dataModel.replyShowCount = targetCount;
            
            [self refreshCollectionView];
            
            
        }
        
        //如果回复数没有从接口取完，则去接口取
        else
        {
            [self requestReplyListData:dataModel.id];
        }
        
    }
    
    //收起
    else
    {
        
        //展示的数量修改为初始数量
        dataModel.replyShowCount = dataModel.replyInitialCount;
        
        [self refreshCollectionView];
        
        
    }
    
}


-(CGSize)getHeaderSize
{
    [self layoutIfNeeded];
    
    CGFloat bottom = line.bottom;
    
    return CGSizeMake(SCREEN_WIDTH, bottom);
}



-(void)refreshCollectionView
{
    UICollectionView * collectionview = (UICollectionView*)self.superview;
    [collectionview reloadData];
}

#pragma mark - Request
-(void)requestReplyListData:(NSString*)commentID
{
    ReplyListModel * model = [ReplyListModel model];
    model.isJSON = YES;
    model.hideLoading = YES;
    model.hideErrorMsg = YES;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:[NSNumber numberWithInteger:dataModel.contentId] forKey:@"contentId"];
    [param setValue:@"9999" forKey:@"pageSize"];
    [param setValue:@"1" forKey:@"pageNum"];
    [param setValue:commentID forKey:@"pcommentId"];
    
    __weak typeof (self) weakSelf = self;
    [model PostRequestInView:nil WithUrl:APPEND_SUBURL(BASE_URL, API_URL_GET_REPLY_LIST) Params:param Success:^(id responseObject) {
            [weakSelf requestDone:model.dataArr];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}

-(void)requestDone:(NSArray*)replys
{
    [dataModel.dataArr removeAllObjects];
    [dataModel.dataArr addObjectsFromArray:replys];
    
    [self unfoldReplys:YES];
}

@end
