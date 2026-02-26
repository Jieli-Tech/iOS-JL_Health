//
//  EmergencyContactsVC.m
//  JieliJianKang
//
//  Created by 李放 on 2021/10/26.
//

#import "EmergencyContactsVC.h"

@interface EmergencyContactsVC ()<UITextFieldDelegate>{
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet UIView *headView;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    
    UIView *view1; //紧急联系人view
    UITextField *phoneField;
    
    UIButton *enterContactsBtn;
    UIButton *saveContactsBtn;
    
    DFLabel *modifyLabel; //修改电话号码的Label
    UILabel *label1;
}

@end

@implementation EmergencyContactsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    titleHeight.constant = kJL_HeightNavBar;
    float sw = [DFUITools screen_2_W];
    float sh = [DFUITools screen_2_H];
    
    headView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("紧急联系人");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    CGFloat height = kJL_HeightNavBar;
    
    view1 = [[UIView alloc] init];
    view1.frame = CGRectMake(0,height+8,sw,60);
    view1.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [self.view addSubview:view1];
    
    label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(17,19,sw-17,21);
    label1.numberOfLines = 0;
    [view1 addSubview:label1];
    label1.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label1.text =  kJL_TXT("手机号");
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    phoneField = [[UITextField alloc] initWithFrame:CGRectMake(view1.frame.size.width/2-35, view1.frame.size.height/2-18/2, sw-44, 18)];
    phoneField.textAlignment = NSTextAlignmentLeft;
    phoneField.placeholder = kJL_TXT("请填写紧急联系人手机号");
    phoneField.textColor = kDF_RGBA(36, 36, 36, 1.0);
    phoneField.tintColor = kDF_RGBA(180, 180, 180, 1.0);
    phoneField.font = [UIFont fontWithName:@"PingFangSC" size:13];
    phoneField.keyboardAppearance=UIKeyboardTypeDefault;
    phoneField.keyboardType= UIKeyboardTypePhonePad;
    phoneField.delegate = self;
    phoneField.tag =0;
    [view1 addSubview:phoneField];
    phoneField.hidden = NO;
    phoneField.text = [JL_Tools getUserByKey:@"ACCOUNT_NUM"];
    
    enterContactsBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-16-22,view1.frame.size.height/2-16/2,16,16)];
    [enterContactsBtn setImage:[UIImage imageNamed:@"icon_address_book"] forState:UIControlStateNormal];
    [enterContactsBtn addTarget:self action:@selector(enterContactsAction:) forControlEvents:UIControlEventTouchUpInside];
    [view1 addSubview:enterContactsBtn];
    enterContactsBtn.hidden = NO;
    
    modifyLabel = [[DFLabel alloc] init];
    if([kJL_GET hasPrefix:@"zh"]){
        modifyLabel.frame = CGRectMake(sw-16-26,view1.frame.size.height/2-18/2,26,18);
    }else{
        modifyLabel.frame = CGRectMake(sw-16-50,view1.frame.size.height/2-18/2,50,18);
    }
    modifyLabel.numberOfLines = 0;
    [view1 addSubview:modifyLabel];
    modifyLabel.labelType = DFLeftRight;
    modifyLabel.textAlignment = NSTextAlignmentLeft;
    modifyLabel.numberOfLines = 0;
    modifyLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 13];
    modifyLabel.text =  kJL_TXT("修改");
    modifyLabel.textColor = kDF_RGBA(85, 140, 255, 1.0);
    modifyLabel.hidden = YES;
    
    UITapGestureRecognizer *modifyPhoneGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(modifyPhoneNum)];
    [modifyLabel addGestureRecognizer:modifyPhoneGestureRecognizer];
    modifyLabel.userInteractionEnabled=YES;
    
    saveContactsBtn = [[UIButton alloc] initWithFrame:CGRectMake(24,sh-82-48,sw-48,48)];
    [saveContactsBtn addTarget:self action:@selector(saveContactsBtn:) forControlEvents:UIControlEventTouchUpInside];
    [saveContactsBtn setTitle:kJL_TXT("保存联系人") forState:UIControlStateNormal];
    [saveContactsBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:15]];
    [saveContactsBtn setTitleColor:kDF_RGBA(255, 255, 255, 1.0) forState:UIControlStateNormal];
    [saveContactsBtn setBackgroundColor:kDF_RGBA(128, 91, 235, 1.0)];
    saveContactsBtn.layer.cornerRadius = 24;
    [self.view addSubview:saveContactsBtn];
    saveContactsBtn.hidden = YES;
    
    if(phoneField.text){
        saveContactsBtn.hidden = YES;
        phoneField.hidden = YES;
        enterContactsBtn.hidden = YES;
        modifyLabel.hidden = NO;
        label1.text =  phoneField.text;
        titleName.text = kJL_TXT("紧急联系人");
    }
    if(phoneField.text.length == 0){
        saveContactsBtn.hidden = YES;
        phoneField.hidden = NO;
        enterContactsBtn.hidden = NO;
        modifyLabel.hidden = YES;
        label1.text =  kJL_TXT("手机号");
        titleName.text = kJL_TXT("紧急联系人设置");
    }
}

#pragma mark 进入手机通讯录界面
-(void)enterContactsAction:(UIButton *)btn{
    
}

#pragma mark 修改手机号码
-(void)modifyPhoneNum{
    saveContactsBtn.hidden = YES;
    phoneField.hidden = NO;
    enterContactsBtn.hidden = NO;
    modifyLabel.hidden = YES;
    label1.text =  kJL_TXT("手机号");
    titleName.text = kJL_TXT("紧急联系人设置");
}

#pragma mark 保存联系人号码
-(void)saveContactsBtn:(UIButton *)btn{
    BOOL isMatch = [[User_Http shareInstance] validateMobile:phoneField.text];
    
    if(phoneField.text.length ==0){
        [DFUITools showText:kJL_TXT("请输入手机号码") onView:self.view delay:1.5];
        return;
    }
    if(phoneField.text.length <11){
        [DFUITools showText:kJL_TXT("当前手机号少于11位") onView:self.view delay:1.5];
        return;
    }
    if (!isMatch) {
        [DFUITools showText:kJL_TXT("手机号不符合规则") onView:self.view delay:1.5];
        return;
    }

    if(isMatch == YES && phoneField.text){
        saveContactsBtn.hidden = YES;
        phoneField.hidden = YES;
        enterContactsBtn.hidden = YES;
        modifyLabel.hidden = NO;
        label1.text =  phoneField.text;
        titleName.text = kJL_TXT("紧急联系人");
    }
    
    [self sendDataToDevice];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
    saveContactsBtn.hidden = NO;
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
            [phoneField becomeFirstResponder];
        }
        default:
            break;
    }
    [textField endEditing:YES];
    return YES;
}

- (IBAction)exitAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 发送数据给设备端
-(void)sendDataToDevice{
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];

    [JL_Tools setUser:phoneField.text forKey:@"ACCOUNT_NUM"];
    JLFallDetectionModel *model1 = [[JLFallDetectionModel alloc] initWithModel:self.type Status:self.state phoneNumber:phoneField.text];
    [models addObject:model1];
    
    JLWearable *w = [JLWearable sharedInstance];
    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
}

@end
