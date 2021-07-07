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

+(NSURL *)getBundleImageURL:(NSString *)filename
{
    NSString * bundelpath = [[NSBundle mainBundle]pathForResource:@"CSAssets.bundle/images" ofType:nil];
    NSString * filepath = [bundelpath stringByAppendingPathComponent:filename];
    NSURL * url = [NSURL fileURLWithPath:filepath];
    return url;
}

@end
