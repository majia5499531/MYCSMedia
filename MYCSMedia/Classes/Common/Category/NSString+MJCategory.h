//
//  NSString+MJCategory.h
//  星乐园
//
//  Created by 马佳 on 2017/5/24.
//  Copyright © 2017年 HW_tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (MJCategory)

-(NSString*)SHA256;
-(NSString*)encryptWithMD5;

+(NSString *)generateRandomStringWithLength:(NSInteger)len;
+(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
-(double)convertHexStingToDouble;


+(NSString *)urlEncodeStr:(NSString *)input;
+(NSString *)decoderUrlEncodeStr:(NSString *)input;


+(NSString*)convertToTimeString:(NSInteger)timeInterval;
+(NSString*)converUTCDateStr:(NSString*)utc;
+(NSString*)converToViewCountStr:(NSInteger)viewCount;
-(NSString*)convertTimeStingToSeconds;



-(instancetype)appenURLParam:(NSString*)key value:(NSString*)value;

@end
