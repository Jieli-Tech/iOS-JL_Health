//
//  JLSpeedFrequencyItemView.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/13.
//

#import "JLSpeedFrequencyItemView.h"

@interface JLSpeedFrequencyItemView ()

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UIView *progressView;

@end

@implementation JLSpeedFrequencyItemView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.layer.cornerRadius = self.height / 2;
        [self.layer masksToBounds];
    }
    return self;
}

- (void)setNumber:(NSInteger)number {
    if (number > 0)
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)number];
}

- (void)setSpeed:(NSString *)speedString {
    if (speedString)
    self.speedLabel.text = speedString;
}

@end
