//
//  ValidationMobileView.m
//  JieliJianKang
//
//  Created by 李放 on 2021/4/8.
//

#import "ValidationMobileView.h"
#import "JL_RunSDK.h"
#import "User_Http.h"

@interface ValidationMobileView()<UITextFieldDelegate>{
    float   sw;
    float   sh;
    
    UIView  *bgView;
    UIView  *contentView;
    
    UITextField *verTF;       //验证码
    UIView  *fenGeView;      //验证码分割线
    DFLabel *verLabel;        //发送验证码
    DFLabel *verLabel2;       //重新获取(60s)
    UILabel *label3;
    
    NSString *mMobile;
    
    JLUSER_WAY userWay;
}

@end

@implementation ValidationMobileView

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
    
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, sw, sh)];
    //样式
    toolbar.barStyle = UIBarStyleBlackTranslucent;//半透明
    UITapGestureRecognizer *ttohLefttapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelBtnAction:)];
    [toolbar addGestureRecognizer:ttohLefttapGestureRecognizer];
    toolbar.userInteractionEnabled=YES;
    //透明度
    toolbar.alpha = 0.45f;
    [self addSubview:toolbar];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(16,sh/2-262/2, sw-32, 262)];
    [self addSubview:contentView];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 16;
    
    UILabel *label1 = [[UILabel alloc] init]; //身份验证
    label1.frame = CGRectMake(contentView.frame.size.width/2-72/2,33,72,25);
    label1.numberOfLines = 0;
    [contentView addSubview:label1];
    label1.font =  [UIFont fontWithName:@"Helvetica-Bold" size: 18];
    label1.text =  kJL_TXT("身份验证");
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UILabel *label2 = [[UILabel alloc] init]; //为确认是您本人操作，请进行身份验证
    if(sw == 320){
        label2.frame = CGRectMake(36,label1.frame.origin.y+label1.frame.size.height+20,contentView.frame.size.width-72,42);
        label2.numberOfLines = 2;
    }else{
        label2.frame = CGRectMake(contentView.frame.size.width/2-270/2,label1.frame.origin.y+label1.frame.size.height+20,270,21);
        label2.numberOfLines = 1;
    }
    [contentView addSubview:label2];
    label2.contentMode =  UIViewContentModeCenter;
    label2.font =  [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    label2.text =  kJL_TXT("为确认是您本人操作，请进行身份验证");
    label2.textColor = kDF_RGBA(75, 75, 75, 1.0);
    label2.adjustsFontSizeToFitWidth = YES;
    label2.minimumScaleFactor =0.7;
    
    label3 = [[UILabel alloc] init];
    label3.frame = CGRectMake(contentView.frame.size.width/2-100/2,label2.frame.origin.y+label2.frame.size.height+8,120,21);
    label3.numberOfLines = 1;
    [contentView addSubview:label3];
    label3.contentMode =  UIViewContentModeCenter;
    label3.font =  [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    label3.textColor = kDF_RGBA(75, 75, 75, 1.0);

    verTF = [[UITextField alloc] initWithFrame:CGRectMake(24, label3.frame.origin.y+label3.frame.size.height+25, contentView.frame.size.width-130-48, 21)];
    verTF.textAlignment = NSTextAlignmentLeft;
    verTF.placeholder = kJL_TXT("短信验证码");
    verTF.textColor = kDF_RGBA(36, 36, 36, 1.0);
    verTF.tintColor = kDF_RGBA(145, 145, 145, 1.0);
    verTF.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    verTF.keyboardAppearance = UIKeyboardAppearanceDefault;
    verTF.keyboardType = UIKeyboardTypePhonePad;
    verTF.delegate = self;
    verTF.tag =0;
    [contentView addSubview:verTF];
    verTF.clearButtonMode=UITextFieldViewModeWhileEditing;

    verLabel = [[DFLabel alloc] init];
    verLabel.frame = CGRectMake(contentView.frame.size.width-20-90, label3.frame.origin.y+label3.frame.size.height+23, 90, 20);
    verLabel.numberOfLines = 0;
    verLabel.text = kJL_TXT("发送验证码");
    verLabel.labelType = DFLeftRight;
    verLabel.textAlignment = NSTextAlignmentLeft;
    verLabel.font =  [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    verLabel.textColor = kDF_RGBA(128, 91, 235, 1.0);
    verLabel.tag = 0;
    [contentView addSubview:verLabel];
    verLabel.hidden = NO;
    
    UIView *mFengeView = [[UIView alloc] initWithFrame:CGRectMake(26, verLabel.frame.origin.y+20+4, contentView.frame.size.width-52, 1)];
    [contentView addSubview:mFengeView];
    mFengeView.backgroundColor = kDF_RGBA(247.0, 247.0, 247.0, 1.0);

    UITapGestureRecognizer *verGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendVerClick)];
    [verLabel addGestureRecognizer:verGestureRecognizer];
    verLabel.userInteractionEnabled=YES;

    verLabel2 = [[DFLabel alloc] init];
    verLabel2.frame = CGRectMake(contentView.frame.size.width-20-120, label3.frame.origin.y+label3.frame.size.height+23, 125, 20);
    verLabel2.numberOfLines = 0;
    verLabel2.labelType = DFLeftRight;
    verLabel2.textAlignment = NSTextAlignmentLeft;
    verLabel2.font =  [UIFont fontWithName:@"PingFangSC" size:14];
    verLabel2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    [contentView addSubview:verLabel2];
    verLabel2.hidden = YES;

    fenGeView = [[UIView alloc] initWithFrame:CGRectMake(verLabel2.frame.origin.x-8, label3.frame.origin.y+label3.frame.size.height+28, 1, 12)];
    [contentView addSubview:fenGeView];
    fenGeView.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);

    UIView *fengeView = [[UIView alloc] initWithFrame:CGRectMake(0, 212, contentView.frame.size.width, 1)];
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
    [sureBtn addTarget:self action:@selector(sureBtn:) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitle:kJL_TXT("确定") forState:UIControlStateNormal];
    [sureBtn setTitleColor:kDF_RGBA(84,140, 255, 1.0) forState:UIControlStateNormal];
    [contentView addSubview:sureBtn];
}

