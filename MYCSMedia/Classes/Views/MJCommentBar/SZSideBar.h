//
//  SZSideBar.h
//  MYCSMedia
//
//  Created by 马佳 on 2022/4/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SZSideBar : UIView
@property(strong,nonatomic)NSString * contentId;
-(void)setHidePublishBtn:(BOOL)b;
-(void)clearAllData;
@end

NS_ASSUME_NONNULL_END
