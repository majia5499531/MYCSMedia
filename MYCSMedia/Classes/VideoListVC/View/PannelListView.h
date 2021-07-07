//
//  PannelListView.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/22.
//

#import <UIKit/UIKit.h>
#import "CategoryModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface PannelListView : UIView

@property(strong,nonatomic)NSString * subcateCode;

@property(strong,nonatomic)CategoryModel * subcateModel;

-(void)fetchData;

@end

NS_ASSUME_NONNULL_END
