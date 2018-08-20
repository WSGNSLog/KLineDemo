//
//  KLineView.m
//  KLineDemo
//
//  Created by shiguang on 2018/8/10.
//  Copyright © 2018年 shiguang. All rights reserved.
//

#import "KLineView.h"
#import "KLineModel.h"
#import "AveragePriceLayer.h"

static const NSInteger KlineCellSpace = 2;//cell间隔
static const NSInteger KlineCellWidth = 6;//cell宽度
static const NSInteger CellOffset = 3;//偏移的单位（速度）
static const CGFloat scale_Min = 0.1;//最小缩放量
static const CGFloat scale_Max = 1;//最大缩放量

@interface KLineView()

@property (nonatomic, strong)CAShapeLayer *ShapeLayer;//父layer
@property (nonatomic, assign)NSInteger ShowArrayMaxCount;//展示的最大个数 保存这个最大值

@property (nonatomic, strong)UIPanGestureRecognizer *pan;//拖动手势
@property (nonatomic, strong)NSMutableArray *KlineShowArray;//保存k线图需要展示的数据

@property (nonatomic, assign)CGFloat ShowHeight;//保存这个view的高
@property (nonatomic, assign)CGFloat ShowWidth;//保存这个view的宽

@property (nonatomic, assign)CGFloat h;//view每个点代表的高度
@property (nonatomic, assign)NSInteger count;//view能容纳显示多少个


@property (nonatomic, assign)NSInteger OffsetIndex;//偏移量 记录数据下标开始的显示范围
@property (nonatomic, assign)CGFloat x_scale;//x坐标缩放的比例

@property (nonatomic, strong)CAShapeLayer *TrackingCrosslayer;//十字光标的layer层

@property (nonatomic, strong)UIColor *redColor;//红色 涨的蜡烛
@property (nonatomic, strong)UIColor *BlueColor;//蓝色 跌的蜡烛 偏绿色吧
@property (nonatomic, strong)UIColor *whiteColor;//白色 平的蜡烛

@property (nonatomic, strong)AveragePriceLayer *APLayer;//均线的

@end

@implementation KLineView
- (instancetype)initWithFrame:(CGRect)frame Delegate:(id)delegate{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        self.APLayer = [AveragePriceLayer layer];
        self.APLayer.frame = self.bounds;
        [self kLineInit];
    }
    return self;
}
- (void)kLineInit{
    self.KlineShowArray = [NSMutableArray new];
    
    self.pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
    [self addGestureRecognizer:self.pan];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchAction:)];
    [self addGestureRecognizer:pinch];
    
    self.redColor = [UIColor redColor];
    self.BlueColor = [UIColor colorWithRed:71/255.0 green:211/255.0 blue:209/255.0 alpha:1];
    self.whiteColor = [UIColor whiteColor];
    
    [self reload];
}
#pragma mark- 响应手势
- (void)panGesture:(UIPanGestureRecognizer *)pan{
    
    //十字光标开启 进入滑动显示对应的model数据
    
}

//缩放
- (void)pinchAction:(UIPinchGestureRecognizer *)pinch{
    
}
//重新绘制
- (void)reload{
    if ([self.delegate respondsToSelector:@selector(numberOfLineView:)]) {
        self.ShowArrayMaxCount = [self.delegate numberOfLineView:self];
    }
    self.ShowHeight = CGRectGetHeight(self.frame);
    self.ShowWidth = CGRectGetWidth(self.frame);
    
    if (!self.x_scale) {
        self.x_scale = 1;
    }
    
    //计算这个视图里面 能容纳多少个蜡烛图  宽度/(间隔＋单位蜡烛的宽度)*缩放的比例
    self.count = self.ShowWidth/((KlineCellSpace+KlineCellWidth)*self.x_scale);
    //计算现在是从哪一个下标开始取 总个数减去显示的个数
    NSInteger index = self.ShowArrayMaxCount - self.count;
    if (index < 0) {
        index = 0;
    }
    self.OffsetIndex = index;//初始化偏移位置
    
    //开始绘图
    [self offsetNormal];
}
- (void)offsetNormal{
    [self offset_xPoint:CGPointMake(0, 0)];
}

