//
//  ContentPanelManager.m
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/25.
//

#import "ContentPanelManager.h"
#import "PanelModel.h"
#import "PanelConfigModel.h"
#import "VideoPanelCell.h"
#import "TVPanelCell.h"
#import "LivePanelCell.h"
#import "ContentModel.h"
#import "OtherPanelCell.h"
#import "ReviewNewsPanelCell.h"

#import "TextNewsPanelCell.h"
#import "MultipicNewsPanelCell.h"
#import "VideoNewsPanelCell.h"
#import "PicwordNewsPanelCell.h"
#import "LiveNewPanelCell.h"
#import "AdNewsPanelCell.h"
#import "ActivityNewsPanelCell.h"
#import "TopicNewsPanelCell.h"

#import "FilterHeaderView.h"

#import "UIView+MJCategory.h"
#import "SZDefines.h"


//面板类型
NSString * PannelTypeList = @"core.list.content";
NSString * PannelTypeTopicNews = @"news.special-overview";
NSString * PannelTypeSimple = @"core.simple";


//Cell ID
NSString * CellKeyTV = @"TVPanelCellReuse";
NSString * CellKeyLive = @"LivePanelCellReuse";
NSString * CellKeyVideo = @"VideoPanelCellReuse";

NSString * cellKeyFilterHeader = @"cellKeyFilterHeaderReuse";
NSString * cellKeyNormalHeader = @"cellKeyNormalHeaderReuse";
//电视回放类型
NSString * cellKeyReviewNews = @"cellKeyReviewNewsReuse";

//新闻类型
NSString * cellKeyTextNews = @"cellKeyTextNewsReuse";
NSString * cellkeyMultiPicNews = @"cellkeyMultiPicNewsReuse";
NSString * cellKeyVideoNews = @"cellKeyVideoNewsReuse";
NSString * cellKeyLiveNews = @"cellKeyLiveNewsReuse";
NSString * cellKeyADNews = @"cellKeyADNewsReuse";
NSString * cellKeyActivityNews = @"cellKeyActivityNewsReuse";
NSString * cellKeyPicwordNews = @"cellKeyPicwordNewsReuse";
NSString * cellKeyTopicNews = @"cellKeyTopicNewsReuse";

//其他
NSString * CellKeyOther = @"OtherPanelCellReuse";           //调试用

@implementation ContentPanelManager




#pragma mark - Cell
+(void)regeisterPanelCell:(UICollectionView*)collectionview
{
    [collectionview registerClass:[VideoPanelCell class] forCellWithReuseIdentifier:CellKeyVideo];
    [collectionview registerClass:[TVPanelCell class] forCellWithReuseIdentifier:CellKeyTV];
    [collectionview registerClass:[LivePanelCell class] forCellWithReuseIdentifier:CellKeyLive];
    [collectionview registerClass:[OtherPanelCell class] forCellWithReuseIdentifier:CellKeyOther];
    
    [collectionview registerClass:[ReviewNewsPanelCell class] forCellWithReuseIdentifier:cellKeyReviewNews];
    
    [collectionview registerClass:[VideoNewsPanelCell class] forCellWithReuseIdentifier:cellKeyVideoNews];
    [collectionview registerClass:[MultipicNewsPanelCell class] forCellWithReuseIdentifier:cellkeyMultiPicNews];
    [collectionview registerClass:[PicwordNewsPanelCell class] forCellWithReuseIdentifier:cellKeyPicwordNews];
    [collectionview registerClass:[LiveNewPanelCell class] forCellWithReuseIdentifier:cellKeyLiveNews];
    [collectionview registerClass:[AdNewsPanelCell class] forCellWithReuseIdentifier:cellKeyADNews];
    [collectionview registerClass:[ActivityNewsPanelCell class] forCellWithReuseIdentifier:cellKeyActivityNews];
    [collectionview registerClass:[TextNewsPanelCell class] forCellWithReuseIdentifier:cellKeyTextNews];
    [collectionview registerClass:[TopicNewsPanelCell class] forCellWithReuseIdentifier:cellKeyTopicNews];
    
    [collectionview registerClass:[FilterHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:cellKeyFilterHeader];
    [collectionview registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:cellKeyNormalHeader];
}

+(UICollectionViewCell *)dequeueCellFrom:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath PanelModel:(PanelModel*)panelM
{
    
    //竖列表
    if ([panelM.typeCode isEqualToString:PannelTypeList] && panelM.config.horizontal.boolValue==NO)
    {
        ContentModel * content = panelM.dataArr[indexPath.row];
        
        //直播
        if ([content.type isEqualToString:@"news_live"])
        {
            LivePanelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellKeyLive forIndexPath:indexPath];
            [cell setCellData:panelM.dataArr[indexPath.row]];
            return cell;
        }
        
        //短视频
        else if ([content.type isEqualToString:@"short_video"])
        {
            VideoPanelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellKeyVideo forIndexPath:indexPath];
            [cell setCellData:panelM.dataArr[indexPath.row]];
            return cell;
        }
        
        
        //左文右图新闻
        else if ([content.type isEqualToString:@"news_common"])
        {
            TextNewsPanelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellKeyTextNews forIndexPath:indexPath];
//            [cell setCellData:panelM.dataArr[indexPath.row]];
            return cell;
        }
        
        //多图新闻
        else if ([content.type isEqualToString:@"news_multipic"])
        {
            MultipicNewsPanelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellkeyMultiPicNews forIndexPath:indexPath];
