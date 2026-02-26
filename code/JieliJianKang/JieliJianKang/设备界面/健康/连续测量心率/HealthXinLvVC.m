//
//  HealthXinLvVC.m
//  JieliJianKang
//
//  Created by 李放 on 2021/7/22.
//

#import "HealthXinLvVC.h"
#import "JL_RunSDK.h"

@interface HealthXinLvVC ()<JL_WatchProtocol>{
    __weak IBOutlet UIView *headView;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UISwitch *mSwitch;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    
    float sW;
    float sH;
    
    UIButton *sel1Btn; //智能心率测量
    UIButton *sel2Btn; //实时心率测量
    
    int currentType;
    BOOL switchState;
    
    UIView *contentView1;
    UIView *contentView2;
}

@end

@implementation HealthXinLvVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self addNote];
    [self requireDataFromDevice];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    titleHeight.constant = kJL_HeightNavBar;
    sW = [UIScreen mainScreen].bounds.size.width;
    sH = [UIScreen mainScreen].bounds.size.height;
    
    currentType = -1;
    
    headView.frame = CGRectMake(0, 0, sW, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("连续测量心率");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sW/2.0, kJL_HeightStatusBar+20);
    mSwitch.center = CGPointMake(sW-50, kJL_HeightStatusBar+20);
    mSwitch.bounds = CGRectMake(0, 0, 48, 26);
    
    UILabel *label = [[UILabel alloc] init];
    if([kJL_GET hasPrefix:@"zh"]){
        label.frame = CGRectMake(16,kJL_HeightStatusBar+44+15,150,20);
    }else{
        label.frame = CGRectMake(16,kJL_HeightStatusBar+44+15,260,20);
    }
    label.numberOfLines = 0;
    [self.view addSubview:label];
    label.text = kJL_TXT("心率测量方式");
    label.font = [UIFont fontWithName:@"PingFangSC" size: 14];
    label.textColor = kDF_RGBA(145, 145, 145, 1.0);
    label.textAlignment = NSTextAlignmentJustified;
    label.alpha = 1.0;
    
    UIView *contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(0,label.frame.origin.y+label.frame.size.height+15,sW,176);
    contentView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [self.view addSubview:contentView];
    
    contentView1 = [[UIView alloc] init];
    contentView1.frame = CGRectMake(0,0,sW,88);
    contentView1.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [contentView addSubview:contentView1];
    
    UITapGestureRecognizer *zhiNengGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zhiNengClick)];
    [contentView1 addGestureRecognizer:zhiNengGestureRecognizer];
    contentView1.userInteractionEnabled=YES;
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.frame = CGRectMake(16,16,80,21);
    label2.numberOfLines = 0;
    [contentView1 addSubview:label2];
    label2.text = kJL_TXT("智能");
    label2.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    label2.textColor = kDF_RGBA(36, 36, 36, 1.0);
    label2.textAlignment = NSTextAlignmentLeft;
    label2.alpha = 1.0;
    
    UILabel *label3 = [[UILabel alloc] init];
    label3.frame = CGRectMake(16,label2.frame.origin.y+2,contentView.frame.size.width-16-60,80);
    label3.numberOfLines = 2;
    [contentView1 addSubview:label3];
    label3.text = kJL_TXT("根据运动状态动态调整测量频率，24小时智能监测您的心率，有助于省电");
    label3.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
    label3.textColor = kDF_RGBA(145, 145, 145, 1.0);
    label3.textAlignment = NSTextAlignmentLeft;
    label3.alpha = 1.0;
    
    sel1Btn = [[UIButton alloc] initWithFrame:CGRectMake(sW-40,32,24,24)];
    [sel1Btn setImage:[UIImage imageNamed:@"icon_choose_nol"] forState:UIControlStateNormal];
    [contentView1 addSubview:sel1Btn];
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(16, 87, sW-32, 1)];
    [contentView addSubview:view1];
    view1.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    contentView2 = [[UIView alloc] init];
    contentView2.frame = CGRectMake(0,88,sW,88);
    contentView2.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [contentView addSubview:contentView2];
    
    UITapGestureRecognizer *shiShiGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shiShiClick)];
    [contentView2 addGestureRecognizer:shiShiGestureRecognizer];
    contentView2.userInteractionEnabled=YES;
    
    UILabel *label4 = [[UILabel alloc] init];
    label4.frame = CGRectMake(16,16,80,21);
    label4.numberOfLines = 0;
    [contentView2 addSubview:label4];
    label4.text = kJL_TXT("实时");
    label4.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    label4.textColor = kDF_RGBA(36, 36, 36, 1.0);
    label4.textAlignment = NSTextAlignmentLeft;
    label4.alpha = 1.0;
    
    UILabel *label5 = [[UILabel alloc] init];
    label5.frame = CGRectMake(16,label2.frame.origin.y+2,contentView.frame.size.width-16-60,80);
    label5.numberOfLines = 2;
    [contentView2 addSubview:label5];
    label5.text = kJL_TXT("24小时实时监测您的心率，心率数据更详细，刷新更及时，对功耗影响大");
    label5.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
    label5.textColor = kDF_RGBA(145, 145, 145, 1.0);
    label5.textAlignment = NSTextAlignmentLeft;
    label5.alpha = 1.0;
    
    sel2Btn = [[UIButton alloc] initWithFrame:CGRectMake(sW-40,32,24,24)];
    [sel2Btn setImage:[UIImage imageNamed:@"icon_choose_nol"] forState:UIControlStateNormal];
    [contentView2 addSubview:sel2Btn];
    sel2Btn.hidden = YES;
}

