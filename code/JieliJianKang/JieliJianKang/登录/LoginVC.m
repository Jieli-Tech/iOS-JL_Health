//
//  LoginVC.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/2.
//

#import "LoginVC.h"
#import "JL_RunSDK.h"
#import "SmallEye.h"
#import "RegisterVC.h"
#import "VerificationCodeLoginVC.h"
#import "ForgetPwdVC.h"
#import "User_Http.h"

@interface LoginVC ()<UITextFieldDelegate>{
    UILabel     *label1;
    DFLabel     *verLabel;    //验证码登录
    DFLabel     *forgetLabel; //忘记密码登录
    UITextField *phoneTF;
    UITextField *passwordTF;
    
    UIButton    *cleanBtn;    //清除按钮
    UIButton    *loginBtn;    //登录按钮
    UIButton    *registerBtn; //注册按钮
    SmallEye    *eyeBtn;      //显示或者隐藏密码按钮
    BOOL        networkFlag;
    
    JLUSER_WAY userWay;
}

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self addNote];
}

-(void)initUI{
    networkFlag = YES;
    
    /*--- 网络监测 ---*/
    AFNetworkReachabilityManager *net = [AFNetworkReachabilityManager sharedManager];
    [net startMonitoring];
    
    float sW = [UIScreen mainScreen].bounds.size.width;
    
    label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(24,kJL_HeightNavBar+10,sW,33);
    label1.numberOfLines = 0;
    label1.text = kJL_TXT("登录");
    label1.font =  [UIFont fontWithName:@"Helvetica-Bold" size:24];
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [self.view addSubview:label1];
    
    phoneTF = [[UITextField alloc] initWithFrame:CGRectMake(24, label1.frame.origin.y+label1.frame.size.height+47, sW, 35)];
    phoneTF.textAlignment = NSTextAlignmentLeft;
    phoneTF.placeholder = kJL_TXT("请输入手机号码/邮箱");
    phoneTF.textColor = kDF_RGBA(36, 36, 36, 1.0);
    phoneTF.tintColor = kDF_RGBA(180, 180, 180, 1.0);
    phoneTF.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    phoneTF.keyboardAppearance=UIKeyboardAppearanceDefault;
    phoneTF.keyboardType= UIKeyboardTypeEmailAddress;
    phoneTF.delegate = self;
    phoneTF.tag =0;
    [self.view addSubview:phoneTF];
    phoneTF.text = [JL_Tools getUserByKey:kUI_ACCOUNT_NUM];
    phoneTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 34, sW-48, 1)];
    [phoneTF addSubview:view1];
    view1.backgroundColor = [UIColor grayColor];
    view1.alpha = 0.1;
    
    passwordTF = [[UITextField alloc] initWithFrame:CGRectMake(24, phoneTF.frame.origin.y+phoneTF.frame.size.height+33, sW-48, 35)];
    passwordTF.textAlignment = NSTextAlignmentLeft;
    passwordTF.placeholder = kJL_TXT("请输入密码");
    passwordTF.textColor = kDF_RGBA(36, 36, 36, 1.0);
    passwordTF.tintColor = kDF_RGBA(180, 180, 180, 1.0);
    passwordTF.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    passwordTF.delegate = self;
    passwordTF.tag = 1;
    passwordTF.secureTextEntry = YES;
    [self.view addSubview:passwordTF];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 34, sW-48, 1)];
    [passwordTF addSubview:view2];
    view2.backgroundColor = [UIColor grayColor];
    view2.alpha = 0.1;
    
    //    cleanBtn = [[UIButton alloc] initWithFrame:CGRectMake(sW-48-20,35/2-20/2,20,20)];
    //    [cleanBtn addTarget:self action:@selector(phoneCleanBtn:) forControlEvents:UIControlEventTouchUpInside];
    //    [cleanBtn setImage:[UIImage imageNamed:@"login_icon_delete_nol"] forState:UIControlStateNormal];
    //    [phoneTF addSubview:cleanBtn];
    //    cleanBtn.hidden = YES;
    
    __block LoginVC *blockSelf = self;
    eyeBtn = [[SmallEye alloc]initWithFrame:CGRectMake(sW-52-20, 35/2-20/2, 20, 20)];
    eyeBtn.actionBlock = ^(BOOL selected) {
        blockSelf->passwordTF.secureTextEntry = selected ? NO: YES;
    };
    
    [passwordTF addSubview:eyeBtn];
    eyeBtn.hidden = YES;
    
    verLabel = [[DFLabel alloc] init];
    verLabel.frame = CGRectMake(24,passwordTF.frame.origin.y+passwordTF.frame.size.height+15,sW/2-24,20);
    verLabel.numberOfLines = 0;
    verLabel.labelType = DFLeftRight;
    verLabel.textAlignment = NSTextAlignmentLeft;
    verLabel.text = kJL_TXT("使用验证码登录");
    verLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    verLabel.textColor = kDF_RGBA(143, 143, 143, 1.0);
    [self.view addSubview:verLabel];
    
    UITapGestureRecognizer *verGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(verLogin)];
    [verLabel addGestureRecognizer:verGestureRecognizer];
    verLabel.userInteractionEnabled=YES;
    
    forgetLabel = [[DFLabel alloc] init];
    forgetLabel.frame = CGRectMake(sW-24-80,passwordTF.frame.origin.y+passwordTF.frame.size.height+15,80,20);
    forgetLabel.numberOfLines = 0;
    forgetLabel.text = kJL_TXT("忘记密码");
    forgetLabel.labelType = DFLeftRight;
    forgetLabel.textAlignment = NSTextAlignmentLeft;
    forgetLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    forgetLabel.textColor = kDF_RGBA(143, 143, 143, 1.0);
    [self.view addSubview:forgetLabel];
    
    UITapGestureRecognizer *forgetGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forgetLogin)];
    [forgetLabel addGestureRecognizer:forgetGestureRecognizer];
    forgetLabel.userInteractionEnabled=YES;
    
    loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(24,verLabel.frame.origin.y+verLabel.frame.size.height+70,sW-48,48)];
    [loginBtn addTarget:self action:@selector(loginBtn:) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn setTitle:kJL_TXT("登录") forState:UIControlStateNormal];
    [loginBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15]];
    [loginBtn setTitleColor:kDF_RGBA(179, 179, 179, 1.0) forState:UIControlStateNormal];
    [loginBtn setBackgroundColor:kDF_RGBA(240, 241, 241, 1.0)];
    loginBtn.layer.cornerRadius = 24;
    [self.view addSubview:loginBtn];
    
    registerBtn = [[UIButton alloc] initWithFrame:CGRectMake(24,loginBtn.frame.origin.y+loginBtn.frame.size.height+16,sW-48,48)];
    [registerBtn addTarget:self action:@selector(registerBtn:) forControlEvents:UIControlEventTouchUpInside];
    [registerBtn setTitle:kJL_TXT("没有账号?立即注册") forState:UIControlStateNormal];
    [registerBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15]];
    [registerBtn setTitleColor:kDF_RGBA(174, 174, 174, 1.0) forState:UIControlStateNormal];
    [registerBtn setBackgroundColor:[UIColor whiteColor]];
    registerBtn.layer.borderWidth = 1.0;
    registerBtn.layer.borderColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0].CGColor;
    registerBtn.layer.cornerRadius = 24;
    [self.view addSubview:registerBtn];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    switch (textField.tag) {
        case 0:
        {
            cleanBtn.hidden = NO;
        }
            break;
        case 1:
        {
            eyeBtn.hidden = NO;
            
        }
            break;
        default:
            break;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    //[JL_Tools setUser:phoneTF.text forKey:@"phoneNum"];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(passwordTF.text.length>0 && phoneTF.text.length>0){
        [loginBtn setBackgroundColor:kDF_RGBA(128, 91, 235, 1.0)];
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        [loginBtn setTitleColor:kDF_RGBA(179, 179, 179, 1.0) forState:UIControlStateNormal];
        [loginBtn setBackgroundColor:kDF_RGBA(240, 241, 241, 1.0)];
    }
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
            [passwordTF becomeFirstResponder];
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
    
    //邮箱判断流程
    if (![phoneTF.text containsString:@"@"]) {
        userWay = JLUSER_WAY_PHONE;
        
        if(phoneTF.text.length <11){
            [DFUITools showText:kJL_TXT("当前手机号少于11位") onView:self.view delay:1.5];
            return NO;
        }
        
        NSString *pattern2 = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,12}";
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern2];
        BOOL isMatch_2 = [pred2 evaluateWithObject:passwordTF.text];
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
        userWay = JLUSER_WAY_EMAIL;
        
        if (phoneTF.text.length < 5) {
            [DFUITools showText:kJL_TXT("邮箱地址格式不正确") onView:self.view delay:1.5];
            return NO;
        }
    }
    
    
    if(passwordTF.text.length ==0){
        [DFUITools showText:kJL_TXT("请输入密码") onView:self.view delay:1.5];
        return NO;
    }
    return YES;
}


