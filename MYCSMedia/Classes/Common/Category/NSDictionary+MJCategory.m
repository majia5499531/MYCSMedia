//
//  NSDictionary+MJCategory.m
//  星乐园
//
//  Created by 马佳 on 2017/6/8.
//  Copyright © 2017年 HW_tech. All rights reserved.
//

#import "NSDictionary+MJCategory.h"

@implementation NSDictionary (MJCategory)

//字典转字符串
-(NSString*)converteDictionaryToJsonStr
{    
    NSArray * keysASC = [[self allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    NSMutableString * str=[NSMutableString string];
    for (int i= 0; i<keysASC.count; i++)
    {
        NSString * key=keysASC[i];
        NSString * value=[self objectForKey:key];
        
        if (i==0)
        {
            [str appendFormat:@"%@=%@",key,value];
        }
        else
        {
            [str appendFormat:@"&%@=%@",key,value];
        }
    }
    return str;
}

//转JSON
-(NSString*)convertToJSON;
{
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData)
    {
        NSLog(@"%@",error);
    }
    else
    {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}

-(NSString*)converteDictionaryToCustomStr
{
    NSArray * keysASC = [[self allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    NSMutableString * str=[NSMutableString string];
    for (int i= 0; i<keysASC.count; i++)
    {
        NSString * key=keysASC[i];
        NSString * value=[self objectForKey:key];
        
        
        [str appendFormat:@"%@-%@--",key,value];
        
    }
    return str;
}

-(NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    NSMutableString *str = [NSMutableString string];

    [str appendString:@"{\n"];

    // 遍历字典的所有键值对
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [str appendFormat:@"\t%@ : %@,\n", key, obj];
    }];

    [str appendString:@"}"];

    // 查出最后一个,的范围
    NSRange range = [str rangeOfString:@"," options:NSBackwardsSearch];
    if (range.length != 0) {
        // 删掉最后一个,
        [str deleteCharactersInRange:range];
    }

    return str;
}

@end
