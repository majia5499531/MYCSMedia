//
//  NSAttributedString+MJCategory.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/9/14.
//

#import "NSAttributedString+MJCategory.h"

@implementation NSAttributedString (MJCategory)

#pragma mark - 带标签的标题
-(UIImage*)imageWithUIView:(UIView*)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}

+(NSMutableAttributedString*)makeTaggedTitle:(NSString*)str tag:(NSString*)tagStr textColor:(UIColor*)textColor tagTintColor:(UIColor*)bgColor tagTextColor:(UIColor*)tagTextColor type:(int)type;
{
    if (str==nil)
    {
        str = @" ";
    }
    
    //标签颜色
    UIColor * tagBGColor = bgColor;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    
    //实心tag样式   (新闻标题)
    if (type==0)
    {
        //设置富文本
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        paragraphStyle.firstLineHeadIndent=0;
        paragraphStyle.alignment=NSTextAlignmentNatural;
        [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, str.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, str.length)];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:(17)] range:NSMakeRange(0, str.length)];
        
        
        //创建标签图片并插入
        if (tagStr.length)
        {
            NSInteger tagFont = 10;
            CGFloat tagLabelW = (tagFont + 2)*tagStr.length + 2;
            CGFloat tagLabelH = (tagFont + 7);
            UILabel *tagLabel = [[UILabel alloc]init];
            tagLabel.frame = CGRectMake(0, 0, tagLabelW*3, tagLabelH*3);
            tagLabel.text = tagStr;
            tagLabel.font = [UIFont systemFontOfSize:tagFont*3];
            tagLabel.textColor = tagTextColor;
            tagLabel.layer.backgroundColor=tagBGColor.CGColor;
            tagLabel.clipsToBounds = YES;
            tagLabel.layer.cornerRadius = 5;
            tagLabel.textAlignment = NSTextAlignmentCenter;

            UIGraphicsBeginImageContext(tagLabel.bounds.size);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            [tagLabel.layer renderInContext:ctx];
            UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.bounds = CGRectMake(15, -2, tagLabelW, tagLabelH);
            attach.image = image;
            NSAttributedString * imageStr = [NSAttributedString attributedStringWithAttachment:attach];
            [attStr insertAttributedString:imageStr atIndex:0];
            
            NSTextAttachment *attach2 = [[NSTextAttachment alloc] init];
            attach2.bounds = CGRectMake(0, 0, 5, 15);
            attach2.image = [UIImage imageNamed:@"emptyBar"];
            NSAttributedString * imageStr2 = [NSAttributedString attributedStringWithAttachment:attach2];
            [attStr insertAttributedString:imageStr2 atIndex:1];
        }
    }
    
    
    
    //镂空样式 (banner advertise)
    else if (type==1)
    {
        //设置富文本
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2.0;
        paragraphStyle.firstLineHeadIndent=0;
        paragraphStyle.alignment=NSTextAlignmentNatural;
        [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, str.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, str.length)];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, str.length)];
        
        //则创建图片并插入
        if (tagStr.length)
        {
            NSInteger tagFont = 10;
            CGFloat tagLabelW = (tagFont + 2)*tagStr.length + 4;
            CGFloat tagLabelH = (tagFont + 4);
            UILabel *tagLabel = [[UILabel alloc]init];
            tagLabel.frame = CGRectMake(0, 0, tagLabelW*3, tagLabelH*3);
            tagLabel.text = tagStr;
            tagLabel.font = [UIFont systemFontOfSize:tagFont*3];
            tagLabel.textColor = tagTextColor;
            tagLabel.layer.backgroundColor=[UIColor clearColor].CGColor;
            tagLabel.layer.borderColor=bgColor.CGColor;
            tagLabel.layer.borderWidth=1;
            tagLabel.clipsToBounds = YES;
            tagLabel.layer.cornerRadius = 3*3;
            tagLabel.textAlignment = NSTextAlignmentCenter;

            UIGraphicsBeginImageContext(tagLabel.bounds.size);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            [tagLabel.layer renderInContext:ctx];
            UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            //tag
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.bounds = CGRectMake(0, -2, tagLabelW, tagLabelH);
            attach.image = image;
            NSAttributedString * imageStr = [NSAttributedString attributedStringWithAttachment:attach];
            [attStr insertAttributedString:imageStr atIndex:0];
            
            //empty
            NSTextAttachment *attach2 = [[NSTextAttachment alloc] init];
            attach2.bounds = CGRectMake(0, 0, 5, 15);
            attach2.image =  [UIImage imageNamed:@"emptyBar"];
            NSAttributedString * imageStr2 = [NSAttributedString attributedStringWithAttachment:attach2];
            [attStr insertAttributedString:imageStr2 atIndex:1];
        }
    }
    
    
    
    //单行样式 (banner normal)
    else if (type==2)
    {
        //设置富文本
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        paragraphStyle.firstLineHeadIndent=0;
        paragraphStyle.alignment=NSTextAlignmentNatural;
        [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, str.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, str.length)];
        [attStr addAttribute:NSFontAttributeName value: [UIFont systemFontOfSize:17] range:NSMakeRange(0, str.length)];
        
        
        //创建标签图片并插入
        if (tagStr.length)
        {
            NSInteger tagFont = 10;
            CGFloat tagLabelW = (tagFont + 2)*tagStr.length + 2;
            CGFloat tagLabelH = (tagFont + 7);
            UILabel *tagLabel = [[UILabel alloc]init];
            tagLabel.frame = CGRectMake(0, 0, tagLabelW*3, tagLabelH*3);
            tagLabel.text = tagStr;
            tagLabel.font = [UIFont systemFontOfSize:tagFont*3];
            tagLabel.textColor = tagTextColor;
            tagLabel.layer.backgroundColor=tagBGColor.CGColor;
            tagLabel.clipsToBounds = YES;
            tagLabel.layer.cornerRadius = 3*3;
            tagLabel.textAlignment = NSTextAlignmentCenter;

            UIGraphicsBeginImageContext(tagLabel.bounds.size);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            [tagLabel.layer renderInContext:ctx];
            UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.bounds = CGRectMake(0, -3.5, tagLabelW, tagLabelH);
            attach.image = image;
            NSAttributedString * imageStr = [NSAttributedString attributedStringWithAttachment:attach];
            [attStr insertAttributedString:imageStr atIndex:0];
            
            NSTextAttachment *attach2 = [[NSTextAttachment alloc] init];
            attach2.bounds = CGRectMake(0, 0, 5, 15);
            attach2.image = [UIImage imageNamed:@"emptyBar"];
            NSAttributedString * imageStr2 = [NSAttributedString attributedStringWithAttachment:attach2];
            [attStr insertAttributedString:imageStr2 atIndex:1];
        }
    }
    
    
    
    //镂空，大字 （活动新闻、活动面板）
    else if (type==3)
    {
        //设置富文本
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2.0;
        paragraphStyle.firstLineHeadIndent=0;
        paragraphStyle.alignment=NSTextAlignmentNatural;
        [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, str.length)];
        [attStr addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, str.length)];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, str.length)];
        
        //则创建图片并插入
        if (tagStr.length)
        {
            NSInteger tagFont = 10;
            CGFloat tagLabelW = (tagFont + 2)*tagStr.length + 2;
            CGFloat tagLabelH = (tagFont + 6);
            UILabel *tagLabel = [[UILabel alloc]init];
            tagLabel.frame = CGRectMake(0, 0, tagLabelW*3, tagLabelH*3);
            tagLabel.text = tagStr;
            tagLabel.font = [UIFont systemFontOfSize:tagFont*3];
            tagLabel.textColor = tagTextColor;
            tagLabel.layer.backgroundColor=[UIColor clearColor].CGColor;
            tagLabel.layer.borderColor=bgColor.CGColor;
            tagLabel.layer.borderWidth=1;
            tagLabel.clipsToBounds = YES;
            tagLabel.layer.cornerRadius = 3*3;
            tagLabel.textAlignment = NSTextAlignmentCenter;

            UIGraphicsBeginImageContext(tagLabel.bounds.size);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            [tagLabel.layer renderInContext:ctx];
            UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            //tag
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.bounds = CGRectMake(15, -2, tagLabelW, tagLabelH);
            attach.image = image;
            NSAttributedString * imageStr = [NSAttributedString attributedStringWithAttachment:attach];
            [attStr insertAttributedString:imageStr atIndex:0];
            
            //empty
            NSTextAttachment *attach2 = [[NSTextAttachment alloc] init];
            attach2.bounds = CGRectMake(0, 0, 5, 15);
            attach2.image =  [UIImage imageNamed:@"emptyBar"];
            NSAttributedString * imageStr2 = [NSAttributedString attributedStringWithAttachment:attach2];
            [attStr insertAttributedString:imageStr2 atIndex:1];
        }
        
        
        
        
    }
    
    
    return attStr;
}



