//
//  RelateAlbumsModel.m
//  MYCSMedia
//
//  Created by 马佳 on 2022/4/19.
//

#import "RelateAlbumsModel.h"
#import "NSObject+MJCategory.h"
#import "ContentModel.h"
#import "YYModel.h"

@implementation RelateAlbumsModel

-(void)parseData:(id)data
{
    self.topicName = [data mj_valueForKey:@"topicName"];
    NSArray * arr = [data mj_valueForKey:@"list"];
    for (int i = 0; i<arr.count; i++)
    {
        if (i==3)
        {
            break;
        }
        ContentModel * model = [ContentModel model];
        NSDictionary * dic = arr[i];
        
        [model yy_modelSetWithDictionary:dic];

        [self.dataArr addObject:model];
    }
}


@end
