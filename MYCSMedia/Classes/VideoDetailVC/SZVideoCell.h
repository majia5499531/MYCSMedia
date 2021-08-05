//
//  SZVideoCell.h
//  智慧长沙
//
//  Created by 马佳 on 2019/11/13.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VideoCellDelegate <NSObject>

-(void)didSelectVideo:(id)model;

@end





@interface SZVideoCell : UICollectionViewCell

@property(weak,nonatomic)id<VideoCellDelegate>delegate;

-(void)setCellData:(NSObject*)news;


@end

NS_ASSUME_NONNULL_END
