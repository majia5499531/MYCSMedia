/**
 * DevKit
 *
 * Created by Andy Roth.
 * Copyright 2009 Roozy. All rights reserved.
 */
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface UIColor (MJCategory)

//Color space utility methods
-(CGColorSpaceModel)colorSpaceModel;

//获取RGB值
-(BOOL)canProvideRGBComponents;
-(CGFloat)red;
-(CGFloat)green;
-(CGFloat)blue;
-(CGFloat)alpha;
-(CGFloat)luminance;

//获取颜色的Hex值
-(NSString *) hexString;

//Hex创建颜色
+(UIColor *)colorWithHexString:(NSString *)stringToConvert;

@end
