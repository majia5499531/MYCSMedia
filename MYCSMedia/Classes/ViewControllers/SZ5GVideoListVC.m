//
//  SZ5GVideoListVC.m
//  MYCSMedia
//
//  Created by 马佳 on 2023/4/11.
//

#import "SZ5GVideoListVC.h"
#import "SZVideoListVC.h"
#import "SZDefines.h"
#import "UIColor+MJCategory.h"
#import "CustomFooter.h"
#import "CustomAnimatedHeader.h"
#import "SZVideoCell.h"
#import "UIImage+MJCategory.h"
#import "MJButton.h"
#import "MJVideoManager.h"
#import <Masonry/Masonry.h>
#import "SZManager.h"
#import "UIView+MJCategory.h"
#import "SZInputView.h"
#import "MJHUD.h"
#import "BaseModel.h"
#import "ContentListModel.h"
#import "ContentModel.h"
#import "TokenExchangeModel.h"
#import "ConsoleVC.h"
#import "SZData.h"
#import "SZGlobalInfo.h"
#import "UIScrollView+MJCategory.h"
#import "UIResponder+MJCategory.h"
#import "SZHomeVC.h"
#import "SDWebImage.h"
#import <MJRefresh/MJRefresh.h>

@interface SZ5GVideoListVC ()

@end

@implementation SZ5GVideoListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}





#pragma mark - Override
-(void)requestVideoList
{
    ContentListModel * model = [ContentListModel model];
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    NSString * ssid = [[SZManager sharedManager].delegate onGetUserDevice];
    
    [param setValue:self.categoryCode forKey:@"categoryCode"];
    [param setValue:@"open" forKey:@"refreshType"];
    [param setValue:ssid forKey:@"ssid"];
    [param setValue:@"1" forKey:@"personalRec"];
    
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:nil WithUrl:APPEND_SUBURL(BASE_URL, API_WANDA_GET_CONTENTS) Params:param Success:^(id responseObject) {
        [weakSelf requestVideoListDone:model];
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];
}

-(void)requestMoreVideos
{
    ContentListModel * model = [ContentListModel model];
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    NSString * ssid = [[SZManager sharedManager].delegate onGetUserDevice];
    ContentModel * lastContent = self.dataModel.dataArr.lastObject;
    
    [param setValue:self.categoryCode forKey:@"categoryCode"];
    [param setValue:@"open" forKey:@"refreshType"];
    [param setValue:ssid forKey:@"ssid"];
    [param setValue:@"1" forKey:@"personalRec"];
    [param setValue:@"10" forKey:@"pageSize"];
    [param setValue:lastContent.id forKey:@"contentId"];
    
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:nil WithUrl:APPEND_SUBURL(BASE_URL, API_WANDA_GET_MORE_CONTENTS) Params:param Success:^(id responseObject) {
        [weakSelf requestMoreVideoDone:model];
        } Error:^(id responseObject) {
            [weakSelf requestFailed];
        } Fail:^(NSError *error) {
            [weakSelf requestFailed];
        }];
}



@end
