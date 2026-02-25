//
//  JLSportHistoryUserSpeedTableViewCell.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/13.
//

#import "JLSportHistoryUserSpeedTableViewCell.h"

@interface JLSportHistoryUserSpeedTableViewCell ()

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
