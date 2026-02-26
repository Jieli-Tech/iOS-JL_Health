//
//  ChangePwdVC.m
//  JieliJianKang
//
//  Created by 李放 on 2021/4/9.
//

#import "ChangePwdVC.h"
#import "JL_RunSDK.h"
#import "SmallEye.h"
#import "ForgetPwdVC.h"
#import "User_Http.h"

@interface ChangePwdVC ()<UITextFieldDelegate>{
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet UIView *headView;
    
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    UIView      *view1;  //输入旧密码
    UIView      *view2;  //输入新的密码和再次输入新的密码
    UITextField *passwordTF;
    UITextField *newPwdTF;
    UITextField *sureNewPwdTF;
    
    UIView *fengeView;
    float sw;
    float sh;
    
    SmallEye    *eyeBtn;  //旧密码显示或者隐藏密码按钮
    SmallEye    *eyeBtn2; //新密码显示或者隐藏密码按钮
    
    UILabel     *errorPwdLabel;   //密码不一致，请重新输入
    UIButton    *sureBtn;         //确定按钮
}

@end

@implementation ChangePwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(246, 247, 248, 1.0);
    titleHeight.constant = kJL_HeightNavBar;
    sw = [UIScreen mainScreen].bounds.size.width;
    sh = [UIScreen mainScreen].bounds.size.height;
    
    headView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("更改密码");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    UILabel *oldPwd = [[UILabel alloc] init];
    oldPwd.frame = CGRectMake(16,kJL_HeightNavBar+16,sw-16,21);
    oldPwd.numberOfLines = 0;
    [self.view addSubview:oldPwd];
    oldPwd.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    oldPwd.text =  kJL_TXT("旧密码");
    oldPwd.textColor = kDF_RGBA(75, 75, 75, 1.0);
    
    view1 = [[UIView alloc] initWithFrame:CGRectMake(0, kJL_HeightNavBar+45, sw, 50)];
    [self.view addSubview:view1];
    view1.backgroundColor = [UIColor whiteColor];
    
    passwordTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 15, view1.frame.size.width-32-40, 21)];
    passwordTF.textAlignment = NSTextAlignmentLeft;
    passwordTF.placeholder = kJL_TXT("输入旧密码");
    passwordTF.textColor = kDF_RGBA(36, 36, 36, 1.0);
    passwordTF.tintColor = kDF_RGBA(180, 180, 180, 1.0);
    passwordTF.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    passwordTF.delegate = self;
    passwordTF.tag = 0;
    passwordTF.secureTextEntry = YES;
    [view1 addSubview:passwordTF];
    
    __block ChangePwdVC *blockSelf = self;
    
    eyeBtn = [[SmallEye alloc]initWithFrame:CGRectMake(view1.frame.size.width-25-16,50/2-40/2, 40, 40)];
    eyeBtn.actionBlock = ^(BOOL selected) {
        blockSelf->passwordTF.secureTextEntry = selected ? NO: YES;
    };
    
    [view1 addSubview:eyeBtn];
    eyeBtn.hidden = YES;
    
    UILabel *newPwd = [[UILabel alloc] init];
    newPwd.numberOfLines = 0;
    [self.view addSubview:newPwd];
    newPwd.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    newPwd.text =  kJL_TXT("新密码");
    newPwd.textColor = kDF_RGBA(75, 75, 75, 1.0);
    CGFloat width = [self getWidthWithText:kJL_TXT("新密码") height:21 font:15];
    newPwd.frame = CGRectMake(16,view1.frame.size.height+view1.frame.origin.y+16,width,21);

    DFLabel *label1 = [[DFLabel alloc] init];
    label1.frame = CGRectMake(newPwd.frame.origin.x+newPwd.frame.size.width+12,view1.frame.size.height+view1.frame.origin.y+17,sw-16-45-12-70,21);
    label1.numberOfLines = 0;
    [self.view addSubview:label1];
    label1.font =  [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
    label1.labelType = DFLeftRight;
    label1.textAlignment = NSTextAlignmentLeft;
    label1.text =  kJL_TXT("请设置6-12位字母和数字组合的新密码");
    label1.textColor = kDF_RGBA(145, 145, 145, 1.0);
    label1.adjustsFontSizeToFitWidth = YES;
    label1.minimumScaleFactor =0.7;
    
    view2 = [[UIView alloc] initWithFrame:CGRectMake(0,newPwd.frame.origin.y+newPwd.frame.size.height+8, sw, 100)];
    [self.view addSubview:view2];
    view2.backgroundColor = [UIColor whiteColor];
    
    newPwdTF = [[UITextField alloc] initWithFrame:CGRectMake(16, 15, view1.frame.size.width-32-40, 21)];
    newPwdTF.textAlignment = NSTextAlignmentLeft;
    newPwdTF.placeholder = kJL_TXT("输入新的密码");
    newPwdTF.textColor = kDF_RGBA(36, 36, 36, 1.0);
    newPwdTF.tintColor = kDF_RGBA(180, 180, 180, 1.0);
    newPwdTF.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    newPwdTF.delegate = self;
    newPwdTF.tag = 1;
    newPwdTF.secureTextEntry= YES;
    [view2 addSubview:newPwdTF];
    
    eyeBtn2 = [[SmallEye alloc]initWithFrame:CGRectMake(view2.frame.size.width-25-16,50/2-40/2, 40, 40)];
    eyeBtn2.actionBlock = ^(BOOL selected) {
        blockSelf->newPwdTF.secureTextEntry = selected ? NO: YES;
        blockSelf->sureNewPwdTF.secureTextEntry = selected ? NO: YES;
    };
    
    [view2 addSubview:eyeBtn2];
    eyeBtn2.hidden = YES;
    
    fengeView = [[UIView alloc] initWithFrame:CGRectMake(16, 49, sw-16, 1)];
    [view2 addSubview:fengeView];
    fengeView.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    sureNewPwdTF = [[UITextField alloc] initWithFrame:CGRectMake(16, fengeView.frame.origin.y+fengeView.frame.size.height+14, view1.frame.size.width-32-40, 21)];
    sureNewPwdTF.textAlignment = NSTextAlignmentLeft;
    sureNewPwdTF.placeholder = kJL_TXT("再次输入新的密码");
    sureNewPwdTF.textColor = kDF_RGBA(36, 36, 36, 1.0);
    sureNewPwdTF.tintColor = kDF_RGBA(180, 180, 180, 1.0);
    sureNewPwdTF.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    sureNewPwdTF.delegate = self;
    sureNewPwdTF.tag = 2;
    sureNewPwdTF.secureTextEntry= YES;
    [view2 addSubview:sureNewPwdTF];
    
    errorPwdLabel = [[UILabel alloc] init];
    errorPwdLabel.frame = CGRectMake(16,view2.frame.size.height+view2.frame.origin.y+14,150,17);
    errorPwdLabel.numberOfLines = 0;
    [self.view addSubview:errorPwdLabel];
    errorPwdLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 12];
    errorPwdLabel.text =  kJL_TXT("密码不一致，请重新输入");
    errorPwdLabel.textColor = kDF_RGBA(255, 105, 105, 1.0);
    errorPwdLabel.hidden = YES;
    
    if ([kJL_GET isEqualToString:@"zh-Hans"] || [kJL_GET isEqual:@"auto"]) {
        UILabel *forgetPwdLabel = [[UILabel alloc] init];
        forgetPwdLabel.numberOfLines = 0;
        forgetPwdLabel.text = kJL_TXT("忘记密码");
        forgetPwdLabel.font =  [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        forgetPwdLabel.textColor = kDF_RGBA(85, 140, 255, 1.0);
        forgetPwdLabel.frame = CGRectMake(sw-16-70,view2.frame.origin.y+view2.frame.size.height+12
                                          ,70,20);
        [self.view addSubview:forgetPwdLabel];
        UITapGestureRecognizer *forgetGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forgetLogin)];
        [forgetPwdLabel addGestureRecognizer:forgetGestureRecognizer];
        forgetPwdLabel.userInteractionEnabled=YES;
        
        UITapGestureRecognizer *forgetGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forgetLogin)];
        [forgetPwdLabel addGestureRecognizer:forgetGestureRecognizer1];
        forgetPwdLabel.userInteractionEnabled=YES;
    }else{
        DFLabel *forgetPwdLabel = [[DFLabel alloc] init];
        forgetPwdLabel.numberOfLines = 0;
        forgetPwdLabel.text = kJL_TXT("忘记密码");
        forgetPwdLabel.font =  [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        forgetPwdLabel.textColor = kDF_RGBA(85, 140, 255, 1.0);
        forgetPwdLabel.labelType = DFLeftRight;
        forgetPwdLabel.textAlignment = NSTextAlignmentLeft;
        CGFloat forgetPwdLabelWidth = [self getWidthWithText:kJL_TXT("忘记密码") height:20 font:14];
        forgetPwdLabel.frame = CGRectMake(sw-16-forgetPwdLabelWidth,view2.frame.origin.y+view2.frame.size.height+12
                                          ,forgetPwdLabelWidth,20);
        [self.view addSubview:forgetPwdLabel];
        UITapGestureRecognizer *forgetGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forgetLogin)];
        [forgetPwdLabel addGestureRecognizer:forgetGestureRecognizer2];
        forgetPwdLabel.userInteractionEnabled=YES;
    }
    
    sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(24,sh-54-48,sw-48,48)];
    [sureBtn addTarget:self action:@selector(sureBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitle:kJL_TXT("确定") forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:15]];
    [sureBtn setTitleColor:kDF_RGBA(145, 145, 145, 1.0) forState:UIControlStateNormal];
    [sureBtn setBackgroundColor:kDF_RGBA(255, 255, 255, 1.0)];
    sureBtn.layer.cornerRadius = 24;
    [self.view addSubview:sureBtn];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    switch (textField.tag) {
        case 0:
        {
            eyeBtn.hidden = NO;
        }
            break;
        case 1:
        {
            eyeBtn2.hidden = NO;
        }
            break;
        case 2:{
            [sureBtn setBackgroundColor:kDF_RGBA(255, 255, 255, 1.0)];
            [sureBtn setTitleColor:kDF_RGBA(85, 140, 255, 1.0) forState:UIControlStateNormal];
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
            [passwordTF becomeFirstResponder];
        }
            break;
        case 1:
        {
            [newPwdTF becomeFirstResponder];
        }
            break;
        case 2:
        {
            [sureNewPwdTF becomeFirstResponder];
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

#pragma mark 忘记密码登录
-(void)forgetLogin{
    ForgetPwdVC *vc = [[ForgetPwdVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.type = 1;
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)sureBtnAction:(UIButton *)btn{
    if(![newPwdTF.text isEqualToString:sureNewPwdTF.text]){
        errorPwdLabel.hidden = NO;
    }else{
        errorPwdLabel.hidden = YES;
    }
    
    NSString *pattern = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,12}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch_1 = [pred evaluateWithObject:passwordTF.text];
    BOOL isMatch_2 = [pred evaluateWithObject:newPwdTF.text];
    BOOL isMatch_3 = [pred evaluateWithObject:sureNewPwdTF.text];
    
    if(isMatch_1 == YES && isMatch_2 == YES  && isMatch_3 == YES && passwordTF.text && newPwdTF.text && sureNewPwdTF.text){
        [[User_Http shareInstance] requestOldPwdModifyNewPwd:passwordTF.text WithNewPwd:newPwdTF.text Result:^(NSDictionary * _Nonnull info) {
            [JL_Tools mainTask:^{
                int code = [info[@"code"] intValue];
                NSString *errorStr = info[@"msg"];
                if(code!=0){
                    [DFUITools showText:errorStr onView:self.view delay:1.5];
                    return;
                }
                
                [JL_Tools post:kUI_CHANGE_PHONE_PWD Object:@(2)];
                
                //[self.navigationController popViewControllerAnimated:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }];
    }else{
        [DFUITools showText:kJL_TXT("密码请使用6-12位数字和字母组合") onView:self.view delay:1.5];
        return;
    }
}

- (IBAction)backAction:(UIButton *)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/// 计算宽度
/// @param text 文字
/// @param height 高度
/// @param font 字体
- (CGFloat)getWidthWithText:(NSString *)text height:(CGFloat)height font:(CGFloat)font{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size: font]} context:nil];
    return rect.size.width;
}

@end