+(NSMutableAttributedString*)makeTaggedTitleAtEnd:(NSString*)str tag:(NSString*)tagStr textColor:(UIColor*)textColor tagColor:(UIColor*)tagColor
{
    NSString * originstr = nil;
    if (tagStr.length)
    {
        originstr = [NSString stringWithFormat:@" %@",str];
    }
    else
    {
        originstr=str;
    }
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:originstr];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8.0;
    paragraphStyle.firstLineHeadIndent=0;
    [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, originstr.length)];
    
    if (tagStr.length)
    {
        //创建占位符号
        NSAttributedString * spaceStr = [[NSAttributedString alloc]initWithString:@"  "];
        [attStr insertAttributedString:spaceStr atIndex:originstr.length];
        
        
        
        
        //创建标签
        CGFloat tagLabelW = 14*tagStr.length +6;
        UILabel *tagLabel = [[UILabel alloc]init];
        NSInteger tagFont = 10;
        CGFloat tagHeight = 18;
        tagLabel.frame = CGRectMake(0, 0, tagLabelW*3, tagHeight*3);
        tagLabel.text = tagStr;
        tagLabel.font = [UIFont systemFontOfSize:tagFont*3];
        tagLabel.textColor = textColor;
        tagLabel.layer.backgroundColor=tagColor.CGColor;
        tagLabel.clipsToBounds = YES;
        tagLabel.layer.cornerRadius = 3*3;
        tagLabel.textAlignment = NSTextAlignmentCenter;
        
        UIGraphicsBeginImageContext(CGSizeMake(tagLabel.frame.size.width, tagLabel.frame.size.height+5));
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [tagLabel.layer renderInContext:ctx];
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        attach.bounds = CGRectMake(0, -7, tagLabelW, tagHeight);
        attach.image = image;
        
        NSAttributedString * imageStr = [NSAttributedString attributedStringWithAttachment:attach];
        [attStr insertAttributedString:imageStr atIndex:attStr.length];
        
    }
    
    return attStr;
}




