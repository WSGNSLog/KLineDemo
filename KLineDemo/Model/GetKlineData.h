//
//  GetKlineData.h
//  KLineDemo
//
//  Created by shiguang on 2018/8/9.
//  Copyright © 2018年 shiguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GetKlineData;

@protocol GetKlineDataDelegate <NSObject>

- (void)GetDatasFromGetKline:(GetKlineData *)obj Array:(NSArray *)array;

@end

@interface GetKlineData : NSObject

@property (weak, nonatomic)id <GetKlineDataDelegate>delegate;

- (void)GetDataAddDelegate:(id<GetKlineDataDelegate>)delegate;


@end
