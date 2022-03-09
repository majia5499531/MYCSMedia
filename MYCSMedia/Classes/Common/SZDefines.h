//
//  HW_SZDefines.h
//  星乐园
//
//  Created by 马佳 on 2017/5/17.
//  Copyright © 2017年 HW_tech. All rights reserved.
//


#ifdef __OBJC__

#ifndef PCH_HEADER
#define PCH_HEADER



#define UAT 1


//Debug
#ifdef DEBUG
    #define CONSOLE_DURATION        0.3
    #define DEV_ENV                 1

//Release
#else
    #define CONSOLE_DURATION        2
    #define DEV_ENV                 0
#endif







#define BASE_URL                    [SZGlobalInfo mjgetBaseURL]
#define BASE_H5_URL                 [SZGlobalInfo mjgetBaseH5URL]
#define API_URL_VIDEO_LIST          @"api/cms/client/video/queryVideoPullDownList"
#define API_URL_RANDOM_VIDEO_LIST   @"api/cms/client/video/queryRandomVideoList"
#define API_URL_VIDEO               @"api/cms/client/video/getVideoDetails"
#define API_URL_VIDEOCOLLECT        @"api/cms/client/content/getSpecList"
#define API_URL_VIDEO_COLLECTION    @"api/cms/client/video/getVideoCollect"
#define API_URL_FAVOR               @"api/cms/client/favor/addOrCancelFavor"
#define API_URL_ZAN                 @"api/cms/client/like/likeOrCancel"
#define API_URL_VIEW_COUNT          @"api/cms/client/contentStats/view/count"
#define API_URL_SEND_COMMENT        @"api/cms/client/comment/add"
#define API_URL_SEND_REPLY          @"api/cms/client/comment/addUserReply"
#define API_URL_GET_COMMENT_LIST    @"api/cms/client/comment/getCommentWithReply"
#define API_URL_GET_CONTENT_STATE   @"api/cms/client/contentStats/queryStatsData"
#define API_URL_GET_REPLY_LIST      @"api/cms/client/comment/getCommentByContent"
#define API_URL_TOKEN_EXCHANGE      @"api/sys/login/mycs/token"
#define API_URL_QUERYCATEGORY       @"api/cms/client/panel/queryPanelByCategory"
#define API_URL_RELATED_CONTENT     @"api/cms/client/content/recommend"
#define API_URL_FOLLOW_USER         @"api/sys/user/me/follow"
#define API_URL_UNFOLLOW_USER       @"api/sys/user/me/unfollow"
#define API_URL_TOPICS              @"api/cms/client/content/page"
#define API_URL_VIDEO_UPLOAD        @"api/media/file/upload?isPublic=1&generateCoverImage=1"
//#define API_URL_VIDEO_COMMIT        @"api/cms/client/content/activity/works/create"
#define API_URL_VIDEO_COMMIT        @"api/cms/client/content/activity/works/create/v2"

#define API_URL_PANEL_ACTIVITY      @"api/cms/client/panel/info"
#define API_URL_CONTENT_TRACKING    @"api/cms/client/tracking/upload"
#define API_URL_CONTENT_IN_ALBUM    @"api/cms/client/video/getCollectToVideo"
#define API_URL_CATEGORY_LIST       @"api/cms/client/category/getCategoryData"




//业务
#define VIDEO_PAGE_SIZE             15
#define COMMENT_BAR_HEIGHT          (CGFloat)(IS_IPHONE_X?(121):(87))
#define IMG_RADIUS                  5
#define IMAGE_RATE_169              (9.0/16.0)
#define IMAGE_RATE_1611             (11.0/16.0)
#define IMAGE_RATE_34               0.75
#define IMAGE_RATE_ACTIVITY         (0.382)
#define TOPIC_NEWS_IMAGE_RATE       (300.0/750.0)


#define SEARCHBAR_HEIGHT        ([UIApplication sharedApplication].statusBarFrame.size.height+48)
//REX
#define MAX_NICKNAME        15
#define MAX_ID_NUMBER       18
#define MAX_VERIFY          6
#define MAX_PHONE           11
#define MAX_PASSWORD        20
#define MAX_BAOLIAO_TITLE   20
//验证码时长
#define VERIFY_TIME         60



//REGEX
#define PASSOWRD_STRENGTH_1         @"[0-9]+"
#define PASSOWRD_STRENGTH_2         @"[a-z]+"
#define PASSOWRD_STRENGTH_3         @"[A-Z]+"
#define PASSOWRD_STRENGTH_4         @"([`~!@#$^&*()=|{}':;',.<>/?~！@#￥……&*（）——|{}【】‘；：”“'。，、？%])"




//屏幕尺寸(普通和X)
//statusBar 20-44
//tabbar    58-80
#define SCREEN_WIDTH                [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT               [UIScreen mainScreen].bounds.size.height
#define SCREEN_CENTER_X             SCREEN_WIDTH/2
#define SCREEN_CENTER_Y             SCREEN_HEIGHT/2
#define NAVI_HEIGHT                 ([UIApplication sharedApplication].statusBarFrame.size.height+\
                                    self.navigationController.navigationBar.frame.size.height)
