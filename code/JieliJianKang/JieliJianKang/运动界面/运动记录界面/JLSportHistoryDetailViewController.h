//
//  JLSportHistoryDetailViewController.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/14.
//

#import <UIKit/UIKit.h>
#import "SportVC.h"
#import "JLSqliteSportRunningRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface JLSportHistoryDetailViewController : UIViewController

@property (strong, nonatomic) JL_SportRecord_Chart *chart;
@property (assign, nonatomic) BOOL needPopToRootViewController;

@end

NS_ASSUME_NONNULL_END