//滑动效果
- (void)offset_xPoint:(CGPoint)point{
    if ([self.delegate respondsToSelector:@selector(LineView:cellAtIndex:)]) {
        
        //计算偏移量
        if (point.x < 0) {
            self.OffsetIndex += CellOffset;
        }else if(point.x > 0){
            self.OffsetIndex -= CellOffset;
        }
        if (self.OffsetIndex < 0) {
            self.OffsetIndex = 0;
        }
        if (self.OffsetIndex > self.ShowArrayMaxCount-self.count) {
            self.OffsetIndex = self.ShowArrayMaxCount-self.count-1;
        }
        NSInteger index = self.OffsetIndex;
        if (index < 0) {
            index = 0;
        }
        //获取到对应的数据
        @synchronized(self){
            [self.KlineShowArray removeAllObjects];
            NSInteger count = MIN(self.count, self.ShowArrayMaxCount);
            for (int i=0; i<count; i++,index++) {
                KLineModel *model = [self.delegate LineView:self cellAtIndex:index];
                if (model) {
                    [self.KlineShowArray addObject:model];
                }
            }
        }
        //继续走流程
        [self calculateHeightAndLowerFromArray:self.KlineShowArray];
        
        //todo
        //这是均线的
        [self initAP];
    }
}
- (void)initAP{
    
}
//计算最高最低
- (void)calculateHeightAndLowerFromArray:(NSArray *)array{
    _lowerPrice = 0;
    _heightPrice = 0;
    //遍历获取最高最低值
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KLineModel *model = obj;
        CGFloat heightestFloat = MAX(model.HighestPrice, model.LastPrice);
        if (heightestFloat > self.heightPrice) {
            _heightPrice = heightestFloat;
        }
        
        if (self.lowerPrice == 0) {
            _lowerPrice = model.LowestPrice;
        }
        
        if (model.LowestPrice < self.lowerPrice || model.LastPrice < self.lowerPrice) {
            if (model.LastPrice >0 && model.LowestPrice >0) {
                _lowerPrice = MIN(model.LowestPrice, model.LastPrice);
            }
        }
    }];
    
    //调整比例
    _lowerPrice *= 0.9996;
    _heightPrice *= 1.0004;
    
    [self calculateH];
}
- (void)calculateH{
    //将改变的值 放出去
    if ([self.delegate respondsToSelector:@selector(willReload)]) {
        [self.delegate willReload];
    }
    
    self.h = (self.heightPrice - self.lowerPrice)/self.ShowHeight;
    
    [self CalculationShowPointFromLastPrices:self.KlineShowArray];
}
//计算所有点位
- (void)CalculationShowPointFromLastPrices:(NSArray <KLineModel *>*)array{
    //重置ShapeLayer 父层
    [self initShapeLayer];
    [array enumerateObjectsUsingBlock:^(KLineModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
       
        //生成蜡烛图 添加到父层
        CAShapeLayer *cellCAShapeLayer = [self GetShapeLayerFromModel:model Index:idx];
        [self.ShapeLayer addSublayer:cellCAShapeLayer];
    }];
    
    //把这些层添加到这个view
    [self.layer addSublayer:self.ShapeLayer];
    [self.layer addSublayer:self.APLayer];
    
}
//制作CAShapeLayer
- (CAShapeLayer *)GetShapeLayerFromModel:(KLineModel *)model Index:(NSInteger)idx{
    CGFloat openPrice = (model.OpenPrice- self.lowerPrice)/self.h;//开盘价减去这个视图的最小价格得出差值除以每一个点代表的值 以下一样
    CGFloat preClosePrice = (model.PreClosePrice - self.lowerPrice)/self.h;
    CGFloat x = (KlineCellSpace + KlineCellWidth)*idx*self.x_scale;
    CGFloat y = openPrice > preClosePrice ? preClosePrice:openPrice;
    //fabs 取整
    CGFloat height = MAX(fabs(preClosePrice-openPrice), 1);
    
    //在这里绘制好方形，如果出现蜡烛倒置，可用showHeight-height或者倒转这个layer
    CGRect rect = CGRectMake(x, y, KlineCellWidth*self.x_scale, height);
    
    //用贝塞尔描述路径
    UIBezierPath *cellPath = [UIBezierPath bezierPathWithRect:rect];
    cellPath.lineWidth = 0.75;
    
    //移动点 绘制最高最低值--绘制上影线、下影线
    [cellPath moveToPoint:CGPointMake(x+KlineCellWidth/2, y)];
    [cellPath addLineToPoint:CGPointMake(x+KlineCellWidth/2, (model.LowestPrice-self.lowerPrice)/self.h)];
    
    [cellPath moveToPoint:CGPointMake(x+KlineCellWidth/2, y+height)];
    [cellPath addLineToPoint:CGPointMake(x+KlineCellWidth/2, (model.HighestPrice-self.lowerPrice)/self.h)];
    
    //生成layer 用贝塞尔路径给他渲染
    CAShapeLayer *cellShapeLayer = [CAShapeLayer layer];
    cellShapeLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    cellShapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    //调整颜色
    if (model.OpenPrice == model.PreClosePrice) {
        cellShapeLayer.strokeColor = self.whiteColor.CGColor;
    }else if (model.OpenPrice > model.PreClosePrice){
        cellShapeLayer.strokeColor = self.redColor.CGColor;
    }else{
        cellShapeLayer.fillColor = self.BlueColor.CGColor;
    }
    cellShapeLayer.path = cellPath.CGPath;
    
    //返回一个蜡烛图
    [cellPath removeAllPoints];
    
    return cellShapeLayer;
}
- (void)initShapeLayer{
    if (self.ShapeLayer) {
        [self.ShapeLayer removeFromSuperlayer];
        self.ShapeLayer = nil;
    }
    if (self.ShapeLayer == nil) {
        self.ShapeLayer = [CAShapeLayer layer];
        self.ShapeLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        self.ShapeLayer.strokeColor = [UIColor colorWithRed:40/255.0 green:135/255.0 blue:255/255.0 alpha:1].CGColor;
        self.ShapeLayer.fillColor = [UIColor clearColor].CGColor;
    }
}
@end
