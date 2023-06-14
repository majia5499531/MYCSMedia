//
//  ContentCollectionModel.m
//  MYCSMedia
//
//  Created by 马佳 on 2023/4/13.
//

#import "ContentCollectionModel.h"
#import "NSObject+MJCategory.h"
#import "ContentModel.h"
#import <YYText/YYText.h>
#import "YYModel.h"

@implementation ContentCollectionModel
-(void)parseData:(id)data
{
    self.collectionModel = [ContentModel model];
    [self.collectionModel yy_modelSetWithDictionary:data];
    NSArray * arr = [data mj_valueForKey:@"children"];
    for (int i = 0; i<arr.count; i++)
    {
        NSDictionary * dic = arr[i];
        ContentModel * childModel = [ContentModel model];
        [childModel yy_modelSetWithDictionary:dic];
        [self.dataArr addObject:childModel];
    }
}
@end
