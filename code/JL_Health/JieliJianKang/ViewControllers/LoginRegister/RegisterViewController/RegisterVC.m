//
//  RegisterVC.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/2.
//

#import "RegisterVC.h"
#import "JL_RunSDK.h"
#import "SmallEye.h"
#import "PersonDetailVC.h"
#import "User_Http.h"

@interface RegisterVC ()<UITextFieldDelegate>{
    __weak IBOutlet UIView   *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel  *titleName;
    __weak IBOutlet UIButton *btnWay;
    JLUSER_WAY               userWay;
    
    
    UIButton    *phoneCleanBtn;    //手机号码清除按钮
    UIButton    *verCleanBtn;      //验证码清除按钮
    UIButton    *registerBtn;      //注册按钮
    
    UITextField *phoneTF;     //手机号码
    UITextField *verTF;       //验证码
    UITextField *pwdTF;       //密码
    UILabel *label1;          //+86
    UIButton *verBtn;        //发送验证码
    DFLabel *verLabel2;       //重新获取(60s)
    UIView  *fenGeView;       //手机号码分割线
    UIView  *fenGeView2;      //验证码分割线
    SmallEye    *eyeBtn;      //显示或者隐藏密码按钮
    AgreementView *agreeMentView;
    
    AFHTTPSessionManager *afManager;
    __weak IBOutlet NSLayoutConstraint *subTitle_H;
    
    float sW;
    NSTimer *codeTimer;
    int codeCount;
}

@end

