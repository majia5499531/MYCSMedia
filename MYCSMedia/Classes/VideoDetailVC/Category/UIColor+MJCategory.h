/**
 * DevKit
 *
 * Created by Andy Roth.
 * Copyright 2009 Roozy. All rights reserved.
 */
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface UIColor (MJCategory)

// Color space utility methods
- (CGColorSpaceModel) colorSpaceModel;

// RGB components
- (BOOL) canProvideRGBComponents;
- (CGFloat) red;
- (CGFloat) green;
- (CGFloat) blue;
- (CGFloat) alpha;
- (CGFloat) luminance;

// String utility methods
- (NSString *) hexString;

// Static methods
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;


- (UIImage*) createImageWithColor;
@end
