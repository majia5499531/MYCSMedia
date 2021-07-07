//
//  ContentPanelManager.h
//  MYCSMedia
//
//  Created by 马佳 on 2021/6/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContentPanelManager : NSObject

+(void)regeisterPanelCell:(UICollectionView*)collectionview;

+(UICollectionViewCell *)dequeueCellFrom:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath PanelModel:(id)panelM;

+(NSInteger)getRowCountFromPanel:(id)panel;

+(UICollectionReusableView*)dequeueHeaderFrom:(UICollectionView*)collectionview indexPath:(NSIndexPath*)indexPath  panelModel:(id)panel;

+(CGSize)getHeaderViewSize:(id)panel;

@end

NS_ASSUME_NONNULL_END