@implementation RegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    afManager = [AFHTTPSessionManager manager];
    afManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    afManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    afManager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    
    
    subTitle_H.constant = kJL_HeightStatusBar+44;
    
    sW = [UIScreen mainScreen].bounds.size.width;
    //subTitleView.frame = CGRectMake(0, 0, sW, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("手机注册");
    //titleName.bounds = CGRectMake(0, 0, 200, 20);
    //titleName.center = CGPointMake(sW/2.0, kJL_HeightStatusBar+20);
    
    label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(24, kJL_HeightNavBar+36, 35, 20);
    label1.numberOfLines = 0;
    label1.text = kJL_TXT("+86");
    label1.font =  [UIFont fontWithName:@"PingFangSC" size:14];
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [self.view addSubview:label1];
    
    fenGeView = [[UIView alloc] initWithFrame:CGRectMake(label1.frame.origin.x+label1.frame.size
                                                         .width+8, kJL_HeightNavBar+41, 1, 12)];
    [self.view addSubview:fenGeView];
    fenGeView.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(24, label1.frame.origin.y+label1.frame.size.height+8, sW-48, 1)];
    [self.view addSubview:view1];
    view1.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    phoneTF = [[UITextField alloc] initWithFrame:CGRectMake(label1.frame.origin.x+label1.frame.size.width+22, kJL_HeightNavBar+30, sW, 35)];
    phoneTF.textAlignment = NSTextAlignmentLeft;
    phoneTF.placeholder = kJL_TXT("请输入手机号码");
    phoneTF.textColor = kDF_RGBA(36, 36, 36, 1.0);
    phoneTF.tintColor = kDF_RGBA(180, 180, 180, 1.0);
    phoneTF.font = [UIFont fontWithName:@"PingFangSC" size:14];
    phoneTF.keyboardAppearance=UIKeyboardAppearanceDefault;
    phoneTF.keyboardType=UIKeyboardTypePhonePad;
    phoneTF.delegate = self;
    phoneTF.tag =0;
    [self.view addSubview:phoneTF];
    phoneTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    
    //    phoneCleanBtn = [[UIButton alloc] initWithFrame:CGRectMake(sW-100-20,35/2-20/2,20,20)];
    //    [phoneCleanBtn addTarget:self action:@selector(phoneCleanBtn:) forControlEvents:UIControlEventTouchUpInside];
    //    [phoneCleanBtn setImage:[UIImage imageNamed:@"login_icon_delete_nol"] forState:UIControlStateNormal];
    //    [phoneTF addSubview:phoneCleanBtn];
    //    phoneCleanBtn.hidden = YES;
    
    verTF = [[UITextField alloc] initWithFrame:CGRectMake(24, view1.frame.origin.y+view1
                                                          .frame.size.height+32, sW, 35)];
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
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 34, sW-48, 1)];
    [verTF addSubview:view2];
    view2.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    pwdTF = [[UITextField alloc] initWithFrame:CGRectMake(24, verTF.frame.origin.y+verTF
                                                          .frame.size.height+32, sW, 35)];
    pwdTF.textAlignment = NSTextAlignmentLeft;
    pwdTF.placeholder = kJL_TXT("请设置6-12位字母和数字组合的密码");
    pwdTF.textColor = kDF_RGBA(36, 36, 36, 1.0);
    pwdTF.tintColor = kDF_RGBA(180, 180, 180, 1.0);
    pwdTF.font = [UIFont fontWithName:@"PingFangSC" size:12];
    pwdTF.delegate = self;
    pwdTF.tag =2;
    pwdTF.secureTextEntry = YES;
    [self.view addSubview:pwdTF];
    
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(0, 34, sW-48, 1)];
    [pwdTF addSubview:view3];
    view3.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    __block RegisterVC *blockSelf = self;
    eyeBtn = [[SmallEye alloc]initWithFrame:CGRectMake(sW-51-20, 35/2-20/2, 20, 20)];
    eyeBtn.actionBlock = ^(BOOL selected) {
        blockSelf->pwdTF.secureTextEntry = selected ? NO: YES;
    };
    
    [pwdTF addSubview:eyeBtn];
    eyeBtn.hidden = YES;
    
    verBtn = [[UIButton alloc] init];
    verBtn.frame = CGRectMake(sW-20-90, phoneTF.frame.origin.y+phoneTF.frame.size.height+38, 90, 20);
    [verBtn setTitle:kJL_TXT("发送验证码") forState:UIControlStateNormal];
    verBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    verBtn.titleLabel.font =  [UIFont fontWithName:@"PingFangSC" size:14];
    [verBtn setTitleColor:kDF_RGBA(128, 91, 235, 1.0) forState:UIControlStateNormal];
    [verBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [verBtn addTarget:self action:@selector(sendVerClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:verBtn];
    
    

    verLabel2 = [[DFLabel alloc] init];
    verLabel2.frame = CGRectMake(sW-20-120, phoneTF.frame.origin.y+phoneTF.frame.size.height+38, 125, 20);
    verLabel2.numberOfLines = 0;
    verLabel2.font =  [UIFont fontWithName:@"PingFangSC" size:14];
    verLabel2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    verLabel2.tag = 1;
    verLabel2.labelType = DFLeftRight;
    verLabel2.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:verLabel2];
    verLabel2.hidden = YES;
    
    fenGeView2 = [[UIView alloc] initWithFrame:CGRectMake(verLabel2.frame.origin.x-8, view1.frame.origin.y+view1.frame.size.height+42, 1, 12)];
    [self.view addSubview:fenGeView2];
    fenGeView2.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
    fenGeView2.hidden = YES;
    
    //    verCleanBtn = [[UIButton alloc] initWithFrame:CGRectMake(fenGeView2.frame.origin.x-30,view1.frame.origin.y+view1.frame.size.height+38,20,20)];
    //    [verCleanBtn addTarget:self action:@selector(verCleanBtn:) forControlEvents:UIControlEventTouchUpInside];
    //    [verCleanBtn setImage:[UIImage imageNamed:@"login_icon_delete_nol"] forState:UIControlStateNormal];
    //    [self.view addSubview:verCleanBtn];
    //    verCleanBtn.hidden = YES;
    
    registerBtn = [[UIButton alloc] initWithFrame:CGRectMake(24,pwdTF.frame.origin.y+pwdTF.frame.size.height+148,sW-48,48)];
    [registerBtn addTarget:self action:@selector(registerBtn:) forControlEvents:UIControlEventTouchUpInside];
    [registerBtn setTitle:kJL_TXT("注册") forState:UIControlStateNormal];
    [registerBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:15]];
    [registerBtn setTitleColor:kDF_RGBA(179, 179, 179, 1.0) forState:UIControlStateNormal];
    [registerBtn setBackgroundColor:kDF_RGBA(240, 241, 241, 1.0)];
    registerBtn.layer.cornerRadius = 24;
    [self.view addSubview:registerBtn];
    
    
    [btnWay setTitle:kJL_TXT("邮箱注册") forState:UIControlStateNormal];
    userWay = JLUSER_WAY_PHONE;
    
    agreeMentView = [[AgreementView alloc] init];
    [self.view addSubview:agreeMentView];
    agreeMentView.parentViewController = self;
    [agreeMentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(30);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-20);
    }];

}


-(void)updateUIForUserWay:(JLUSER_WAY)way{
    if (way == JLUSER_WAY_PHONE) {
        label1.hidden = NO;
        fenGeView.hidden = NO;
        phoneTF.frame = CGRectMake(label1.frame.origin.x+label1.frame.size.width+22, kJL_HeightNavBar+30, sW-60-48, 35);
        phoneTF.placeholder = kJL_TXT("请输入手机号码");
        phoneTF.keyboardType=UIKeyboardTypePhonePad;

        [btnWay setTitle:kJL_TXT("邮箱注册") forState:UIControlStateNormal];
        titleName.text = kJL_TXT("手机注册");
    } else {
        label1.hidden = YES;
        fenGeView.hidden = YES;
        phoneTF.frame = CGRectMake(24, kJL_HeightNavBar+30, sW-60-48, 35);
        phoneTF.placeholder = kJL_TXT("请输入邮箱地址");
        phoneTF.keyboardType=UIKeyboardTypeEmailAddress;

        [btnWay setTitle:kJL_TXT("手机注册") forState:UIControlStateNormal];
        titleName.text = kJL_TXT("邮箱注册");
    }
}


