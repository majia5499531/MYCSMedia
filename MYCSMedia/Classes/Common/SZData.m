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
#import "SZUserTracker.h"
#import "StatusModel.h"
#import "ReplyModel.h"
#import "ReplyListModel.h"
#import "ContentListModel.h"
#import "SZUserTracker.h"

@implementation SZData

+(SZData *)sharedSZData
{
    static SZData * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil)
        {
            manager = [[SZData alloc]init];
            
            [manager addDataBinding];
        }
        });
    return manager;
}
                  


#pragma mark - Binding
-(void)addDataBinding
{
    //绑定数据
    [self bindModel:self];
    
    __weak typeof (self) weakSelf = self;
    self.observe(@"currentContentId",^(id value){
        
        if(self.currentContentId.length)
        {
            [weakSelf requestContentBelongedAlbums];
            [weakSelf requestContentState];
            [weakSelf requestCommentListData];
            [weakSelf requestForAddingViewCount];
            [weakSelf requestContentRelatedContent];
        }
        
    });
}



#pragma mark - Request
//请求内容所属合辑
-(void)requestContentBelongedAlbums
{
    ContentListModel * model = [ContentListModel model];
    
    NSString * url = APPEND_SUBURL(BASE_URL, API_URL_CONTENT_IN_ALBUM);
    url = APPEND_SUBURL(url, self.currentContentId);
    
    __weak typeof (self) weakSelf = self;
    [model GETRequestInView:nil WithUrl:url Params:nil Success:^(id responseObject) {
        [weakSelf requestContentBelongedAlbumsDone:model];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
    
    
}


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
    [param setValue:@"0" forKey:@"pcommentId"];
    
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

-(void)requestFollowUser:(NSString*)userId
{
    StatusModel * model = [StatusModel model];
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:userId forKey:@"targetUserId"];
    
    NSString * url = APPEND_SUBURL(BASE_URL, API_URL_FOLLOW_USER);
    url = APPEND_SUBURL(url, userId);
    __weak typeof (self) weakSelf = self;
    [model PostRequestInView:nil WithUrl:url Params:param Success:^(id responseObject) {
        [weakSelf requestFollowCreatorDone:YES];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}


-(void)requestUnFollowUser:(NSString*)userId
{
    StatusModel * model = [StatusModel model];
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:userId forKey:@"targetUserId"];
    
    NSString * url = APPEND_SUBURL(BASE_URL, API_URL_UNFOLLOW_USER);
    url = APPEND_SUBURL(url, userId);
    __weak typeof (self) weakSelf = self;
    [model PostRequestInView:nil WithUrl:url Params:param Success:^(id responseObject) {
        [weakSelf requestFollowCreatorDone:NO];
        } Error:^(id responseObject) {
            
        } Fail:^(NSError *error) {
            
        }];
}





#pragma mark - Request Done
-(void)requestContentBelongedAlbumsDone:(ContentListModel*)listModel
{
    if (listModel.dataArr.count==0)
    {
        return;
    }
    
    //保存在字典中
    [self.contentBelongAlbumsDic setValue:listModel forKey:self.currentContentId];
    
    //更新time
    NSNumber * currrentTime = [NSNumber numberWithInteger:[[NSDate date]timeIntervalSince1970]];
    self.contentBelongAlbumsUpdateTime = currrentTime;
}

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
    
    if (model.data.boolValue)
    {
        NSInteger k = stateM.favorCountShow;
        k++;
        stateM.favorCountShow = k;
    }
    else
    {
        NSInteger k = stateM.favorCountShow;
        k--;
        stateM.favorCountShow = k;
    }
    
    //行为埋点
    ContentModel * contentM = [self.contentDic valueForKey:self.currentContentId];
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:contentM.id forKey:@"content_id"];
    [param setValue:contentM.title forKey:@"content_name"];
    [param setValue:contentM.source forKey:@"content_source"];
    [param setValue:contentM.thirdPartyId forKey:@"third_ID"];
    [param setValue:contentM.keywords forKey:@"content_key"];
    [param setValue:contentM.tags forKey:@"content_list"];
    [param setValue:contentM.classification forKey:@"content_classify"];
    [param setValue:contentM.startTime forKey:@"create_time"];
    [param setValue:contentM.issueTimeStamp forKey:@"publish_time"];
    [param setValue:contentM.type forKey:@"content_type"];
    
    [SZUserTracker trackingButtonEventName:@"content_favorite" param:param];
    
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
    
    
    //行为埋点
    ContentModel * contentM = [self.contentDic valueForKey:self.currentContentId];
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setValue:contentM.id forKey:@"content_id"];
    [param setValue:contentM.title forKey:@"content_name"];
    [param setValue:contentM.source forKey:@"content_source"];
    [param setValue:contentM.keywords forKey:@"content_key"];
    [param setValue:contentM.tags forKey:@"content_list"];
    [param setValue:contentM.classification forKey:@"content_classify"];
    [param setValue:contentM.thirdPartyId forKey:@"third_ID"];
    [param setValue:contentM.startTime forKey:@"create_time"];
    [param setValue:contentM.issueTimeStamp forKey:@"publish_time"];
    [param setValue:contentM.type forKey:@"content_type"];
    
    [SZUserTracker trackingButtonEventName:@"content_like" param:param];
    
    
    
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

-(void)requestFollowCreatorDone:(BOOL)isFollow
{
    //取model
    ContentStateModel * stateM = [self.contentStateDic valueForKey:self.currentContentId];
    
    //修改值
    stateM.whetherFollow = isFollow;
    
    //更新time
    NSNumber * currrentTime = [NSNumber numberWithInteger:[[NSDate date]timeIntervalSince1970]];
    self.contentCreateFollowTime = currrentTime;
}

-(void)requestReplyListDone:(NSArray*)replys commentID:(NSString*)commentID
{
    //找到这条评论，并将回复数据插入
    CommentDataModel * commentDataM = [self.contentCommentDic valueForKey:self.currentContentId];
    
    for (CommentModel * M in commentDataM.dataArr)
    {
        if ([M.id isEqualToString:commentID])
        {
            //评论数据保存起来
            [M.dataArr removeAllObjects];
            [M.dataArr addObjectsFromArray:replys];
            
            
        }
    }
    
    
    //更新time
    NSNumber * currrentTime = [NSNumber numberWithInteger:[[NSDate date]timeIntervalSince1970]];
    self.contentCommentsUpdateTime = currrentTime;
}


#pragma mark - Getter
-(NSMutableDictionary *)contentBelongAlbumsDic
{
    if (_contentBelongAlbumsDic==nil)
    {
        _contentBelongAlbumsDic=[NSMutableDictionary dictionary];
    }
    return _contentBelongAlbumsDic;
}

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
-(NSMutableDictionary *)contentRelateContentDislikeDic
{
    if (_contentRelateContentDislikeDic==nil)
    {
        _contentRelateContentDislikeDic = [NSMutableDictionary dictionary];
    }
    return _contentRelateContentDislikeDic;
}


@end
