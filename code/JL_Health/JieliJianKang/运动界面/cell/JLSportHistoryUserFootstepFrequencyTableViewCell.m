//
//  JLSportHistoryUserFootstepFrequencyTableViewCell.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/13.
//

#import "JLSportHistoryUserFootstepFrequencyTableViewCell.h"

@interface JLSportHistoryUserFootstepFrequencyTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgFootstepFrequencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgFootstepFrequencyUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *biggestFootstepFrequencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *biggestFootstepFrequencyUnitLabel;

@end

@implementation JLSportHistoryUserFootstepFrequencyTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
