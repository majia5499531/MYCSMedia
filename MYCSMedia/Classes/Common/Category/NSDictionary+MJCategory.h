//
//  NSDictionary+MJCategory.h
//  星乐园
//
//  Created by 马佳 on 2017/6/8.
//  Copyright © 2017年 HW_tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (MJCategory)
//字典转字符串
-(NSString*)converteDictionaryToJsonStr;
-(NSString*)convertToJSON;
-(NSString*)converteDictionaryToCustomStr;
@end
