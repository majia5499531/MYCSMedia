//
//  SZVideoCell.h
//  智慧长沙
//
//  Created by 马佳 on 2019/11/13.
//  Copyright © 2019 ChangShaBroadcastGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SZVideoCell : UICollectionViewCell

-(void)setCellData:(NSObject*)news;

-(void)playingVideo;

@end

NS_ASSUME_NONNULL_END
