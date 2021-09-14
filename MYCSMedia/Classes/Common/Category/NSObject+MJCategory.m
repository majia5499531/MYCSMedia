//
//  NSObject+MJCategory.m
//  区块链钱包
//
//  Created by 马佳 on 2018/9/10.
//  Copyright © 2018年 iBESTLOVE_HangZhou. All rights reserved.
//

#import "NSObject+MJCategory.h"
#import "objc/runtime.h"

@implementation NSObject (MJCategory)

//获取属性名
-(NSArray*)getPropertyNames
{
    u_int count;
    
    objc_property_t *properties  =class_copyPropertyList([self class], &count);
    
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i<count; i++)
        
    {
        
        const char* propertyName =property_getName(properties[i]);
        
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
        
    }
    
    free(properties);
    
    return propertiesArray;
}

//获取属性值
-(NSDictionary*)getPropertyValues
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    
    unsigned int outCount, i;
    
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    for (i = 0; i<outCount; i++)
        
    {
        
        objc_property_t property = properties[i];
        
        const char* char_f =property_getName(property);
        
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
        
    }
    
    free(properties);
    
    return props;
}

//取值
-(id)mj_valueForKey:(NSString *)key
{
    id obj = [self valueForKey:key];
    
    //Null转nil
    if ([obj isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    
    //Number转字符串
    if ([obj isKindOfClass:[NSNumber class]])
    {
        return [NSString stringWithFormat:@"%@",obj];
    }
    
    return obj;
}

//获取字符串
-(instancetype)mj_stringValue
{
    if ([self isKindOfClass:[NSString class]])
    {
        return self;
    }
    else if ([self isKindOfClass:[NSNumber class]])
    {
        return [NSString stringWithFormat:@"%@",self];
    }
    else
    {
        return nil;
    }
}

//获取数组
-(instancetype)mj_arrayValue
{
    if ([self isKindOfClass:[NSArray class]])
    {
        return self;
    }
    else
    {
        return nil;
    }
}

//赋值
-(void)setMJ_value:(id)value forKey:(NSString*)key
{
    if (value==nil)
    {
        value = @"";
    }
    
    [self setValue:value forKey:key];
}


//序列化
-(void)MJ_encode:(NSCoder *)aCoder
{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++)
    {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        NSString *key = [[NSString alloc]initWithUTF8String:name];
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}

//反序列化
-(void)MJ_decode:(NSCoder *)aDecoder
{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++)
    {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        NSString *key = [[NSString alloc]initWithUTF8String:name];
        id value = [aDecoder decodeObjectForKey:key];
        [self setValue:value forKey:key];
    }
}



//去掉NSNull
-(instancetype)trimNSNullFromArray
{
    if ([self isKindOfClass:[NSArray class]])
    {
        NSMutableArray * arr = [NSMutableArray arrayWithArray:(NSArray*)self];
        for (int i = 0; i<arr.count; i++)
        {
            id objc = arr[i];
            if ([objc isKindOfClass:[NSNull class]])
            {
                [arr removeObject:objc];
            }
        }
        
        return [NSArray arrayWithArray:arr];
    }
    
    return self;
}


@end
