//
//  SZCommentList.h
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/29.
//

#import <UIKit/UIKit.h>
#import "SZCommentBar.h"
#import "CommentDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SZCommentList : UIView

@property(weak,nonatomic)SZCommentBar * commentbar;

-(void)updateCommentData:(CommentDataModel*)model;

-(void)updateZanState:(BOOL)b count:(NSInteger)count;

-(void)updateCollectState:(BOOL)b;

-(void)showCommentList:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
