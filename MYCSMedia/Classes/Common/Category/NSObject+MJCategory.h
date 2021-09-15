//
//  NSObject+MJCategory.h
//  区块链钱包
//
//  Created by 马佳 on 2018/9/10.
//  Copyright © 2018年 iBESTLOVE_HangZhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MJCategory)


//获取属性
-(NSArray*)getPropertyNames;
-(NSDictionary*)getPropertyValues;

//取值
-(id)mj_valueForKey:(NSString *)key;
-(instancetype)mj_stringValue;
-(instancetype)mj_arrayValue;

//KVC
-(void)setMJ_value:(id)value forKey:(NSString*)key;

//序列化
-(void)MJ_encode:(NSCoder *)aCoder;

//反序列化
-(void)MJ_decode:(NSCoder *)aDecoder;

//去掉NSNull
-(instancetype)trimNSNullFromArray;

@end
