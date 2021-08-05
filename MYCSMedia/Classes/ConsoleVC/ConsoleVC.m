//
//  ConsoleVC.m
//  MYCSMedia-CSAssets
//
//  Created by 马佳 on 2021/7/10.
//

#import "ConsoleVC.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "SZManager.h"
#import "MJHud.h"
#import "SZGlobalInfo.h"
@interface ConsoleVC ()

@end

@implementation ConsoleVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self MJInitSubviews];
}

#pragma mark - 界面&布局
-(void)MJInitSubviews
{
    self.view.backgroundColor=[UIColor whiteColor];
    
    NSString * str1 = [SZGlobalInfo sharedManager].SZRMToken;
    NSString * str2 = [SZGlobalInfo sharedManager].localTGT;
    NSUInteger env = [SZManager sharedManager].enviroment;
    
    
    UILabel * label1=[[UILabel alloc]init];
    [label1 setFrame:CGRectMake(15, NAVI_HEIGHT, SCREEN_WIDTH-30, 20)];
    label1.text=[NSString stringWithFormat:@"SZRMToken:%@",str1];
    label1.textColor=HW_BLACK;
    label1.textAlignment=NSTextAlignmentLeft;
    label1.font=FONT(15);
    label1.tag=1;
    label1.userInteractionEnabled=YES;
    [self.view addSubview:label1];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [label1 addGestureRecognizer:tap];
    
    UILabel * label2=[[UILabel alloc]init];
    [label2 setFrame:CGRectMake(15, NAVI_HEIGHT+30, SCREEN_WIDTH-30, 20)];
    label2.text=[NSString stringWithFormat:@"TGT:%@",str2];
    label2.textColor=HW_BLACK;
    label2.textAlignment=NSTextAlignmentLeft;
    label2.font=FONT(15);
    label2.tag=2;
    label2.userInteractionEnabled=YES;
    [self.view addSubview:label2];
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [label2 addGestureRecognizer:tap2];
    
    UILabel * label3=[[UILabel alloc]init];
    [label3 setFrame:CGRectMake(15, NAVI_HEIGHT+60, SCREEN_WIDTH-30, 20)];
    label3.text=[NSString stringWithFormat:@"ENV:%lu",(unsigned long)env];
    label3.textColor=HW_BLACK;
    label3.textAlignment=NSTextAlignmentLeft;
    label3.font=FONT(15);
    label3.tag=3;
    label3.userInteractionEnabled=YES;
    [self.view addSubview:label3];
    UITapGestureRecognizer * tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [label3 addGestureRecognizer:tap3];
}


-(void)tapAction:(UIGestureRecognizer*)gest
{
    UILabel * label = (UILabel*)gest.view;
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:label.text];
    
    [MJHUD_Notice showNoticeView:[NSString stringWithFormat:@"复制：%@",label.text] inView:self.view hideAfterDelay:0.7];
}


@end
