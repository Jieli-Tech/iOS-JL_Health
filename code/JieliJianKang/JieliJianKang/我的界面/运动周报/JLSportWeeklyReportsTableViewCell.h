//
//  JLSportWeeklyReportsTableViewCell.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/16.
//

#import <UIKit/UIKit.h>
#import "PGBarChart.h"
#import "PGBarChartDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JLSportWeeklyReportsTableViewCell : UITableViewCell

- (void)configureCellWithBarChartDataModelArray:(NSMutableArray<PGBarChartDataModel *> *)barChartDataModelArray withGoalStep:(int)goalStep;

@end

NS_ASSUME_NONNULL_END
