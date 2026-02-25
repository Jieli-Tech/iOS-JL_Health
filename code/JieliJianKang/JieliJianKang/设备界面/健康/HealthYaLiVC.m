//
//  HealthYaLiVC.m
//  JieliJianKang
//
//  Created by 李放 on 2021/7/22.
//

#import "HealthYaLiVC.h"
#import "JL_RunSDK.h"

@interface HealthYaLiVC ()<JL_WatchProtocol>{
    
    __weak IBOutlet UIView *headView;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UISwitch *mSwitch;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    
    float sW;
    float sH;
    
    UIView *viewContent; //放松、正常、中等、偏高(建议合理管控压力)的内容View
    UIView *view1;       //放松
    UIView *view2;       //正常
    UIView *view3;       //中等
    UIView *view4;       //偏高，建议合理管控压力
}

@end

@implementation HealthYaLiVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self addNote];
    [self requireDataFromDevice];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    
    sW = [DFUITools screen_2_W];
    sH = [DFUITools screen_2_H];
    
    titleHeight.constant = kJL_HeightNavBar;
    
    headView.frame = CGRectMake(0, 0, sW, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("压力自动检测");
    
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sW/2.0, kJL_HeightStatusBar+20);
    
    mSwitch.center = CGPointMake(sW-50, kJL_HeightStatusBar+20);
    mSwitch.bounds = CGRectMake(0, 0, 48, 26);
    
    CGFloat height = kJL_HeightNavBar;
    
    viewContent = [[UIView alloc] initWithFrame:CGRectMake(0, height+8, sW, 240)];
    [self.view addSubview:viewContent];
    viewContent.backgroundColor = [UIColor whiteColor];
    
    //放松
    view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sW, 60)];
    [viewContent addSubview:view1];
    
    UIView *viewCircle1 = [[UIView alloc] init];
    viewCircle1.frame = CGRectMake(16,27,6,6);
    viewCircle1.layer.backgroundColor = kDF_RGBA(150,197,218,1.0).CGColor;
    viewCircle1.layer.cornerRadius = 3;
    [view1 addSubview:viewCircle1];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(42,19,sW-22,21);
    label1.numberOfLines = 0;
    [view1 addSubview:label1];
    label1.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label1.text =  kJL_TXT("放松");
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.frame = CGRectMake(sW-22-34,21,50,21);
    label2.numberOfLines = 0;
    [view1 addSubview:label2];
    label2.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label2.text =  @"1-29";
    label2.textColor = kDF_RGBA(88, 88, 88, 1.0);
    
    UIView *viewline1 = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sW-32, 1)];
    [view1 addSubview:viewline1];
    viewline1.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    //正常
    view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 60, sW, 60)];
    [viewContent addSubview:view2];
    
    UIView *viewCircle2 = [[UIView alloc] init];
    viewCircle2.frame = CGRectMake(16,27,6,6);
    viewCircle2.layer.backgroundColor =  kDF_RGBA(123,208,131,1.0).CGColor;
    viewCircle2.layer.cornerRadius = 3;
    [view2 addSubview:viewCircle2];
    
    UILabel *label3 = [[UILabel alloc] init];
    label3.frame = CGRectMake(42,19,sW-22,21);
    label3.numberOfLines = 0;
    [view2 addSubview:label3];
    label3.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label3.text =  kJL_TXT("正常");
    label3.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UILabel *label4 = [[UILabel alloc] init];
    label4.frame = CGRectMake(sW-22-45,21,50,21);
    label4.numberOfLines = 0;
    [view2 addSubview:label4];
    label4.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label4.text =  @"30-59";
    label4.textColor = kDF_RGBA(88, 88, 88, 1.0);
    
    UIView *viewline2 = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sW-32, 1)];
    [view2 addSubview:viewline2];
    viewline2.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    //中等
    view3 = [[UIView alloc] initWithFrame:CGRectMake(0, 120, sW, 60)];
    [viewContent addSubview:view3];
    
    UIView *viewCircle3 = [[UIView alloc] init];
    viewCircle3.frame = CGRectMake(16,27,6,6);
    viewCircle3.layer.backgroundColor =  kDF_RGBA(243,198,165,1.0).CGColor;
    viewCircle3.layer.cornerRadius = 3;
    [view3 addSubview:viewCircle3];
    
    UILabel *label5 = [[UILabel alloc] init];
    label5.frame = CGRectMake(42,19,sW-22,21);
    label5.numberOfLines = 0;
    [view3 addSubview:label5];
    label5.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label5.text =  kJL_TXT("中等");
    label5.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UILabel *label6 = [[UILabel alloc] init];
    label6.frame = CGRectMake(sW-22-45,21,50,21);
    label6.numberOfLines = 0;
    [view3 addSubview:label6];
    label6.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label6.text =  @"60-79";
    label6.textColor = kDF_RGBA(88, 88, 88, 1.0);
    
    UIView *viewline3 = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sW-32, 1)];
    [view3 addSubview:viewline3];
    viewline3.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    //偏高，建议合理管控压力
    view4 = [[UIView alloc] initWithFrame:CGRectMake(0, 180, sW, 60)];
    [viewContent addSubview:view4];
    
    UIView *viewCircle4 = [[UIView alloc] init];
    viewCircle4.frame = CGRectMake(16,27,6,6);
    viewCircle4.layer.backgroundColor = kDF_RGBA(215,119,119,1.0).CGColor;
    viewCircle4.layer.cornerRadius = 3;
    [view4 addSubview:viewCircle4];
    
    UILabel *label7 = [[UILabel alloc] init];
    label7.frame = CGRectMake(42,19,sW-22,21);
    label7.numberOfLines = 0;
    [view4 addSubview:label7];
    label7.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label7.text =  kJL_TXT("偏高");
    label7.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UILabel *label8 = [[UILabel alloc] init];
    label8.frame = CGRectMake(sW-22-45,21,50,21);
    label8.numberOfLines = 0;
    [view4 addSubview:label8];
    label8.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label8.text =  @"80-99";
    label8.textColor = kDF_RGBA(88, 88, 88, 1.0);
    
    UILabel *label9 = [[UILabel alloc] init];
    label9.frame = CGRectMake(21,viewContent.frame.origin.y+viewContent.frame.size.height+10,sW-2*21,68);
    label9.numberOfLines = 3;
    [self.view addSubview:label9];
    label9.font =  [UIFont fontWithName:@"PingFang SC" size: 12];
    label9.text =  kJL_TXT("压力检测");
    label9.textColor = kDF_RGBA(145, 145, 145, 1.0);
}

-(void)requireDataFromDevice{
    JLWearable *w = [JLWearable sharedInstance];
    [w w_addDelegate:self];
    
    [w w_InquireDeviceFuncWith:JL_WATCH_SETTING_AUTOMATIC_PRESSURE_DETECTION withEntity:kJL_BLE_EntityM];
}

- (IBAction)actionExit:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionYaliSwtich:(UISwitch *)sender {
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    
    JLAutoPressureModel *model1 =  [[JLAutoPressureModel alloc] initWithModel:0x00 switchStatus:sender.on];
    [models addObject:model1];
    
    JLWearable *w = [JLWearable sharedInstance];

    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
}

#pragma mark 自动压力测试
-(void)jlWatchSetAutoPressure:(JLAutoPressureModel *)model{
    mSwitch.on = model.status;
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
