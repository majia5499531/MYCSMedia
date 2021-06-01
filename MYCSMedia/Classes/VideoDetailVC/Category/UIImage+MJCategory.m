//
//  UIImage+MJCategory.m
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/28.
//

#import "UIImage+MJCategory.h"

@implementation UIImage (MJCategory)

+(UIImage *)getBundleImage:(NSString *)filename
{
    UIImage * img = [UIImage imageNamed:[@"CSAssets.bundle/images" stringByAppendingPathComponent:filename]];
    return img;
}

@end
