//
//  PanelModel.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/23.
//

#import "PanelModel.h"
#import "NSObject+MJCategory.h"
#import "NSObject+YYModel.h"
#import "PanelConfigModel.h"
#import "ContentModel.h"
#import "CategoryModel.h"


@implementation PanelModel

-(void)parseData:(id)data
{
    //其他属性
    [self modelSetWithDictionary:data];
    
    //config
    PanelConfigModel * configModel = [PanelConfigModel model];
    NSDictionary * configdic = [data mj_valueForKey:@"config"];
    [configModel parseData:configdic];
    self.config = configModel;
    
    //contents
    NSArray * contents = [data mj_valueForKey:@"contents"];
    for (int i = 0; i<contents.count; i++)
    {
        NSDictionary * contentDic = contents[i];
        ContentModel * model = [ContentModel model];
        [model modelSetWithDictionary:contentDic];
        [self.dataArr addObject:model];
    }
    
    //subcategories
    NSArray * subarr = [data mj_valueForKey:@"subCategories"];
    NSMutableArray * subcate = [NSMutableArray array];
    self.subCategories = subcate;
    for (int i = 0; i<subarr.count; i++)
    {
        NSDictionary * subcateDic = subarr[i];
        
        CategoryModel * submodel = [CategoryModel model];
        [submodel modelSetWithDictionary:subcateDic];
        [self.subCategories addObject:submodel];
    }
}

@end

