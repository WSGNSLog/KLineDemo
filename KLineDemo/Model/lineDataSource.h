//
//  lineDataSource.h
//  KLineDemo
//
//  Created by shiguang on 2018/8/10.
//  Copyright © 2018年 shiguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CAShapeLayer,KLineModel;

@protocol lineDataSource <NSObject>
//展示的下标位置 count 展示的个数
- (KLineModel *)LineView:(UIView *)view cellAtIndex:(NSInteger)index;
- (NSInteger)numberOfLineView:(UIView *)view ;//返回数组总共要移动的个数

@optional
- (void)TrackingCrossIndexModel:(KLineModel *)model IndexPoint:(CGPoint)Point;//十字光标滑动时候选择的model和对应的point

- (void)willReload;//在这个方法里面  会刷新最高最低价格
@end
