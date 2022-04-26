//
//  SZVideoUploadVC.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/21.
//

#import "SZVideoUploadVC.h"
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
#import "TopicModel.h"
#import "FileUploadModel.h"
#import <SDWebImage/SDWebImage.h>
#import "ContentModel.h"
#import "UIScrollView+MJCategory.h"
#import "StatusModel.h"
#import "UploadModel.h"
#import "SZUserTracker.h"


@interface SZVideoUploadVC ()
{
    UIScrollView * bgscroll;

    MJButton * uploadBtn;
    UIProgressView * progress;
    MJButton * deleteBtn;
    UIImageView * coverImage;
    UILabel * coverLabel;
    UIView * topicTagsBG;
    
    
    NSMutableArray * topicBtnArr;
    
    TopicModel * topicsModel;
    FileUploadModel * uploadModel;
}
@property(strong,nonatomic)FSTextView * inputview;
@end

@implementation SZVideoUploadVC



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self MJInitSubviews];
    
    [self requestTopicLists];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showProtocol];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //检查登录状态
    [SZGlobalInfo checkLoginStatus:nil];
}

#pragma mark - 界面&布局
-(void)MJInitSubviews
{
    //bg color
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
    
    //title
    UILabel * titleLabel = [[UILabel alloc]init];
    [titleLabel setFrame:CGRectMake(SCREEN_WIDTH/2-80, STATUS_BAR_HEIGHT, 160, 44)];
    titleLabel.text=@"发布作品";
    titleLabel.textColor=HW_BLACK;
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.font=BOLD_FONT(18);
    [self.view addSubview:titleLabel];
    
    //bgscorll
    bgscroll  = [[UIScrollView alloc]init];
    bgscroll.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:bgscroll];
    [bgscroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(STATUS_BAR_HEIGHT+44);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT-NAVI_HEIGHT);
    }];
    UITapGestureRecognizer * tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeKeyboardAction)];
    [bgscroll addGestureRecognizer:tap];
    
    
    //视频上传
    UILabel * title1 = [[UILabel alloc]init];
    title1.text=@"视频上传";
    title1.textColor=HW_BLACK;
    title1.font=BOLD_FONT(18);
    [bgscroll addSubview:title1];
    [title1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(20);
    }];


    //视频上传描述
    UILabel * desc1 = [[UILabel alloc]init];
    desc1.text=@"视频时长建议不超过180秒，小于25M";
    desc1.textColor=HW_GRAY_BG_9;
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
    }];


    //封面图
    coverImage = [[UIImageView alloc]init];
    coverImage.userInteractionEnabled=YES;
    coverImage.layer.cornerRadius=6;
    coverImage.layer.masksToBounds=YES;
    coverImage.contentMode=UIViewContentModeScaleAspectFill;
    coverImage.hidden=YES;
    [bgscroll addSubview:coverImage];
    UITapGestureRecognizer * covertap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(coverImageTapAction)];
    [coverImage addGestureRecognizer:covertap];
    [coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(uploadBtn);
        make.width.height.mas_equalTo(uploadBtn);
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
    coverLabel = [[UILabel alloc]init];
    coverLabel.text = @"选封面";
    coverLabel.font=FONT(13);
    coverLabel.textAlignment=NSTextAlignmentCenter;
    coverLabel.textColor = HW_WHITE;
    coverLabel.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [coverImage addSubview:coverLabel];
    [coverLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(coverImage);
        make.width.mas_equalTo(coverImage.mas_width);
        make.height.mas_equalTo(24);
        make.bottom.mas_equalTo(0);
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
    _inputview = [[FSTextView alloc]init];
    _inputview.placeholder=@"填写视频介绍，让更多人了解你的作品，最多120个字符";
    _inputview.placeholderColor=HW_GRAY_BG_9;
    _inputview.font=FONT(15);
    _inputview.backgroundColor=HW_WHITE;
    _inputview.textColor=HW_BLACK;
    _inputview.maxLength=120;
    __weak typeof (self) weakSelf = self;
    [_inputview addTextDidChangeHandler:^(FSTextView *textView) {
        [weakSelf.inputview mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(weakSelf.inputview.contentSize.height);
        }];
    }];
    [bgscroll addSubview:_inputview];
    [_inputview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.top.mas_equalTo(secTitle2.mas_bottom).offset(8);
        make.width.mas_equalTo(SCREEN_WIDTH-24);

    }];

    //话题选择
    UILabel * secTitle3 = [[UILabel alloc]init];
    secTitle3.text=@"话题选择";
    secTitle3.textColor=HW_BLACK;
    secTitle3.font=BOLD_FONT(18);
    [bgscroll addSubview:secTitle3];
    [secTitle3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(_inputview.mas_bottom).offset(55);
    }];

    //话题选择desc
    UILabel * desc3 = [[UILabel alloc]init];
    desc3.text=@"非必选";
    desc3.textColor=HW_GRAY_BG_9;
    desc3.font=FONT(13);
    [bgscroll addSubview:desc3];
    [desc3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(secTitle3.mas_right).offset(6);
        make.bottom.mas_equalTo(secTitle3.mas_bottom);
    }];

    //话题标签组
    topicTagsBG = [[UIView alloc]init];
    [topicTagsBG setWidth:SCREEN_WIDTH];
    [bgscroll addSubview:topicTagsBG];
    [topicTagsBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(secTitle3.mas_bottom).offset(20);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(55);
    }];

    //保存按钮
    MJButton * saveBtn = [[MJButton alloc]init];
    saveBtn.mj_text = @"保存草稿";
    saveBtn.mj_font=FONT(17);
    saveBtn.mj_textColor=HW_BLACK;
    saveBtn.layer.cornerRadius=22;
    saveBtn.layer.borderWidth=MINIMUM_PX;
    saveBtn.layer.borderColor=HW_GRAY_BG_9.CGColor;
    [bgscroll addSubview:saveBtn];
    [saveBtn addTarget:self action:@selector(saveBtnAction) forControlEvents:UIControlEventTouchUpInside];
    CGFloat btnw = (SCREEN_WIDTH - (3*16) )/2;
    [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(topicTagsBG.mas_bottom).offset(90);
        make.width.mas_equalTo( btnw );
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(-88);
    }];

    //提交按钮
    MJButton * commitBtn = [[MJButton alloc]init];
    commitBtn.mj_text = @"提交发布";
    commitBtn.mj_font=FONT(17);
    commitBtn.mj_textColor=HW_WHITE;
    commitBtn.layer.cornerRadius=22;
    commitBtn.layer.borderWidth=0;
    commitBtn.backgroundColor=HW_RED_WORD_1;
    [bgscroll addSubview:commitBtn];
    [commitBtn addTarget:self action:@selector(commitBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(saveBtn.mas_right).offset(16);
        make.top.mas_equalTo(saveBtn.mas_top);
        make.width.mas_equalTo(saveBtn);
        make.height.mas_equalTo(saveBtn);
    }];
    
    
}

