//
//  GetKlineData.m
//  KLineDemo
//
//  Created by shiguang on 2018/8/9.
//  Copyright © 2018年 shiguang. All rights reserved.
//

#import "GetKlineData.h"

@implementation GetKlineData

- (void)GetDataAddDelegate:(id<GetKlineDataDelegate>)delegate{
    self.delegate = delegate;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"];
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (dict) {
            NSMutableArray *datas = [NSMutableArray new];
            NSArray *dataArray = dict[@"ResultData"];
            [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [datas addObject: [self getHQDataArrayFromDataString:obj]];
            }];
            if ([self.delegate respondsToSelector:@selector(GetDatasFromGetKline:Array:)]) {
                [self.delegate GetDatasFromGetKline:self Array:datas];
            }
        }
    }
    
}


- (NSMutableArray *)getHQDataArrayFromDataString:(NSDictionary *)dict{
    if ([[dict class] isSubclassOfClass:[NSDictionary class]]) {
        if (dict == nil) {
            return nil;
        }
        NSMutableArray *dataArray = [NSMutableArray new];
        NSMutableString *dataString = [[NSMutableString alloc]initWithString:dict[@"d"]];
        while (1) {
            if ([dataString rangeOfString:@","].location != NSNotFound) {
                NSRange range = [dataString rangeOfString:@","];
                [dataArray addObject:[dataString substringWithRange:NSMakeRange(0, range.location)]];
                [dataString setString:[dataString substringFromIndex:range.location+1]];
                
            }else{
                if (dataString.length>0) {//最后一个
                    [dataArray addObject:dataString];
                }
                break;
            }
        }
        return dataArray;
    }
    return nil;
}











@end
