//
//  SZInputView.h
//  智慧长沙
//
//  Created by 马佳 on 2020/3/18.
//  Copyright © 2020 ChangShaBroadcastGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)(id responseObject);

@interface SZInputView : UIView

+(instancetype)sharedSZInputView;

+(void)callInputView:(NSInteger)type contentId:(NSString*)contentId placeHolder:(NSString*)placeholder completion:(CompletionBlock)finish;

@end

