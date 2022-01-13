//
//  SZVideoDetailVC.h
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/27.
//

#import <UIKit/UIKit.h>


@interface SZVideoDetailVC : UIViewController

@property(assign,nonatomic)NSInteger detailType;            //0单条视频 1视频集合

@property(strong,nonatomic)NSString * albumId;
@property(strong,nonatomic)NSString * albumName;
@property(strong,nonatomic)NSString * contentId;
@property(strong,nonatomic)NSString * category_name;
@property(assign,nonatomic)BOOL isPreview;

@end