#pragma mark 登录按钮
-(void)loginBtn:(UIButton *)btn{
//    [self dismissViewControllerAnimated:YES completion:nil];
//    if ([self->_delegate respondsToSelector:@selector(loginAction)]) {
//        [self->_delegate loginAction];
//    }
//    return;
    
    
    BOOL isOk = [self checkTextInput];
    if(isOk == NO) return;
    
    
    if(phoneTF.text && passwordTF.text){
        
        NSString *stringPhone = nil;
        NSString *stringEmail = nil;
        
        if (userWay == JLUSER_WAY_PHONE) {
            stringPhone = self->phoneTF.text;
            stringEmail = nil;
        } else {
            stringPhone = nil;
            stringEmail = self->phoneTF.text;
        }
        
        
        [[User_Http shareInstance] requestPwdLogin:stringPhone
                                           OrEmail:stringEmail
                                               Pwd:self->passwordTF.text
                                            Result:^(NSDictionary * _Nonnull info)
         {
            [JL_Tools mainTask:^{
                if(info == nil && self->networkFlag==NO){
                    [DFUITools showText:kJL_TXT("请检查网络") onView:self.view delay:1.0];
                    return;
                }
                
                int code = [info[@"code"] intValue];
                NSString *errorStr = info[@"msg"];
                if(code!=0){
                    [DFUITools showText:errorStr onView:self.view delay:1.5];
                    return;
                }

                [JL_Tools setUser:self->phoneTF.text forKey:kUI_ACCOUNT_NUM];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                if ([self->_delegate respondsToSelector:@selector(loginAction:)]) {
                    [self->_delegate loginAction:self->phoneTF.text];
                }
            }];
        }];
    }
}