- (IBAction)btnChangeWay:(id)sender {
    if (userWay == JLUSER_WAY_PHONE) {
        userWay = JLUSER_WAY_EMAIL;
    } else {
        userWay = JLUSER_WAY_PHONE;
    }
    [self updateUIForUserWay:userWay];
}



- (IBAction)actionExit:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    switch (textField.tag) {
        case 0:
        {
            phoneCleanBtn.hidden = NO;
        }
            break;
        case 1:
        {
            verCleanBtn.hidden = NO;
        }
            break;
        case 2:
        {
            eyeBtn.hidden = NO;
        }
            break;
        default:
            break;
    }
    
    [registerBtn setBackgroundColor:kDF_RGBA(128, 91, 235, 1.0)];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
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
        case 2:
        {
            [pwdTF becomeFirstResponder];
        }
            break;
        default:
            break;
    }
    [textField endEditing:YES];
    return YES;
}

-(BOOL)checkTextInput{
    if(phoneTF.text.length == 0){
        [DFUITools showText:kJL_TXT("请输入手机号码/邮箱") onView:self.view delay:1.5];
        return NO;
    }
    
    if (![phoneTF.text containsString:@"@"]) {
        //邮箱判断流程
        if(phoneTF.text.length <11){
            [DFUITools showText:kJL_TXT("当前手机号少于11位") onView:self.view delay:1.5];
            return NO;
        }
        
        NSString *pattern2 = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,12}";
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern2];
        BOOL isMatch_2 = [pred2 evaluateWithObject:pwdTF.text];
        BOOL isMatch = [[User_Http shareInstance] validateMobile:phoneTF.text];

        if (!isMatch) {
            [DFUITools showText:kJL_TXT("手机号不符合规则") onView:self.view delay:1.5];
            return NO;
        }
        if (!isMatch_2) {
            [DFUITools showText:kJL_TXT("密码请使用6-12位数字和字母组合") onView:self.view delay:1.5];
            return NO;
        }
    }else{
        if (phoneTF.text.length < 5) {
            [DFUITools showText:kJL_TXT("验证码格式不正确") onView:self.view delay:1.5];
            return NO;
        }
    }
    
    if(pwdTF.text.length == 0){
        [DFUITools showText:kJL_TXT("请输入密码") onView:self.view delay:1.5];
        return NO;
    }
    
    if(verTF.text.length ==0){
        [DFUITools showText:kJL_TXT("请输入验证码") onView:self.view delay:1.5];
        return NO;
    }
    return YES;
}

-(BOOL)checkTextInput_1{
    if(phoneTF.text.length == 0){
        [DFUITools showText:kJL_TXT("请输入手机号码/邮箱") onView:self.view delay:1.5];
        return NO;
    }
    
    if (![phoneTF.text containsString:@"@"]) {
        //邮箱判断流程
        if(phoneTF.text.length <11){
            [DFUITools showText:kJL_TXT("当前手机号少于11位") onView:self.view delay:1.5];
            return NO;
        }
        BOOL isMatch = [[User_Http shareInstance] validateMobile:phoneTF.text];

        if (!isMatch) {
            [DFUITools showText:kJL_TXT("手机号不符合规则") onView:self.view delay:1.5];
            return NO;
        }
    }else{
        if (phoneTF.text.length < 5) {
            [DFUITools showText:kJL_TXT("邮箱地址格式不正确") onView:self.view delay:1.5];
            return NO;
        }
    }
    return YES;
}

