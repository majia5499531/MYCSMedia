//
//  NSString+MJCategory.m
//  星乐园
//
//  Created by 马佳 on 2017/5/24.
//  Copyright © 2017年 HW_tech. All rights reserved.
//

#import "NSString+MJCategory.h"
#import <CommonCrypto/CommonCrypto.h>
#import "UIColor+MJCategory.h"


@implementation NSString (MJCategory)
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


-(NSString*)converToTimeString
{
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * date=[formatter dateFromString:self];
    NSInteger dateValue=[date timeIntervalSince1970];
    return [NSString stringWithFormat:@"%ld",(long)dateValue];
}

+(NSString *)randomStringWithLength:(NSInteger)len
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (NSInteger i = 0; i < len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    return randomString;
}

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
+(NSString *)decoderUrlEncodeStr: (NSString *) input
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+" withString:@"" options:NSLiteralSearch range:NSMakeRange(0,[outputStr length])];
    return [outputStr stringByRemovingPercentEncoding];
}


-(NSMutableAttributedString*)underLineString
{
    NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:self attributes:attribtDic];
    return attribtStr;
}

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
    
    NSString * leftTime = [NSString stringWithFormat:@"%ld:%ld:%ld",h,m,s];
    
    return leftTime;
}


#pragma mark - 带标签的标题
-(UIImage*)imageWithUIView:(UIView*)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}

