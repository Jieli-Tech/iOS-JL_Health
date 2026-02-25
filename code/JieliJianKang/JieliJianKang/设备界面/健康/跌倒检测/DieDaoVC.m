//
//  DieDaoVC.m
//  JieliJianKang
//
//  Created by 李放 on 2021/10/26.
//

#import "DieDaoVC.h"
#import "EmergencyContactsVC.h"

@interface DieDaoVC ()<JL_WatchProtocol>{
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet UIButton *exitBtn;
    __weak IBOutlet UIView *headView;
    __weak IBOutlet UISwitch *switch1;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    
    float sW;
    float sH;
    
    UIView *view1; //跌倒响应操作的view
    UIView *view2; //跌倒的紧急联系人的view
    
    UIButton *sel1Btn; //亮屏
    UIButton *sel2Btn; //震动
    UIButton *sel3Btn; //电话呼叫
    
    UILabel *contactsPhoneLabel;
    
    int currentType;
}

@end

@implementation DieDaoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self addNote];
}

-(void)viewWillAppear:(BOOL)animated{
    [self requireDataFromDevice];
}

-(void)requireDataFromDevice{
    JLWearable *w = [JLWearable sharedInstance];
    [w w_addDelegate:self];
    
    [w w_InquireDeviceFuncWith:JL_WATCH_SETTING_FALL_DETECTION withEntity:kJL_BLE_EntityM];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    titleHeight.constant = kJL_HeightNavBar;
    currentType = -1;
    
    sW = [DFUITools screen_2_W];
    sH = [DFUITools screen_2_H];
    
    headView.frame = CGRectMake(0, 0, sW, kJL_HeightStatusBar+44);
    exitBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("跌倒检测");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sW/2.0, kJL_HeightStatusBar+20);
    switch1.center = CGPointMake(sW-50, kJL_HeightStatusBar+20);
    switch1.bounds = CGRectMake(0, 0, 48, 26);
    
    CGFloat height = kJL_HeightNavBar;
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(16,height+15,sW-16,20);
    label1.numberOfLines = 0;
    [self.view addSubview:label1];
    label1.font =  [UIFont fontWithName:@"PingFang SC" size: 14];
    label1.text =  kJL_TXT("跌倒响应方式");
    label1.textColor = kDF_RGBA(145, 145, 145, 1.0);
    
    view1 = [[UIView alloc] init];
    view1.frame = CGRectMake(0,label1.frame.size.height+label1.frame.origin.y+15,sW,180);
    view1.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [self.view addSubview:view1];
    
    UIView *contentView1 = [[UIView alloc] init];
    contentView1.frame = CGRectMake(0,0,sW,60);
    contentView1.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [view1 addSubview:contentView1];
    
    UITapGestureRecognizer *liangPingGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(liangPingAction)];
    [contentView1 addGestureRecognizer:liangPingGestureRecognizer];
    contentView1.userInteractionEnabled=YES;
    
    UILabel *liangPingLabel = [[UILabel alloc] init];
    liangPingLabel.frame = CGRectMake(16,19,sW-16,21);
    liangPingLabel.numberOfLines = 0;
    [contentView1 addSubview:liangPingLabel];
    liangPingLabel.text = kJL_TXT("亮屏");
    liangPingLabel.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    liangPingLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    liangPingLabel.textAlignment = NSTextAlignmentLeft;
    
    sel1Btn = [[UIButton alloc] initWithFrame:CGRectMake(sW-40,18,24,24)];
    [sel1Btn setImage:[UIImage imageNamed:@"icon_choose_nol"] forState:UIControlStateNormal];
    [contentView1 addSubview:sel1Btn];
    sel1Btn.hidden = YES;
    
    UIView *viewline1 = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sW-32, 1)];
    [contentView1 addSubview:viewline1];
    viewline1.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    UIView *contentView2 = [[UIView alloc] init];
    contentView2.frame = CGRectMake(0,60,sW,60);
    contentView2.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [view1 addSubview:contentView2];
    
    UITapGestureRecognizer *zhengDongGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zhengDongAction)];
    [contentView2 addGestureRecognizer:zhengDongGestureRecognizer];
    contentView2.userInteractionEnabled=YES;
    
    UILabel *zhenDongLabel = [[UILabel alloc] init];
    zhenDongLabel.frame = CGRectMake(16,19,sW-16,21);
    zhenDongLabel.numberOfLines = 0;
    [contentView2 addSubview:zhenDongLabel];
    zhenDongLabel.text = kJL_TXT("震动");
    zhenDongLabel.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    zhenDongLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    zhenDongLabel.textAlignment = NSTextAlignmentLeft;
    
    sel2Btn = [[UIButton alloc] initWithFrame:CGRectMake(sW-40,18,24,24)];
    [sel2Btn setImage:[UIImage imageNamed:@"icon_choose_nol"] forState:UIControlStateNormal];
    [contentView2 addSubview:sel2Btn];
    sel2Btn.hidden = YES;
    
    UIView *viewline2 = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sW-32, 1)];
    [contentView2 addSubview:viewline2];
    viewline2.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    UIView *contentView3 = [[UIView alloc] init];
    contentView3.frame = CGRectMake(0,120,sW,60);
    contentView3.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [view1 addSubview:contentView3];
    
    UITapGestureRecognizer *callPhoneGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(phoneCallAction)];
    [contentView3 addGestureRecognizer:callPhoneGestureRecognizer];
    contentView3.userInteractionEnabled=YES;
    
    UILabel *phoneCallLabel = [[UILabel alloc] init];
    phoneCallLabel.frame = CGRectMake(16,19,sW-16,21);
    phoneCallLabel.numberOfLines = 0;
    [contentView3 addSubview:phoneCallLabel];
    phoneCallLabel.text = kJL_TXT("电话呼叫");
    phoneCallLabel.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    phoneCallLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    phoneCallLabel.textAlignment = NSTextAlignmentLeft;
    
    sel3Btn = [[UIButton alloc] initWithFrame:CGRectMake(sW-40,18,24,24)];
    [sel3Btn setImage:[UIImage imageNamed:@"icon_choose_nol"] forState:UIControlStateNormal];
    [contentView3 addSubview:sel3Btn];
    sel3Btn.hidden = YES;
    
    view2 = [[UIView alloc] init];
    view2.frame = CGRectMake(0,view1.frame.size.height+view1.frame.origin.y+8,sW,88);
    view2.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [self.view addSubview:view2];
    
    UITapGestureRecognizer *contactsGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emergencyContactsAction)];
    [view2 addGestureRecognizer:contactsGestureRecognizer];
    view2.userInteractionEnabled=YES;
    
    DFLabel *contactsLabel = [[DFLabel alloc] init];
    contactsLabel.frame = CGRectMake(16,13,230,21);
    contactsLabel.numberOfLines = 0;
    [view2 addSubview:contactsLabel];
    contactsLabel.labelType = DFLeftRight;
    contactsLabel.textAlignment = NSTextAlignmentLeft;
    contactsLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    contactsLabel.text =  kJL_TXT("紧急联系人");
    contactsLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    DFLabel *contactsLabel2 = [[DFLabel alloc] initWithFrame:CGRectMake(16, 36, sW-60, 17)];
    contactsLabel2.font =  [UIFont fontWithName:@"PingFang SC" size: 12];
    contactsLabel2.text =  kJL_TXT("当跌倒时自动电话呼叫紧急联系人");
    contactsLabel2.labelType = DFLeftRight;
    contactsLabel2.textAlignment = NSTextAlignmentLeft;
    contactsLabel2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    [view2 addSubview:contactsLabel2];
    
    UIButton *contactsBtn = [[UIButton alloc] initWithFrame:CGRectMake(sW-16-22,19,22,22)];
    [contactsBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [view2 addSubview:contactsBtn];
    view2.backgroundColor = [UIColor whiteColor];
    
    contactsPhoneLabel = [[UILabel alloc] init];
    contactsPhoneLabel.frame = CGRectMake(sW-16-22-75,21,100,18);
    contactsPhoneLabel.numberOfLines = 0;
    [view2 addSubview:contactsPhoneLabel];
    contactsPhoneLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 13];
    contactsPhoneLabel.textColor = kDF_RGBA(145, 145, 145, 1.0);
}

