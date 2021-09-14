//
//  UIImage+MJCategory.h
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/28.
//

#import <UIKit/UIKit.h>

@interface UIImage (MJCategory)

+(UIImage*)createColorImage:(UIColor*)color;
+(UIImage*)getBundleImage:(NSString*)img;
+(NSURL*)getBundleImageURL:(NSString *)filename;

@end
