//
//  JLSportHistoryUserDataView.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/28.
//

#import <UIKit/UIKit.h>
#import "JLSqliteSportRunningRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface JLSportHistoryUserDataView : UIView

+ (instancetype)userDataView;
- (void)setChart:(JL_SportRecord_Chart *)chart withAvgHeartRate:(NSInteger)avgHeartRate;

@end

NS_ASSUME_NONNULL_END
