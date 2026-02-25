//
//  NoNetView.m
//  JieliJianKang
//
//  Created by 李放 on 2021/3/30.
//

#import "NoNetView.h"
#import "JL_RunSDK.h"

@interface NoNetView(){
    UIView *bgView;
    float sw;
    float sh;
}

@end

@implementation NoNetView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kDF_RGBA(0, 0, 0, 0.1);
        [self initUI];
    }
    return self;
}

-(void)initUI{
    sw = [DFUITools screen_2_W];
    sh = [DFUITools screen_2_H];
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(16, sh/2-116/2, sw-32, 116)];
    [self addSubview:bgView];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 16;
    bgView.layer.masksToBounds = YES;
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(bgView.frame.size.width/2-224/2,32,224,22);
    label.numberOfLines = 0;
    [bgView addSubview:label];
    label.contentMode = UIViewContentModeCenter;
    label.font =  [UIFont fontWithName:@"PingFang SC" size: 16];
    label.text =  kJL_TXT("网络未连接，请检查网络设置");
    label.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,bgView.frame.size.height-55,bgView.frame.size.width,55)];
    [sureBtn addTarget:self action:@selector(sureBtn:) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitle:kJL_TXT("确定") forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:16]];
    [sureBtn setTitleColor:kDF_RGBA(85, 140, 255, 1.0) forState:UIControlStateNormal];
    [sureBtn setBackgroundColor:[UIColor whiteColor]];
    sureBtn.layer.cornerRadius = 24;
    [bgView addSubview:sureBtn];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.hidden = YES;
}

-(void)sureBtn:(UIButton *)btn{
    self.hidden = YES;
}

@end
