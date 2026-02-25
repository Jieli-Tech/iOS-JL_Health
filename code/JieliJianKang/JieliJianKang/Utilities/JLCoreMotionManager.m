//
//  JLCoreMotionManager.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/4.
//

#import "JLCoreMotionManager.h"

@interface JLCoreMotionManager ()

@property (nonatomic, strong) CMPedometer * pedometer;
@property (nonatomic, assign) BOOL isUpdating;

@end

@implementation JLCoreMotionManager

+ (JLCoreMotionManager *)sharedInstance {
    static dispatch_once_t onceToken;
    static JLCoreMotionManager * sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[JLCoreMotionManager alloc] init];
    });
    return sSharedInstance;
}

- (CMPedometer *)pedometer {
    if (_pedometer == nil) {
        _pedometer = [[CMPedometer alloc] init];
    }
    return _pedometer;
}

/**
 *  从当前时间开始统计步数
 */
- (void)startPedometerUpdatesFromNow {
    if ([CMPedometer isStepCountingAvailable] && _isUpdating == false) {
        _isUpdating = true;
        NSLog(@"startPedometerUpdatesFromNow start!");
        [self.pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
            if (error) {
                NSLog(@"startPedometerUpdatesFromNow error ===%@", error);
            } else {
                NSLog(@"步数====%@", pedometerData.numberOfSteps);
                NSLog(@"距离====%@", pedometerData.distance);
                if ([self.delegate respondsToSelector:@selector(numberOfSteps:distance:)]) {
                    [self.delegate numberOfSteps:pedometerData.numberOfSteps distance:pedometerData.distance];
                }
            }
        }];
    } else {
        NSLog(@"startPedometerUpdatesFromNow is not available or is already update!");
    }
}

/**
 *  结束统计步数
 */
- (void)stopPedometerUpdates {
    _isUpdating = false;
    [self.pedometer stopPedometerUpdates];
}

@end
