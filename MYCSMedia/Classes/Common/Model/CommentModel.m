//
//  CommentModel.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/7.
//

#import "CommentModel.h"
#import <YYText/YYText.h>
#import "YYModel.h"
#import "NSObject+MJCategory.h"

@implementation CommentModel
-(void)parseData:(id)data
{
    [self yy_modelSetWithDictionary:data];
    
    NSArray * arr = [data mj_valueForKey:@"children"];
    for (int i = 0; i<arr.count; i++)
    {
        NSDictionary * dic = arr[i];
        CommentModel * model = [CommentModel model];
        [model yy_modelSetWithDictionary:dic];
        [self.dataArr addObject:model];
    }
}
@end
