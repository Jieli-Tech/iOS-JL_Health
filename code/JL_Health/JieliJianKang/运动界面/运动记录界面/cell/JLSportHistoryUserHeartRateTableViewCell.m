//
//  JLSportHistoryUserHeartRateTableViewCell.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/17.
//

#import "JLSportHistoryUserHeartRateTableViewCell.h"
#import <CoreDraw/CoreDraw.h>
#import "NSString+Time.h"
#import "JLSportStrengthView.h"

@interface JLSportHistoryUserHeartRateTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgHeartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgHeartRateUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxHeartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxHeartRateUnitLabel;
@property (weak, nonatomic) IBOutlet UIView *lineViewContainer;

@end

@implementation JLSportHistoryUserHeartRateTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setChart:(JL_SportRecord_Chart *)chart {
    _chart = chart;
    self.containerView.layer.cornerRadius = 12;
    self.lineViewContainer.layer.cornerRadius = 12;
    
    self.titleLabel.text = kJL_TXT("平均心率（次/分钟）");
    self.avgHeartRateUnitLabel.text = kJL_TXT("平均心率");
    self.maxHeartRateUnitLabel.text = kJL_TXT("最大心率");
    
    // 设置横坐标
    NSInteger durationUnit = chart.duration / 5;
    NSMutableArray *timeLabArray = [NSMutableArray array];
    for (int i = 0; i <= 5; i++) {
        NSString *txt = @"00:00:00";
        if (i > 0) {
            NSInteger duration = durationUnit * i;
            txt = [NSString stringWithFormat:@"%@", [NSString timeFormatted:duration]];
        }
        [timeLabArray addObject:txt];
    }
    
    // 设置折线图数据
    /// 运动记录标记包类型
//    typedef NS_ENUM(UInt8, JL_SRMDataType) {
//        ///开始包
//        JL_SRM_Start = 0x00,
//        ///基础包
//        JL_SRM_Basic = 0x01,
//        ///暂停包
//        JL_SRM_Pause = 0x02,
//        ///每公里配速包
//        JL_SRM_Pace = 0x03,
//        ///结束包
//        JL_SRM_End = 0xff,
//    };
    // 数据采样间隔，如24*60，代表一天时间内的每分钟就一条数据采样
    NSMutableArray *tmp = [NSMutableArray new];
    NSInteger maxHeartRate = 0;
    NSInteger avgHeartRate = 0;
    NSInteger heartRateCount = 0;
    for (int i = 0; i < chart.dataArray.count; i++) {
        JL_SRM_DataFormat *data = chart.dataArray[i];
        if (data.heartRate > maxHeartRate) {
            maxHeartRate = data.heartRate;
        }
        if (data.heartRate > 0) {
            avgHeartRate += data.heartRate;
            heartRateCount++;
        }
        if (data.type != JL_SRM_Basic) {
            continue;
        }
        NSValue *v = [NSValue valueWithCGPoint:CGPointMake(i, data.heartRate)];
        [tmp addObject:v];
    }
    if (heartRateCount > 0) {
        avgHeartRate = avgHeartRate / heartRateCount;
    } else {
        avgHeartRate = 0;
    }
    self.maxHeartRateLabel.text = [NSString stringWithFormat:@"%ld", (long)maxHeartRate];
    self.avgHeartRateLabel.text = [NSString stringWithFormat:@"%ld", (long)avgHeartRate];
    
    ECBrokenLine *lineView = [[ECBrokenLine alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 20, 196)];
    lineView.userInteractionEnabled = NO;
    [self.lineViewContainer addSubview:lineView];
    lineView.textColor = [JLColor colorWithString:@"#A0A0A0"];
    lineView.lineColor = [JLColor colorWithString:@"#E27575"];
    lineView.dashlineColor = [JLColor colorWithString:@"#E27575"];
    lineView.lineShadowStartColor = [JLColor colorWithString:@"#E27575" alpha:0.75];
    lineView.lineShadowEndColor = [JLColor colorWithString:@"#FFFFFF" alpha:0.01];
    lineView.startBgColor = [JLColor colorWithString:@"#FFFFFF"];
    lineView.endBgColor = [JLColor colorWithString:@"#FFFFFF"];
    lineView.maxValue = maxHeartRate + 20;
    lineView.minValue = 0;
    lineView.dtNumber = chart.dataArray.count;
    lineView.timeLabArray = timeLabArray;
    [lineView setDataArray:tmp withIsLineTextShowLeft:YES];
    [lineView setNeedsDisplay];
    
    CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width - 20;
    for (int i = 0; i < chart.exerciseIntensArray.count; i++) {
        JLWatchExerciseIntens *watchExerciseIntens = chart.exerciseIntensArray[i];
        
        JLSportStrengthView *view = [[NSBundle mainBundle] loadNibNamed:@"JLSportStrengthView" owner:nil options:nil].firstObject;
        [view setWatchHeartRateType:chart.heartRateType withWatchExerciseIntensityType:watchExerciseIntens.type withTimeInterval:watchExerciseIntens.duration withTotalTimeInterval:chart.duration withViewWidth:viewWidth];
        view.frame = CGRectMake(0, 330 + i * 46, viewWidth, 46);
        [self.containerView addSubview:view];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
