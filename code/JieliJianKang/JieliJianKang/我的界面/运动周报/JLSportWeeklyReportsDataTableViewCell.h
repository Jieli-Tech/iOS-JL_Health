//
//  JLSportWeeklyReportsDataTableViewCell.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/15.
//

#import <UIKit/UIKit.h>
#import <TYCoreText/TYAttributedLabel.h>


NS_ASSUME_NONNULL_BEGIN

@interface JLSportWeeklyReportsDataTableViewCell : UITableViewCell

@property (assign, nonatomic) NSInteger step;
@property (assign, nonatomic) NSInteger stepChange;

@property (assign, nonatomic) double distance;
@property (assign, nonatomic) double distanceChange;

@property (assign, nonatomic) NSInteger calories;
@property (assign, nonatomic) NSInteger caloriesChange;

@end

NS_ASSUME_NONNULL_END
