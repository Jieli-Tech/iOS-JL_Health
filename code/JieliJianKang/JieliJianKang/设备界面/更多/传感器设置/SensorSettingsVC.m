//
//  SensorSettingsVC.m
//  JieliJianKang
//
//  Created by 李放 on 2021/10/11.
//

#import "SensorSettingsVC.h"

@interface SensorSettingsVC ()<JL_WatchProtocol>{
    __weak IBOutlet UIView *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    
    UIView *view1;   //计步传感器外部View
    UIView *view2;   //心率传感器外部View
    UIView *view3;   //海拔气压传感器外部View
    UIView *viewXue; //血氧传感器外部View

    UIView *view4; //计步传感器View
    UIView *viewJiBuCunChu; //数据记录存储View1
    
    UIView *view6; //心率传感器View
    UIView *viewXinLvCunChu; //数据记录存储View2
    
    UIView *viewXue1; //血氧传感器View
    UIView *viewXueYangCunChu; //数据记录存储View2

    UIView *view8; //海拔气压传感器View
    UIView *viewHaiBaCunChu; //数据记录存储View3
    
    UISwitch *switchJiBu;
    UISwitch *switchJiBuCunChu;
    UISwitch *switchXinLv;
    UISwitch *switchXinLvCunChu;
    UISwitch *switchXueYang;
    UISwitch *switchXueYangCunChu;
    UISwitch *switchHaiBa;
    UISwitch *switchHaiBaCunChu;
    
    JLSensorFuncModel *sensorFuncModel;
}

@end

