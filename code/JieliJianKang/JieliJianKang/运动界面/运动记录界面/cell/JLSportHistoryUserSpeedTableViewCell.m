//
//  JLSportHistoryUserSpeedTableViewCell.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/13.
//

#import "JLSportHistoryUserSpeedTableViewCell.h"
#import "JLSpeedFrequencyItemView.h"
#import "NSString+Time.h"

@interface JLSportHistoryUserSpeedTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgSpeedUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *fastestSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *fastestSpeedUnitLabel;

@end

@implementation JLSportHistoryUserSpeedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSpeedPerKMArray:(NSMutableArray<JL_SRM_DataFormat *> *)speedPerKMArray {
    _speedPerKMArray = speedPerKMArray;
    self.containerView.layer.cornerRadius = 12;
    
    self.titleLabel.text = kJL_TXT("每公里配速");
    self.avgSpeedUnitLabel.text = kJL_TXT("平均配速（/公里）");
    self.fastestSpeedUnitLabel.text = kJL_TXT("最快配速（/公里）");
    
    self.avgSpeedLabel.text = [NSString paceFormatted:0];
    self.fastestSpeedLabel.text = [NSString paceFormatted:0];
    
    if (speedPerKMArray.count > 0) {
        NSInteger maxPace = 0;
        NSInteger avgPace = 0;
        for (int i = 0; i < speedPerKMArray.count; i++) {
            JL_SRM_DataFormat *dataFormat = speedPerKMArray[i];
            if (dataFormat.pace > maxPace) {
                maxPace = dataFormat.pace;
            }
            avgPace += dataFormat.pace;
        }
        if (speedPerKMArray.count > 0) {
            avgPace = avgPace / speedPerKMArray.count;
        }
        self.avgSpeedLabel.text = [NSString paceFormatted:avgPace];
        self.fastestSpeedLabel.text = [NSString paceFormatted:maxPace];
        // 添加配速表
        for (int i = 0; i < speedPerKMArray.count; i++) {
            JLSpeedFrequencyItemView *view = [[NSBundle mainBundle] loadNibNamed:@"JLSpeedFrequencyItemView" owner:nil options:nil].firstObject;
            JL_SRM_DataFormat *dataFormat = speedPerKMArray[i];
            [view setNumber:i+1 withSpeed:dataFormat.pace withMaxSpeed:maxPace + 30];
            view.frame = CGRectMake(20, 135 + i * 30, [UIScreen mainScreen].bounds.size.width - 72, 18);
            [self.containerView addSubview:view];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
