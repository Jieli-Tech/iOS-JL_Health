//
//  WatchDialTitleView.m
//  JieliJianKang
//
//  Created by EzioChan on 2023/10/20.
//

#import "WatchDialTitleView.h"

@interface WatchDialTitleView(){
    NSMutableArray *titleBtnViews;
    NSMutableArray *titleViews;
}
@end

@implementation WatchDialTitleView




- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        titleViews = [NSMutableArray array];
        titleBtnViews = [NSMutableArray array];
        [self initUI];
    }
    return self;
}

-(void)initUI{
    NSArray *targetArray = @[kJL_TXT("表盘商城"),kJL_TXT("我的表盘"),kJL_TXT("自定义")];
    CGFloat w = self.frame.size.width/3;
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(w*i, 0, w, 30)];
        btn.tag = i;
        [btn setTitle:targetArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:[JLColor colorWithString:@"#000000" alpha:0.9] forState:UIControlStateNormal];
        btn.titleLabel.font = FontMedium(15);
        [btn addTarget:self action:@selector(btn_click:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        UIView *bottomView = [[UIView alloc] init];
        [bottomView setBackgroundColor:[JLColor colorWithString:@"#805BEB"]];
        bottomView.layer.cornerRadius = 1;
        bottomView.layer.masksToBounds = YES;
        [self addSubview:bottomView];
        
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(16));
            make.height.equalTo(@(2));
            make.centerX.equalTo(btn);
            make.top.equalTo(btn.mas_bottom).offset(2);
        }];
        
        [titleBtnViews addObject:btn];
        [titleViews addObject:bottomView];
    }
    
    [self handleBtnClick:0];
    
}

- (void)btn_click:(UIButton *)sender {
    [self handleBtnClick:(int)sender.tag];
    self.callback((int)sender.tag);
}

-(void)handleBtnClick:(int)index{
    for (int i = 0; i < 3; i++) {
        UIButton *btn = titleBtnViews[i];
        UIView *bottomView = titleViews[i];
        if (index == i) {
            [btn setTitleColor:[JLColor colorWithString:@"#000000" alpha:0.9] forState:UIControlStateNormal];
            bottomView.hidden = NO;
        }else{
            bottomView.hidden = YES;
            [btn setTitleColor:[JLColor colorWithString:@"#919191" alpha:0.6] forState:UIControlStateNormal];
        }
    }
}

@end
