//
//  MJProvider.h
//  IQDataBindingDemo
//
//  Created by 马佳 on 2021/6/12.
//  Copyright © 2021 lobster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryViewModel.h"




@interface MJProvider : NSObject

+ (MJProvider *)provider;

@property(strong,nonatomic)CategoryViewModel * cateViewModel;


@end