+(NSMutableAttributedString*)makeTaggedTitle:(NSString*)str tag:(NSString*)tagStr textColor:(UIColor*)textColor tagTintColor:(UIColor*)bgColor tagTextColor:(UIColor*)tagTextColor type:(int)type;
{
    if (str==nil)
    {
        str = @" ";
    }
    
    //标签颜色
    UIColor * tagBGColor = bgColor;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    
    //实心tag样式   (新闻标题)
    if (type==0)
    {
        //设置富文本
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        paragraphStyle.firstLineHeadIndent=0;
        paragraphStyle.alignment=NSTextAlignmentNatural;
        [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, str.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, str.length)];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:(17)] range:NSMakeRange(0, str.length)];
        
        
        //创建标签图片并插入
        if (tagStr.length)
        {
            NSInteger tagFont = 10;
            CGFloat tagLabelW = (tagFont + 2)*tagStr.length + 2;
            CGFloat tagLabelH = (tagFont + 7);
            UILabel *tagLabel = [[UILabel alloc]init];
            tagLabel.frame = CGRectMake(0, 0, tagLabelW*3, tagLabelH*3);
            tagLabel.text = tagStr;
            tagLabel.font = [UIFont systemFontOfSize:tagFont*3];
            tagLabel.textColor = tagTextColor;
            tagLabel.layer.backgroundColor=tagBGColor.CGColor;
            tagLabel.clipsToBounds = YES;
            tagLabel.layer.cornerRadius = 5;
            tagLabel.textAlignment = NSTextAlignmentCenter;

            UIGraphicsBeginImageContext(tagLabel.bounds.size);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            [tagLabel.layer renderInContext:ctx];
            UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.bounds = CGRectMake(15, -2, tagLabelW, tagLabelH);
            attach.image = image;
            NSAttributedString * imageStr = [NSAttributedString attributedStringWithAttachment:attach];
            [attStr insertAttributedString:imageStr atIndex:0];
            
            NSTextAttachment *attach2 = [[NSTextAttachment alloc] init];
            attach2.bounds = CGRectMake(0, 0, 5, 15);
            attach2.image = [UIImage imageNamed:@"emptyBar"];
            NSAttributedString * imageStr2 = [NSAttributedString attributedStringWithAttachment:attach2];
            [attStr insertAttributedString:imageStr2 atIndex:1];
        }
    }
    
    
    
    //镂空样式 (banner advertise)
    else if (type==1)
    {
        //设置富文本
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2.0;
        paragraphStyle.firstLineHeadIndent=0;
        paragraphStyle.alignment=NSTextAlignmentNatural;
        [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, str.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, str.length)];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, str.length)];
        
        //则创建图片并插入
        if (tagStr.length)
        {
            NSInteger tagFont = 10;
            CGFloat tagLabelW = (tagFont + 2)*tagStr.length + 4;
            CGFloat tagLabelH = (tagFont + 4);
            UILabel *tagLabel = [[UILabel alloc]init];
            tagLabel.frame = CGRectMake(0, 0, tagLabelW*3, tagLabelH*3);
            tagLabel.text = tagStr;
            tagLabel.font = [UIFont systemFontOfSize:tagFont*3];
            tagLabel.textColor = tagTextColor;
            tagLabel.layer.backgroundColor=[UIColor clearColor].CGColor;
            tagLabel.layer.borderColor=bgColor.CGColor;
            tagLabel.layer.borderWidth=1;
            tagLabel.clipsToBounds = YES;
            tagLabel.layer.cornerRadius = 3*3;
            tagLabel.textAlignment = NSTextAlignmentCenter;

            UIGraphicsBeginImageContext(tagLabel.bounds.size);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            [tagLabel.layer renderInContext:ctx];
            UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            //tag
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.bounds = CGRectMake(0, -2, tagLabelW, tagLabelH);
            attach.image = image;
            NSAttributedString * imageStr = [NSAttributedString attributedStringWithAttachment:attach];
            [attStr insertAttributedString:imageStr atIndex:0];
            
            //empty
            NSTextAttachment *attach2 = [[NSTextAttachment alloc] init];
            attach2.bounds = CGRectMake(0, 0, 5, 15);
            attach2.image =  [UIImage imageNamed:@"emptyBar"];
            NSAttributedString * imageStr2 = [NSAttributedString attributedStringWithAttachment:attach2];
            [attStr insertAttributedString:imageStr2 atIndex:1];
        }
    }
    
    
    
    //单行样式 (banner normal)
    else if (type==2)
    {
        //设置富文本
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        paragraphStyle.firstLineHeadIndent=0;
        paragraphStyle.alignment=NSTextAlignmentNatural;
        [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, str.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, str.length)];
        [attStr addAttribute:NSFontAttributeName value: [UIFont systemFontOfSize:17] range:NSMakeRange(0, str.length)];
        
        
        //创建标签图片并插入
        if (tagStr.length)
        {
            NSInteger tagFont = 10;
            CGFloat tagLabelW = (tagFont + 2)*tagStr.length + 2;
            CGFloat tagLabelH = (tagFont + 7);
            UILabel *tagLabel = [[UILabel alloc]init];
            tagLabel.frame = CGRectMake(0, 0, tagLabelW*3, tagLabelH*3);
            tagLabel.text = tagStr;
            tagLabel.font = [UIFont systemFontOfSize:tagFont*3];
            tagLabel.textColor = tagTextColor;
            tagLabel.layer.backgroundColor=tagBGColor.CGColor;
            tagLabel.clipsToBounds = YES;
            tagLabel.layer.cornerRadius = 3*3;
            tagLabel.textAlignment = NSTextAlignmentCenter;

            UIGraphicsBeginImageContext(tagLabel.bounds.size);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            [tagLabel.layer renderInContext:ctx];
            UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.bounds = CGRectMake(0, -3.5, tagLabelW, tagLabelH);
            attach.image = image;
            NSAttributedString * imageStr = [NSAttributedString attributedStringWithAttachment:attach];
            [attStr insertAttributedString:imageStr atIndex:0];
            
            NSTextAttachment *attach2 = [[NSTextAttachment alloc] init];
            attach2.bounds = CGRectMake(0, 0, 5, 15);
            attach2.image = [UIImage imageNamed:@"emptyBar"];
            NSAttributedString * imageStr2 = [NSAttributedString attributedStringWithAttachment:attach2];
            [attStr insertAttributedString:imageStr2 atIndex:1];
        }
    }
    
    
    
    //镂空，大字 （活动新闻、活动面板）
    else if (type==3)
    {
        //设置富文本
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2.0;
        paragraphStyle.firstLineHeadIndent=0;
        paragraphStyle.alignment=NSTextAlignmentNatural;
        [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, str.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, str.length)];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, str.length)];
        
        //则创建图片并插入
        if (tagStr.length)
        {
            NSInteger tagFont = 10;
            CGFloat tagLabelW = (tagFont + 2)*tagStr.length + 2;
            CGFloat tagLabelH = (tagFont + 6);
            UILabel *tagLabel = [[UILabel alloc]init];
            tagLabel.frame = CGRectMake(0, 0, tagLabelW*3, tagLabelH*3);
            tagLabel.text = tagStr;
            tagLabel.font = [UIFont systemFontOfSize:tagFont*3];
            tagLabel.textColor = tagTextColor;
            tagLabel.layer.backgroundColor=[UIColor clearColor].CGColor;
            tagLabel.layer.borderColor=bgColor.CGColor;
            tagLabel.layer.borderWidth=1;
            tagLabel.clipsToBounds = YES;
            tagLabel.layer.cornerRadius = 3*3;
            tagLabel.textAlignment = NSTextAlignmentCenter;

            UIGraphicsBeginImageContext(tagLabel.bounds.size);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            [tagLabel.layer renderInContext:ctx];
            UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            //tag
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.bounds = CGRectMake(15, -2, tagLabelW, tagLabelH);
            attach.image = image;
            NSAttributedString * imageStr = [NSAttributedString attributedStringWithAttachment:attach];
            [attStr insertAttributedString:imageStr atIndex:0];
            
            //empty
            NSTextAttachment *attach2 = [[NSTextAttachment alloc] init];
            attach2.bounds = CGRectMake(0, 0, 5, 15);
            attach2.image =  [UIImage imageNamed:@"emptyBar"];
            NSAttributedString * imageStr2 = [NSAttributedString attributedStringWithAttachment:attach2];
            [attStr insertAttributedString:imageStr2 atIndex:1];
        }
        
        
        
        
    }
    
    
    return attStr;
}



