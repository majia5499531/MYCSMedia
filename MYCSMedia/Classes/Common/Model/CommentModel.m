//
//  CommentModel.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/7.
//

#import "CommentModel.h"
#import <YYText/YYText.h>
#import "YYModel.h"
#import "NSObject+MJCategory.h"
#import "ReplyModel.h"

@implementation CommentModel
-(void)parseData:(id)data
{
    [self yy_modelSetWithDictionary:data];
    
    //回复
    NSDictionary * replyInfo = [data mj_valueForKey:@"reply"];
    self.lastReplyName = [replyInfo mj_valueForKey:@"replyName"];
    self.totalReplyCount = [replyInfo mj_valueForKey:@"replyNum"];
    
    //回复列表
    NSArray * replyList = [replyInfo mj_valueForKey:@"replyList"];
    for (int i = 0; i<replyList.count; i++)
    {
        NSDictionary * dic = replyList[i];
        ReplyModel * model = [ReplyModel model];
        [model yy_modelSetWithDictionary:dic];
        [self.dataArr addObject:model];
    }
    
    //默认显示的回复条数
    self.replyInitialCount = replyList.count;
    
    //显示的条数
    self.replyShowCount=replyList.count;
}


@end
