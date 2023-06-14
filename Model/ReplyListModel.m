//
//  ReplyListModel.m
//  MYCSMedia
//
//  Created by 马佳 on 2022/1/5.
//

#import "ReplyListModel.h"
#import "ReplyModel.h"
#import "YYModel.h"
#import "NSObject+MJCategory.h"
#import <YYText/YYText.h>

@implementation ReplyListModel

-(void)parseData:(id)data
{
    [self yy_modelSetWithDictionary:data];
    
    NSArray * comments = [data mj_valueForKey:@"records"];
    for (int i = 0; i<comments.count; i++)
    {
        NSDictionary * dic = comments[i];
        ReplyModel * model = [ReplyModel model];
        [model parseData:dic];
        [self.dataArr addObject:model];
    }
    
}

@end
