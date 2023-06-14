//
//  CommentDataModel.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/7.
//

#import "CommentDataModel.h"
#import <YYText/YYText.h>
#import "NSObject+MJCategory.h"
#import "CommentModel.h"
#import "YYModel.h"

@implementation CommentDataModel

-(void)parseData:(id)data
{
    [self yy_modelSetWithDictionary:data];
    
    NSArray * comments = [data mj_valueForKey:@"records"];
    for (int i = 0; i<comments.count; i++)
    {
        NSDictionary * dic = comments[i];
        CommentModel * model = [CommentModel model];
        [model parseData:dic];
        [self.dataArr addObject:model];
    }
    
}

@end
