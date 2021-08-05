//
//  MJHUD_Selection.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/2.
//

#import "MJHUD_Base.h"

NS_ASSUME_NONNULL_BEGIN

@interface MJHUD_Selection : MJHUD_Base

+(void)showEpisodeSelectionView:(UIView*)view currenIdx:(NSInteger)idx episode:(NSInteger)count clickAction:(HUD_BLOCK)block;

+(void)showShareView:(HUD_BLOCK)reslt;

@end

NS_ASSUME_NONNULL_END
