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
    UIResponder * respder = self;
    while (respder.nextResponder)
    {
        respder = respder.nextResponder;
        
        
        if ([respder isKindOfClass:[UINavigationController class]])
        {
            return respder;
        }
    }
    
    return nil;
}

@end
