//
//  NSString+MJCategory.m
//  星乐园
//
//  Created by 马佳 on 2017/5/24.
//  Copyright © 2017年 HW_tech. All rights reserved.
//

#import "NSString+MJCategory.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (MJCategory)

//MD5
-(NSString*)encryptWithMD5
{
    const char *original_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str,(CC_LONG) strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

//SHA
-(NSString*)SHA256
{
    const char *s = [self cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
    CC_SHA256(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *out = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash = [out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}


//年月日 转 时间戳
-(NSString*)convertTimeStingToSeconds
{
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * date=[formatter dateFromString:self];
    NSInteger dateValue=[date timeIntervalSince1970];
    return [NSString stringWithFormat:@"%ld",(long)dateValue];
}


//创建随机字符串
+(NSString *)generateRandomStringWithLength:(NSInteger)len
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (NSInteger i = 0; i < len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    return randomString;
}


//JSON转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil)
    {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


//转十六进制为数字
-(double)convertHexStingToDouble
{
    NSString * hex = self;
    if ([self hasPrefix:@"0x"] && self.length>2)
    {
        hex = [self substringFromIndex:2];
    }
    
    NSString * binaStr = [NSString getBinaryByHex:hex];
    double d = [NSString getDecimalByBinary:binaStr];
    return d;
}


//十六进制转二进制
+(NSString *)getBinaryByHex:(NSString *)hex
{
    
    NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"A"];
    [hexDic setObject:@"1011" forKey:@"B"];
    [hexDic setObject:@"1100" forKey:@"C"];
    [hexDic setObject:@"1101" forKey:@"D"];
    [hexDic setObject:@"1110" forKey:@"E"];
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSString *binary = @"";
    for (int i=0; i<[hex length]; i++) {
        
        NSString *key = [hex substringWithRange:NSMakeRange(i, 1)];
        NSString *value = [hexDic objectForKey:key.uppercaseString];
        if (value) {
            
            binary = [binary stringByAppendingString:value];
        }
    }
    return binary;
}


//二进制转十进制
+(double)getDecimalByBinary:(NSString *)binary
{
    double num = 0;
    for (int i=0; i<binary.length; i++)
    {
        
        NSString *number = [binary substringWithRange:NSMakeRange(binary.length - i - 1, 1)];
        if ([number isEqualToString:@"1"])
        {
            num += pow(2, i);
        }
    }
    return num;
}


//urlEncode编码
+(NSString *)urlEncodeStr:(NSString *)input
{
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *upSign = [input stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return upSign;
}


//urlEncode解码
+(NSString *)decoderUrlEncodeStr:(NSString *)input
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+" withString:@"" options:NSLiteralSearch range:NSMakeRange(0,[outputStr length])];
    return [outputStr stringByRemovingPercentEncoding];
}


//时长秒数 转 时分秒
+(NSString *)convertToTimeString:(NSInteger)timeInterval
{
    NSInteger h = 0;
    NSInteger m = 0;
    NSInteger s = 0;
    NSInteger yu = 0;
    
    
    //时
    h = timeInterval / 3600;
    yu = timeInterval % 3600;
    
    //分
    m = yu/60;
    yu = yu%60;
    
    //秒
    s = yu;
    
    NSString * leftTime = [NSString stringWithFormat:@"%ld:%ld:%ld",(long)h,(long)m,(long)s];
    
    return leftTime;
}


//国际时间 转 当地时间
+(NSString*)converUTCDateStr:(NSString*)utc
{
    NSDateFormatter *format1 = [[NSDateFormatter alloc] init];
    [format1 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *originDate = [format1 dateFromString:utc];
    
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    NSInteger timeoffsets = [localTimeZone secondsFromGMT];
    NSInteger timeStamp = [originDate timeIntervalSince1970];
    timeStamp += timeoffsets;
    
    //现在的时间戳
    NSInteger localTime = [[NSDate date]timeIntervalSince1970];
    
    //本地计算的时间差
    NSInteger timepass = localTime - timeStamp;
        
    //秒、时、天、年
    NSInteger min = 60;
    NSInteger hour = min * 60;
    NSInteger day = 24 * hour;
    NSInteger year = 365 * day;
    
    
    if (timepass<10)
    {
        return @"刚刚";
    }
    else if (timepass<min)
    {
        return [NSString stringWithFormat:@"%ld秒前",(long)timepass];
    }
    else if (timepass<hour)
    {
        NSInteger minutes = timepass/60;
        return [NSString stringWithFormat:@"%ld分钟前",(long)minutes];
    }
    else if (timepass<day)
    {
        NSInteger hours = timepass/3600;
        return [NSString stringWithFormat:@"%ld小时前",(long)hours];
    }
    else if (timepass<year)
    {
        NSDateFormatter * format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"MM-dd"];
        NSString * str = [format stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeStamp]];
        return [NSString stringWithFormat:@"%@",str];
    }
    else
    {
        NSDateFormatter * format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"yyyy-MM-dd"];
        NSString * str = [format stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeStamp]];
        return [NSString stringWithFormat:@"%@",str];
    }

}


//点击量
+(NSString*)converToViewCountStr:(NSInteger)viewCount
{
    NSInteger views = viewCount;
    
    if (views<10000)
    {
        return [NSString stringWithFormat:@"%ld",(long)views];
    }
    else
    {
        int k = (int)views/10000;
        return [NSString stringWithFormat:@"%d 万",k];
    }
}




#pragma mark - URL加参数
-(instancetype)appenURLParam:(NSString*)key value:(NSString*)value
{
    NSString * returnStr = [self mutableCopy];
    
    if (returnStr.length && key.length && value.length)
    {
        if (![returnStr containsString:@"?"])
        {
            returnStr = [NSString stringWithFormat:@"%@?%@=%@",returnStr,key,value];
        }
        else
        {
            returnStr = [NSString stringWithFormat:@"%@&%@=%@",returnStr,key,value];
        }
    }
    
    return returnStr;
    
}


@end
