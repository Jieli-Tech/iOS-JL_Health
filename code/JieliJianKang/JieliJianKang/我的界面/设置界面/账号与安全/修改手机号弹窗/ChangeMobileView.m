//
//  ChangeMobileView.m
//  JieliJianKang
//
//  Created by 李放 on 2021/4/8.
//

#import "ChangeMobileView.h"
#import "JL_RunSDK.h"

@interface ChangeMobileView(){
    float   sw;
    float   sh;
    
    UIView  *bgView;
    UIView  *contentView;
    
    UILabel *label3;
    
    JLUSER_WAY userWay;
}

@end

@implementation ChangeMobileView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

-(void)initUI{
    sw = [DFUITools screen_2_W];
    sh = [DFUITools screen_2_H];
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self addSubview:bgView];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.2;
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(16,sh/2-180/2, sw-32, 180)];
    [self addSubview:contentView];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 16;
    
    UILabel *label1 = [[UILabel alloc] init]; //更换绑定的手机号
    if([kJL_GET hasPrefix:@"zh"] || [kJL_GET hasPrefix:@"en-GB"]){
        label1.frame = CGRectMake(contentView.frame.size.width/2-200/2,36,200,25);
    }else{
        label1.frame = CGRectMake(0,36,contentView.frame.size.width,25);
    }
    label1.numberOfLines = 0;
    [contentView addSubview:label1];
    label1.font =  [UIFont fontWithName:@"Helvetica-Bold" size: 18];
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    label1.adjustsFontSizeToFitWidth = YES;
    label1.minimumScaleFactor =0.7;
    
    userWay = [[JL_Tools getUserByKey:@"httpUserWay"] intValue];
    if(userWay == JLUSER_WAY_PHONE) label1.text = kJL_TXT("更换绑定的手机号?");
    if(userWay == JLUSER_WAY_EMAIL) label1.text = kJL_TXT("更换绑定的邮箱地址?");
    
    
    
    UILabel *label2 = [[UILabel alloc] init]; //当前绑定的手机号码
    if([kJL_GET hasPrefix:@"zh"]|| [kJL_GET hasPrefix:@"en-GB"]){
        label2.frame = CGRectMake(contentView.frame.size.width/2-175/2,label1.frame.origin.y+label1.frame.size.height+8,175,20);
    }else{
        label2.frame = CGRectMake(0,label1.frame.origin.y+label1.frame.size.height+8,contentView.frame.size.width,20);
    }
    label2.numberOfLines = 1;
    [contentView addSubview:label2];
    label2.contentMode =  UIViewContentModeCenter;
    label2.font =  [UIFont fontWithName:@"PingFangSC" size: 14];
    label2.textColor = kDF_RGBA(75, 75, 75, 1.0);
    label2.adjustsFontSizeToFitWidth = YES;
    label2.minimumScaleFactor =0.7;
    
    if(userWay == JLUSER_WAY_PHONE) label2.text = kJL_TXT("当前绑定的手机号码为");
    if(userWay == JLUSER_WAY_EMAIL) label2.text = kJL_TXT("当前绑定的邮箱地址为");
    
    
    label3 = [[UILabel alloc] init]; //具体的手机号码
    label3.frame = CGRectMake(label2.frame.origin.x+10,label2.frame.origin.y+label2.frame.size.height+5,180,20);
    label3.numberOfLines = 1;
    [contentView addSubview:label3];
    label3.contentMode =  UIViewContentModeCenter;
    label3.font =  [UIFont fontWithName:@"PingFangSC" size: 14];
    label3.adjustsFontSizeToFitWidth = YES;
    label3.minimumScaleFactor =0.7;
    label3.textColor = kDF_RGBA(75, 75, 75, 1.0);
    
    UIView *fengeView = [[UIView alloc] initWithFrame:CGRectMake(0, 130, contentView.frame.size.width, 1)];
    [contentView addSubview:fengeView];
    fengeView.backgroundColor = kDF_RGBA(247.0, 247.0, 247.0, 1.0);
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,contentView.frame.size.height-50,contentView.frame.size.width/2,50)];
    [cancelBtn addTarget:self action:@selector(cancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:kJL_TXT("取消") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:kDF_RGBA(84,140, 255, 1.0) forState:UIControlStateNormal];
    [contentView addSubview:cancelBtn];
    
    UIView *fengeView2 = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.size.width/2,contentView.frame.size.height-50, 1, 50)];
    [contentView addSubview:fengeView2];
    fengeView2.backgroundColor = kDF_RGBA(247.0, 247.0, 247.0, 1.0);
    
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(fengeView2.frame.origin.x,contentView.frame.size.height-50,contentView.frame.size.width/2,50)];
    [sureBtn addTarget:self action:@selector(changeBtn:) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitle:kJL_TXT("更换") forState:UIControlStateNormal];
    [sureBtn setTitleColor:kDF_RGBA(84,140, 255, 1.0) forState:UIControlStateNormal];
    [contentView addSubview:sureBtn];
}

-(void)setMobile:(NSString *)mobile{
    if(userWay == JLUSER_WAY_PHONE) label3.text = [NSString stringWithFormat:@"%@ %@",@"+86",mobile];
    if(userWay == JLUSER_WAY_EMAIL) label3.text = mobile;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.hidden = YES;
}

-(void)cancelBtn:(UIButton *)btn{
    self.hidden = YES;
    
    if([_delegate respondsToSelector:@selector(onChangeMobileCancel)]){
        [_delegate onChangeMobileCancel];
    }
}

-(void)changeBtn:(UIButton *)btn{
    self.hidden = YES;
    
    if([_delegate respondsToSelector:@selector(onChangeMobileSure)]){
        [_delegate onChangeMobileSure];
    }
}

@end
