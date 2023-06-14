//
//  TopicListModel.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/27.
//

#import "TopicModel.h"
#import "NSObject+MJCategory.h"
#import "ContentModel.h"
#import "YYModel.h"

@implementation TopicModel

-(void)parseData:(id)data
{
    NSArray * arr = [data mj_arrayValue];
    
    for (int i = 0; i<arr.count; i++)
    {
        NSDictionary * dic = arr[i];
        TopicModel * model = [TopicModel model];
        [model yy_modelSetWithJSON:dic];
        [self.dataArr addObject:model];
    }
}

@end
