//
//  VerificationCodeLoginVC.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/3.
//

#import "VerificationCodeLoginVC.h"
#import "JL_RunSDK.h"
#import "LoginVC.h"
#import "User_Http.h"

@interface VerificationCodeLoginVC ()<UITextFieldDelegate>{
    UILabel *label1;          //验证码登录
    UILabel *label2;          //+86
    UILabel *label3;          //使用账号密码登录
    UIView  *fenGeView;       //手机号码分割线
    UIView  *fenGeView2;      //验证码分割线
    UITextField *phoneTF;     //手机号码
    UITextField *verTF;       //验证码
    DFLabel *verLabel;        //发送验证码
    DFLabel *verLabel2;       //重新获取(60s)
    
    UIButton    *loginBtn;    //登录按钮
    
    JLUSER_WAY  userWay;
}

@end

@implementation VerificationCodeLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    
    float sw = [DFUITools screen_2_W];
    
    label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(24,kJL_HeightNavBar+10,sw-24,33);
    label1.numberOfLines = 0;
    label1.text = kJL_TXT("验证码登录");
    label1.font =  [UIFont fontWithName:@"Helvetica-Bold" size:24];
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [self.view addSubview:label1];
    
    label2 = [[UILabel alloc] init];
    label2.frame = CGRectMake(24, label1.frame.origin.y+label1.frame.size.height+55, 35, 20);
    label2.numberOfLines = 0;
    label2.text = kJL_TXT("+86");
    label2.font =  [UIFont fontWithName:@"PingFangSC" size:14];
    label2.textColor = kDF_RGBA(36, 36, 36, 1.0);
    label2.hidden = YES;
    [self.view addSubview:label2];
    
    fenGeView = [[UIView alloc] initWithFrame:CGRectMake(label2.frame.origin.x+label2.frame.size
                                                           .width+8, label1.frame.origin.y+label1.frame.size.height+58, 1, 12)];
    [self.view addSubview:fenGeView];
    fenGeView.hidden = YES;

    fenGeView.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(24, label2.frame.origin.y+label2.frame.size.height+8, sw-48, 1)];
    [self.view addSubview:view1];
    view1.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