@implementation SensorSettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self addNote];
    [self requireDataFromDevice];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    titleHeight.constant = kJL_HeightNavBar;
    float sw = [DFUITools screen_2_W];
    
    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("传感器设置");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    CGFloat height = kJL_HeightNavBar;
    
    view1 = [[UIView alloc] initWithFrame:CGRectMake(0, height+8, sw, 120)];
    [self.view addSubview:view1];
    view1.backgroundColor = [UIColor whiteColor];
    
    view4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, 60)];
    [view1 addSubview:view4];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(16,19,sw-60,21);
    label1.numberOfLines = 0;
    [view4 addSubview:label1];
    label1.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label1.text =  kJL_TXT("计步传感器");
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    switchJiBu = [[UISwitch alloc] initWithFrame:CGRectMake(sw-50-12, view4.frame.size.height/2-15, 50, 30)];
    switchJiBu.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
    [switchJiBu addTarget:self action:@selector(jibuAlert:) forControlEvents:UIControlEventValueChanged];
    [view4 addSubview:switchJiBu];
    
    UIView *fenge1 = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sw-32, 1)];
    [view4 addSubview:fenge1];
    fenge1.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
        
    viewJiBuCunChu = [[UIView alloc] initWithFrame:CGRectMake(0, 60, sw, 60)];
    [view1 addSubview:viewJiBuCunChu];
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.frame = CGRectMake(16,19,sw-60,21);
    label2.numberOfLines = 0;
    [viewJiBuCunChu addSubview:label2];
    label2.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label2.text =  kJL_TXT("数据记录存储");
    label2.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    switchJiBuCunChu= [[UISwitch alloc] initWithFrame:CGRectMake(sw-50-12, view4.frame.size.height/2-15, 50, 30)];
    switchJiBuCunChu.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
    [switchJiBuCunChu addTarget:self action:@selector(dataJiBuCunChu:) forControlEvents:UIControlEventValueChanged];
    [viewJiBuCunChu addSubview:switchJiBuCunChu];
        
    view2 = [[UIView alloc] initWithFrame:CGRectMake(0, view1.frame.origin.y+view1.frame.size.height+8, sw, 120)];
    [self.view addSubview:view2];
    view2.backgroundColor = [UIColor whiteColor];
    
    view6 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, 60)];
    [view2 addSubview:view6];
    
    UILabel *label3 = [[UILabel alloc] init];
    label3.frame = CGRectMake(16,19,sw-60,21);
    label3.numberOfLines = 0;
    [view6 addSubview:label3];
    label3.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label3.text =  kJL_TXT("心率传感器");
    label3.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    switchXinLv = [[UISwitch alloc] initWithFrame:CGRectMake(sw-50-12, view6.frame.size.height/2-15, 50, 30)];
    switchXinLv.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
    [switchXinLv addTarget:self action:@selector(xinlvAlert:) forControlEvents:UIControlEventValueChanged];
    [view6 addSubview:switchXinLv];
    
    UIView *fenge2 = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sw-32, 1)];
    [view6 addSubview:fenge2];
    fenge2.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    viewXinLvCunChu = [[UIView alloc] initWithFrame:CGRectMake(0, 60, sw, 60)];
    [view2 addSubview:viewXinLvCunChu];
    
    UILabel *label4 = [[UILabel alloc] init];
    label4.frame = CGRectMake(16,19,sw-60,21);
    label4.numberOfLines = 0;
    [viewXinLvCunChu addSubview:label4];
    label4.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label4.text =  kJL_TXT("数据记录存储");
    label4.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    switchXinLvCunChu = [[UISwitch alloc] initWithFrame:CGRectMake(sw-50-12, viewXinLvCunChu.frame.size.height/2-15, 50, 30)];
    switchXinLvCunChu.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
    [switchXinLvCunChu addTarget:self action:@selector(dataXinLvCunChu:) forControlEvents:UIControlEventValueChanged];
    [viewXinLvCunChu addSubview:switchXinLvCunChu];
    
    viewXue = [[UIView alloc] initWithFrame:CGRectMake(0, view2.frame.origin.y+view2.frame.size.height+8, sw, 120)];
    [self.view addSubview:viewXue];
    viewXue.backgroundColor = [UIColor whiteColor];
    
    viewXue1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, 60)];
    [viewXue addSubview:viewXue1];
    
    UILabel *labelXue = [[UILabel alloc] init];
    labelXue.frame = CGRectMake(16,19,sw-60,21);
    labelXue.numberOfLines = 0;
    [viewXue1 addSubview:labelXue];
    labelXue.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    labelXue.text =  kJL_TXT("血氧传感器");
    labelXue.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    switchXueYang = [[UISwitch alloc] initWithFrame:CGRectMake(sw-50-12, viewXue1.frame.size.height/2-15, 50, 30)];
    switchXueYang.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
    [switchXueYang addTarget:self action:@selector(xueYangAlert:) forControlEvents:UIControlEventValueChanged];
    [viewXue1 addSubview:switchXueYang];
    
    UIView *fengXue = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sw-32, 1)];
    [viewXue1 addSubview:fengXue];
    fengXue.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    viewXueYangCunChu = [[UIView alloc] initWithFrame:CGRectMake(0, 60, sw, 60)];
    [viewXue addSubview:viewXueYangCunChu];
    
    UILabel *labelXue2 = [[UILabel alloc] init];
    labelXue2.frame = CGRectMake(16,19,sw-60,21);
    labelXue2.numberOfLines = 0;
    [viewXueYangCunChu addSubview:labelXue2];
    labelXue2.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    labelXue2.text =  kJL_TXT("数据记录存储");
    labelXue2.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    switchXueYangCunChu = [[UISwitch alloc] initWithFrame:CGRectMake(sw-50-12, viewXueYangCunChu.frame.size.height/2-15, 50, 30)];
    switchXueYangCunChu.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
    [switchXueYangCunChu addTarget:self action:@selector(dataXueYangCunChu:) forControlEvents:UIControlEventValueChanged];
    [viewXueYangCunChu addSubview:switchXueYangCunChu];
    
    view3 = [[UIView alloc] initWithFrame:CGRectMake(0, viewXue.frame.origin.y+viewXue.frame.size.height+8, sw, 120)];
    [self.view addSubview:view3];
    view3.backgroundColor = [UIColor whiteColor];
    
    view8 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, 60)];
    [view3 addSubview:view8];
    
    UILabel *label5 = [[UILabel alloc] init];
    label5.frame = CGRectMake(16,19,sw-60,21);
    label5.numberOfLines = 0;
    [view8 addSubview:label5];
    label5.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label5.text =  kJL_TXT("海拔气压传感器");
    label5.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    switchHaiBa = [[UISwitch alloc] initWithFrame:CGRectMake(sw-50-12, view6.frame.size.height/2-15, 50, 30)];
    switchHaiBa.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
    [switchHaiBa addTarget:self action:@selector(haibaAlert:) forControlEvents:UIControlEventValueChanged];
    [view8 addSubview:switchHaiBa];
    
    UIView *fenge3 = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sw-32, 1)];
    [view8 addSubview:fenge3];
    fenge3.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    viewHaiBaCunChu = [[UIView alloc] initWithFrame:CGRectMake(0, 60, sw, 60)];
    [view3 addSubview:viewHaiBaCunChu];
    
    UILabel *label6 = [[UILabel alloc] init];
    label6.frame = CGRectMake(16,19,sw-60,21);
    label6.numberOfLines = 0;
    [viewHaiBaCunChu addSubview:label6];
    label6.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label6.text =  kJL_TXT("数据记录存储");
    label6.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    switchHaiBaCunChu = [[UISwitch alloc] initWithFrame:CGRectMake(sw-50-12, viewHaiBaCunChu.frame.size.height/2-15, 50, 30)];
    switchHaiBaCunChu.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
    [switchHaiBaCunChu addTarget:self action:@selector(dataHaibaCunChu:) forControlEvents:UIControlEventValueChanged];
    [viewHaiBaCunChu addSubview:switchHaiBaCunChu];
}

