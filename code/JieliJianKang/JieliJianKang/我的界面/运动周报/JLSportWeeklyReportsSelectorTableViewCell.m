//
//  JLSportWeeklyReportsSelectorTableViewCell.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/15.
//

#import "JLSportWeeklyReportsSelectorTableViewCell.h"

@interface JLSportWeeklyReportsSelectorTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *achieveGoalDaysLabel;
@property (weak, nonatomic) IBOutlet UIImageView *upImageView;
@property (weak, nonatomic) IBOutlet UILabel *compareLastWeekAchieveUpDaysLabel;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation JLSportWeeklyReportsSelectorTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - 控件方法

- (IBAction)lastWeekBtnFunc:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onClickLastWeekBtnFunc)]) {
        [self.delegate onClickLastWeekBtnFunc];
    }
}

- (IBAction)nextWeekBtnFunc:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onClickNextWeekBtnFunc)]) {
        [self.delegate onClickNextWeekBtnFunc];
    }
}

#pragma mark - 设置方法

- (void)setNextBtnEnable:(BOOL)nextBtnEnable {
    _nextButton.enabled = nextBtnEnable;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setAchieveGoalDays:(NSInteger)achieveGoalDays {
    _achieveGoalDaysLabel.text = [NSString stringWithFormat:@"%@ %ld %@", kJL_TXT("达成目标"), achieveGoalDays, kJL_TXT("天")];
}

- (void)setCompareLastWeekAchieveUpDays:(NSInteger)compareLastWeekAchieveUpDays {
    if (compareLastWeekAchieveUpDays > 0) {
        _compareLastWeekAchieveUpDaysLabel.text = [NSString stringWithFormat:@"%ld%@", compareLastWeekAchieveUpDays, kJL_TXT("天")];
        _upImageView.image = [UIImage imageNamed:@"icon_up_nol"];
        [_upImageView setHidden:NO];
        [_compareLastWeekAchieveUpDaysLabel setHidden:NO];
    } else if (compareLastWeekAchieveUpDays < 0) {
        _compareLastWeekAchieveUpDaysLabel.text = [NSString stringWithFormat:@"%ld%@", labs(compareLastWeekAchieveUpDays), kJL_TXT("天")];
        _upImageView.image = [UIImage imageNamed:@"icon_down_nol"];
        [_upImageView setHidden:NO];
        [_compareLastWeekAchieveUpDaysLabel setHidden:NO];
    } else {
        [_upImageView setHidden:YES];
        [_compareLastWeekAchieveUpDaysLabel setHidden:YES];
    }
}

@end
