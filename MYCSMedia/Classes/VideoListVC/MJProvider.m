//
//  MJProvider.m
//  IQDataBindingDemo
//
//  Created by 马佳 on 2021/6/12.
//  Copyright © 2021 lobster. All rights reserved.
//

#import "MJProvider.h"

@implementation MJProvider
+ (MJProvider *)provider
{
    static MJProvider * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil)
        {
            manager = [[MJProvider alloc]init];
        }
        });
    return manager;
}



-(CategoryViewModel *)cateViewModel
{
    if (_cateViewModel==nil)
    {
        _cateViewModel = [[CategoryViewModel alloc]init];
    }
    return _cateViewModel;
}


@end