#pragma mark 注册按钮
-(void)registerBtn:(UIButton *)btn{
    RegisterVC *vc = [[RegisterVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark 清空手机号码
-(void)phoneCleanBtn:(UIButton *)btn{
    phoneTF.text = @"";
    cleanBtn.hidden = YES;
}

#pragma mark 使用验证码登录
-(void)verLogin{
    VerificationCodeLoginVC *vc = [[VerificationCodeLoginVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark 忘记密码登录
-(void)forgetLogin{
    ForgetPwdVC *vc = [[ForgetPwdVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.type = 0;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - 网络监测
- (void)actionNetStatus:(AFNetworkReachabilityStatus)status {
    if (status == AFNetworkReachabilityStatusNotReachable) {
        networkFlag = NO;
    }
    if (status == AFNetworkReachabilityStatusUnknown) {
        networkFlag = NO;
    }
    if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
        networkFlag = YES;
    }
    if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        networkFlag = YES;
    }
}

- (void)noteNetworkStatus:(NSNotification*)note {
    AFNetworkReachabilityManager *net = note.object;
    NSLog(@"---> Network Status: %ld",(long)net.networkReachabilityStatus);
    [self actionNetStatus:net.networkReachabilityStatus];
}

-(void)addNote{
    [JL_Tools add:AFNetworkingReachabilityDidChangeNotification Action:@selector(noteNetworkStatus:) Own:self];
}

- (void)dealloc {
    [JL_Tools remove:nil Own:self];
}
@end
