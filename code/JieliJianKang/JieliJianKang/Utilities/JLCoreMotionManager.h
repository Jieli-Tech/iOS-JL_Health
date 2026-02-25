//
//  JLCoreMotionManager.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/4.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JLCoreMotionManagerDelegate <NSObject>

- (void)numberOfSteps:(NSNumber *)numberOfSteps distance:(NSNumber *)distance;

@end

@interface JLCoreMotionManager : NSObject

@property (weak, nonatomic) id<JLCoreMotionManagerDelegate> delegate;

+ (JLCoreMotionManager *)sharedInstance;

/**
 *  从当前时间开始统计步数
 */
- (void)startPedometerUpdatesFromNow;
/**
 *  结束统计步数、距离
 */
- (void)stopPedometerUpdates;

@end

NS_ASSUME_NONNULL_END