-(void)showProtocol
{
    
    BOOL auth = [[NSUserDefaults standardUserDefaults]boolForKey:@"UGC_Protocol"];
    if (auth)
    {
        return;
    }
    
    [MJHUD_Alert showUGCNoticeAlert:^(id objc) {
        
        
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"UGC_Protocol"];
        
        [MJHUD_Alert hideAlertView];
        
    } cancel:^(id objc) {
        [MJHUD_Alert hideAlertView];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)createTopicItems
{
    CGFloat marginX = 16;
    CGFloat marginY = 10;
    CGFloat btnH = 26;
    CGFloat originX=16;
    CGFloat originY=0;
    
    topicBtnArr = [NSMutableArray array];
    for (int i = 0; i<topicsModel.dataArr.count; i++)
    {
        ContentModel * model = topicsModel.dataArr[i];
        MJButton * btn = [[MJButton alloc]init];
        btn.mj_text = [NSString stringWithFormat:@"#%@",model.title];
        btn.mj_font = FONT(13);
        btn.mj_textColor=HW_BLACK;
        btn.mj_textColor_sel = HW_WHITE;
        btn.mj_bgColor=[UIColor colorWithHexString:@"F5F5F5"];
        btn.mj_bgColor_sel = HW_RED_WORD_1;
        btn.layer.cornerRadius=5;
        [btn addTarget:self action:@selector(topicBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [btn sizeToFit];
        [btn setSize:CGSizeMake(btn.width+20, btnH)];
        
        
        //如果当前行放得下
        if (originX + btn.width + marginX <= SCREEN_WIDTH)
        {
            [btn setOrigin:CGPointMake(originX, originY)];
            
            originX = btn.right+marginX;
            originY = btn.top;
        }
        else
        {
            [btn setOrigin:CGPointMake(marginX, originY+marginY+btnH)];
            
            originX = btn.right+marginX;
            originY = btn.top;
        }
        
        
        
        [topicTagsBG addSubview:btn];
        [topicBtnArr addObject:btn];
    }
    
    
    [self.view layoutIfNeeded];
    [topicTagsBG mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(originY+btnH);
    }];
    
    
}


#pragma mark - Request
-(void)requestVideoDraft
{
    NSString * url = APPEND_SUBURL(BASE_URL, API_URL_UGC_CONTENT);
    url = APPEND_SUBURL(url, self.drafId);
    __weak typeof (self) weakSelf = self;
    ContentModel * model = [ContentModel model];
    [model GETRequestInView:self.view WithUrl:url Params:nil Success:^(id responseObject) {
        [weakSelf requestVideoDraftDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}


-(void)requestTopicLists
{
    TopicModel * model =[TopicModel model];
    model.isJSON=YES;
    
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_URL_TOPICS) Params:param Success:^(id responseObject) {
        [weakSelf requestTopicsDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}

-(void)requestUploadData:(NSURL*)dataUrl
{
    FileUploadModel * model = [FileUploadModel model];
    
    NSData * videoData = [NSData dataWithContentsOfURL:dataUrl];
    
    NSArray * dataArr = [NSArray arrayWithObject:videoData];
    NSArray * nameArr = [NSArray arrayWithObject:@"mjvideo"];
    
    __weak typeof (self) weakSelf = self;
    [model requestMultipartVideoUpload:APPEND_SUBURL(BASE_URL, API_URL_VIDEO_UPLOAD) model:nil fileDataArray:dataArr fileNameArray:nameArr success:^(id responseObject) {
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


-(void)requestUploadImage:(UIImage*)img
{
    FileUploadModel * model = [FileUploadModel model];
    
    NSData * imgData = UIImageJPEGRepresentation(img , 1.0);
    
    NSArray * dataArr = [NSArray arrayWithObject:imgData];
    NSArray * nameArr = [NSArray arrayWithObject:@"mjvideo"];
    
    __weak typeof (self) weakSelf = self;
    [model requestMultipartImageUpload:APPEND_SUBURL(BASE_URL, API_URL_IMAGE_UPLOAD) model:nil fileDataArray:dataArr fileNameArray:nameArr success:^(id responseObject) {
        [weakSelf requestImageUploadDone:model];
        } error:^(id responseObject) {
            
        } fail:^(NSError *error) {
            
        } progress:^(NSProgress *progress) {
            
            long long current = progress.completedUnitCount;
            long long total = progress.totalUnitCount;
            CGFloat value = current * 1.0/total;
            [weakSelf uploadProgressDidChange:value];
            
        }];
}


-(void)requestCommitVideo:(FileUploadModel*)upmodel isPublish:(BOOL)ispub
{
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:upmodel.url forKey:@"playUrl"];
    [param setValue:upmodel.coverImageUrl forKey:@"imagesUrl"];
    [param setValue:upmodel.coverImageUrl forKey:@"thumbnailUrl"];
    [param setValue:upmodel.width forKey:@"width"];
    [param setValue:upmodel.height forKey:@"height"];
    [param setValue:@"activity.works" forKey:@"type"];
    [param setValue:upmodel.duration forKey:@"playDuration"];
    [param setValue:_inputview.text forKey:@"title"];
    [param setValue:@"video" forKey:@"subType"];
    
    //所选话题
    NSString * tagstr = [self getSelectedTagString];
    if (tagstr.length)
    {
        [param setValue:tagstr forKey:@"belongTopicId"];
    }
    
    //是发布
    if (ispub)
    {
        [param setValue:@"1" forKey:@"ugcUploadWay"];
    }
    //是草稿
    else
    {
        [param setValue:@"0" forKey:@"ugcUploadWay"];
    }
    
    
    //方向
    if ([upmodel.orientation isEqualToString:@"Portrait"])
    {
        [param setValue:@"2" forKey:@"orientation"];
    }
    else
    {
        [param setValue:@"1" forKey:@"orientation"];
    }
    
    
    
    
    __weak typeof (self) weakSelf = self;
    UploadModel * model = [UploadModel model];
    model.size = upmodel.size;
    model.isJSON = YES;
    [model PostRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_URL_ARTICLE_CREATE) Params:param Success:^(id responseObject) {
        [weakSelf requestCommitDone:model ispublish:ispub];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}


-(void)requestUpdateVideo:(FileUploadModel*)upmodel ispublish:(BOOL)ispub
{
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:upmodel.url forKey:@"playUrl"];
    [param setValue:upmodel.coverImageUrl forKey:@"imagesUrl"];
    [param setValue:upmodel.coverImageUrl forKey:@"thumbnailUrl"];
    [param setValue:upmodel.width forKey:@"width"];
    [param setValue:upmodel.height forKey:@"height"];
    [param setValue:@"activity.works" forKey:@"type"];
    [param setValue:upmodel.duration forKey:@"playDuration"];
    [param setValue:_inputview.text forKey:@"title"];
    [param setValue:@"video" forKey:@"subType"];
    
    //草稿ID
    [param setValue:self.drafId forKey:@"id"];
    
    //所选话题
    NSString * tagstr = [self getSelectedTagString];
    if (tagstr.length)
    {
        [param setValue:tagstr forKey:@"belongTopicId"];
    }
    
    //是发布
    if (ispub)
    {
        [param setValue:@"1" forKey:@"ugcUploadWay"];
    }
    //是草稿
    else
    {
        [param setValue:@"0" forKey:@"ugcUploadWay"];
    }
    
    
    //方向
    if ([upmodel.orientation isEqualToString:@"Portrait"])
    {
        [param setValue:@"2" forKey:@"orientation"];
    }
    else
    {
        [param setValue:@"1" forKey:@"orientation"];
    }
    
    
    __weak typeof (self) weakSelf = self;
    UploadModel * model = [UploadModel model];
    model.size = upmodel.size;
    model.isJSON = YES;
    [model PostRequestInView:self.view WithUrl:APPEND_SUBURL(BASE_URL, API_URL_ARTICLE_UPDATE) Params:param Success:^(id responseObject) {
        [weakSelf requestCommitDone:model ispublish:ispub];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}



#pragma mark - Rquest Done
-(void)requestVideoDraftDone:(ContentModel*)draftContent
{
    //草稿的标题
    _inputview.text = draftContent.title;
    
    //草稿的视频信息
    FileUploadModel * uploadM = [FileUploadModel model];
    uploadM.coverImageUrl = draftContent.imagesUrl;
    uploadM.url = draftContent.playUrl;
    uploadM.width = draftContent.width;
    uploadM.height = draftContent.height;
    uploadM.duration = draftContent.playDuration;
    uploadM.orientation = draftContent.orientation;
    
    [self requestUploadDone:uploadM];
    
    //草稿的话题
    if (draftContent.belongTopicId.length)
    {
        [self setDraftSelectedTopicItem:draftContent.belongTopicId];
    }
}


-(void)requestTopicsDone:(TopicModel*)model
{
    topicsModel = model;
    
    [self createTopicItems];
    
    if (self.drafId.length)
    {
        [self requestVideoDraft];
    }
}

-(void)requestUploadDone:(FileUploadModel*)model
{
    //显示封面图，删除按钮
    uploadBtn.hidden=YES;
    coverImage.hidden=NO;
    deleteBtn.hidden=NO;
    [coverImage sd_setImageWithURL:[NSURL URLWithString:model.coverImageUrl]];
    
    
    //隐藏进度条
    progress.hidden=YES;
    
    //保存数据
    uploadModel = model;
}


-(void)requestImageUploadDone:(FileUploadModel*)model
{
    //显示封面图，删除按钮
    uploadBtn.hidden=YES;
    coverImage.hidden=NO;
    deleteBtn.hidden=NO;
    [coverImage sd_setImageWithURL:[NSURL URLWithString:model.url]];
    
    
    //隐藏进度条
    progress.hidden=YES;
    
    //保存数据
    uploadModel.coverImageUrl = model.url;
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


-(void)requestCommitDone:(UploadModel*)model ispublish:(BOOL)ispub
{
    if (ispub)
    {
        [MJHUD_Notice showSuccessView:@"提交成功" inView:self.view hideAfterDelay:2];
    }
    else
    {
        [MJHUD_Notice showSuccessView:@"保存成功" inView:self.view hideAfterDelay:2];
    }
    
    
    //行为埋点
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:model.title forKey:@"content_name"];
    [param setValue:model.id forKey:@"content_id"];
    [param setValue:model.playDuration forKey:@"works_duration"];
    [param setValue:model.size forKey:@"works_size"];
    [SZUserTracker trackingButtonEventName:@"short_video_submit" param:param];
    
    
    [self performSelector:@selector(dissmissVC) withObject:nil afterDelay:1];
    
    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 1.5*NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            NSString * h5url = APPEND_SUBURL(BASE_H5_URL, @"act/xksh/#/me");
            [[SZManager sharedManager].delegate onOpenWebview:h5url param:nil];
        });
    
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
    if (_inputview.text.length==0)
    {
        [MJHUD_Notice showNoticeView:@"请输入视频简介" inView:self.view hideAfterDelay:2];
    }
    else if (uploadModel.url.length==0)
    {
        [MJHUD_Notice showNoticeView:@"视频还未上传完成" inView:self.view hideAfterDelay:2];
    }
    else
    {
        if (self.drafId.length)
        {
            [self requestUpdateVideo:uploadModel ispublish:YES];
        }
        else
        {
            [self requestCommitVideo:uploadModel isPublish:YES];
        }
        
    }
}
-(void)saveBtnAction
{
    
    
    if (_inputview.text.length==0 && uploadModel.url.length==0)
    {
        [MJHUD_Notice showNoticeView:@"没有内容可保存" inView:self.view hideAfterDelay:1.5];
    }
    else
    {
        if (self.drafId.length)
        {
            [self requestUpdateVideo:uploadModel ispublish:NO];
        }
        else
        {
            [self requestCommitVideo:uploadModel isPublish:NO];
        }
    }
}

-(void)coverImageTapAction
{
    [[HDPhotoHelper creatWithSourceType:MJImagePickerSourceTypeAlbumImageOnly]showMediaSelectionViewFromVC:self completion:^(id data) {
        [self requestUploadImage:data];
    }];
}

-(void)closeKeyboardAction
{
    [self.view.window endEditing:YES];
}

-(void)topicBtnAction:(MJButton*)sender
{
    for (MJButton * btn in topicBtnArr)
    {
        if (btn != sender)
        {
            btn.MJSelectState = NO;
        }
    }
    
    sender.MJSelectState=!sender.MJSelectState;
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
    uploadModel = nil;
    uploadBtn.hidden=NO;
    coverImage.hidden=YES;
    deleteBtn.hidden=YES;
}

#pragma mark - Other
-(NSString*)getSelectedTagString
{
    for (int i = 0; i<topicBtnArr.count; i++)
    {
        MJButton * btn = topicBtnArr[i];
        if (btn.MJSelectState)
        {
            ContentModel * model = topicsModel.dataArr [i];
            return model.id;
            
        }
    }
    
    
        return nil;
}

-(void)setDraftSelectedTopicItem:(NSString*)topicId
{
    for (int i =0; i<topicsModel.dataArr.count; i++)
    {
        ContentModel * topic = topicsModel.dataArr[i];
        if ([topic.id isEqualToString:topicId])
        {
            MJButton * btn = topicBtnArr[i];
            [self topicBtnAction:btn];
        }
    }
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
