//
//  SZCommentNotify.h
//  智慧长沙
//
//  Created by 马佳 on 2020/4/3.
//  Copyright © 2020 ChangShaBroadcastGroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SZCommentNotify : NSObject
@property(strong,nonatomic)NSString * newsID;
@property(strong,nonatomic)NSString * commentID;
@property(strong,nonatomic)NSString * replyID;
@property(strong,nonatomic)NSString * isSender;
+(void)postCommentNotificationItemID:(NSString*)itemID delay:(CGFloat)time;

@end


