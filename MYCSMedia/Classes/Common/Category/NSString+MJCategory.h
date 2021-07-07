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
-(NSString*)converToTimeString;
+(NSString *)randomStringWithLength:(NSInteger)len;
+(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
-(double)convertHexStingToDouble;
-(NSMutableAttributedString*)underLineString;
+(NSString*)convertToTimeString:(NSInteger)timeInterval;
+(NSString *)urlEncodeStr:(NSString *)input;
+(NSString *)decoderUrlEncodeStr:(NSString *)input;
+(NSString*)converUTCDateStr:(NSString*)utc;

+(NSMutableAttributedString*)makeTaggedTitle:(NSString*)str tag:(NSString*)tagStr textColor:(UIColor*)textColor tagTintColor:(UIColor*)bgColor tagTextColor:(UIColor*)tagTextColor type:(int)type;
+(NSMutableAttributedString*)makeTaggedTitleAtEnd:(NSString*)str tag:(NSString*)tagStr textColor:(UIColor*)color tagColor:(UIColor*)tagColor;

+(NSMutableAttributedString*)makeADString:(NSString*)str tag:(NSString*)tagStr ADColor:(UIColor*)textcolor tagColor:(UIColor*)tagColor;
+(NSMutableAttributedString*)makeADString:(NSString*)str tag:(NSString*)tagStr tagColor:(UIColor*)tagColor;

+(NSMutableAttributedString*)makeDescStyleStr:(NSString*)str;
+(NSMutableAttributedString*)makeDescStyleStrWithNoIndent:(NSString*)str ;
+(NSMutableAttributedString*)makeDescStyleStr:(NSString*)str lineSpacing:(CGFloat)space indent:(CGFloat)indent;
+(NSMutableAttributedString*)makeTitleStr:(NSString*)str lineSpacing:(CGFloat)space indent:(CGFloat)indent;

+(NSMutableAttributedString*)makeMultiColorStr:(NSString*)str color:(UIColor*)color at:(NSInteger)index length:(NSInteger)length;

-(instancetype)appenURLParam:(NSString*)key value:(NSString*)value;

@end
