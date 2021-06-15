//
//  VideoCollectModel.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/5.
//

#import "VideoCollectModel.h"
#import <YYModel/YYModel.h>
#import "NSObject+MJCategory.h"

@implementation VideoCollectModel
-(void)parseData:(id)data
{
    [self yy_modelSetWithJSON:data];

    
    NSArray * arr = [data mj_valueForKey:@"children"];
    for (int i = 0; i<arr.count; i++)
    {
        NSDictionary * dic = arr[i];
        VideoModel * model = [VideoModel  model];
        [model yy_modelSetWithJSON:dic];
        [self.dataArr addObject:model];
    }
}

@end
