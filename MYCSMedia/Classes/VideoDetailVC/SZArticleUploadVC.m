//
//  SZNewsUploadVC.m
//  MYCSMedia
//
//  Created by 马佳 on 2022/4/19.
//

#import "SZArticleUploadVC.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "UIImage+MJCategory.h"
#import "MJButton.h"
#import <Masonry/Masonry.h>

@interface SZArticleUploadVC ()

@end

@implementation SZArticleUploadVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    [self initSubviews];
}

-(void)initSubviews
{
    self.view.backgroundColor=[UIColor whiteColor];
    
    //navi
    UIView * navibg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, STATUS_BAR_HEIGHT + 44)];
    navibg.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:navibg];
    
    //cancel
    MJButton * cancelBtn = [[MJButton alloc]initWithFrame:CGRectMake(16, STATUS_BAR_HEIGHT+8, 55, 26)];
    cancelBtn.mj_text=@"取消";
    cancelBtn.mj_font=BOLD_FONT(15);
    cancelBtn.mj_textColor=HW_BLACK;
    [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    //cancel
    MJButton * previewBtn = [[MJButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-16-55, STATUS_BAR_HEIGHT+8, 55, 26)];
    previewBtn.mj_text=@"预览";
    previewBtn.mj_font=BOLD_FONT(15);
    previewBtn.mj_textColor=[UIColor colorWithHexString:@"1C337A"];
    [previewBtn addTarget:self action:@selector(previewBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:previewBtn];
    
    //title
    UILabel * titleLabel = [[UILabel alloc]init];
    [titleLabel setFrame:CGRectMake(SCREEN_WIDTH/2-80, STATUS_BAR_HEIGHT, 160, 44)];
    titleLabel.text=@"发布作品";
    titleLabel.textColor=HW_BLACK;
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.font=BOLD_FONT(18);
    [self.view addSubview:titleLabel];
}


-(void)cancelBtnAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)previewBtnAction
{
    
}


@end
