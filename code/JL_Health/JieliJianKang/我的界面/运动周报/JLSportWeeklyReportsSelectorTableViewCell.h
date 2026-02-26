//
//  JLSportWeeklyReportsSelectorTableViewCell.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JLSportWeeklyReportsSelectorTableViewCellDelegate <NSObject>

@required
- (void)onClickLastWeekBtnFunc;
- (void)onClickNextWeekBtnFunc;

@end

@interface JLSportWeeklyReportsSelectorTableViewCell : UITableViewCell

@property (weak, nonatomic) id<JLSportWeeklyReportsSelectorTableViewCellDelegate> delegate;

@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) NSInteger achieveGoalDays;
@property (assign, nonatomic) NSInteger compareLastWeekAchieveUpDays;
@property (assign, nonatomic) BOOL nextBtnEnable;

@end

NS_ASSUME_NONNULL_END
