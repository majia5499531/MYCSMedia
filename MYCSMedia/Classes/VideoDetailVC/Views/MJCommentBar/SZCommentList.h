//
//  SZCommentList.h
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/29.
//

#import <UIKit/UIKit.h>
#import "SZCommentBar.h"
#import "CommentDataModel.h"






@interface SZCommentList : UIView



@property(strong,nonatomic)NSString * contentId;


-(void)showCommentList:(BOOL)show;

@end


