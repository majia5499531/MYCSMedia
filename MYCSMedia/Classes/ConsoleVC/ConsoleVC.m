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
    
    NSString * str1 = [SZManager sharedManager].SZRMToken;
    NSString * str2 = [SZManager sharedManager].localTGT;
    NSUInteger env = [SZManager sharedManager].enviroment;
    
    UILabel * labellabel=[[UILabel alloc]init];
    [labellabel setFrame:CGRectMake(15, NAVI_HEIGHT, 200, 20)];
    labellabel.text=[NSString stringWithFormat:@"SZRMToken:%@",str1];
    labellabel.textColor=HW_BLACK;
    labellabel.textAlignment=NSTextAlignmentLeft;
    labellabel.font=FONT(15);
    [self.view addSubview:labellabel];
    
    UILabel * label2=[[UILabel alloc]init];
    [label2 setFrame:CGRectMake(15, NAVI_HEIGHT+30, 200, 20)];
    label2.text=[NSString stringWithFormat:@"TGT:%@",str2];
    label2.textColor=HW_BLACK;
    label2.textAlignment=NSTextAlignmentLeft;
    label2.font=FONT(15);
    [self.view addSubview:label2];
    
    UILabel * label3=[[UILabel alloc]init];
    [label3 setFrame:CGRectMake(15, NAVI_HEIGHT+60, 200, 20)];
    label3.text=[NSString stringWithFormat:@"ENV:%lu",(unsigned long)env];
    label3.textColor=HW_BLACK;
    label3.textAlignment=NSTextAlignmentLeft;
    label3.font=FONT(15);
    [self.view addSubview:label3];
}

@end

