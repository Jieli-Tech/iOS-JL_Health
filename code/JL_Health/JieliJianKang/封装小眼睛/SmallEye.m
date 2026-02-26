//
//  SmallEye.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/2.
//

#import "SmallEye.h"
@implementation SmallEye
-(instancetype)initWithFrame:(CGRect)frame{
    if ([super initWithFrame: frame]) {
        [self setImage:[UIImage imageNamed:@"login_icon_close_nol"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"login_icon_open_nol"] forState:UIControlStateSelected];
        [self addTarget:self action:@selector(selectedChanged) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}
-(void)selectedChanged{
    self.selected = !self.selected;
    _actionBlock(self.selected);
}
@end
