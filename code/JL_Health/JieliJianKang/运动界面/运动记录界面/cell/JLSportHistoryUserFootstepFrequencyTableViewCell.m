//
//  JLSportHistoryUserFootstepFrequencyTableViewCell.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/13.
//

#import "JLSportHistoryUserFootstepFrequencyTableViewCell.h"
#import <CoreDraw/CoreDraw.h>
#import "NSString+Time.h"

@interface JLSportHistoryUserFootstepFrequencyTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgFootstepFrequencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgFootstepFrequencyUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxFootstepFrequencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxFootstepFrequencyUnitLabel;
@property (weak, nonatomic) IBOutlet UIView *lineViewContainer;

@end

@implementation JLSportHistoryUserFootstepFrequencyTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.titleLabel.text = kJL_TXT("步频（步/分钟）");
    self.avgFootstepFrequencyUnitLabel.text = kJL_TXT("平均步频");
    self.maxFootstepFrequencyUnitLabel.text = kJL_TXT("最大步频");
}

- (void)setChart:(JL_SportRecord_Chart *)chart {
    _chart = chart;
    self.containerView.layer.cornerRadius = 12;
    self.lineViewContainer.layer.cornerRadius = 12;
    
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
//        ///结束包
//        JL_SRM_End = 0xff,
//    };
    // 数据采样间隔，如24*60，代表一天时间内的每分钟就一条数据采样
    NSMutableArray *tmp = [NSMutableArray new];
    NSInteger maxFootstepFrequency = 0;
    NSInteger avgFootstepFrequency = 0;
    for (int i = 0; i < chart.dataArray.count; i++) {
        JL_SRM_DataFormat *data = chart.dataArray[i];
        if (data.stride > maxFootstepFrequency) {
            maxFootstepFrequency = data.stride;
        }
        avgFootstepFrequency += data.stride;
        if (data.type != JL_SRM_Basic) {
            continue;
        }
        NSValue *v = [NSValue valueWithCGPoint:CGPointMake(i, data.stride)];
        [tmp addObject:v];
    }
    avgFootstepFrequency = avgFootstepFrequency / chart.dataArray.count;
    self.maxFootstepFrequencyLabel.text = [NSString stringWithFormat:@"%ld", (long)maxFootstepFrequency];
    self.avgFootstepFrequencyLabel.text = [NSString stringWithFormat:@"%ld", (long)avgFootstepFrequency];
    
    ECBrokenLine *lineView = [[ECBrokenLine alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 20, 196)];
    lineView.userInteractionEnabled = NO;
    [self.lineViewContainer addSubview:lineView];
    lineView.textColor = [JLColor colorWithString:@"#A0A0A0"];
    lineView.lineColor = [JLColor colorWithString:@"#51CD96"];
    lineView.dashlineColor = [JLColor colorWithString:@"#51CD96"];
    lineView.lineShadowStartColor = [JLColor colorWithString:@"#51CD96"];//[UIColor colorWithRed:128/255.0 green:91/255.0 blue:235/255.0 alpha:0.75];
    lineView.lineShadowEndColor = [JLColor colorWithString:@"#FFFFFF" alpha:0.01];
    lineView.startBgColor = [JLColor colorWithString:@"#FFFFFF"];
    lineView.endBgColor = [JLColor colorWithString:@"#FFFFFF"];
    lineView.maxValue = maxFootstepFrequency + 20;
    lineView.minValue = 0;
    lineView.dtNumber = chart.dataArray.count;
    lineView.timeLabArray = timeLabArray;
    [lineView setDataArray:tmp withIsLineTextShowLeft:YES];
    
    [lineView setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
