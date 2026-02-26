//
//  DateLabelView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/23.
//

#import "DateLabelView.h"


@interface DateLabelView(){
    UILabel *titleLab;
    UILabel *detailLab;
    TYAttributedLabel *showLab;
}

@end

@implementation DateLabelView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_leftBtn setImage:[UIImage imageNamed:@"icon_left_nol"] forState:UIControlStateNormal];
        [_leftBtn addTarget:self action:@selector(leftBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_leftBtn];
        
        _rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-40, 0, 40, 40)];
        [_rightBtn setImage:[UIImage imageNamed:@"icon_right_nol"] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(rightBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_rightBtn];
        
        titleLab = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.frame.size.width-80, 40)];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.textColor = [UIColor whiteColor];
        [self addSubview:titleLab];
        
        detailLab = [[UILabel alloc] initWithFrame:CGRectMake(40, 30, self.frame.size.width-80, 20)];
        detailLab.font = [UIFont systemFontOfSize:13];
        detailLab.textColor = [UIColor whiteColor];
        detailLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:detailLab];
        
        showLab = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(20, 55, self.frame.size.width-40, 45)];
        showLab.backgroundColor = [UIColor clearColor];
        [self addSubview:showLab];
        
    }
    return self;
}


-(void)setTitleLab:(NSString *)title SecondLabel:(NSString *)text{
    titleLab.text = title;
    detailLab.text = text;
}

-(void)setSecondLab:(NSString *)text{
    detailLab.text = text;
}

-(void)leftBtnAction{
    if ([_delegate respondsToSelector:@selector(dateLabelViewPreviousBtnAction)]) {
        [_delegate dateLabelViewPreviousBtnAction];
    }
}

-(void)rightBtnAction{
    if ([_delegate respondsToSelector:@selector(dateLabelViewNextBtnAction)]) {
        [_delegate dateLabelViewNextBtnAction];
    }
}

-(void)setTextWithContainer:(TYTextContainer *)container{
    showLab.textContainer = container;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
