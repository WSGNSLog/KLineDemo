//
//  AveragePriceLayer.m
//  KLineDemo
//
//  Created by shiguang on 2018/8/10.
//  Copyright © 2018年 shiguang. All rights reserved.
//

#import "AveragePriceLayer.h"
#import <UIKit/UIKit.h>
#import "KlineModel.h"

static NSString *const fiveColor = @"18c9f2";
static NSString *const TenColor  = @"ffe500";
static NSString *const TwentyColor  = @"dd3ddc";
static const NSInteger KlineCellSpace = 2;//cell间隔
static const NSInteger KlineCellWidth = 6;//cell宽度

static const NSInteger fiveLine = 4;
static const NSInteger tenLine  = 9;
static const NSInteger twentyLine = 19;

@interface AveragePriceLayer()
@property (nonatomic, strong)CAShapeLayer *fiveMinAP;
@property (nonatomic, strong)CAShapeLayer *TenMinAP;
@property (nonatomic, strong)CAShapeLayer *TwentyMinAP;
@end

@implementation AveragePriceLayer
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    if (_fiveMinAP == nil) {
        _fiveMinAP = [CAShapeLayer layer];
        _fiveMinAP.frame = frame;
        _fiveMinAP.strokeColor = [self colorWithHexString:fiveColor].CGColor;
        _fiveMinAP.fillColor   = [UIColor clearColor].CGColor;
        [self addSublayer:_fiveMinAP];
    }
    
    if (_TenMinAP == nil) {
        _TenMinAP = [CAShapeLayer layer];
        _TenMinAP.frame = frame;
        _TenMinAP.strokeColor = [self colorWithHexString:TenColor].CGColor;
        _TenMinAP.fillColor   = [UIColor clearColor].CGColor;
        [self addSublayer:_TenMinAP];
    }
    if (_TwentyMinAP == nil) {
        _TwentyMinAP = [CAShapeLayer layer];
        _TwentyMinAP.frame = frame;
        _TwentyMinAP.strokeColor = [self colorWithHexString:TwentyColor].CGColor;
        _TwentyMinAP.fillColor   = [UIColor clearColor].CGColor;
        [self addSublayer:_TwentyMinAP];
    }
    
}
- (void)loadLayerPreMigration:(NSInteger)offsetX KmodelArray:(NSMutableArray<KLineModel *> *)array{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block CGFloat fiveLineFloat = 0;
        __block CGFloat TenLineFloat  = 0;
        __block CGFloat TwenryFloat   = 0;
        
        UIBezierPath *fivePath = [UIBezierPath bezierPath];
        UIBezierPath *tenPath = [UIBezierPath bezierPath];
        UIBezierPath *twentyPath = [UIBezierPath bezierPath];
        
        NSInteger space = KlineCellSpace + KlineCellWidth;
        NSInteger halfWidth = KlineCellWidth/2.0;
        
        //5个的均线
        __block NSInteger starIndex = offsetX-fiveLine;//开始展示的获取的数据下标
        __block NSInteger showIndex = 0;//开始展示的下标
        if (starIndex<fiveLine) {
            showIndex = 0;
        }
        if (starIndex<0) {
            starIndex = 0;
        }
        //10个的均线
        __block NSInteger starIndexTen = offsetX-tenLine;//开始展示的获取的数据下标
        __block NSInteger showIndexTen = 0;//开始展示的下标
        //FIXME:if (starIndexTen < tenLine)
        if (starIndexTen < tenLine) {
            showIndexTen = -starIndexTen;
        }
        if (starIndexTen < 0) {
            starIndexTen = 0;
        }
        //20个的均线
        __block NSInteger starIndexTwenty = offsetX-twentyLine;//开始展示的获取的数据下标
        __block NSInteger showIndexTwenty = 0;//开始展示的下标
        if (starIndexTwenty < twentyLine) {
            showIndexTwenty = -starIndexTwenty;
        }
        if (starIndexTwenty < 0) {
            starIndexTwenty = 0;
        }
        //FIXME:todo
        [array enumerateObjectsUsingBlock:^(KLineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
        }];
    });
}
- (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] <6) {
        
        return [UIColor clearColor];
        
    }
    
    // strip 0X if it appears
    
    if ([cString hasPrefix:@"0X"])
        
        cString = [cString substringFromIndex:2];
    
    if ([cString hasPrefix:@"#"])
        
        cString = [cString substringFromIndex:1];
    
    if ([cString length] !=6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    
    NSRange range;
    
    range.location =0;
    
    range.length =2;
    
    
    NSString *rString = [cString substringWithRange:range];
    
    
    range.location =2;
    
    NSString *gString = [cString substringWithRange:range];
    
    
    range.location =4;
    
    NSString *bString = [cString substringWithRange:range];
    
    
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r /255.0f) green:((float) g /255.0f) blue:((float) b /255.0f) alpha:1.0f];
}
@end
