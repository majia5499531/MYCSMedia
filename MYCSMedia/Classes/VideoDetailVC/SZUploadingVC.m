//
//  SZUploadingVC.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/21.
//

#import "SZUploadingVC.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "UIImage+MJCategory.h"
#import "MJButton.h"
#import <Masonry/Masonry.h>
#import "SZManager.h"
#import "UIView+MJCategory.h"
#import "MJHUD.h"
#import "NSString+MJCategory.h"
#import "SZGlobalInfo.h"
#import "SZData.h"
#import <FSTextView/FSTextView.h>
#import "HDPhotoHelper.h"
#import "IQDataBinding.h"
#import "TopicListModel.h"
#import "FileUploadModel.h"
#import <SDWebImage/SDWebImage.h>
#import "ContentModel.h"
#import "UIScrollView+MJCategory.h"
#import "StatusModel.h"
#import "UploadModel.h"
#import "SZUserTracker.h"

@interface SZUploadingVC ()
{
    UIScrollView * bgscroll;
    
    FSTextView * inputview;
    MJButton * uploadBtn;
    UIProgressView * progress;
    MJButton * deleteBtn;
    UIImageView * coverImage;
    UILabel * successLabel;
    
    
    
    NSMutableArray * btsArr;
    
    NSString * currentDesc;
    
    FileUploadModel * uploadModel;
}
@end

@implementation SZUploadingVC



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self MJInitSubviews];
}