-(void)requireDataFromDevice{
    JLWearable *w = [JLWearable sharedInstance];
    [w w_addDelegate:self];
    

    [w w_InquireDeviceFuncWith:JL_WATCH_SETTING_SENSOR_FUNC withEntity:kJL_BLE_EntityM];
}

- (IBAction)backExit:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 设置计步传感器
-(void)jibuAlert:(UISwitch *)sender{
    if(sensorFuncModel == nil){
        return;
    }
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    sensorFuncModel.pedometerStatus = sender.on;
    [models addObject:sensorFuncModel];
    
    JLWearable *w = [JLWearable sharedInstance];

    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
        if(sender.on == NO){
            self->switchJiBuCunChu.on = NO;
            self->viewJiBuCunChu.userInteractionEnabled = NO;
            self->viewJiBuCunChu.alpha = 0.5;
        }else{
            self->viewJiBuCunChu.userInteractionEnabled = YES;
            self->viewJiBuCunChu.alpha = 1.0;
        }
        
        NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
        self->sensorFuncModel.pedometerRecordStatus = self->switchJiBuCunChu.on;
        [models addObject:self->sensorFuncModel];
        
        JLWearable *w = [JLWearable sharedInstance];

        [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
        }];
    }];
}

#pragma mark 计步器数据记录存储
-(void)dataJiBuCunChu:(UISwitch *)sender{
    if(sensorFuncModel == nil){
        return;
    }
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    sensorFuncModel.pedometerRecordStatus = sender.on;
    [models addObject:sensorFuncModel];
    
    JLWearable *w = [JLWearable sharedInstance];

    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
}

#pragma mark 设置心率传感器
-(void)xinlvAlert:(UISwitch *)sender{
    if(sensorFuncModel == nil){
        return;
    }
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    sensorFuncModel.heartRateStatus = sender.on;
    [models addObject:sensorFuncModel];
    
    JLWearable *w = [JLWearable sharedInstance];

    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
        if(sender.on == NO){
            self->switchXinLvCunChu.on = NO;
            self->viewXinLvCunChu.userInteractionEnabled = NO;
            self->viewXinLvCunChu.alpha = 0.5;
        }else{
            self->viewXinLvCunChu.userInteractionEnabled = YES;
            self->viewXinLvCunChu.alpha = 1.0;
        }
        
        NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
        self->sensorFuncModel.heartRateRecordStatus = self->switchXinLvCunChu.on;
        [models addObject:self->sensorFuncModel];
        
        JLWearable *w = [JLWearable sharedInstance];

        [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
        }];
    }];
}

#pragma mark 心率数据记录存储
-(void)dataXinLvCunChu:(UISwitch *)sender{
    if(sensorFuncModel == nil){
        return;
    }
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    sensorFuncModel.heartRateRecordStatus = sender.on;
    [models addObject:sensorFuncModel];
    
    JLWearable *w = [JLWearable sharedInstance];

    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
}

#pragma mark 设置血氧传感器
-(void)xueYangAlert:(UISwitch *)sender{
    if(sensorFuncModel == nil){
        return;
    }
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    sensorFuncModel.bloodOxygenStatus = sender.on;
    [models addObject:sensorFuncModel];
    
    JLWearable *w = [JLWearable sharedInstance];

    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
        if(sender.on == NO){
            self->switchXueYangCunChu.on = NO;
            self->viewXueYangCunChu.userInteractionEnabled = NO;
            self->viewXueYangCunChu.alpha = 0.5;
        }else{
            self->viewXueYangCunChu.userInteractionEnabled = YES;
            self->viewXueYangCunChu.alpha = 1.0;
        }
        
        NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
        self->sensorFuncModel.bloodOxygenRecordStatus = self->switchXueYangCunChu.on;
        [models addObject:self->sensorFuncModel];
        
        JLWearable *w = [JLWearable sharedInstance];

        [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
        }];
    }];
}

