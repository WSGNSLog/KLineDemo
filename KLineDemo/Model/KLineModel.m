//
//  KLineModel.m
//  KLineDemo
//
//  Created by shiguang on 2018/8/9.
//  Copyright © 2018年 shiguang. All rights reserved.
//

#import "KLineModel.h"
#import "GetKlineData.h"

@interface KLineModel()<GetKlineDataDelegate>

@property (nonatomic,copy) void(^block)(NSArray *array);

@end

@implementation KLineModel

- (void)GetModelArray:(void (^)(NSArray *))block{
    self.block = [block copy];
    GetKlineData *getObj = [GetKlineData new];
    [getObj GetDataAddDelegate:self];
}
- (void)GetDatasFromGetKline:(GetKlineData *)obj Array:(NSArray *)array{
    NSMutableArray *datas = [NSMutableArray new];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [datas addObject:[self getModel:obj]];
    }];
    if (self.block) {
        self.block(datas);
    }
    
    
}

/*
 * 数组的顺序
 InstrumentID,LastPrice,AveragePrice,PreSettlementPrice,HighestPrice, 0-4
 LowestPrice,PreClosePrice,BidPrice1,BidVolume1,AskPrice1, 5-9
 AskVolume1,CreateTime,OpenInterest 10-12
 */
- (KLineModel *)getModel:(id)obj{
    KLineModel *model;
    if ([[obj class] isSubclassOfClass:[NSArray class]]) {
        NSMutableArray *dataArray = obj;
        model = [[KLineModel alloc]init];
        model.LastPrice = [dataArray[1] floatValue];
        model.PreClosePrice = [dataArray[3] floatValue];
        model.HighestPrice  = [dataArray[4] floatValue];
        model.LowestPrice   = [dataArray[5] floatValue];
        model.OpenPrice     = [dataArray[6] floatValue];
    }else{
        return nil;
    }
    return model;
}

@end
