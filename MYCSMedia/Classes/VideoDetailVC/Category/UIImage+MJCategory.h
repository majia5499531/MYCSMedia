//
//  UIImage+MJCategory.h
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (MJCategory)

+(UIImage*)getBundleImage:(NSString*)img;
+(NSURL *)getBundleImageURL:(NSString *)filename;
@end

NS_ASSUME_NONNULL_END
