//
//  VideoErrorMessageView.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/8/10.
//

#import "VideoErrorMessageView.h"
#import <Masonry/Masonry.h>
@implementation VideoErrorMessageView
{
    UILabel * errLabel;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor=[UIColor blackColor];
        
        errLabel=[[UILabel alloc]init];
        
        errLabel.numberOfLines=0;
        errLabel.textColor=[UIColor whiteColor];
        errLabel.textAlignment=NSTextAlignmentCenter;
        errLabel.font=[UIFont systemFontOfSize:12];;
        errLabel.alpha=0.5;
        [self addSubview:errLabel];
        [errLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.mas_width).multipliedBy(0.5);
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self);
        }];

    }
    return self;
}


-(void)showErrorMessage:(NSString *)msg
{
    errLabel.text = msg;
}

@end