-(NSMutableAttributedString*)underLineString
{
    NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:self attributes:attribtDic];
    return attribtStr;
}


#pragma mark - 文本
+ (NSMutableAttributedString *)makeDescStyleStrWithNoIndent:(NSString *)str
{
    return [NSAttributedString makeDescStyleStr:str lineSpacing:8 indent:0];
}

+ (NSMutableAttributedString *)makeDescStyleStr:(NSString *)str
{
    return [NSAttributedString makeDescStyleStr:str lineSpacing:5 indent:30];
}



+(NSMutableAttributedString*)makeDescStyleStr:(NSString*)str lineSpacing:(CGFloat)space indent:(CGFloat)indent
{
    if (str.length==0)
    {
        str = @" ";
    }
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = space;
    paragraphStyle.firstLineHeadIndent=indent;
    paragraphStyle.alignment = NSTextAlignmentNatural;
    [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedStr.length)];
    
    return attributedStr;
}



+(NSMutableAttributedString*)makeTitleStr:(NSString*)str lineSpacing:(CGFloat)space indent:(CGFloat)indent
{
    if (str.length==0)
    {
        str = @" ";
    }
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = space;
    paragraphStyle.firstLineHeadIndent=indent;
    paragraphStyle.alignment = NSTextAlignmentNatural;
    [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedStr.length)];
    
    return attributedStr;
}



+(NSMutableAttributedString*)makeMultiColorStr:(NSString*)str color:(UIColor*)color at:(NSInteger)index length:(NSInteger)length
{
    if (str.length==0)
    {
        str = @" ";
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:str];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(index,length)];
    return attributedString;
}

@end
