//
//  MyAccountVC.m
//  JieliJianKang
//
//  Created by 李放 on 2021/4/8.
//

#import "MyAccountVC.h"
#import "JL_RunSDK.h"
#import "ChangeMobileView.h"
#import "LogoutAccountView.h"
#import "ValidationMobileView.h"
#import "BindingNewPhoneVC.h"
#import "ChangePwdVC.h"
#import "User_Http.h"

@interface MyAccountVC ()<ChangeMobileViewPickDelegate,ValidationMobileViewPickDelegate,LogoutAccountViewPickDelegate>{
    float sw;
    float sh;
    
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet UIView *headView;
    __weak IBOutlet NSLayoutConstraint *mTitleHight;
    
    UIView *view1; //修改手机号码
    UIView *view2; //更改密码
    
    ChangeMobileView     *changeMobileView;
    ValidationMobileView *validationMobileView;
    LogoutAccountView    *logoutAccountView;
    
    UILabel *changeMobileLabel2;
    UIView  *bgView;
    
    UILabel *logoutAccountLabel;
    DFLabel *logoutAccountLabel2;
    
    JLUSER_WAY userWay;
}

@end

@implementation MyAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self addNote];
}

-(void)initUI{
    sw = [DFUITools screen_2_W];
    sh = [DFUITools screen_2_H];
    
    mTitleHight.constant = kJL_HeightNavBar;
    
    float sw = [DFUITools screen_2_W];
    headView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("账号与安全");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2, kJL_HeightStatusBar+20);
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kJL_HeightStatusBar+44+8, sw, sh-kJL_HeightStatusBar-44-8)];
    [self.view addSubview:bgView];
    bgView.backgroundColor = kDF_RGBA(246, 247, 248, 1.0);
    
    //修改手机号码
    view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 8, sw, 60)];
    [bgView addSubview:view1];
    UITapGestureRecognizer *view1GestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeMobileAction)];
    [view1 addGestureRecognizer:view1GestureRecognizer];
    view1.backgroundColor = [UIColor whiteColor];
    view1.userInteractionEnabled=YES;
    
    UILabel *changeMobileLabel = [[UILabel alloc] init];
    changeMobileLabel.frame = CGRectMake(16,19,sw-70,21);
    changeMobileLabel.numberOfLines = 0;
    [view1 addSubview:changeMobileLabel];
    changeMobileLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    changeMobileLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    userWay = [[JL_Tools getUserByKey:@"httpUserWay"] intValue];
    if(userWay == JLUSER_WAY_PHONE) changeMobileLabel.text = kJL_TXT("修改手机号码");
    if(userWay == JLUSER_WAY_EMAIL) changeMobileLabel.text = kJL_TXT("更改邮箱地址");

    UIButton *changeMobileBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-16-22,19,22,22)];
    [changeMobileBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [view1 addSubview:changeMobileBtn];
    view1.backgroundColor = [UIColor whiteColor];

    changeMobileLabel2 = [[UILabel alloc] init];
    changeMobileLabel2.frame = CGRectMake(sw-220,20,180,18);
    changeMobileLabel2.numberOfLines = 0;
    [view1 addSubview:changeMobileLabel2];
    changeMobileLabel2.font = [UIFont fontWithName:@"PingFang SC" size: 13];
    changeMobileLabel2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    changeMobileLabel2.textAlignment = NSTextAlignmentRight;
    changeMobileLabel2.text = [JL_Tools getUserByKey:@"ACCOUNT_NUM"];
    
    
    view2 = [[UIView alloc] initWithFrame:CGRectMake(0, view1.frame.origin.y+view1.frame.size.height+8, sw, 60)];
    [bgView addSubview:view2];
    UITapGestureRecognizer *view2GestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changePwdAction)];
    [view2 addGestureRecognizer:view2GestureRecognizer];
    view2.backgroundColor = [UIColor whiteColor];
    view2.userInteractionEnabled=YES;
    
    UILabel *changePwdLabel = [[UILabel alloc] init];
    changePwdLabel.frame = CGRectMake(16,19,sw-70,21);
    changePwdLabel.numberOfLines = 0;
    [view2 addSubview:changePwdLabel];
    changePwdLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    changePwdLabel.text =  kJL_TXT("更改密码");
    changePwdLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);

    UIButton *changePwdBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-16-22,19,22,22)];
    [changePwdBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [view2 addSubview:changePwdBtn];
    view2.backgroundColor = [UIColor whiteColor];
    
    changeMobileView = [[ChangeMobileView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self.view addSubview:changeMobileView];
    changeMobileView.mobile = [JL_Tools getUserByKey:@"ACCOUNT_NUM"];
    changeMobileView.delegate = self;
    changeMobileView.hidden = YES;
    
    validationMobileView = [[ValidationMobileView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self.view addSubview:validationMobileView];
    validationMobileView.mobile = [JL_Tools getUserByKey:@"ACCOUNT_NUM"];
    validationMobileView.delegate = self;
    validationMobileView.hidden = YES;
    
    logoutAccountLabel = [[UILabel alloc] init];
    if([kJL_GET hasPrefix:@"zh"]){
        logoutAccountLabel.frame = CGRectMake(76,sh-20-42,150,20);
    }else{
        logoutAccountLabel.frame = CGRectMake(46,sh-20-42,250,20);
    }
    logoutAccountLabel.numberOfLines = 0;
    logoutAccountLabel.text = kJL_TXT("不想继续使用了");
    logoutAccountLabel.font =  [UIFont fontWithName:@"PingFangSC" size:13];
    logoutAccountLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [self.view addSubview:logoutAccountLabel];
    
    logoutAccountLabel2 = [[DFLabel alloc] init];
    logoutAccountLabel2.frame = CGRectMake(logoutAccountLabel.frame.origin.x+logoutAccountLabel.frame.size.width-8,sh-20-42,70,20);
    logoutAccountLabel2.numberOfLines = 0;
    logoutAccountLabel2.text = kJL_TXT("注销账号");
    logoutAccountLabel2.font =  [UIFont fontWithName:@"PingFangSC" size:13];
    logoutAccountLabel2.textColor = kDF_RGBA(85, 140, 255, 1.0);
    logoutAccountLabel2.labelType = DFLeftRight;
    logoutAccountLabel2.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:logoutAccountLabel2];
    
    UITapGestureRecognizer *logoutAccountGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoutAccountAction)];
    [logoutAccountLabel2 addGestureRecognizer:logoutAccountGestureRecognizer];
    logoutAccountLabel2.userInteractionEnabled = YES;
    
    logoutAccountView = [[LogoutAccountView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self.view addSubview:logoutAccountView];
    logoutAccountView.delegate = self;
    logoutAccountView.hidden = YES;
}