#pragma mark 血氧数据记录存储
-(void)dataXueYangCunChu:(UISwitch *)sender{
    if(sensorFuncModel == nil){
        return;
    }
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    sensorFuncModel.bloodOxygenRecordStatus = sender.on;
    [models addObject:sensorFuncModel];
    
    JLWearable *w = [JLWearable sharedInstance];

    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
}

#pragma mark 设置海拔传感器
-(void)haibaAlert:(UISwitch *)sender{
    if(sensorFuncModel == nil){
        return;
    }
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    sensorFuncModel.AltitudeAirPressureStatus = sender.on;
    [models addObject:sensorFuncModel];
    
    JLWearable *w = [JLWearable sharedInstance];

    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
        if(sender.on == NO){
            self->switchHaiBaCunChu.on = NO;
            self->viewHaiBaCunChu.userInteractionEnabled = NO;
            self->viewHaiBaCunChu.alpha = 0.5;
        }else{
            self->viewHaiBaCunChu.userInteractionEnabled = YES;
            self->viewHaiBaCunChu.alpha = 1.0;
        }
        
        NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
        self->sensorFuncModel.AltitudeAirPressureRecordStatus = self->switchHaiBaCunChu.on;
        [models addObject:self->sensorFuncModel];
        
        JLWearable *w = [JLWearable sharedInstance];

        [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
        }];
    }];
}

#pragma mark 海拔数据记录存储
-(void)dataHaibaCunChu:(UISwitch *)sender{
    if(sensorFuncModel == nil){
        return;
    }
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    sensorFuncModel.AltitudeAirPressureRecordStatus = sender.on;
    [models addObject:sensorFuncModel];
    
    JLWearable *w = [JLWearable sharedInstance];

    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
}

#pragma mark 回调传感器相关设置
-(void)jlWatchSetSensorFunc:(JLSensorFuncModel *)model{
    sensorFuncModel = model;
    
    switchJiBu.on = model.pedometerStatus;
    switchJiBuCunChu.on = model.pedometerRecordStatus;
    switchXinLv.on = model.heartRateStatus;
    switchXinLvCunChu.on = model.heartRateRecordStatus;
    switchXueYang.on = model.bloodOxygenStatus;
    switchXueYangCunChu.on = model.bloodOxygenRecordStatus;
    switchHaiBa.on = model.AltitudeAirPressureStatus;
    switchHaiBaCunChu.on = model.AltitudeAirPressureRecordStatus;
    
    //计步
    if(switchJiBu.on == NO){
        [viewJiBuCunChu setUserInteractionEnabled:NO];
        viewJiBuCunChu.alpha = 0.5;
    }
    if(switchJiBu.on == YES){
        [viewJiBuCunChu setUserInteractionEnabled:YES];
        viewJiBuCunChu.alpha = 1.0;
    }
    
    //心率
    if(switchXinLv.on == NO){
        [viewXinLvCunChu setUserInteractionEnabled:NO];
        viewXinLvCunChu.alpha = 0.5;
    }
    if(switchXinLv.on == YES){
        [viewXinLvCunChu setUserInteractionEnabled:YES];
        viewXinLvCunChu.alpha = 1.0;
    }
    
    //血氧
    if(switchXueYang.on == NO){
        [viewXueYangCunChu setUserInteractionEnabled:NO];
        viewXueYangCunChu.alpha = 0.5;
    }
    if(switchXueYang.on == YES){
        [viewXueYangCunChu setUserInteractionEnabled:YES];
        viewXueYangCunChu.alpha = 1.0;
    }
    
    //海拔
    if(switchHaiBa.on == NO){
        [viewHaiBaCunChu setUserInteractionEnabled:NO];
        viewHaiBaCunChu.alpha = 0.5;
    }
    if(switchHaiBa.on == YES){
        [viewHaiBaCunChu setUserInteractionEnabled:YES];
        viewHaiBaCunChu.alpha = 1.0;
    }
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
