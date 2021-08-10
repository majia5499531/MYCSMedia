//
//  SZData.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/3.
//

#import "SZData.h"
#import "SZDefines.h"
#import "ContentStateModel.h"
#import "SZManager.h"
#import "CommentDataModel.h"
#import "StatusModel.h"
#import "VideoRelateModel.h"
#import "SZGlobalInfo.h"


@implementation SZData

+(SZData *)sharedSZData
{
    static SZData * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil)
        {
            manager = [[SZData alloc]init];
            
            [manager bindingData];
        }
        });
    return manager;
}
                  



#pragma mark - Binding
-(void)bindingData
{
    //绑定数据
    [self bindModel:self];
    
    __weak typeof (self) weakSelf = self;
    self.observe(@"currentContentId",^(id value){
        
        if(self.currentContentId.length)
        {
            [weakSelf requestContentState];
            [weakSelf requestCommentListData];
            [weakSelf requestForAddingViewCount];
            [weakSelf requestContentRelatedContent];
        }
        
    });
}


#pragma mark - Request
//请求内容状态
-(void)requestContentState
{
    ContentStateModel * model = [ContentStateModel model];
    model.hideLoading=YES;
    model.hideErrorMsg=YES;
    __weak typeof (self) weakSelf = self;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:self.currentContentId forKey:@"contentId"];
    [model GETRequestInView:nil WithUrl:APPEND_SUBURL(BASE_URL, API_URL_GET_CONTENT_STATE) Params:param Success:^(id responseObject) {
        [weakSelf requestContentStateDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}

//评论列表
-(void)requestCommentListData
{
    CommentDataModel * model = [CommentDataModel model];
    model.isJSON = YES;
    model.hideLoading = YES;
    model.hideErrorMsg = YES;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:self.currentContentId forKey:@"contentId"];
    [param setValue:@"9999" forKey:@"pageSize"];
    [param setValue:@"1" forKey:@"pageNum"];
    
    __weak typeof (self) weakSelf = self;
    [model PostRequestInView:nil WithUrl:APPEND_SUBURL(BASE_URL, API_URL_GET_COMMENT_LIST) Params:param Success:^(id responseObject) {
        [weakSelf requestCommentListDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}

//请求接口浏览量
-(void)requestForAddingViewCount
{
    NSString * url = APPEND_SUBURL(BASE_URL, API_URL_VIEW_COUNT);
    url = APPEND_SUBURL(url, self.currentContentId);
    
    StatusModel * model = [StatusModel model];
    [model PostRequestInView:nil WithUrl:url Params:nil Success:^(id responseObject) {
            
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}

//点赞+1
-(void)requestZan
{
    StatusModel * model = [StatusModel model];
    model.hideLoading=YES;
    model.isJSON=YES;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:self.currentContentId forKey:@"targetId"];
    [param setValue:@"content" forKey:@"type"];
    
    __weak typeof (self) weakSelf = self;
    [model PostRequestInView:nil WithUrl:APPEND_SUBURL(BASE_URL, API_URL_ZAN) Params:param Success:^(id responseObject) {
            [weakSelf requestZanDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}

//添加收藏
-(void)requestCollect
{
    StatusModel * model = [StatusModel model];
    model.isJSON=YES;
    model.hideLoading=YES;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:self.currentContentId forKey:@"contentId"];
    [param setValue:@"short_video" forKey:@"type"];
    __weak typeof (self) weakSelf = self;
    [model PostRequestInView:nil WithUrl:APPEND_SUBURL(BASE_URL, API_URL_FAVOR) Params:param Success:^(id responseObject) {
        [weakSelf requestCollectDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}

//请求内容相关的推荐
-(void)requestContentRelatedContent
{
    VideoRelateModel * model = [VideoRelateModel model];
    model.isJSON=YES;
    model.hideLoading=YES;
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:self.currentContentId forKey:@"contentId"];
    [param setValue:@"100" forKey:@"pageSize"];
    [param setValue:@"1" forKey:@"pageIndex"];
    [param setValue:@"1" forKey:@"current"];
    __weak typeof (self) weakSelf = self;
    [model PostRequestInView:nil WithUrl:APPEND_SUBURL(BASE_URL, API_URL_RELATED_CONTENT) Params:param Success:^(id responseObject) {
            [weakSelf requestVideoRelateContentDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
    
}

#pragma mark - Request Done
-(void)requestContentStateDone:(ContentStateModel*)model
{
    //保存在字典中
    [self.contentStateDic setValue:model forKey:self.currentContentId];
    
    //更新time
    NSNumber * currrentTime = [NSNumber numberWithInteger:[[NSDate date]timeIntervalSince1970]];
    self.contentStateUpdateTime = currrentTime;
    
}

-(void)requestCommentListDone:(CommentDataModel*)model
{
    //保存
    [self.contentCommentDic setValue:model forKey:self.currentContentId];
    
    //更新time
    NSNumber * currrentTime = [NSNumber numberWithInteger:[[NSDate date]timeIntervalSince1970]];
    self.contentCommentsUpdateTime = currrentTime;
}

-(void)requestCollectDone:(StatusModel*)model
{
    //取model
    ContentStateModel * stateM = [self.contentStateDic valueForKey:self.currentContentId];
    
    //修改值
    stateM.whetherFavor = model.data.boolValue;
    
    //更新time
    NSNumber * currrentTime = [NSNumber numberWithInteger:[[NSDate date]timeIntervalSince1970]];
    self.contentCollectTime = currrentTime;
}

-(void)requestZanDone:(StatusModel*)model
{
    //取model
    ContentStateModel * stateM = [self.contentStateDic valueForKey:self.currentContentId];
    
    //修改值
    stateM.whetherLike = model.data.boolValue;
    
    if (model.data.boolValue)
    {
        NSInteger k = stateM.likeCountShow;
        k++;
        stateM.likeCountShow = k;
    }
    else
    {
        NSInteger k = stateM.likeCountShow;
        k--;
        stateM.likeCountShow = k;
    }
    
    
    //更新time
    NSNumber * currrentTime = [NSNumber numberWithInteger:[[NSDate date]timeIntervalSince1970]];
    self.contentZanTime = currrentTime;
}

-(void)requestVideoRelateContentDone:(VideoRelateModel*)model
{
    //保存
    [self.contentRelateContentDic setValue:model forKey:self.currentContentId];
    
    //更新time
    NSNumber * currrentTime = [NSNumber numberWithInteger:[[NSDate date]timeIntervalSince1970]];
    self.contentRelateUpdateTime = currrentTime;
}




#pragma mark - Lazy
-(NSMutableDictionary *)contentStateDic
{
    if (_contentStateDic==nil)
    {
        _contentStateDic = [NSMutableDictionary dictionary];
    }
    return _contentStateDic;;
}

-(NSMutableDictionary *)contentCommentDic
{
    if (_contentCommentDic==nil)
    {
        _contentCommentDic = [NSMutableDictionary dictionary];
    }
    return _contentCommentDic;
}
-(NSMutableDictionary *)contentDic
{
    if (_contentDic==nil)
    {
        _contentDic = [NSMutableDictionary dictionary];
    }
    return _contentDic;
}
-(NSMutableDictionary *)contentRelateContentDic
{
    if (_contentRelateContentDic==nil)
    {
        _contentRelateContentDic = [NSMutableDictionary dictionary];
    }
    return _contentRelateContentDic;
}


@end
