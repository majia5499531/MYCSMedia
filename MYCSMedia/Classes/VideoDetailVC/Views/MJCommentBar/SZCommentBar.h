//
//  SZCommentBar.h
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SZCommentBar : UIView

@property(strong,nonatomic)NSString * contentId;

-(void)updateCommentBarData:(NSString*)contentId;


-(void)sendCommentAction;
-(void)requestZan;
-(void)requestCollect;

@end

NS_ASSUME_NONNULL_END
