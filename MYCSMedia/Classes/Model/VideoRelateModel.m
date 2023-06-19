//
//  VideoRelateModel.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/5.
//

#import "VideoRelateModel.h"
#import "YYText.h"
#import "YYModel.h"

@implementation VideoRelateModel

-(void)parseData:(id)data
{
    NSDictionary * dic = data;
    NSArray * arr = [dic valueForKey:@"records"];
    
    for(int i = 0;i<arr.count;i++)
    {
        VideoRelateModel * model = [VideoRelateModel model];
        NSDictionary * dic = arr[i];
        [model yy_modelSetWithDictionary:dic];
        [self.dataArr addObject:model];
    }
}

@end
