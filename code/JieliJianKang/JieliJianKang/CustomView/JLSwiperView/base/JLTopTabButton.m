//
//  JLTopTabButton.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/2.
//

#import "JLTopTabButton.h"

@interface JLTopTabButton()

@property (nonatomic, strong) UIColor *defaultTitleColor;
@property (nonatomic, strong) UIColor *selectedTitleColor;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation JLTopTabButton

+ (instancetype)topTabButtonWithFrame:(CGRect)frame withTitle:(NSString *)title withDefaulTitleColor:(UIColor *)defaultTitleColor withSelectedTitleColor:(UIColor *)selectedTitleColor {
    JLTopTabButton *topTabButton = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([JLTopTabButton class]) owner:nil options:nil] lastObject];
    
    topTabButton.frame = frame;
    topTabButton.backgroundColor = [UIColor whiteColor];
    topTabButton.defaultTitleColor = defaultTitleColor ? defaultTitleColor : [UIColor blackColor];
    topTabButton.selectedTitleColor = selectedTitleColor ? selectedTitleColor : [UIColor redColor];
    topTabButton.titleLabel.text = title;
    topTabButton.titleLabel.textColor = topTabButton.defaultTitleColor;
    topTabButton.bottomView.backgroundColor = topTabButton.selectedTitleColor;
    topTabButton.bottomView.hidden = YES;
    
    return topTabButton;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        _titleLabel.textColor = _selectedTitleColor;
        _bottomView.hidden = false;
    } else {
        _titleLabel.textColor = _defaultTitleColor;
        _bottomView.hidden = YES;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.touchesBeganBlock) {
        self.touchesBeganBlock();
    }
}

@end
