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

@property (weak, nonatomic) JL_SportRecord_Chart *chart;
+ (instancetype)userDataView;

@end

NS_ASSUME_NONNULL_END