-(void)setMobile:(NSString *)mobile{
    
    userWay = [[JL_Tools getUserByKey:kUI_HTTP_USER_WAY] intValue];
    
    if(userWay == JLUSER_WAY_PHONE){
        mMobile = mobile;
        
        NSString *mobileString = [mobile stringByReplacingCharactersInRange:NSMakeRange(3,6) withString:@"******"];
        label3.text =  mobileString;
    }
    if(userWay == JLUSER_WAY_EMAIL){
        mMobile = mobile;
        label3.text =  mMobile;
    }
}

#pragma mark 发送验证码点击事件
-(void)sendVerClick{
    
    NSString *stringPhone = nil;
    NSString *stringEmail = nil;
    
    if (userWay == JLUSER_WAY_PHONE) {
        stringPhone = mMobile;
        stringEmail = nil;
    } else {
        stringPhone = nil;
        stringEmail = mMobile;
    }
    
    [[User_Http shareInstance] requestSMSCode:stringPhone
                                      OrEmail:stringEmail
                                       Result:^(NSDictionary * _Nonnull info)
     {
        [JL_Tools mainTask:^{
            int code = [info[@"code"] intValue];
            NSString *errorStr = info[@"msg"];
            if(code!=0){
                [DFUITools showText:errorStr onView:self delay:1.5];
                return;
            }
            
            self->fenGeView.hidden = NO;
            self->verLabel2.hidden = NO;
            self->verLabel.hidden = YES;
            
            [self openCountdown];
        }];
    }];
}

- (void)cancelBtnAction:(UIButton *)sender {
    self.hidden = YES;
    [self endEditing:YES];
}

// 开启倒计时效果
-(void)openCountdown{
    
    __block NSInteger time = 119; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time <= 0){ //倒计时结束，关闭
            
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                self->fenGeView.hidden = YES;
                self->verLabel2.hidden = YES;
                self->verLabel.hidden = NO;
                
                self->verLabel2.userInteractionEnabled = YES;
            });
            
        }else{
            int seconds = time % 120;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(seconds<10){
                    self->verLabel2.text = [NSString stringWithFormat:@"%@%@%.1d%@%@",kJL_TXT("重新获取"),@"(",seconds,@"s",@")"];
                }else{
                    self->verLabel2.text = [NSString stringWithFormat:@"%@%@%.2d%@%@",kJL_TXT("重新获取"),@"(",seconds,@"s",@")"];
                }
                self->verLabel2.userInteractionEnabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
   
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    switch (textField.tag) {
        case 0:
        {
            [verTF becomeFirstResponder];
        }
            break;
        default:
            break;
    }
    [textField endEditing:YES];
    return YES;
}

-(void)cancelBtn:(UIButton *)btn{
    self.hidden = YES;
    
    if([_delegate respondsToSelector:@selector(onValidationMobileCancel)]){
        [_delegate onValidationMobileCancel];
    }
}

-(void)sureBtn:(UIButton *)btn{
    
    if(verTF.text.length ==0){
        [DFUITools showText:kJL_TXT("请输入验证码") onView:self delay:1.5];
        return;
    }
    
    NSString *stringPhone = nil;
    NSString *stringEmail = nil;
    
    if (userWay == JLUSER_WAY_PHONE) {
        stringPhone = mMobile;
        stringEmail = nil;
    } else {
        stringPhone = nil;
        stringEmail = mMobile;
    }
    
    [[User_Http shareInstance] checkSMSCode:stringPhone OrEmail:stringEmail Code:verTF.text Result:^(NSDictionary * _Nonnull info) {
        [JL_Tools mainTask:^{
            int code = [info[@"code"] intValue];
            NSString *errorStr = info[@"msg"];
            if(code!=0){
                [DFUITools showText:errorStr onView:self delay:1.5];
                return;
            }
            
            self.hidden = YES;

            if([self->_delegate respondsToSelector:@selector(onValidationMobileSure)]){
                [self->_delegate onValidationMobileSure];
            }
        }];
    }];
}

@end