#pragma mark - 界面&布局
-(void)MJInitSubviews
{
    //bg color
    self.view.backgroundColor=[UIColor whiteColor];
    
    //bgscorll
    bgscroll  = [[UIScrollView alloc]init];
    bgscroll.showsVerticalScrollIndicator=NO;
    bgscroll.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:bgscroll];
    [bgscroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT);
    }];
    UITapGestureRecognizer * tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeKeyboardAction)];
    [bgscroll addGestureRecognizer:tap];
    
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
    
    //title
    UILabel * titleLabel = [[UILabel alloc]init];
    [titleLabel setFrame:CGRectMake(SCREEN_WIDTH/2-80, STATUS_BAR_HEIGHT, 160, 44)];
    titleLabel.text=@"发布作品";
    titleLabel.textColor=HW_BLACK;
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.font=BOLD_FONT(18);
    [self.view addSubview:titleLabel];
    
    //sure
    MJButton * sureBtn = [[MJButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-55-16, STATUS_BAR_HEIGHT+8, 55, 26)];
    sureBtn.mj_text=@"发布";
    sureBtn.mj_font=FONT(15);
    sureBtn.layer.cornerRadius=3;
    sureBtn.backgroundColor=HW_RED_WORD_1;
    sureBtn.mj_textColor=HW_WHITE;
    [sureBtn addTarget:self action:@selector(commitBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sureBtn];
    
    
    //视频上传
    UILabel * title1 = [[UILabel alloc]init];
    title1.text=@"视频上传";
    title1.textColor=HW_BLACK;
    title1.font=BOLD_FONT(18);
    [bgscroll addSubview:title1];
    [title1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(cancelBtn.mas_bottom).offset(21);
    }];
    
    
    //视频上传描述
    UILabel * desc1 = [[UILabel alloc]init];
    desc1.text=@"视频时长建议不超过180秒";
    desc1.textColor=HW_GRAY_WORD_1;
    desc1.font=FONT(13);
    [bgscroll addSubview:desc1];
    [desc1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(title1.mas_right).offset(6);
        make.bottom.mas_equalTo(title1.mas_bottom);
    }];
    
    
    //上传按钮
    uploadBtn = [[MJButton alloc]init];
    uploadBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_upload_add"];
    uploadBtn.mj_imageObject_sel = [UIImage getBundleImage:@"sz_upload_loading"];
    [bgscroll addSubview:uploadBtn];
    [uploadBtn addTarget:self action:@selector(uploadBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(title1.mas_left);
        make.top.mas_equalTo(title1.mas_bottom).offset(20);
        make.width.mas_equalTo(94);
        make.height.mas_equalTo(94);
    }];
    
    
    //进度条
    progress = [[UIProgressView alloc]init];
    progress.progressTintColor = HW_RED_WORD_1;
    progress.backgroundColor = HW_GRAY_BORDER;
    progress.hidden=YES;
    [bgscroll addSubview:progress];
    [progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(uploadBtn.mas_left);
        make.top.mas_equalTo(uploadBtn.mas_bottom).offset(8);
        make.width.mas_equalTo(uploadBtn.mas_width);
        make.height.mas_equalTo(4);
        make.bottom.mas_equalTo(-155);
    }];
    
    
    //封面图
    coverImage = [[UIImageView alloc]init];
    coverImage.userInteractionEnabled=YES;
    coverImage.layer.cornerRadius=6;
    coverImage.layer.masksToBounds=YES;
    coverImage.hidden=YES;
    [uploadBtn addSubview:coverImage];
    [coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    
    //删除封面
    deleteBtn = [[MJButton alloc]init];
    deleteBtn.mj_imageObjec = [UIImage getBundleImage:@"sz_cover_delete"];
    deleteBtn.hidden=YES;
    [self.view addSubview:deleteBtn];
    [deleteBtn addTarget:self action:@selector(deleteBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(uploadBtn.mas_right).offset(10);
        make.top.mas_equalTo(uploadBtn.mas_top).offset(-10);
        make.width.mas_equalTo(22);
        make.height.mas_equalTo(22);
        
    }];
    
    
    //成功label
    successLabel = [[UILabel alloc]init];
    successLabel.text = @"上传成功";
    successLabel.font=FONT(11);
    successLabel.hidden=YES;
    successLabel.textAlignment=NSTextAlignmentCenter;
    successLabel.textColor = HW_GRAY_WORD_1;
    [self.view addSubview:successLabel];
    [successLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(uploadBtn);
        make.top.mas_equalTo(uploadBtn.mas_bottom).offset(5);
    }];
    
    
    //视频简介
    UILabel * secTitle2 = [[UILabel alloc]init];
    secTitle2.text=@"视频简介";
    secTitle2.textColor=HW_BLACK;
    secTitle2.font=BOLD_FONT(18);
    [bgscroll addSubview:secTitle2];
    [secTitle2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(uploadBtn.mas_bottom).offset(35);
    }];
    
    
    //输入框
    inputview = [[FSTextView alloc]init];
    inputview.placeholder=@"填写视频介绍，让更多人了解你的作品，最多120个字符";
    inputview.font=FONT(14);
    inputview.maxLength=120;
    inputview.backgroundColor=HW_WHITE;
    inputview.textColor=HW_BLACK;
    inputview.maxLength=120;
    [inputview addTextDidChangeHandler:^(FSTextView *textView) {
        self->currentDesc = textView.text;
    }];
    [bgscroll addSubview:inputview];
    [inputview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.top.mas_equalTo(secTitle2.mas_bottom).offset(8);
        make.width.mas_equalTo(SCREEN_WIDTH-24);
        make.height.mas_equalTo(150);
    }];
    
    
}




#pragma mark - Request
-(void)requestUploadData:(NSURL*)dataUrl
{
    FileUploadModel * model = [FileUploadModel model];
    
    NSData * videoData = [NSData dataWithContentsOfURL:dataUrl];
    
    NSArray * dataArr = [NSArray arrayWithObject:videoData];
    NSArray * nameArr = [NSArray arrayWithObject:@"mjvideo"];
    
    __weak typeof (self) weakSelf = self;
    [model requestMultipartFileUpload:APPEND_SUBURL(BASE_URL, API_URL_VIDEO_UPLOAD) model:nil fileDataArray:dataArr fileNameArray:nameArr success:^(id responseObject) {
           [weakSelf requestUploadDone:model];
        } error:^(id responseObject) {
            
        } fail:^(NSError *error) {
            
        } progress:^(NSProgress *progress) {
            
            long long current = progress.completedUnitCount;
            long long total = progress.totalUnitCount;
            CGFloat value = current * 1.0/total;
            [weakSelf uploadProgressDidChange:value];
            
        }];
}



