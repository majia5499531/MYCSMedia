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


@interface SZInputView ()<UITextViewDelegate>
@property(strong,nonatomic)UIWindow * inputWindow;
@end

@implementation SZInputView
{
    //键盘高度
    CGFloat keyboardHeight;
    
    //输入框
    FSTextView * input;
    UIView * inputBG;
    MJButton * sendBtn;
    
    //data
    NSString * contentId;
    
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
        inputBG = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 50)];
        inputBG.backgroundColor=HW_WHITE;
        [self.inputWindow addSubview:inputBG];
        
        //输入框
        input = [[FSTextView alloc]initWithFrame:CGRectMake(15, 7.5, inputBG.frame.size.width-100, 35)];
        input.layer.cornerRadius=7;
        input.layer.backgroundColor=HW_GRAY_BG_5.CGColor;
        input.autocapitalizationType=UITextAutocapitalizationTypeNone;
        input.font=FONT(15);
        input.textColor=HW_BLACK;
        input.delegate=self;
        [inputBG addSubview:input];
        
        //发布按钮
        sendBtn = [[MJButton alloc]initWithFrame:CGRectMake(input.right, input.top, inputBG.width-input.right, input.height)];
        sendBtn.mj_text=@"发布";
        sendBtn.mj_textColor=HW_BLACK;
        sendBtn.mj_font = BOLD_FONT(15);
        [sendBtn addTarget:self action:@selector(sendBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [inputBG addSubview:sendBtn];
        
        //监听键盘
        [self addKeyboardNotification];
    }
    return self;
}


#pragma mark - 公共方法
+(void)callInputView:(NSInteger)type contentId:(NSString*)contentId placeHolder:(NSString*)placeholder completion:(CompletionBlock)finish
{
    //未登录则跳转登录
    if (![SZManager sharedManager].SZRMToken.length)
    {
        [SZManager mjgoToLoginPage];
        return;
    }
    
    SZInputView * view = [SZInputView sharedSZInputView];
    
    view.inputWindow.hidden=NO;
    [view.inputWindow makeKeyAndVisible];
    
    
    view->contentId = contentId;
    view->input.placeholder = placeholder;
    view->resultBlock = finish;
    
    [view->input becomeFirstResponder];
}

-(void)dissmissInputView
{
    [input resignFirstResponder];
    
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
    
    [inputBG setFrame:CGRectMake(0, SCREEN_HEIGHT-keyboardHeight-inputBG.height, inputBG.width, inputBG.height)];
}
-(void)keyboardWillHide:(NSNotification*)notify
{
    [inputBG setFrame:CGRectMake(0, SCREEN_HEIGHT, inputBG.width, inputBG.height)];
}
-(void)textViewDidChange:(UITextView *)textView
{
    CGSize siz = [textView sizeThatFits:CGSizeMake(inputBG.width-100, 34)];
    [textView setFrame:CGRectMake(15, 8, inputBG.width-100, siz.height)];
    [inputBG setFrame:CGRectMake(0, SCREEN_HEIGHT-keyboardHeight-(siz.height+16), inputBG.width, siz.height+16)];
}


#pragma mark - Btn Actions
-(void)closeCustomWindow
{
    [self dissmissInputView];
}

-(void)sendBtnAction
{
    NSString * text = [input.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length)
    {
        
        [self requestForSendingComment:input.text];
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
    [param setValue:contentId forKey:@"contentId"];
    
    UIWindow * keywindow = MJ_KEY_WINDOW;
    
    
    [model PostRequestInView:keywindow WithUrl:APPEND_SUBURL(BASE_URL, API_URL_SEND_COMMENT) Params:param Success:^(id responseObject) {
        [weakSelf requestSendingDone];
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];
    
    
}


#pragma mark - Request Done
-(void)requestSendingDone
{
    //关闭窗口
    [self closeCustomWindow];
    
    //清空输入框
    input.text=@"";

    //回调
    resultBlock(contentId);
}
-(void)requestFailed
{
//    [self closeCustomWindow];
}

 

@end
