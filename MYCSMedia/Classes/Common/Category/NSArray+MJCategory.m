//
//  NSArray+MJCategory.m
//  区块链钱包
//
//  Created by 马佳 on 2018/7/31.
//  Copyright © 2018年 iBESTLOVE_HangZhou. All rights reserved.
//

#import "NSArray+MJCategory.h"

@implementation NSArray (MJCategory)

-(NSString *)convertToJsonSting
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

-(NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString *str = [NSMutableString string];
    
    [str appendString:@"[\n"];
    
    // 遍历数组的所有元素
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [str appendFormat:@"%@,\n", obj];
    }];
    
    [str appendString:@"]"];
    
    // 查出最后一个,的范围
    NSRange range = [str rangeOfString:@"," options:NSBackwardsSearch];
    if (range.length != 0)
    {
        // 删掉最后一个,
        [str deleteCharactersInRange:range];
    }
    
    return str;
}


@end
