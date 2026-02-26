//
//  ChangeMobileView.m
//  JieliJianKang
//
//  Created by 李放 on 2021/11/25.
//

#import "LogoutAccountView.h"
#import "JL_RunSDK.h"

@interface LogoutAccountView(){
    float   sw;
    float   sh;
    
    UIView  *bgView;
    UIView  *contentView;
}

@end

@implementation LogoutAccountView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

-(void)initUI{
    sw = [UIScreen mainScreen].bounds.size.width;
    sh = [UIScreen mainScreen].bounds.size.height;
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self addSubview:bgView];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.2;
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(16,sh/2-180/2, sw-32, 180)];
    [self addSubview:contentView];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 16;
    
    DFLabel *label1 = [[DFLabel alloc] init];
    label1.frame = CGRectMake(contentView.frame.size.width/2-80/2,36,120,25);
    label1.numberOfLines = 0;
    [contentView addSubview:label1];
    label1.font =  [UIFont fontWithName:@"Helvetica-Bold" size: 18];
    label1.text =  kJL_TXT("注销账号");
    label1.labelType = DFLeftRight;
    label1.textAlignment = NSTextAlignmentLeft;
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.frame = CGRectMake(contentView.frame.size.width/2-265/2,label1.frame.origin.y+label1.frame.size.height+18,265,20);
    label2.numberOfLines = 1;
    [contentView addSubview:label2];
    label2.contentMode =  UIViewContentModeCenter;
    label2.font =  [UIFont fontWithName:@"PingFangSC" size: 14];
    label2.text =  kJL_TXT("注销后账号不可恢复，是否继续");
    label2.textColor = kDF_RGBA(75, 75, 75, 1.0);
    label2.adjustsFontSizeToFitWidth = YES;
    label2.minimumScaleFactor =0.7;
    
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
    [sureBtn addTarget:self action:@selector(continuteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitle:kJL_TXT("继续") forState:UIControlStateNormal];
    [sureBtn setTitleColor:kDF_RGBA(228,77, 63, 1.0) forState:UIControlStateNormal];
    [contentView addSubview:sureBtn];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.hidden = YES;
}

-(void)cancelBtn:(UIButton *)btn{
    self.hidden = YES;
    
    if([_delegate respondsToSelector:@selector(onLogoutAccountCancel)]){
        [_delegate onLogoutAccountCancel];
    }
}

-(void)continuteBtn:(UIButton *)btn{
    self.hidden = YES;
    
    if([_delegate respondsToSelector:@selector(onLogoutAccountSure)]){
        [_delegate onLogoutAccountSure];
    }
}

@end
