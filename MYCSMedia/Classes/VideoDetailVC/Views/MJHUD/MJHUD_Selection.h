//
//  MJHUD_Selection.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/2.
//

#import "MJHUD_BASE.h"

NS_ASSUME_NONNULL_BEGIN

@interface MJHUD_Selection : MJHUD_BASE

+(void)showEpisodeSelectionView:(UIView*)view episode:(NSInteger)count clickAction:(HUD_BLOCK)block;

@end

NS_ASSUME_NONNULL_END
