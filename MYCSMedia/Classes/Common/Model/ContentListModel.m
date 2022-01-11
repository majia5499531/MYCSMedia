//
//  ContentListModel.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/3.
//

#import "ContentListModel.h"
#import "NSObject+MJCategory.h"
#import "ContentModel.h"
#import <YYText/YYText.h>
#import "YYModel.h"

@implementation ContentListModel
-(void)parseData:(id)data
{
    NSArray * arr = [data mj_arrayValue];
    for (int i = 0; i<arr.count; i++)
    {
        ContentModel * model = [ContentModel model];
        NSDictionary * dic = data[i];
        
        [model yy_modelSetWithDictionary:dic];

        [self.dataArr addObject:model];
    }
}

@end
