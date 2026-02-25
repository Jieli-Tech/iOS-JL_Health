//
//  ForgetSetPwdVC.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/3.
//

#import "ForgetSetPwdVC.h"
#import "JL_RunSDK.h"
#import "SmallEye.h"
#import "User_Http.h"

@interface ForgetSetPwdVC ()<UITextFieldDelegate>{
    __weak IBOutlet UIView *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
    
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    UILabel *pwdLabel;      //密码Label
    UILabel *surePwdLabel;  //确认密码Label
    
    UITextField *pwdTF;     //密码
    UITextField *surePwdTF; //确认密码
    
    SmallEye    *eyeBtn1;    //密码显示或者隐藏密码按钮
    SmallEye    *eyeBtn2;    //确认密码显示或者隐藏密码按钮

    UIButton    *finishBtn; //完成按钮
}

@end

@implementation ForgetSetPwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    titleHeight.constant = kJL_HeightNavBar;
    float sw = [DFUITools screen_2_W];
    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("设置密码");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    pwdLabel = [[UILabel alloc] init];
    pwdLabel.frame = CGRectMake(24,kJL_HeightNavBar+37,50,20);
    pwdLabel.numberOfLines = 0;
    pwdLabel.text = kJL_TXT("密码");
    pwdLabel.font =  [UIFont fontWithName:@"PingFangSC" size:14];
    pwdLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [self.view addSubview:pwdLabel];
    
    pwdTF = [[UITextField alloc] initWithFrame:CGRectMake(pwdLabel.frame.origin.x+pwdLabel.frame.size.width-5, kJL_HeightNavBar+29, sw, 35)];
    pwdTF.textAlignment = NSTextAlignmentLeft;
    pwdTF.placeholder = kJL_TXT("请设置6-12位字母和数字组合的新密码");
    pwdTF.textColor = kDF_RGBA(36, 36, 36, 1.0);
    pwdTF.tintColor = kDF_RGBA(180, 180, 180, 1.0);
    pwdTF.font = [UIFont fontWithName:@"PingFangSC" size:14];
    pwdTF.delegate = self;
    pwdTF.tag = 0;
    pwdTF.secureTextEntry = YES;
    [self.view addSubview:pwdTF];
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(24, pwdLabel.frame.origin.y+pwdLabel.frame.size.height+8, sw-48, 1)];
    [self.view addSubview:view1];
    view1.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    __block ForgetSetPwdVC *blockSelf = self;
    eyeBtn1 = [[SmallEye alloc]initWithFrame:CGRectMake(sw-90-20, 35/2-20/2, 20, 20)];
    eyeBtn1.actionBlock = ^(BOOL selected) {
        blockSelf->pwdTF.secureTextEntry = selected ? NO: YES;
    };
        
    [pwdTF addSubview:eyeBtn1];
    eyeBtn1.hidden = YES;
    
    surePwdLabel = [[UILabel alloc] init];
    surePwdLabel.frame = CGRectMake(24,view1.frame.origin.y+view1.frame.size.height+32,50,20);
    surePwdLabel.numberOfLines = 0;
    surePwdLabel.text = kJL_TXT("密码");
    surePwdLabel.font =  [UIFont fontWithName:@"PingFangSC" size:14];
    surePwdLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [self.view addSubview:surePwdLabel];
    
    surePwdTF = [[UITextField alloc] initWithFrame:CGRectMake(surePwdLabel.frame.origin.x+surePwdLabel.frame.size.width-5, view1.frame.origin.y+view1.frame.size.height+24, sw-48, 35)];
    surePwdTF.textAlignment = NSTextAlignmentLeft;
    surePwdTF.placeholder = kJL_TXT("请再次确认密码");
    surePwdTF.textColor = kDF_RGBA(36, 36, 36, 1.0);
    surePwdTF.tintColor = kDF_RGBA(180, 180, 180, 1.0);
    surePwdTF.font = [UIFont fontWithName:@"PingFangSC" size:14];
    surePwdTF.delegate = self;
    surePwdTF.tag = 1;
    surePwdTF.secureTextEntry = YES;
    [self.view addSubview:surePwdTF];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(24, surePwdLabel.frame.origin.y+surePwdLabel.frame.size.height+8, sw-48, 1)];
    [self.view addSubview:view2];
    view2.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    eyeBtn2 = [[SmallEye alloc]initWithFrame:CGRectMake(sw-90-20, 35/2-20/2, 20, 20)];
    eyeBtn2.actionBlock = ^(BOOL selected) {
        blockSelf->surePwdTF.secureTextEntry = selected ? NO: YES;
    };
        
    [surePwdTF addSubview:eyeBtn2];
    eyeBtn2.hidden = YES;
    
    finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(24,surePwdLabel.frame.origin.y+surePwdLabel.frame.size.height+111,sw-48,48)];
    [finishBtn addTarget:self action:@selector(finishBtn:) forControlEvents:UIControlEventTouchUpInside];
    [finishBtn setTitle:kJL_TXT("完成") forState:UIControlStateNormal];
    [finishBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:15]];
    [finishBtn setTitleColor:kDF_RGBA(179, 179, 179, 1.0) forState:UIControlStateNormal];
    [finishBtn setBackgroundColor:kDF_RGBA(240, 241, 241, 1.0)];
    finishBtn.layer.cornerRadius = 24;
    [self.view addSubview:finishBtn];
}

