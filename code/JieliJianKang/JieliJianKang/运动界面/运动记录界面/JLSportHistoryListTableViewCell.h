//
//  JLSportHistoryListTableViewCell.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/13.
//

#import <UIKit/UIKit.h>
#import "JLSqliteSportRunningRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface JLSportHistoryListTableViewCell : UITableViewCell

@property (weak, nonatomic) JL_SportRecord_Chart *chart;
- (void)configureCell;

@end

NS_ASSUME_NONNULL_END
