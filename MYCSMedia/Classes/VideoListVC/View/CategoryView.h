//
//  CategoryView.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CategoryView : UIView

@property(strong,nonatomic)NSString * categoryCode;

-(void)fetchData;

@end

NS_ASSUME_NONNULL_END
