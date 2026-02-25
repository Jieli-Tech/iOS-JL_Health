//
//  JLSportStrengthView.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/18.
//

#import "JLSportStrengthView.h"
#import "NSString+Time.h"

@interface JLSportStrengthView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *progressContainerView;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewWidthLayoutConstraint;

@end

@implementation JLSportStrengthView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)setWatchHeartRateType:(WatchHeartRateType)heartRateType withWatchExerciseIntensityType:(WatchExerciseIntensityType)intensityType withTimeInterval:(NSTimeInterval)timeInterval withTotalTimeInterval:(NSTimeInterval)totalTimeInterval withViewWidth:(CGFloat)width {
    if (totalTimeInterval == 0) totalTimeInterval = 1;
    self.timeLabel.text = [NSString stringWithFormat:@"%@", [NSString timeFormatted:timeInterval]];
    double ratio = timeInterval / totalTimeInterval;
    if (ratio > 1) ratio = 1;
    CGFloat constant = ratio * (width - 32);
    self.progressViewWidthLayoutConstraint.constant = constant;
    self.progressContainerView.layer.cornerRadius = self.progressContainerView.height / 2;
    [self.progressContainerView.layer masksToBounds];
    self.progressView.layer.cornerRadius = self.progressView.height / 2;
    [self.progressView.layer masksToBounds];
    switch (intensityType) {
        case WatchExercise_Level1:
            self.progressView.backgroundColor = [JLColor colorWithString:@"#87C1EF"];
            self.progressContainerView.backgroundColor = [JLColor colorWithString:@"#87C1EF" alpha:0.1f];
            self.titleLabel.text = heartRateType == WatchHeartRate_Max ? kJL_TXT("热身") : kJL_TXT("有氧基础");
            break;
        case WatchExercise_Level2:
            self.progressView.backgroundColor = [JLColor colorWithString:@"#92D58B"];
            self.progressContainerView.backgroundColor = [JLColor colorWithString:@"#92D58B" alpha:0.1f];
            self.titleLabel.text = heartRateType == WatchHeartRate_Max ? kJL_TXT("燃脂") : kJL_TXT("有氧进阶");
            break;
        case WatchExercise_Level3:
            self.progressView.backgroundColor = [JLColor colorWithString:@"#F6E970"];
            self.progressContainerView.backgroundColor = [JLColor colorWithString:@"#F6E970" alpha:0.1f];
            self.titleLabel.text = heartRateType == WatchHeartRate_Max ? kJL_TXT("有氧耐力") : kJL_TXT("乳酸阈值");
            break;
        case WatchExercise_Level4:
            self.progressView.backgroundColor = [JLColor colorWithString:@"#F9B478"];
            self.progressContainerView.backgroundColor = [JLColor colorWithString:@"#F9B478" alpha:0.1f];
            self.titleLabel.text = heartRateType == WatchHeartRate_Max ? kJL_TXT("无氧耐力") : kJL_TXT("无氧基础");
            break;
        case WatchExercise_Level5:
            self.progressView.backgroundColor = [JLColor colorWithString:@"#F07B71"];
            self.progressContainerView.backgroundColor = [JLColor colorWithString:@"#F07B71" alpha:0.1f];
            self.titleLabel.text = heartRateType == WatchHeartRate_Max ? kJL_TXT("极限") : kJL_TXT("无氧进阶");
            break;
        default:
            self.progressView.backgroundColor = [JLColor colorWithString:@"#BABABA"];
            self.progressContainerView.backgroundColor = [JLColor colorWithString:@"#BABABA" alpha:0.1f];
            self.titleLabel.text = kJL_TXT("非运动");
            break;
    }
}

@end
