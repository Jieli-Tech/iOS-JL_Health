//
//  JLSportHistoryUserDataView.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/28.
//

#import "JLSportHistoryUserDataView.h"
#import "MyImageStore.h"
#import "NSString+Time.h"

@interface JLSportHistoryUserDataView ()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *calorieLabel;
@property (weak, nonatomic) IBOutlet UILabel *calorieUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepCountUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgHeartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgHeartRateUnitLabel;

@end

@implementation JLSportHistoryUserDataView

+ (instancetype)userDataView {
    JLSportHistoryUserDataView *userDataView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([JLSportHistoryUserDataView class]) owner:nil options:nil] lastObject];
    userDataView.layer.cornerRadius = 12;
    userDataView.distanceUnitLabel.text = kJL_TXT("公里");
    userDataView.distanceUnitLabel.numberOfLines=2;
    userDataView.speedUnitLabel.text = kJL_TXT("配速");
    userDataView.speedUnitLabel.numberOfLines=2;
    userDataView.timeUnitLabel.text = kJL_TXT("运动时长");
    userDataView.timeUnitLabel.numberOfLines=2;
    userDataView.calorieUnitLabel.text = kJL_TXT("消耗（千卡）");
    userDataView.calorieUnitLabel.numberOfLines=2;
    userDataView.avgHeartRateUnitLabel.text = kJL_TXT("平均心率（次/分钟）");
    userDataView.avgHeartRateUnitLabel.numberOfLines=2;
    userDataView.stepCountUnitLabel.text = kJL_TXT("步数（步）");
    userDataView.stepCountUnitLabel.numberOfLines=2;
    return userDataView;
}

- (void)configureUserData {
//    UIImage *mImage = [[MyImageStore sharedStore] imageForKey:@"CYFStore"];
//    if (mImage != nil) {
//        self.userImageView.image = mImage;
//    } else {
        if(UserHttpInstance.userInfo.gender == 1) {
            [self.userImageView setImage:[UIImage imageNamed:@"img_profile_02_nol"]];
        } else {
            [self.userImageView setImage:[UIImage imageNamed:@"img_profile_01_nol"]];
        }
 //   }
    self.nameLabel.text = UserHttpInstance.userInfo.nickname;
}

- (void)setChart:(JL_SportRecord_Chart *)chart withAvgHeartRate:(NSInteger)avgHeartRate {
    [self configureUserData];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:chart.sport_id];
    self.dateLabel.text = [NSString stringWithFormat:@"%@ %@", date.toYYYYMMdd, date.toHHmm];
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f", (double)(chart.distance / 100)];
    self.speedLabel.text = [chart getSpeed];
    self.timeLabel.text = [NSString stringWithFormat:@"%@", [NSString timeFormatted:chart.duration]];
    self.calorieLabel.text = [NSString stringWithFormat:@"%ld", (long)chart.calories];
    self.stepCountLabel.text = [NSString stringWithFormat:@"%ld", (long)chart.step];
    self.avgHeartRateLabel.text = [NSString stringWithFormat:@"%ld", (long)avgHeartRate];
}

@end
