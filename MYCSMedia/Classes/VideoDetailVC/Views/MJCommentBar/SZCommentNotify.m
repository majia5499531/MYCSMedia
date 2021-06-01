//
//  SZCommentNotify.m
//  智慧长沙
//
//  Created by 马佳 on 2020/4/3.
//  Copyright © 2020 ChangShaBroadcastGroup. All rights reserved.
//

#import "SZCommentNotify.h"

@implementation SZCommentNotify

+(void)postCommentNotificationItemID:(NSString*)itemID delay:(CGFloat)time
{
//    SZCommentNotify * sender = [SZCommentNotify model];
//    sender.isSender = @"1";
//
//    [sender performSelector:@selector(sendNotification:) withObject:itemID afterDelay:time];
}

-(void)dealloc
{
//    NSLog(@"SZCommentNotify-dealloc-%@",self.isSender);
}

-(void)sendNotification:(NSString*)model
{
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"sendNewComment" object:model userInfo:nil];
}

@end