#pragma mark 修改手机号码
-(void)changeMobileAction{
    changeMobileView.hidden = NO;
}

#pragma mark 修改密码
-(void)changePwdAction{
    ChangePwdVC *vc = [[ChangePwdVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
}

#pragma mark 修改手机号弹窗取消
-(void)onChangeMobileCancel{
    
}

#pragma mark 修改手机号更换
-(void)onChangeMobileSure{
    validationMobileView.hidden = NO;
}

#pragma mark 身份验证取消
-(void)onValidationMobileCancel{
    
}

#pragma mark 身份验证确定
-(void)onValidationMobileSure{
    BindingNewPhoneVC *vc = [[BindingNewPhoneVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
}

- (IBAction)backAction:(UIButton *)sender {
    [self removeNote];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)modifySuccess:(NSNotification *)note{
    int code = [[note object] intValue];
    
    if(code == 1){ //修改手机号成功
        NSString *txt = nil;
        if(userWay == JLUSER_WAY_PHONE) txt = kJL_TXT("新手机号绑定成功");
        if(userWay == JLUSER_WAY_EMAIL) txt = kJL_TXT("新邮箱地址绑定成功!");
        
        [DFUITools showText:txt onView:self.view delay:1.5];
    }
    if(code ==2){ //修改新密码成功
        [DFUITools showText:kJL_TXT("新密码修改成功") onView:self.view delay:1.5];
    }
}

-(void)modifyPhoneNum:(NSNotification *)note{
    NSString *phoneNum = [note object];
    changeMobileLabel2.text = phoneNum;
    changeMobileView.mobile = phoneNum;
    validationMobileView.mobile = phoneNum;
}

-(void)onLogoutAccountCancel{
    
}

-(void)onLogoutAccountSure{
    [[User_Http shareInstance] deleteUserInfo:^(NSDictionary * _Nonnull info) {
        [JL_Tools mainTask:^{
            [self removeNote];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [JL_Tools post:@"LOGOUT" Object:nil];
        [JL_Tools removeUserByKey:@"ACCOUNT_NUM"];
        [JL_Tools removeUserByKey:@"accessToken"];
        [JL_Tools removeUserByKey:@"httpUserWay"];
        
        [self deleteDBFile];
        [UserProfile removeProfile];
    }];
}

-(void)deleteDBFile{
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    UserProfile *userPfInfo = [UserProfile locateProfile];
    if(userPfInfo){
        NSString *identify = userPfInfo.identify;
        
        NSString *deleteHealthPath = [NSString stringWithFormat:@"%@%@%@%@",pathDocuments,@"/",identify,@".db"];
        NSString *deleteUserDevicesPath = [NSString stringWithFormat:@"%@%@%@",pathDocuments,@"/",@"UserDevices.sqlite"];

        [fileManager removeItemAtPath:deleteHealthPath error:nil];
        [fileManager removeItemAtPath:deleteUserDevicesPath error:nil];
    }

}

-(void)logoutAccountAction{
    logoutAccountView.hidden = NO;
}

-(void)addNote{
    [JL_Tools add:@"CHANGE_PHONE_PWD" Action:@selector(modifySuccess:) Own:self];
    [JL_Tools add:@"CHANGE_PHONE_NUM" Action:@selector(modifyPhoneNum:) Own:self];
}

-(void)removeNote{
    [JL_Tools remove:@"CHANGE_PHONE_PWD" Own:self];
    [JL_Tools remove:@"CHANGE_PHONE_NUM" Own:self];
}

-(void)dealloc{
    [self removeNote];
}

@end
