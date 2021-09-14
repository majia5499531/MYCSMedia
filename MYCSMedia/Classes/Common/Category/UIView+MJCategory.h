//
//  UIView+RMAdditions.h
//  RMCategories
//
//  Created by Richard McClellan on 5/27/13.
//  Copyright (c) 2013 Richard McClellan. All rights reserved.
//



#import <UIKit/UIKit.h>

@interface UIView (MJCategory)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;


-(void)MJRemoveAllSubviews;
-(void)MJRemoveAllSubviewsExcept:(NSArray*)objects;
-(void)MJSetIndividualAlpha:(CGFloat)value;
-(void)MJSetPartRadius:(CGFloat)radius RoundingCorners:(UIRectCorner)corners;


-(CGFloat)getBottomY;
-(CGFloat)getRightX;


@end
