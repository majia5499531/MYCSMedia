//
//  SZManger.m
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/28.
//

#import "SZManger.h"

@implementation SZManger

+ (SZManger *)sharedManager
{
    static SZManger * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil)
        {
            manager = [[SZManger alloc]init];

            
        }
        });
    return manager;
}


@end
