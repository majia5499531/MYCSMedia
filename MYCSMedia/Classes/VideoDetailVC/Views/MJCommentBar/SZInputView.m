//
//  SZInputView.m
//  智慧长沙
//
//  Created by 马佳 on 2020/3/18.
//  Copyright © 2020 ChangShaBroadcastGroup. All rights reserved.
//

#import "SZInputView.h"
#import <FSTextView/FSTextView.h>
#import "MJButton.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "UIView+MJCategory.h"
#import "SZManager.h"
#import "MJHud.h"
#import "BaseModel.h"
#import "SZGlobalInfo.h"
#import "SZData.h"
#import "Masonry.h"
#import "SZUserTracker.h"


@interface SZInputView ()<UITextViewDelegate>
@property(strong,nonatomic)UIWindow * inputWindow;
@end

@implementation SZInputView
{
    //键盘高度
    CGFloat keyboardHeight;
    
    //输入框
    FSTextView * inputView;
    UIView * inputBG;
    MJButton * sendBtn;
    
    //data
    SZInputViewType inputType;
    ContentModel * ContentM;
    NSString * replyID;
    
    //block
    CompletionBlock resultBlock;
}



+(instancetype)sharedSZInputView
{
    static SZInputView * singleTon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (singleTon == nil)
        {
            singleTon = [[SZInputView alloc]init];
        }
        });
    return singleTon;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //window
        self.inputWindow = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
        self.inputWindow.windowLevel = UIWindowLevelStatusBar+300;
        
        //maskView
        UIView * maskView = [[UIView alloc]initWithFrame:self.inputWindow.bounds];
        maskView.backgroundColor=HW_BLACK;
        maskView.alpha=0.1;
        [self.inputWindow addSubview:maskView];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeCustomWindow)];
        [maskView addGestureRecognizer:tap];
        
        //输入框背景
        inputBG = [[UIView alloc]init];
        inputBG.backgroundColor=HW_WHITE;
        [self.inputWindow addSubview:inputBG];
        
        //输入框
        __weak typeof (self) weakSelf = self;
        inputView = [[FSTextView alloc]init];
        inputView.layer.cornerRadius=7;
        inputView.layer.backgroundColor=HW_GRAY_BG_White.CGColor;
        inputView.autocapitalizationType=UITextAutocapitalizationTypeNone;
        inputView.maxLength=120;
        inputView.font=FONT(15);
        inputView.textColor=HW_BLACK;
        inputView.delegate=self;
        [inputView addTextDidChangeHandler:^(FSTextView *textView) {
            [weakSelf inputviewDidInput:textView.text];
        }];
        [inputBG addSubview:inputView];
        
        //发布按钮
        sendBtn = [[MJButton alloc]init];
        sendBtn.mj_text=@"发布";
        sendBtn.mj_textColor=HW_BLACK;
        sendBtn.mj_font = BOLD_FONT(15);
        [sendBtn addTarget:self action:@selector(sendBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [inputBG addSubview:sendBtn];
        
        //layout
        [inputView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(7.5);
            make.right.mas_equalTo(-100);
            make.bottom.mas_equalTo(-7.5);
        }];
       
        
        [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(inputView.mas_right);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(inputView.mas_height);
            make.centerY.mas_equalTo(inputView.mas_centerY);
        }];
        
        [inputBG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.bottom.mas_equalTo(0);
        }];
        
        [self.inputWindow layoutIfNeeded];
        
        
        
        //监听键盘
        [self addKeyboardNotification];
    
    }
    return self;
}


#pragma mark - 公共方法
+(void)callInputView:(SZInputViewType)type contentModel:(ContentModel*)M replyId:(NSString*)replyId placeHolder:(NSString*)placeholder completion:(CompletionBlock)finish
{
    //未登录则跳转登录
    if (![SZGlobalInfo sharedManager].SZRMToken.length)
    {
        [SZGlobalInfo mjshowLoginAlert];
        return;
    }
    
    //显示window
    SZInputView * view = [SZInputView sharedSZInputView];
    view.inputWindow.hidden=NO;
    [view.inputWindow makeKeyAndVisible];
    
    //配置属性
    view->inputType = type;
    view->ContentM = M;
    view->inputView.placeholder = placeholder;
    view->resultBlock = finish;
    view->replyID = replyId;
    
    //输入框获取焦点
    [view->inputView becomeFirstResponder];
}

