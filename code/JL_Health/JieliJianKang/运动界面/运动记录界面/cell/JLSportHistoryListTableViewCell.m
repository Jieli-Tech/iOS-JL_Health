//
//  JLSportHistoryListTableViewCell.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/13.
//

#import "JLSportHistoryListTableViewCell.h"

@interface JLSportHistoryListTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *sportCateLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceUnitLabel;

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *calorieLabel;

@end

@implementation JLSportHistoryListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.sportCateLabel.layer.cornerRadius = self.speedLabel.width / 2;
    self.sportCateLabel.layer.borderColor = [JLColor colorWithString:@"#805BEB"].CGColor;
    self.sportCateLabel.layer.borderWidth = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