+(NSMutableAttributedString*)makeTaggedTitleAtEnd:(NSString*)str tag:(NSString*)tagStr textColor:(UIColor*)color tagColor:(UIColor*)tagColor
{
    NSString * originstr = nil;
    if (tagStr.length)
    {
        originstr = [NSString stringWithFormat:@" %@",str];
    }
    else
    {
        originstr=str;
    }
    
    UIColor * tagBGColor = [UIColor colorWithRed:tagColor.red green:tagColor.green blue:tagColor.blue alpha:0.2];
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:originstr];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8.0;
    paragraphStyle.firstLineHeadIndent=0;
    [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, originstr.length)];
    
    if (tagStr.length)
    {
        CGFloat tagLabelW = 14*tagStr.length +6;
        UILabel *tagLabel = [[UILabel alloc]init];
        NSInteger tagFont = 12;
        tagLabel.frame = CGRectMake(0, 0, tagLabelW*3, 18*3);
        tagLabel.text = tagStr;
        tagLabel.font = [UIFont systemFontOfSize:tagFont*3];
        tagLabel.textColor = tagColor;
        tagLabel.layer.backgroundColor=tagBGColor.CGColor;
        tagLabel.layer.borderColor=tagColor.CGColor;
        tagLabel.layer.borderWidth=1;
        tagLabel.clipsToBounds = YES;
        tagLabel.layer.cornerRadius = 3*3;
        tagLabel.textAlignment = NSTextAlignmentCenter;
        
        UIGraphicsBeginImageContext(tagLabel.bounds.size);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [tagLabel.layer renderInContext:ctx];
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        attach.bounds = CGRectMake(18, -2, tagLabelW, 18);
        attach.image = image;
        
        NSAttributedString * imageStr = [NSAttributedString attributedStringWithAttachment:attach];
//        [attStr insertAttributedString:imageStr atIndex:originstr.length];
        [attStr insertAttributedString:imageStr atIndex:0];
        
    }
    
    return attStr;
}




