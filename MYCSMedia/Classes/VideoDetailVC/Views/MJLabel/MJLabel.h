//
//  MJLabel.h
//  AFNetworking
//
//  Created by 马佳 on 2021/6/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MJLabel : UILabel

@property(assign,nonatomic)BOOL unfold;
@property(assign,nonatomic)BOOL alignmentTop;

-(void)mjsizeToFit;
-(CGFloat)estimatedHeight;
-(CGFloat)singleLineHeight;
-(int)getCurrentLines:(CGFloat)lineSpace;

@end

NS_ASSUME_NONNULL_END