-(void)dissmissInputView
{
    [inputView resignFirstResponder];
    
    self.inputWindow.hidden = YES;
    [self.inputWindow resignKeyWindow];
}



#pragma mark - 键盘
-(void)addKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(keyboardWillShow:)
                                          name:UIKeyboardWillShowNotification
                                          object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(keyboardWillHide:)
                                          name:UIKeyboardWillHideNotification
                                          object:nil];
}
-(void)removeKeyboardNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)keyboardWillShow:(NSNotification*)notify
{
    NSDictionary *userInfo = [notify userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardHeight = keyboardRect.size.height;
    
    [inputBG mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.bottom.mas_equalTo(-keyboardHeight);
    }];
    [self.inputWindow layoutIfNeeded];
    
}
-(void)keyboardWillHide:(NSNotification*)notify
{
    [inputBG mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.bottom.mas_equalTo(0);
    }];
    [self.inputWindow layoutIfNeeded];
}
-(void)inputviewDidInput:(NSString*)text
{
    CGSize size = [inputView sizeThatFits:CGSizeMake(inputView.width, 37)];
    
    CGFloat inputHeight = size.height;
    if (inputHeight>150)
    {
        inputHeight = 150;
    }
    
    [inputView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(7.5);
        make.right.mas_equalTo(-100);
        make.bottom.mas_equalTo(-7.5);
        make.height.mas_equalTo(inputHeight);
    }];
}


#pragma mark - Btn Actions
-(void)closeCustomWindow
{
    [self dissmissInputView];
}

-(void)sendBtnAction
{
    NSString * text = [inputView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length)
    {
        if (inputType==TypeSendComment)
        {
            [self requestForSendingComment:inputView.text];
        }
        else
        {
            [self requestForSendingReply:inputView.text];
        }
        
    }
    else
    {
        
        [MJHUD_Notice showNoticeView:@"评论不能为空" inView:self.inputWindow hideAfterDelay:1.0];
    }
}


#pragma mark - Request
-(void)requestForSendingComment:(NSString*)text
{
    BaseModel * model = [BaseModel model];
    __weak typeof (self) weakSelf = self;
    model.isJSON = YES;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:text forKey:@"content"];
    [param setValue:ContentM.id forKey:@"contentId"];
    
    UIWindow * keywindow = MJ_KEY_WINDOW;
    
    
    [model PostRequestInView:keywindow WithUrl:APPEND_SUBURL(BASE_URL, API_URL_SEND_COMMENT) Params:param Success:^(id responseObject) {
        [weakSelf requestSendingDone];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}


-(void)requestForSendingReply:(NSString*)text
{
    BaseModel * model = [BaseModel model];
    __weak typeof (self) weakSelf = self;
    model.isJSON = YES;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:text forKey:@"reply"];
    [param setValue:replyID forKey:@"id"];
    
    UIWindow * keywindow = MJ_KEY_WINDOW;
    
    [model PostRequestInView:keywindow WithUrl:APPEND_SUBURL(BASE_URL, API_URL_SEND_REPLY) Params:param Success:^(id responseObject) {
        [weakSelf requestSendingDone];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}


#pragma mark - Request Done
-(void)requestSendingDone
{
    //关闭窗口
    [self closeCustomWindow];
    
    //清空输入框
    inputView.text=@"";
    
    //刷新评论列表
    [[SZData sharedSZData]requestCommentListData];

    //回调
    if (replyID.length)
    {
        resultBlock(replyID);
    }
    else
    {
        resultBlock(ContentM.id);
    }
    
    
    //行为埋点
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:ContentM.id forKey:@"content_id"];
    [param setValue:ContentM.title forKey:@"content_name"];
    [param setValue:ContentM.keywords forKey:@"content_key"];
    [param setValue:ContentM.tags forKey:@"content_list"];
    [param setValue:ContentM.classification forKey:@"content_classify"];
    [param setValue:ContentM.thirdPartyId forKey:@"third_ID"];
    [param setValue:ContentM.startTime forKey:@"create_time"];
    [param setValue:ContentM.issueTimeStamp forKey:@"publish_time"];
    [param setValue:ContentM.type forKey:@"content_type"];
    
    [SZUserTracker trackingButtonEventName:@"content_comment" param:param];
    
    
}






@end