- (IBAction)actionExit:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    switch (textField.tag) {
        case 0:
        {
            eyeBtn1.hidden = NO;
        }
            break;
        case 1:
        {
            eyeBtn2.hidden = NO;
        }
            break;
        default:
            break;
    }
    
    [finishBtn setBackgroundColor:kDF_RGBA(128, 91, 235, 1.0)];
    [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
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
            [pwdTF becomeFirstResponder];
        }
            break;
        case 1:
        {
            [surePwdTF becomeFirstResponder];
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

-(void)finishBtn:(UIButton *)btn{
    if(![pwdTF.text isEqualToString:surePwdTF.text]){
        [DFUITools showText:kJL_TXT("两次输入密码不匹配") onView:self.view delay:1.5];
        return;
    }
    NSString *pattern1 = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,12}";
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern1];
    BOOL isMatch_1 = [pred1 evaluateWithObject:pwdTF.text];
    
    NSString *pattern2 = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,12}";
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern2];
    BOOL isMatch_2 = [pred2 evaluateWithObject:surePwdTF.text];
    
    if(isMatch_1 == YES && isMatch_2 == YES && pwdTF.text && surePwdTF.text){
        
        NSString *stringPhone = nil;
        NSString *stringEmail = nil;
        
        if (self.userWay == JLUSER_WAY_PHONE) {
            stringPhone = self.mobile;
            stringEmail = nil;
        } else {
            stringPhone = nil;
            stringEmail = self.mobile;
        }
        
        
        [[User_Http shareInstance] resetPassword:stringPhone
                                         OrEmail:stringEmail
                                             Pwd:surePwdTF.text
                                            Code:self.code
                                          Result:^(NSDictionary * _Nonnull info)
         {
            [JL_Tools mainTask:^{
                int code = [info[@"code"] intValue];
                NSString *errorStr = info[@"msg"];
                if(code!=0){
                    [DFUITools showText:errorStr onView:self.view delay:1.5];
                    return;
                }
                
                //[JL_Tools setUser:@"OK" forKey:@"LOGIN_SUCCESS"];
                NSString *acccessToken = [JL_Tools getUserByKey:@"accessToken"];
                if(acccessToken.length>0){ //设置界面->忘记密码->修改密码
                    [self.navigationController popViewControllerAnimated:YES];
                    [JL_Tools post:@"ENTER_MAIN_VC" Object:nil];
                }else{ //登录界面->忘记密码->修改密码
                    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }];
    }else{
        if (!isMatch_1 || !isMatch_2) {
            [DFUITools showText:kJL_TXT("密码请使用6-12位数字和字母组合") onView:self.view delay:1.5];
        }
    }
}
@end