- (IBAction)actionSwitch:(UISwitch *)sender {
    switch1.on = sender.on;
    
    [self sendDataToDevice];
    
    if(sender.on == NO){
        view1.userInteractionEnabled = NO;
        view2.userInteractionEnabled = NO;
        
        view1.alpha = 0.5;
        view2.alpha = 0.5;
    }
    if(sender.on == YES){
        view1.userInteractionEnabled = YES;
        view2.userInteractionEnabled = YES;
        
        view1.alpha = 1.0;
        view2.alpha = 1.0;
    }
}

- (IBAction)exitAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 亮屏操作
-(void)liangPingAction{
    currentType = 0;
    
    sel1Btn.hidden = NO;
    sel2Btn.hidden = YES;
    sel3Btn.hidden = YES;
    
    [self sendDataToDevice];
}

#pragma mark 震动操作
-(void)zhengDongAction{
    currentType = 1;
    
    sel1Btn.hidden = YES;
    sel2Btn.hidden = NO;
    sel3Btn.hidden = YES;
    
    [self sendDataToDevice];
}

#pragma mark 电话呼叫操作
-(void)phoneCallAction{
    currentType = 2;

    sel1Btn.hidden = YES;
    sel2Btn.hidden = YES;
    sel3Btn.hidden = NO;
    
    [self sendDataToDevice];
}

