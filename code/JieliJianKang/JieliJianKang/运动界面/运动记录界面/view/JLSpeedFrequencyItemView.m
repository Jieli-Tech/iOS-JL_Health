//
//  JLSpeedFrequencyItemView.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/13.
//

#import "JLSpeedFrequencyItemView.h"
#import "NSString+Time.h"

@interface JLSpeedFrequencyItemView ()

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewWidthLayoutConstraint;

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

- (void)setNumber:(NSInteger)number withSpeed:(NSInteger)speed withMaxSpeed:(NSInteger)maxSpeed {
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)number];
    self.speedLabel.text = [NSString paceFormatted:speed];
    self.progressViewWidthLayoutConstraint.constant = 100 + (float)speed / maxSpeed * (self.width - 100);
    self.progressView.layer.cornerRadius = self.progressView.height / 2;
    [self.progressView.layer masksToBounds];
}

@end
