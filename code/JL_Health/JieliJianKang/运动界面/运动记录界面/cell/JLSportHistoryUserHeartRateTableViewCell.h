//
//  JLSportHistoryUserHeartRateTableViewCell.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/17.
//

#import <UIKit/UIKit.h>
#import "JLSqliteSportRunningRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface JLSportHistoryUserHeartRateTableViewCell : UITableViewCell

@property (weak, nonatomic) JL_SportRecord_Chart *chart;

@end

NS_ASSUME_NONNULL_END
