//
//  AveragePriceLayer.h
//  KLineDemo
//
//  Created by shiguang on 2018/8/10.
//  Copyright © 2018年 shiguang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class KLineModel;
@interface AveragePriceLayer : CALayer

@property (nonatomic, assign)CGFloat h;//view每个点代表的高度
@property (nonatomic, assign)CGFloat lowerPrice;//最低点的值
@property (nonatomic, assign)CGFloat x_scale;

//传入现在绘制的点下标  还有从20个点之前加上k线图显示的个数的数组
- (void)loadLayerPreMigration:(NSInteger)offsetX KmodelArray:(NSMutableArray <KLineModel *>*)array;

@end