-(void)requireDataFromDevice{
    JLWearable *w = [JLWearable sharedInstance];
    [w w_addDelegate:self];
    
    [w w_InquireDeviceFuncWith:JL_WATCH_SETTING_CONTINUOUS_HEARTRATE_MEASUREMENT withEntity:kJL_BLE_EntityM];
}

-(void)zhiNengClick{
    currentType = 0;
    sel1Btn.hidden = NO;
    sel2Btn.hidden = YES;
    
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    JLConsequentHeartRateModel *model1 = [[JLConsequentHeartRateModel alloc] initWithModel:currentType Status:switchState];
    [models addObject:model1];
    
    JLWearable *w = [JLWearable sharedInstance];

    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
}

-(void)shiShiClick{
    currentType = 1;
    sel1Btn.hidden = YES;
    sel2Btn.hidden = NO;
    
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    JLConsequentHeartRateModel *model1 = [[JLConsequentHeartRateModel alloc] initWithModel:currentType Status:switchState];
    [models addObject:model1];
    
    JLWearable *w = [JLWearable sharedInstance];

    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
}

- (IBAction)actionSwitch:(UISwitch *)sender {
    switchState = sender.on;
    
    if(sender.on == NO){
        contentView1.userInteractionEnabled = NO;
        contentView2.userInteractionEnabled = NO;
        
        contentView1.alpha = 0.5;
        contentView2.alpha = 0.5;
    }
    if(sender.on == YES){
        contentView1.userInteractionEnabled = YES;
        contentView2.userInteractionEnabled = YES;
        
        contentView1.alpha = 1.0;
        contentView2.alpha = 1.0;
    }
    
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    JLConsequentHeartRateModel *model1 = [[JLConsequentHeartRateModel alloc] initWithModel:currentType Status:switchState];
    [models addObject:model1];
    
    JLWearable *w = [JLWearable sharedInstance];

    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
}

- (IBAction)actionExit:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/// 心率测量功能
/// @param model 心率模块
-(void)jlWatchSetConsequentHeartRate:(JLConsequentHeartRateModel *)model{
    switchState = model.status;
    currentType = model.rType;
    
    mSwitch.on = switchState;
    
    if(currentType ==0 ){
        sel1Btn.hidden = NO;
        sel2Btn.hidden = YES;
    }
    if(currentType == 1){
        sel1Btn.hidden = YES;
        sel2Btn.hidden = NO;
    }
    
    if(model.status == NO){
        contentView1.userInteractionEnabled = NO;
        contentView2.userInteractionEnabled = NO;
        
        contentView1.alpha = 0.5;
        contentView2.alpha = 0.5;
    }
    if(model.status == YES){
        contentView1.userInteractionEnabled = YES;
        contentView2.userInteractionEnabled = YES;
        
        contentView1.alpha = 1.0;
        contentView2.alpha = 1.0;
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
