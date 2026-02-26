//
//  JLSportStrengthView.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLSportStrengthView : UIView

- (void)setWatchHeartRateType:(WatchHeartRateType)heartRateType withWatchExerciseIntensityType:(WatchExerciseIntensityType)intensityType withTimeInterval:(NSTimeInterval)timeInterval withTotalTimeInterval:(NSTimeInterval)totalTimeInterval withViewWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
