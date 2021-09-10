//
//  SZHomeRootView1.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SZHomeRootView1 : UIView
@property(assign,nonatomic)BOOL selected;

-(void)viewWillAppear;
-(void)needUpdateCurrentContentId_now:(BOOL)force;


-(void)setActivityImg:(NSString*)img1 simpleImg:(NSString*)img2 linkUrl:(NSString*)url;

@end

NS_ASSUME_NONNULL_END