#define STATUS_BAR_HEIGHT           [UIApplication sharedApplication].statusBarFrame.size.height
#define BOTTOM_SAFEAREA_HEIGHT      (CGFloat)(IS_IPHONE_X?(34.0):(0))
#define TABBAR_HEIGHT               (CGFloat)(IS_IPHONE_X?(80.5):(58.0))
#define NAVIBAR_HEIGHT              self.navigationController.navigationBar.frame.size.height



//设备信息
#define IS_IPHONE                   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPAD                     (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define SCREEN_MAX_LENGTH           (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH           (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_IPHONE_4_OR_LESS         (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5                 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6                 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P                (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_X                 (IS_IPHONE && SCREEN_MAX_LENGTH > 736.0)
#define IS_IPAD_NORMAL              (IS_IPAD && SCREEN_MAX_LENGTH == 1024.0)
#define IS_IPAD_PRO                 (IS_IPAD && SCREEN_MAX_LENGTH == 1366.0)



//NSLog和MJLog
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr, "%s:%zd\t%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif



//调试代码
#ifdef DEBUG
#define TEST_CODE(code) {code};
#else
#define TEST_CODE(code) {}
#endif



//随机数
#define MJ_RANDOM_INT(max)                  (arc4random()%(max+1))
//角度
#define ANGLE_RAD(angle)                    ((angle) / 180.0 * M_PI)
//国际化
#define STRING(key)                         [NSBundle.mainBundle localizedStringForKey:(key) value:@"" table:nil]
//系统版本
#define HW_SYSTEM_VERSION                   [[[UIDevice currentDevice] systemVersion] floatValue]
//APP版本
#define HW_APP_VERSION                      [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]
//拼接URL
#define APPEND_SUBURL(baseUrl,url)          [NSString stringWithFormat:@"%@/%@",baseUrl,url]
#define APPEND_COMPONENT(baseUrl,url,ID)    [NSString stringWithFormat:@"%@/%@/%@",baseUrl,url,ID]
//随机色
#define MJRandomColor                       [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]
//通知中心
#define MJNotificationCenter                [NSNotificationCenter defaultCenter]
//图片
#define MJImageNamed(imageName)             [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]]
//沙盒图片
#define MJLocalFilePath(name)          [[NSBundle mainBundle]pathForResource:name ofType:nil]
//沙盒图片
#define MJLocalImage(name)                      [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:name ofType:nil]]
//获取沙盒temp
#define MJPathTemp                          NSTemporaryDirectory()
//获取沙盒Document
#define MJPathDocument                      [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject]
//获取沙盒Cache
#define MJPathCache                         [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) firstObject]
//GCD - 一次性执行
#define kDISPATCH_ONCE_BLOCK(onceBlock)     static dispatch_once_t onceToken;dispatch_once(&onceToken, onceBlock);
//GCD - 在Main线程上运行
#define kDISPATCH_MAIN_THREAD(mainQueueBlock) dispatch_async(dispatch_get_main_queue(),mainQueueBlock);
//GCD - 开启异步线程
#define kDISPATCH_GLOBAL_QUEUE_DEFAULT(globalQueueBlock) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), globalQueueBlock);
//打印当前函数
#define MJ_PRINT                            NSLog(@"打印函数：%s",__func__);
//window
#define MJ_KEY_WINDOW                       [UIApplication sharedApplication].keyWindow



//字体
#define FONT(f)                     [UIFont fontWithName:@"PingFang SC" size:f]
#define BOLD_FONT(f)                [UIFont boldSystemFontOfSize:f]
#define BOLD_BOLD_FONT(f)           [UIFont systemFontOfSize:f weight:UIFontWeightBlack]
#define LIGHT_FONT(f)               [UIFont systemFontOfSize:f weight:UIFontWeightLight];
#define RGB(R,G,B)                  [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]


//颜色
#define HW_CLEAR                    [UIColor clearColor]

#define HW_WHITE                    [UIColor colorWithHexString:@"FFFFFF"]

#define HW_BLACK                    [UIColor colorWithHexString:@"000000"]



#define HW_GRAY_BG_1                [UIColor colorWithHexString:@"111111"]
#define HW_GRAY_BG_2                [UIColor colorWithHexString:@"222222"]
#define HW_GRAY_BG_3                [UIColor colorWithHexString:@"333333"]
#define HW_GRAY_BG_4                [UIColor colorWithHexString:@"444444"]
#define HW_GRAY_BG_5                [UIColor colorWithHexString:@"555555"]
#define HW_GRAY_BG_6                [UIColor colorWithHexString:@"666666"]
#define HW_GRAY_BG_7                [UIColor colorWithHexString:@"777777"]
#define HW_GRAY_BG_8                [UIColor colorWithHexString:@"888888"]
#define HW_GRAY_BG_9                [UIColor colorWithHexString:@"999999"]

#define HW_GRAY_BG_White            [UIColor colorWithHexString:@"F3F4F5"]
#define HW_GRAY_BORDER              [UIColor colorWithHexString:@"E8E8E8"]
#define HW_GRAY_BORDER_2            [UIColor colorWithHexString:@"A3A3A3"]

#define HW_GRAY_WORD_1              [UIColor colorWithHexString:@"999999"]
#define HW_GRAY_WORD_2              [UIColor colorWithHexString:@"D4D4D4"]


#define HW_RED_WORD_1               [UIColor colorWithHexString:@"FB3838"]


#define MINIMUM_PX                  (1.0/[UIScreen mainScreen].scale)


#endif
#endif

