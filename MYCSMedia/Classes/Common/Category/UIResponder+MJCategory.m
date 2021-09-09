//
//  UIResponder+MJCategory.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/21.
//

#import "UIResponder+MJCategory.h"

@implementation UIResponder (MJCategory)

-(UINavigationController*)getCurrentNavigationController
{
    UIResponder * resp = self;
    while (resp.nextResponder)
    {
        resp = resp.nextResponder;
        
        
        if ([resp isKindOfClass:[UINavigationController class]])
        {
            return (UINavigationController*)resp;
        }
    }
    
    return nil;
}

-(UIViewController*)getCurrentViewController
{
    UIResponder * resp = self;
    while (resp.nextResponder)
    {
        resp = resp.nextResponder;
        
        
        if ([resp isKindOfClass:[UIViewController class]])
        {
            return (UIViewController*)resp;
        }
    }
    
    return nil;
}

@end
