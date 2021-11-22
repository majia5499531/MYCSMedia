//
//  NSAttributedString+MJCategory.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (MJCategory)

+(NSMutableAttributedString*)makeTaggedTitle:(NSString*)str tag:(NSString*)tagStr textColor:(UIColor*)textColor tagTintColor:(UIColor*)bgColor tagTextColor:(UIColor*)tagTextColor type:(int)type;
+(NSMutableAttributedString*)makeTaggedTitleAtEnd:(NSString*)str tag:(NSString*)tagStr textColor:(UIColor*)color tagColor:(UIColor*)tagColor;


+(NSMutableAttributedString*)makeDescStyleStr:(NSString*)str;
+(NSMutableAttributedString*)makeDescStyleStrWithNoIndent:(NSString*)str ;
+(NSMutableAttributedString*)makeDescStyleStr:(NSString*)str lineSpacing:(CGFloat)space indent:(CGFloat)indent;
+(NSMutableAttributedString*)makeTitleStr:(NSString*)str lineSpacing:(CGFloat)space indent:(CGFloat)indent;

+(NSMutableAttributedString*)makeMultiColorStr:(NSString*)str color:(UIColor*)color at:(NSInteger)index length:(NSInteger)length;
-(NSMutableAttributedString*)underLineString;
@end

NS_ASSUME_NONNULL_END
