//
//  SZManager.h
//  CSVideoDemo
//
//  Created by 马佳 on 2021/5/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



@protocol SZDelegate <NSObject>

-(NSString*)getAccessToken;
-(void)onShareAction:(NSString*)title image:(NSString*)imgurl desc:(NSString*)desc URL:(NSString*)url;
-(void)gotoLoginPage;

@end




@interface SZManager : NSObject

@property(weak,nonatomic) id <SZDelegate> delegate;

+ (SZManager *)sharedManager;

-(NSString *)getToken;


@end






NS_ASSUME_NONNULL_END