//    phoneTF = [[UITextField alloc] initWithFrame:CGRectMake(label2.frame.origin.x+label2.frame.size.width+22, label1.frame.origin.y+label1.frame.size.height+47, sw-60-48, 35)];
    phoneTF = [[UITextField alloc] initWithFrame:CGRectMake(24, label1.frame.origin.y+label1.frame.size.height+47, sw, 35)];
    phoneTF.textAlignment = NSTextAlignmentLeft;
    phoneTF.placeholder = kJL_TXT("请输入手机号码/邮箱");
    phoneTF.textColor = kDF_RGBA(36, 36, 36, 1.0);
    phoneTF.tintColor = kDF_RGBA(180, 180, 180, 1.0);
    phoneTF.font = [UIFont fontWithName:@"PingFangSC" size:14];
    phoneTF.keyboardAppearance=UIKeyboardAppearanceDefault;
    phoneTF.keyboardType=UIKeyboardTypeEmailAddress;
    phoneTF.delegate = self;
    phoneTF.tag =0;
    [self.view addSubview:phoneTF];
    phoneTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    
    verTF = [[UITextField alloc] initWithFrame:CGRectMake(24, view1.frame.origin.y+view1
                                                          .frame.size.height+32, sw, 35)];
    verTF.textAlignment = NSTextAlignmentLeft;
    verTF.placeholder = kJL_TXT("输入验证码");
    verTF.textColor = kDF_RGBA(36, 36, 36, 1.0);
    verTF.tintColor = kDF_RGBA(180, 180, 180, 1.0);
    verTF.font = [UIFont fontWithName:@"PingFangSC" size:14];
    verTF.keyboardAppearance = UIKeyboardAppearanceDefault;
    verTF.keyboardType = UIKeyboardTypePhonePad;
    verTF.delegate = self;
    verTF.tag =1;
    [self.view addSubview:verTF];
    verTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    
    verLabel = [[DFLabel alloc] init];
    verLabel.frame = CGRectMake(sw-20-90, phoneTF.frame.origin.y+phoneTF.frame.size.height+38, 90, 20);
    verLabel.numberOfLines = 0;
    verLabel.text = kJL_TXT("发送验证码");
    verLabel.labelType = DFLeftRight;
    verLabel.textAlignment = NSTextAlignmentLeft;
    verLabel.font =  [UIFont fontWithName:@"PingFangSC" size:14];
    verLabel.textColor = kDF_RGBA(128, 91, 235, 1.0);
    verLabel.tag = 0;
    [self.view addSubview:verLabel];
    verLabel.hidden = NO;
    
    UITapGestureRecognizer *verGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendVerClick)];
    [verLabel addGestureRecognizer:verGestureRecognizer];
    verLabel.userInteractionEnabled=YES;
    
    verLabel2 = [[DFLabel alloc] init];
    verLabel2.frame = CGRectMake(sw-20-120, phoneTF.frame.origin.y+phoneTF.frame.size.height+38, 125, 20);
    verLabel2.numberOfLines = 0;
    verLabel2.labelType = DFLeftRight;
    verLabel2.textAlignment = NSTextAlignmentLeft;
    verLabel2.font =  [UIFont fontWithName:@"PingFangSC" size:14];
    verLabel2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    [self.view addSubview:verLabel2];
    verLabel2.hidden = YES;
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 34, sw-48, 1)];
    [verTF addSubview:view2];
    view2.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    fenGeView2 = [[UIView alloc] initWithFrame:CGRectMake(verLabel2.frame.origin.x-8, view1.frame.origin.y+view1.frame.size.height+42, 1, 12)];
    [self.view addSubview:fenGeView2];
    fenGeView2.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
    fenGeView2.hidden = YES;
    
    label3 = [[UILabel alloc] init];
    label3.frame = CGRectMake(24,verTF.frame.origin.y+verTF.frame.size.height+15,sw-24,20);
    label3.numberOfLines = 0;
    label3.text = kJL_TXT("使用账号密码登录");
    label3.font =  [UIFont fontWithName:@"PingFangSC" size:12];
    label3.textColor = kDF_RGBA(143, 143, 143, 1.0);
    [self.view addSubview:label3];
    
    UITapGestureRecognizer *label3GestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(accountLogin)];
    [label3 addGestureRecognizer:label3GestureRecognizer];
    label3.userInteractionEnabled=YES;
    
    loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(24,verLabel.frame.origin.y+verLabel.frame.size.height+111,sw-48,48)];
    [loginBtn addTarget:self action:@selector(loginBtn:) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn setTitle:kJL_TXT("登录") forState:UIControlStateNormal];
    [loginBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:15]];
    [loginBtn setTitleColor:kDF_RGBA(179, 179, 179, 1.0) forState:UIControlStateNormal];
    [loginBtn setBackgroundColor:kDF_RGBA(240, 241, 241, 1.0)];
    loginBtn.layer.cornerRadius = 24;
    [self.view addSubview:loginBtn];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [loginBtn setBackgroundColor:kDF_RGBA(128, 91, 235, 1.0)];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    //[JL_Tools setUser:phoneTF.text forKey:@"phoneNum"];
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
            [phoneTF becomeFirstResponder];
        }
            break;
        case 1:
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


