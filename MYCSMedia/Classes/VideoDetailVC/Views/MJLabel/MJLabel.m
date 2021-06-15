//
//  MJLabel.m
//  AFNetworking
//
//  Created by 马佳 on 2021/6/9.
//



#import "MJLabel.h"

@implementation MJLabel

-(void)mjsizeToFit
{
    CGFloat width = self.frame.size.width;
    CGSize size = [self sizeThatFits:self.frame.size];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, width, size.height)];
}

-(CGFloat)estimatedHeight
{
    CGSize size = [self sizeThatFits:self.frame.size];
    return size.height;
}

-(CGFloat)singleLineHeight
{
    NSString *testString = @"1";
    CGSize size =[testString sizeWithAttributes:@{NSFontAttributeName:self.font}];
    return size.height;
}
-(int)getCurrentLines:(CGFloat)lineSpace;
{
    CGFloat totalHeight = [self estimatedHeight];
    CGFloat singleHeight = [self singleLineHeight];
    return totalHeight/singleHeight;
}

@end