-(void)requestCommitVideo:(FileUploadModel*)upmodel
{
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:upmodel.url forKey:@"playUrl"];
    [param setValue:upmodel.coverImageUrl forKey:@"imagesUrl"];
    [param setValue:upmodel.width forKey:@"width"];
    [param setValue:upmodel.height forKey:@"height"];
    
    if ([upmodel.orientation isEqualToString:@"Portrait"])
    {
        [param setValue:@"2" forKey:@"orientation"];
    }
    else
    {
        [param setValue:@"1" forKey:@"orientation"];
    }
    
    
    [param setValue:upmodel.duration forKey:@"playDuration"];
    [param setValue:currentDesc forKey:@"title"];
    
    __weak typeof (self) weakSelf = self;
    UploadModel * model = [UploadModel model];
    model.size = upmodel.size;
    model.isJSON = YES;
    [model PostRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_URL_VIDEO_COMMIT) Params:param Success:^(id responseObject) {
        [weakSelf requestCommitDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}



#pragma mark - Rquest Done
-(void)requestUploadDone:(FileUploadModel*)model
{
    //显示封面图，删除按钮
    coverImage.hidden=NO;
    deleteBtn.hidden=NO;
    successLabel.hidden=NO;
    [coverImage sd_setImageWithURL:[NSURL URLWithString:model.coverImageUrl]];
    
    
    //隐藏进度条
    progress.hidden=YES;
    
    //保存数据
    uploadModel = model;
}

-(void)uploadProgressDidChange:(CGFloat)value
{
    __weak typeof (self) weakSelf = self;
    kDISPATCH_MAIN_THREAD(^{
        [weakSelf updateUploadProgress:value];
    });
    
}

-(void)updateUploadProgress:(CGFloat)value
{
    if (!uploadBtn.MJSelectState)
    {
        uploadBtn.MJSelectState = YES;
    }
    
    progress.hidden=NO;
    progress.progress = value;
}

-(void)requestCommitDone:(UploadModel*)model
{
    [MJHUD_Notice showSuccessView:@"你的作品发布成功，正在等待审核" inView:self.view hideAfterDelay:2];
    
    [self performSelector:@selector(dissmissVC) withObject:nil afterDelay:2];
    
    
    //行为埋点
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:model.title forKey:@"content_name"];
    [param setValue:model.id forKey:@"content_id"];
    [param setValue:model.playDuration forKey:@"works_duration"];
    [param setValue:model.size forKey:@"works_size"];
    [SZUserTracker trackingButtonEventName:@"short_video_submit" param:param];
}


-(void)dissmissVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Btn Action
-(void)cancelBtnAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)commitBtnAction
{
    if (currentDesc.length==0)
    {
        [MJHUD_Notice showNoticeView:@"请输入视频简介" inView:self.view hideAfterDelay:2];
    }
    else if (uploadModel.url.length==0)
    {
        [MJHUD_Notice showNoticeView:@"视频还未上传完成" inView:self.view hideAfterDelay:2];
    }
    else
    {
        [self requestCommitVideo:uploadModel];
    }
}

-(void)closeKeyboardAction
{
    [self.view.window endEditing:YES];
}

-(void)uploadBtnAction
{
    __weak typeof (self) weakSelf = self;
    [[HDPhotoHelper creatWithSourceType:MJImagePickerSourceTypeAlbumVideoOnly]showMediaSelectionViewFromVC:self completion:^(id data) {
        [weakSelf requestUploadData:data];
    }];
}


-(void)deleteBtnAction
{
    coverImage.hidden=YES;
    deleteBtn.hidden=YES;
    successLabel.hidden=YES;
}


#pragma mark - StatusBar
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
-(BOOL)prefersStatusBarHidden
{
    return NO;
}


@end