#pragma mark - 广告
+(NSMutableAttributedString*)makeADString:(NSString*)str tag:(NSString*)tagStr tagColor:(UIColor*)tagColor
{
    return [NSString makeADString:str tag:tagStr ADColor:[UIColor grayColor] tagColor:tagColor];
}

+(NSMutableAttributedString*)makeADString:(NSString*)str tag:(NSString*)tagStr ADColor:(UIColor*)textcolor tagColor:(UIColor*)tagColor
{
    NSString * originstr = nil;
    if (tagStr.length)
    {
        originstr = [NSString stringWithFormat:@"  %@",str];
    }
    else
    {
        originstr=str;
    }
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:originstr];
    [attStr addAttribute:NSForegroundColorAttributeName value:textcolor range:NSMakeRange(0, originstr.length)];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, originstr.length)];
    
    if (tagStr.length)
    {
        CGFloat tagLabelW = 12*tagStr.length + 6;
        CGFloat tagLabelH = 14;
        UILabel *tagLabel = [[UILabel alloc]init];
        NSInteger tagFont = 10;
        tagLabel.frame = CGRectMake(0, 0, tagLabelW*3, tagLabelH*3);
        tagLabel.text = tagStr;
        tagLabel.font = [UIFont systemFontOfSize:tagFont*3];
        tagLabel.textColor = [UIColor blackColor];
        tagLabel.layer.backgroundColor=[UIColor whiteColor].CGColor;
        tagLabel.layer.borderColor=[UIColor grayColor].CGColor;
        tagLabel.layer.borderWidth=1;
        tagLabel.clipsToBounds = YES;
        tagLabel.layer.cornerRadius = 3*3;
        tagLabel.textAlignment = NSTextAlignmentCenter;
        
        UIGraphicsBeginImageContext(tagLabel.bounds.size);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [tagLabel.layer renderInContext:ctx];
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        attach.bounds = CGRectMake(0, -2.5, tagLabelW, tagLabelH);
        attach.image = image;
        
        NSAttributedString * imageStr = [NSAttributedString attributedStringWithAttachment:attach];
        [attStr insertAttributedString:imageStr atIndex:0];
        
    }
    
    return attStr;
}



#pragma mark - 文本
+ (NSMutableAttributedString *)makeDescStyleStrWithNoIndent:(NSString *)str
{
    return [NSString makeDescStyleStr:str lineSpacing:8 indent:0];
}

+ (NSMutableAttributedString *)makeDescStyleStr:(NSString *)str
{
    return [NSString makeDescStyleStr:str lineSpacing:5 indent:30];
}

+(NSMutableAttributedString*)makeDescStyleStr:(NSString*)str lineSpacing:(CGFloat)space indent:(CGFloat)indent
{
    if (str.length==0)
    {
        str = @"暂无";
    }
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = space;
    paragraphStyle.firstLineHeadIndent=indent;
    paragraphStyle.alignment = NSTextAlignmentNatural;
    [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedStr.length)];
    
    return attributedStr;
}
+(NSMutableAttributedString*)makeTitleStr:(NSString*)str lineSpacing:(CGFloat)space indent:(CGFloat)indent
{
    if (str.length==0)
    {
        str = @"暂无";
    }
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = space;
    paragraphStyle.firstLineHeadIndent=indent;
    paragraphStyle.alignment = NSTextAlignmentNatural;
    [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedStr.length)];
    
    return attributedStr;
}

+(NSMutableAttributedString*)makeMultiColorStr:(NSString*)str color:(UIColor*)color at:(NSInteger)index length:(NSInteger)length
{
    if (str.length==0)
    {
        str = @"暂无";
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:str];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(index,length)];
    return attributedString;
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
