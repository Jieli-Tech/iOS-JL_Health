//
//  JLSportWeeklyReportsDataTableViewCell.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/15.
//

#import "JLSportWeeklyReportsDataTableViewCell.h"

@interface JLSportWeeklyReportsDataTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UILabel *stepTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepUnitLabel;
@property (weak, nonatomic) IBOutlet UIImageView *stepChangeImageView;
@property (weak, nonatomic) IBOutlet UILabel *stepChangeLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceUnitLabel;
@property (weak, nonatomic) IBOutlet UIImageView *distanceChangeImageView;
@property (weak, nonatomic) IBOutlet UILabel *distanceChangeLabel;

@property (weak, nonatomic) IBOutlet UILabel *caloriesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloriesUnitLabel;
@property (weak, nonatomic) IBOutlet UIImageView *caloriesChangeImageView;
@property (weak, nonatomic) IBOutlet UILabel *caloriesChangeLabel;

@end

@implementation JLSportWeeklyReportsDataTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.containerView.layer.cornerRadius = 12;
    
    self.stepTitleLabel.text = kJL_TXT("一周步数");
    self.distanceTitleLabel.text = kJL_TXT("一周里程");
    self.caloriesTitleLabel.text = kJL_TXT("消耗热量");
    
    self.stepUnitLabel.text = kJL_TXT("步");
    self.caloriesUnitLabel.text = kJL_TXT("千卡");
    NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    self.distanceUnitLabel.text = kJL_TXT("公里");
    if ([unitStr isEqualToString:@("英制")]) {
        self.distanceUnitLabel.text = kJL_TXT("英里");
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - 步数
- (void)setStep:(NSInteger)step {
    _stepLabel.text = [NSString stringWithFormat:@"%ld", (long)step];
}

- (void)setStepChange:(NSInteger)stepChange {
    _stepChangeLabel.text = [NSString stringWithFormat:@"%ld%@", labs((long)stepChange), kJL_TXT("步")];
    _stepChangeImageView.image = [self changeImageWithIsUp:stepChange > 0 ? YES : NO];
}

#pragma mark - 距离
- (void)setDistance:(double)distance {
    NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    _distanceLabel.text = [NSString stringWithFormat:@"%.2f", distance];
    if ([unitStr isEqualToString:@("英制")]) {
        _distanceLabel.text = [NSString stringWithFormat:@"%.2f", fabs(distance * 0.621)];
    }
}

- (void)setDistanceChange:(double)distanceChange {
    NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    NSString *units = kJL_TXT("公里");
    if ([unitStr isEqualToString:@("英制")]) {
        units =kJL_TXT("英里");
        distanceChange = fabs(distanceChange * 0.621);
    }
    _distanceChangeLabel.text = [NSString stringWithFormat:@"%.2f%@", distanceChange, units];
    _distanceChangeImageView.image = [self changeImageWithIsUp:distanceChange > 0 ? YES : NO];
}

#pragma mark - 消耗

- (void)setCalories:(NSInteger)calories {
    _caloriesLabel.text = [NSString stringWithFormat:@"%ld", (long)calories];
}

- (void)setCaloriesChange:(NSInteger)caloriesChange {
    _caloriesChangeLabel.text = [NSString stringWithFormat:@"%ld%@", labs((long)caloriesChange), kJL_TXT("千卡")];
    _caloriesChangeImageView.image = [self changeImageWithIsUp:caloriesChange > 0 ? YES : NO];
}

#pragma mark - Private Methods
- (UIImage *)changeImageWithIsUp:(BOOL)isUp {
    if (isUp) {
        return [UIImage imageNamed:@"icon_up_nol"];
    }
    return [UIImage imageNamed:@"icon_down_nol"];
}

@end