-(BOOL)checkTextInput{
    if(phoneTF.text.length == 0){
        [DFUITools showText:kJL_TXT("请输入手机号码/邮箱") onView:self.view delay:1.5];
        return NO;
    }
    
    //邮箱判断流程
    if (![phoneTF.text containsString:@"@"]) {
        userWay = JLUSER_WAY_PHONE;
       
        if(phoneTF.text.length <11){
            [DFUITools showText:kJL_TXT("当前手机号少于11位") onView:self.view delay:1.5];
            return NO;
        }
        
        //NSString *pattern2 = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,12}";
        //NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern2];
        BOOL isMatch = [self validateMobile:phoneTF.text];

        if (!isMatch) {
            [DFUITools showText:kJL_TXT("手机号不符合规则") onView:self.view delay:1.5];
            return NO;
        }
    }else{
        userWay = JLUSER_WAY_EMAIL;

        if (phoneTF.text.length < 5) {
            [DFUITools showText:kJL_TXT("邮箱地址格式不正确") onView:self.view delay:1.5];
            return NO;
        }
    }
    return YES;
}

#pragma mark 发送验证码点击事件
-(void)sendVerClick{
    
    BOOL isOk = [self checkTextInput];
    if (isOk == NO) return;
    
    NSString *stringPhone = nil;
    NSString *stringEmail = nil;
    
    if (userWay == JLUSER_WAY_PHONE) {
        stringPhone = self->phoneTF.text;
        stringEmail = nil;
    } else {
        stringPhone = nil;
        stringEmail = self->phoneTF.text;
    }
    
    [[User_Http shareInstance] requestSMSCode:stringPhone
                                      OrEmail:stringEmail
                                       Result:^(NSDictionary * _Nonnull info)
     {
        [JL_Tools mainTask:^{
            int code = [info[@"code"] intValue];
            NSString *errorStr = info[@"msg"];
            if(code!=0){
                [DFUITools showText:errorStr onView:self.view delay:1.5];
                return;
            }
            
            self->fenGeView2.hidden = NO;
            self->verLabel2.hidden = NO;
            self->verLabel.hidden = YES;
            
            [self openCountdown];
        }];
    }];
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
                self->fenGeView2.hidden = YES;
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

/**
* 功能：校验手机号码
*/
- (BOOL)validateMobile:(NSString *)mobileNumber
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188,183,184,178
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189,181,177
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|70|8[0-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188,183,184,178
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|78|8[2-478])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186,176
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|76|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,181,189,177
     22         */
    NSString * CT = @"^1((33|53|77|8[019])[0-9]|349)\\d{7}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNumber] == YES)
        || ([regextestcm evaluateWithObject:mobileNumber] == YES)
        || ([regextestct evaluateWithObject:mobileNumber] == YES)
        || ([regextestcu evaluateWithObject:mobileNumber] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark 登录按钮
-(void)loginBtn:(UIButton *)btn{
    

    BOOL isOk = [self checkTextInput];
    if (isOk == NO ) return;
    
    
    if(verTF.text.length ==0){
        [DFUITools showText:kJL_TXT("请输入验证码") onView:self.view delay:1.5];
        return;
    }

    
    if(phoneTF.text && verTF.text){
        
        NSString *stringPhone = nil;
        NSString *stringEmail = nil;
        
        if (userWay == JLUSER_WAY_PHONE) {
            stringPhone = self->phoneTF.text;
            stringEmail = nil;
        } else {
            stringPhone = nil;
            stringEmail = self->phoneTF.text;
        }
        
        [[User_Http shareInstance] requestCodeLogin:stringPhone
                                            OrEmail:stringEmail
                                               Code:verTF.text
                                             Result:^(NSDictionary * _Nonnull info)
         {
            [JL_Tools mainTask:^{
                int code = [info[@"code"] intValue];
                NSString *errorStr = info[@"msg"];
                if(code!=0){
                    [DFUITools showText:errorStr onView:self.view delay:1.5];
                    return;
                }
                
                [JL_Tools setUser:self->phoneTF.text forKey:@"ACCOUNT_NUM"];
                
                [self.navigationController popViewControllerAnimated:YES];
                [JL_Tools post:@"ENTER_MAIN_VC" Object:nil];
            }];
        }];
    }
}


#pragma mark 使用账号密码登录
-(void)accountLogin{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    LoginVC *vc = [[LoginVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
