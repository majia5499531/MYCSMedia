//
//  MJLabel.m
//  AFNetworking
//
//  Created by 马佳 on 2021/6/9.
//



#import "MJLabel.h"

@implementation MJLabel


-(id)initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame];
}

-(CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    if (self.alignmentTop)
    {
        CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
        textRect.origin.y = bounds.origin.y;
        return textRect;
    }
    else
    {
        return [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    }
    
}

-(void)drawTextInRect:(CGRect)requestedRect
{
    if (self.alignmentTop)
    {
        CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
        [super drawTextInRect:actualRect];
    }
    else
    {
        [super drawTextInRect:requestedRect];
    }
}

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
