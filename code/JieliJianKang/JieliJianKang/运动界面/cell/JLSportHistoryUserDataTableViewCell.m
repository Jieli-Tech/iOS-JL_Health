//
//  JLSportHistoryUserDataTableViewCell.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/13.
//

#import "JLSportHistoryUserDataTableViewCell.h"

@interface JLSportHistoryUserDataTableViewCell ()

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

@end

@implementation JLSportHistoryUserDataTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
