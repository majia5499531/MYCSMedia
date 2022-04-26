//
//  VideoCollectModel.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/5.
//

#import "VideoCollectModel.h"
#import "NSObject+MJCategory.h"
#import "NSObject+YYModel.h"
#import "YYModel.h"
#import "ContentModel.h"

@implementation VideoCollectModel

-(void)parseData:(id)data
{
    NSArray * arr = [data mj_valueForKey:@"records"];
    
    for (int i = 0; i<arr.count; i++)
    {
        NSDictionary * dic = arr[i];
        ContentModel * model = [ContentModel model];
        [model parseData:dic];
        [self.dataArr addObject:model];
    }
}


@end
