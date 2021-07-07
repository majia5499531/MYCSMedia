//
//  VideoListModel.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/3.
//

#import "VideoListModel.h"
#import "NSObject+MJCategory.h"
#import "ContentModel.h"
#import <YYModel/YYModel.h>

@implementation VideoListModel
-(void)parseData:(id)data
{
    NSArray * arr = [data mj_arrayValue];
    for (int i = 0; i<arr.count; i++)
    {
        ContentModel * model = [ContentModel  model];
        NSDictionary * dic = data[i];
        
        [model yy_modelSetWithJSON:dic];

        [self.dataArr addObject:model];
    }
}

@end
