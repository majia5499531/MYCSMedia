//
//  SZCommentCell.h
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SZCommentCell : UICollectionViewCell

-(void)setCommentData:(id)commentM replyData:(id)replyM;

-(CGSize)getCellSize;

@end

NS_ASSUME_NONNULL_END
