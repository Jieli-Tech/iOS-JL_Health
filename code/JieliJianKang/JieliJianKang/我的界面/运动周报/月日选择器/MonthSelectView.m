//
//  DateLabelView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/23.
//

#import "MonthSelectView.h"
#import "JL_RunSDK.h"


@interface MonthSelectView(){
    UIButton *leftBtn;
    UIButton *rightBtn;
    UILabel *titleLab;
    UILabel *detailLab;
    TYAttributedLabel *showLab;
}

@end

@implementation MonthSelectView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [leftBtn setImage:[UIImage imageNamed:@"icon_left_02_nol"] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(leftBtnAction) forControlEvents:UIControlEventTouchUpInside];
        //[self addSubview:leftBtn];
        
        rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-40, 0, 40, 40)];
        [rightBtn setImage:[UIImage imageNamed:@"icon_right_02_dis"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(rightBtnAction) forControlEvents:UIControlEventTouchUpInside];
        //[self addSubview:rightBtn];
        
        titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = [UIFont fontWithName:@"PingFangSC" size:15];
        titleLab.textColor = kDF_RGBA(36, 36, 36, 1.0);
        [self addSubview:titleLab];
        
        detailLab = [[UILabel alloc] initWithFrame:CGRectMake(40, 30, self.frame.size.width-80, 20)];
        detailLab.font = [UIFont systemFontOfSize:13];
        detailLab.textColor = [UIColor whiteColor];
        detailLab.textAlignment = NSTextAlignmentCenter;
        //[self addSubview:detailLab];
        
        showLab = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(20, 55, self.frame.size.width-40, 45)];
        showLab.backgroundColor = [UIColor clearColor];
        //[self addSubview:showLab];
        
    }
    return self;
}


-(void)setTitleLab:(NSString *)title SecondLabel:(NSString *)text{
    titleLab.text = title;
    detailLab.text = text;
}

-(void)leftBtnAction{
    if ([_delegate respondsToSelector:@selector(monthLabelViewPreviousBtnAction)]) {
        [_delegate monthLabelViewPreviousBtnAction];
    }
}

-(void)rightBtnAction{
    if ([_delegate respondsToSelector:@selector(monthLabelViewNextBtnAction)]) {
        [_delegate monthLabelViewNextBtnAction];
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