#pragma mark 注册按钮
-(void)registerBtn:(UIButton *)btn{
//    BOOL isMatch = [[User_Http shareInstance] validateMobile:phoneTF.text];
//
//    NSString *pattern2 = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,12}";
//    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern2];
//    BOOL isMatch_2 = [pred2 evaluateWithObject:pwdTF.text];
//
//    if(phoneTF.text.length ==0){
//        [DFUITools showText:kJL_TXT("请输入手机号码") onView:self.view delay:1.5];
//        return;
//    }
//    if(phoneTF.text.length <11){
//        [DFUITools showText:kJL_TXT("当前手机号少于11位") onView:self.view delay:1.5];
//        return;
//    }
//    if(verTF.text.length ==0){
//        [DFUITools showText:kJL_TXT("请输入验证码") onView:self.view delay:1.5];
//        return;
//    }
//    if(pwdTF.text.length ==0){
//        [DFUITools showText:kJL_TXT("请输入密码") onView:self.view delay:1.5];
//        return;
//    }
//    if (!isMatch) {
//        [DFUITools showText:kJL_TXT("手机号不符合规则") onView:self.view delay:1.5];
//        return;
//    }
//    if (!isMatch_2) {
//        [DFUITools showText:kJL_TXT("密码请使用6-12位数字和字母组合") onView:self.view delay:1.5];
//        return;
//    }

    
    BOOL isOk = [self checkTextInput];
    if(isOk == NO) return; 
    if ([JL_Tools getUserByKey:AgreementView.kAgreeMent] == nil){
        [DFUITools showText:kJL_TXT("Please read and agree to the Terms of Service and Privacy Policy.") onView:self.view delay:1.5];
        return;
    }
    
    NSString *stringPhone = nil;
    NSString *stringEmail = nil;
    
    if (userWay == JLUSER_WAY_PHONE) {
        stringPhone = self->phoneTF.text;
        stringEmail = nil;
    } else {
        stringPhone = nil;
        stringEmail = self->phoneTF.text;
    }

    if(phoneTF.text && pwdTF.text && verTF.text){
        [[User_Http shareInstance] requestRegister:stringPhone
                                           OrEmail:stringEmail
                                               Pwd:pwdTF.text
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

                [JL_Tools setUser:self->phoneTF.text forKey:kUI_ACCOUNT_NUM];

                PersonDetailVC *vc = [[PersonDetailVC alloc] init];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:vc animated:YES completion:nil];
            }];
        }];
    }
}

#pragma mark 清空手机号码
-(void)phoneCleanBtn:(UIButton *)btn{
    phoneTF.text = @"";
    phoneCleanBtn.hidden = YES;
}

#pragma mark 清空验证码
-(void)verCleanBtn:(UIButton *)btn{
    verTF.text = @"";
    verCleanBtn.hidden = YES;
}

#pragma mark 发送验证码点击事件
-(void)sendVerClick{
    
    BOOL isOk = [self checkTextInput_1];
    if(isOk == NO) return;
    
    NSString *stringPhone = nil;
    NSString *stringEmail = nil;
    
    if (userWay == JLUSER_WAY_PHONE) {
        stringPhone = self->phoneTF.text;
        stringEmail = nil;
    } else {
        stringPhone = nil;
        stringEmail = self->phoneTF.text;
    }

    
    
    if (stringPhone.length != 0 && stringEmail.length == 0) {
        [AlertViewOnWindows showVerifyCodeTipsWithCallBack:^(NSString * _Nonnull code, NSString * _Nonnull value, NSError * _Nullable err) {
            if(code.length > 0 && value.length > 0){
                [self startCodeAction];
                [[User_Http shareInstance] requestSMSCode:stringPhone OrEmail:nil CapchaCode:code CapchaValue:value Result:^(NSDictionary * _Nonnull info) {
                    [self getVerCode:info];
                }];
            }
        }];
    }else if (stringPhone.length == 0 && stringEmail.length != 0) {
        [self startCodeAction];
        [[User_Http shareInstance] requestSMSCode:nil OrEmail:stringEmail CapchaCode:nil CapchaValue:nil Result:^(NSDictionary * _Nonnull info) {
           [self getVerCode:info];
        }];
    }
    
}

-(void)getVerCode:(NSDictionary *)info{
    [JL_Tools mainTask:^{
        int code = [info[@"code"] intValue];
        NSString *errorStr = info[@"msg"];
        if(code != 0){
            [DFUITools showText:errorStr onView:self.view delay:1.5];
            return;
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
                self->verCleanBtn.hidden = YES;
                self->verLabel2.hidden = YES;
                self->verBtn.hidden = NO;
                
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

//MARK: - code send action
static int codeMaxCount = 120;
-(void)startCodeAction{
    [codeTimer invalidate];
    codeCount = 0;
    if (codeTimer != nil){
        codeTimer = nil;
    }
    codeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countTime) userInfo:nil repeats:true];
    [codeTimer fireDate];
}


-(void)countTime{
    codeCount +=1;
    if (codeCount<codeMaxCount){
        fenGeView2.hidden = NO;
        verCleanBtn.hidden = NO;
        verLabel2.hidden = NO;
        verBtn.hidden = YES;
        verLabel2.text = [NSString stringWithFormat:@"%@%@%.1d%@%@",kJL_TXT("重新获取"),@"(",codeMaxCount-codeCount,@"s",@")"];
        verLabel2.userInteractionEnabled = NO;
    }else{
        [codeTimer invalidate];
        fenGeView2.hidden = YES;
        verCleanBtn.hidden = YES;
        verLabel2.hidden = YES;
        verBtn.hidden = NO;
        verLabel2.userInteractionEnabled = YES;
    }
}

@end