//            [cell setCellData:panelM.dataArr[indexPath.row]];
            return cell;
        }
        
        //视频新闻
        else if ([content.type isEqualToString:@"news_video"])
        {
            VideoNewsPanelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellKeyVideoNews forIndexPath:indexPath];
//            [cell setCellData:panelM.dataArr[indexPath.row]];
            return cell;
        }
        
        //直播新闻
        else if ([content.type isEqualToString:@"news_live"])
        {
            LiveNewPanelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellKeyLiveNews forIndexPath:indexPath];
//            [cell setCellData:panelM.dataArr[indexPath.row]];
            return cell;
        }
        
        //广告新闻
        else if ([content.type isEqualToString:@"news_ad"])
        {
            AdNewsPanelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellKeyADNews forIndexPath:indexPath];
//            [cell setCellData:panelM.dataArr[indexPath.row]];
            return cell;
        }
        
        //活动新闻
        else if ([content.type isEqualToString:@"news_activity"])
        {
            ActivityNewsPanelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellKeyActivityNews forIndexPath:indexPath];
//            [cell setCellData:panelM.dataArr[indexPath.row]];
            return cell;
        }
        
        //图文直播新闻
        else if ([content.type isEqualToString:@"news_picword"])
        {
            PicwordNewsPanelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellKeyPicwordNews forIndexPath:indexPath];
//            [cell setCellData:panelM.dataArr[indexPath.row]];
            return cell;
        }
        
        //专题新闻
        else if ([content.type isEqualToString:@"special"])
        {
            TopicNewsPanelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellKeyTopicNews forIndexPath:indexPath];
            
            return cell;
        }
        
    }
    
    
    //横列表
    else if ([panelM.typeCode isEqualToString:PannelTypeList] && panelM.config.horizontal.boolValue==YES)
    {
        ContentModel * content = panelM.dataArr[indexPath.row];
        
        if ([content.type isEqualToString:@"tv"])
        {
            TVPanelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellKeyTV forIndexPath:indexPath];
            [cell setCellData:panelM];
            return cell;
        }
        
    }
    
    //电视回看
    else if ([panelM.typeCode isEqualToString:PannelTypeTopicNews])
    {
        ReviewNewsPanelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellKeyReviewNews forIndexPath:indexPath];
        [cell setCellData:panelM];
        return cell;
    }
    
    

    
    
    
    OtherPanelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellKeyOther forIndexPath:indexPath];
    return cell;
    
}


+ (NSInteger)getRowCountFromPanel:(PanelModel*)panel
{
    //竖列表
    if ([panel.typeCode isEqualToString:PannelTypeList] && panel.config.horizontal.boolValue==NO)
    {
        return panel.dataArr.count;
    }
    
    //横列表
    else if ([panel.typeCode isEqualToString:PannelTypeList] && panel.config.horizontal.boolValue==YES)
    {
        return 1;
    }
    
    //专题新闻
    else if ([panel.typeCode isEqualToString:PannelTypeTopicNews])
    {
        return 1;
    }
    
    //简单面板
    else if ([panel.typeCode isEqualToString:PannelTypeSimple])
    {
        return 1;
    }
    
    else
    {
        return panel.dataArr.count;
    }
}


+(UICollectionReusableView*)dequeueHeaderFrom:(UICollectionView*)collectionview indexPath:(NSIndexPath*)indexPath  panelModel:(PanelModel*)panel
{
    if ([panel.typeCode isEqualToString:PannelTypeList] && panel.config.filterItems.count>0)
    {
        FilterHeaderView * filterHeader = [collectionview dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:cellKeyFilterHeader forIndexPath:indexPath];
        [filterHeader setHeaderData:panel];
        return filterHeader;
    }
    
    else
    {
        return [collectionview dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:cellKeyNormalHeader forIndexPath:indexPath];
    }
}

+(CGSize)getHeaderViewSize:(PanelModel*)panel
{
    if ([panel.typeCode isEqualToString:PannelTypeList] && panel.config.filterItems.count>0)
    {
        return CGSizeMake(SCREEN_WIDTH, 47);
    }
    
    else
    {
        return CGSizeZero;
    }
}

@end
