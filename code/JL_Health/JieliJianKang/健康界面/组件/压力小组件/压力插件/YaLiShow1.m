//
//  YaLiShow1.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/29.
//

#import "YaLiShow1.h"
#import "YaliCircleView.h"

@interface YaLiShow1(){
    __weak IBOutlet UIView *point_0;
    __weak IBOutlet UIView *point_1;
    __weak IBOutlet UIView *point_2;
    __weak IBOutlet UIView *point_3;
    
    __weak IBOutlet UILabel *yali_lb_0;
    __weak IBOutlet UILabel *yali_lb_1;
    __weak IBOutlet UILabel *yali_lb_2;
    __weak IBOutlet UILabel *yali_lb_3;
    
    YaliCircleView *yaliCircleView;
}

@end


@implementation YaLiShow1

- (instancetype)initByFrame:(CGRect)frame
{
    self = [DFUITools loadNib:@"YaLiShow1"];
    if (self) {
        self.frame = frame;
        self.layer.cornerRadius = 12.0;
        point_0.layer.cornerRadius = 2.5;
        point_1.layer.cornerRadius = 2.5;
        point_2.layer.cornerRadius = 2.5;
        point_3.layer.cornerRadius = 2.5;
        
        CGRect rect_1 = CGRectMake(20.0, 20.0, 120.0, 120.0);
        yaliCircleView = [[YaliCircleView alloc] initByFrame:rect_1];
        yaliCircleView.backgroundColor = [UIColor whiteColor];
        [self addSubview:yaliCircleView];
    }
    return self;
}

-(void)updateUI{
    yali_lb_0.text = [NSString stringWithFormat:@"%.1f",_subValue_0*100.f];
    yali_lb_1.text = [NSString stringWithFormat:@"%.1f",_subValue_1*100.f];
    yali_lb_2.text = [NSString stringWithFormat:@"%.1f",_subValue_2*100.f];
    yali_lb_3.text = [NSString stringWithFormat:@"%.1f",_subValue_3*100.f];

    yaliCircleView.value_0 = _subValue_0;
    yaliCircleView.value_1 = _subValue_1;
    yaliCircleView.value_2 = _subValue_2;
    yaliCircleView.value_3 = _subValue_3;
    [yaliCircleView updateUI];
}

@end
