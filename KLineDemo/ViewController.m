//
//  ViewController.m
//  KLineDemo
//
//  Created by shiguang on 2018/8/9.
//  Copyright © 2018年 shiguang. All rights reserved.
//

#import "ViewController.h"

#import "KLineModel.h"
#import "kLineView.h"

@interface ViewController ()<lineDataSource>

@property (nonatomic, strong)NSArray *KlineModels;
@property (nonatomic, assign)NSInteger index;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    KLineModel *model = [KLineModel new];
    
    __weak ViewController *selfWeak = self;
    [model GetModelArray:^(NSArray *dataArray) {
        __strong ViewController *strongSelf = selfWeak;
        strongSelf.KlineModels = dataArray;
    }];
    
    KLineView *kline = [[KLineView alloc] initWithFrame:CGRectMake(0, 200, [UIScreen mainScreen].bounds.size.width, 300) Delegate:self];
    
    kline.ShowTrackingCross = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        kline.ShowTrackingCross = NO;
    });
    
    [self.view addSubview:kline];
    
    
    UIDevice *device = [UIDevice currentDevice];
    SEL selector = NSSelectorFromString(@"deviceInfoForKey:");
    if (![device respondsToSelector:selector]) {
        selector = NSSelectorFromString(@"_deviceInfoForKey:");
    }
    if ([device respondsToSelector:selector]) {
        //NSLog(@"DeviceColor: %@ DeviceEnclosureColor: %@", [device performSelector:selector withObject:@"DeviceColor"], [device performSelector:selector withObject:@"DeviceEnclosureColor"]);
        UIColor *color = [self colorWithHexString:[device performSelector:selector withObject:@"DeviceEnclosureColor"]];
        self.view.backgroundColor = color;
    }
}

- (KLineModel *)LineView:(UIView *)view cellAtIndex:(NSInteger)index;{
    return [self.KlineModels objectAtIndex:index];
}


- (NSInteger)numberOfLineView:(UIView *)view{
    return self.KlineModels.count;
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