#pragma mark 进入紧急联系人界面
-(void)emergencyContactsAction{
    EmergencyContactsVC *vc = [[EmergencyContactsVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.type = currentType;
    vc.state = switch1.on;
    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
}

#pragma mark 跌倒检测
-(void)jlWatchSetFallDetectionModel:(JLFallDetectionModel *)model{
    switch1.on = model.status;
    
    if(model.status == NO){
        view1.userInteractionEnabled = NO;
        view2.userInteractionEnabled = NO;
        
        view1.alpha = 0.5;
        view2.alpha = 0.5;
    }
    if(model.status == YES){
        view1.userInteractionEnabled = YES;
        view2.userInteractionEnabled = YES;
        
        view1.alpha = 1.0;
        view2.alpha = 1.0;
    }
    
    currentType = model.rType;
    if(currentType == WatchRemind_BrightScreen){
        sel1Btn.hidden = NO;
        sel2Btn.hidden = YES;
        sel3Btn.hidden = YES;
    }
    if(currentType == WatchRemind_Shake){
        sel1Btn.hidden = YES;
        sel2Btn.hidden = NO;
        sel3Btn.hidden = YES;
    }
    if(currentType == WatchRemind_Call){
        sel1Btn.hidden = YES;
        sel2Btn.hidden = YES;
        sel3Btn.hidden = NO;
    }
    if(model.phoneNumber.length == 0){
        NSString *phoneStr = [JL_Tools getUserByKey:@"ACCOUNT_NUM"];
        contactsPhoneLabel.text = phoneStr;
    }else{
        contactsPhoneLabel.text = model.phoneNumber;
    }
}

#pragma mark 发送数据给设备端
-(void)sendDataToDevice{
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];

    NSString *phoneStr;
    if([contactsPhoneLabel.text isEqualToString:kJL_TXT("未设置")]){
        phoneStr = @"";
    }else{
        phoneStr = contactsPhoneLabel.text;
    }
    JLFallDetectionModel *model1 = [[JLFallDetectionModel alloc] initWithModel:currentType Status:switch1.on phoneNumber:phoneStr];
    [models addObject:model1];
    
    JLWearable *w = [JLWearable sharedInstance];
    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline || tp == JLDeviceChangeTypeBleOFF) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)removeNote{
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

-(void)dealloc{
    [self removeNote];
}

@end
