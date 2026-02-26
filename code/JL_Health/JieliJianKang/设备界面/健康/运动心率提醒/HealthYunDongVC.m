//
//  HealthYunDongVC.m
//  JieliJianKang
//
//  Created by 李放 on 2021/7/22.
//

#import "HealthYunDongVC.h"
#import "JL_RunSDK.h"
#import "XinLvView.h"

@interface HealthYunDongVC ()<XinLvDelegate,JL_WatchProtocol>{
    __weak IBOutlet UIView *headView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    
    float sW;
    float sH;
    
    UIView *contentView;
    UIView *xinLvAreaView;
    
    UIView *view1;
    UIView *view2;
    
    UILabel *xinLvLabel;
    
    XinLvView *xinLvView;
    
    NSString *mXinLv;
    
    UIButton *sel1Btn; //最大心率百分比
    UIButton *sel2Btn; //储备心率百分比
    
    int currentType;
    
    UISwitch *swtich1;
    
    UIView *contentView1;
    UIView *contentView2;
    
    UILabel *labelSport; //运动心率
}
@end

@implementation HealthYunDongVC

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
    
    headView.frame = CGRectMake(0, 0, sW, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("运动心率提醒");
    if([kJL_GET hasPrefix:@"zh"] || [kJL_GET hasPrefix:@"en-GB"]){ 
        titleName.bounds = CGRectMake(0, 0, 200, 20);
        titleName.center = CGPointMake(sW/2.0, kJL_HeightStatusBar+20);
    }else{
        titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
        titleName.center = CGPointMake(sW/2.0+5, kJL_HeightStatusBar+20);
    }
    
    contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(0,kJL_HeightStatusBar+44+8,sW,128);
    contentView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [self.view addSubview:contentView];
    
    view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sW, 64)];
    [contentView addSubview:view1];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(16,13,sW-60,21);
    label1.numberOfLines = 0;
    [view1 addSubview:label1];
    label1.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label1.text =  kJL_TXT("心率上限预警");
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    labelSport = [[UILabel alloc] initWithFrame:CGRectMake(16, 36, sW-60, 17)];
    labelSport.font =  [UIFont fontWithName:@"PingFang SC" size: 12];
    labelSport.textColor = kDF_RGBA(145, 145, 145, 1.0);
    [view1 addSubview:labelSport];
    
    swtich1 = [[UISwitch alloc] initWithFrame:CGRectMake(sW-50-12, view1.frame.size.height/2-15, 50, 30)];
    swtich1.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
    [swtich1 addTarget:self action:@selector(settingsXinLvAlert:) forControlEvents:UIControlEventValueChanged];
    [view1 addSubview:swtich1];
    view1.backgroundColor = [UIColor whiteColor];
    
    UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(16, 63, sW-32, 1)];
    [contentView addSubview:viewLine];
    viewLine.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 64, sW, 64)];
    [contentView addSubview:view2];
    
    UITapGestureRecognizer *view2GestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterXinLvSettingAlertView)];
    [view2 addGestureRecognizer:view2GestureRecognizer];
    view2.userInteractionEnabled=YES;
    
    DFLabel *label3 = [[DFLabel alloc] init];
    label3.frame = CGRectMake(16,19,sW/2,21);
    label3.numberOfLines = 0;
    [view2 addSubview:label3];
    label3.labelType = DFLeftRight;
    label3.textAlignment = NSTextAlignmentLeft;
    label3.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label3.text =  kJL_TXT("心率上限");
    label3.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(sW-16-22,19,22,22)];
    [btn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [view2 addSubview:btn];
    view2.backgroundColor = [UIColor whiteColor];
    
    xinLvLabel = [[UILabel alloc] init];
    xinLvLabel.numberOfLines = 0;
    [view2 addSubview:xinLvLabel];
    xinLvLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 13];
    xinLvLabel.textColor = kDF_RGBA(145, 145, 145, 1.0);
    
    UILabel *xinLvAreaLabel = [[UILabel alloc] init];
    xinLvAreaLabel.frame = CGRectMake(16,contentView.frame.origin.y+contentView.frame.size.height+15,sW-20,21);
    xinLvAreaLabel.numberOfLines = 0;
    [self.view addSubview:xinLvAreaLabel];
    xinLvAreaLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 14];
    xinLvAreaLabel.text =  kJL_TXT("心率区间划分方式");
    xinLvAreaLabel.textColor = kDF_RGBA(145, 145, 145, 1.0);
    xinLvAreaLabel.alpha = 1.0;
    
    xinLvAreaView = [[UIView alloc] init];
    xinLvAreaView.frame = CGRectMake(0,xinLvAreaLabel.frame.origin.y+xinLvAreaLabel.frame.size.height+15,sW,120);
    xinLvAreaView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [self.view addSubview:xinLvAreaView];
    xinLvAreaView.alpha = 1.0;
    
    contentView1 = [[UIView alloc] init];
    contentView1.frame = CGRectMake(0,0,sW,60);
    contentView1.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [xinLvAreaView addSubview:contentView1];
    
    UITapGestureRecognizer *maxXinlvGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maxXinLvClick)];
    [contentView1 addGestureRecognizer:maxXinlvGestureRecognizer];
    contentView1.userInteractionEnabled=YES;
    
    UILabel *xinLvAreaLabelMax = [[UILabel alloc] init];
    xinLvAreaLabelMax.frame = CGRectMake(16,19,sW-16,21);
    xinLvAreaLabelMax.numberOfLines = 0;
    [contentView1 addSubview:xinLvAreaLabelMax];
    xinLvAreaLabelMax.text = kJL_TXT("最大心率百分比");
    xinLvAreaLabelMax.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    xinLvAreaLabelMax.textColor = kDF_RGBA(36, 36, 36, 1.0);
    xinLvAreaLabelMax.textAlignment = NSTextAlignmentLeft;
    
    sel1Btn = [[UIButton alloc] initWithFrame:CGRectMake(sW-40,18,24,24)];
    [sel1Btn setImage:[UIImage imageNamed:@"icon_choose_nol"] forState:UIControlStateNormal];
    [contentView1 addSubview:sel1Btn];
    sel1Btn.hidden = YES;
    
    UIView *viewline1 = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sW-32, 1)];
    [contentView1 addSubview:viewline1];
    viewline1.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    contentView2 = [[UIView alloc] init];
    contentView2.frame = CGRectMake(0,60,sW,60);
    contentView2.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [xinLvAreaView addSubview:contentView2];
    
    UITapGestureRecognizer *chuBeiGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chuBeiXinLvClick)];
    [contentView2 addGestureRecognizer:chuBeiGestureRecognizer];
    contentView2.userInteractionEnabled=YES;
    
    UILabel *xinLvAreaLabelCunChu = [[UILabel alloc] init];
    xinLvAreaLabelCunChu.frame = CGRectMake(16,19,sW-16,21);
    xinLvAreaLabelCunChu.numberOfLines = 0;
    [contentView2 addSubview:xinLvAreaLabelCunChu];
    xinLvAreaLabelCunChu.text = kJL_TXT("储备心率百分比");
    xinLvAreaLabelCunChu.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    xinLvAreaLabelCunChu.textColor = kDF_RGBA(36, 36, 36, 1.0);
    xinLvAreaLabelCunChu.textAlignment = NSTextAlignmentLeft;
    
    sel2Btn = [[UIButton alloc] initWithFrame:CGRectMake(sW-40,18,24,24)];
    [sel2Btn setImage:[UIImage imageNamed:@"icon_choose_nol"] forState:UIControlStateNormal];
    [contentView2 addSubview:sel2Btn];
    sel2Btn.hidden = YES;
    
    xinLvView = [[XinLvView alloc] initWithFrame:CGRectMake(0, 0, sW, sH)];
    [self.view addSubview:xinLvView];
    xinLvView.delegate = self;
    xinLvView.hidden = YES;
}

-(void)requireDataFromDevice{
    JLWearable *w = [JLWearable sharedInstance];
    [w w_addDelegate:self];
    
    [w w_InquireDeviceFuncWith:JL_WATCH_SETTING_EXERCISE_HEARTRATE_REMINDER withEntity:kJL_BLE_EntityM];
}

-(void)maxXinLvClick{
    currentType = 0;
    sel1Btn.hidden = NO;
    sel2Btn.hidden = YES;
    
    int xinLv = [mXinLv intValue];
    
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    
    JLExerciseHeartRateRemindModel *model1 = [[JLExerciseHeartRateRemindModel alloc] initWithWay:currentType maxRate:(uint8_t)xinLv switchStatus:swtich1.on];
    [models addObject:model1];
    
    JLWearable *w = [JLWearable sharedInstance];

    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
}

-(void)chuBeiXinLvClick{
    currentType = 1;
    sel1Btn.hidden = YES;
    sel2Btn.hidden = NO;
    
    int xinLv = [mXinLv intValue];
    
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    
    JLExerciseHeartRateRemindModel *model1 = [[JLExerciseHeartRateRemindModel alloc] initWithWay:currentType maxRate:(uint8_t)xinLv switchStatus:swtich1.on];
    [models addObject:model1];
    
    JLWearable *w = [JLWearable sharedInstance];

    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
}

- (NSMutableDictionary *)titleTextAttributesWithTitleColor:(UIColor *)titleColor WithTiteleFont:(UIFont *)titleFont{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = titleColor;
    dict[NSFontAttributeName] = titleFont;
    return dict;
}

-(void)xinLvAction:(NSString *) selectValue{
    mXinLv = selectValue;
    
    NSMutableAttributedString * tempString;
    xinLvLabel.text =  [NSString stringWithFormat:@"%@ %@",mXinLv,kJL_TXT("次/分钟")];
    
    labelSport.text = [NSString stringWithFormat:@"%@ %@ %@", kJL_TXT("心率高于"),mXinLv,kJL_TXT("次/分钟时提醒")];
    NSDictionary *dict = [self titleTextAttributesWithTitleColor:kDF_RGBA(128, 91, 235, 1.0) WithTiteleFont:[UIFont fontWithName:@"PingFang SC" size: 12]];
    tempString = [[NSMutableAttributedString alloc] initWithString: labelSport.text];
    NSRange range = [labelSport.text rangeOfString:mXinLv];
    [tempString addAttributes:dict range:range];
    
    labelSport.attributedText = tempString;
    
    if([kJL_GET hasPrefix:@"zh"]){
        xinLvLabel.frame = CGRectMake(sW-16-22-70,22,100,18);
    }else{
        xinLvLabel.frame = CGRectMake(sW-16-22-90,22,100,18);
    }
    
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    
    int xinLv = [mXinLv intValue];
    JLExerciseHeartRateRemindModel *model1 = [[JLExerciseHeartRateRemindModel alloc] initWithWay:currentType maxRate:(uint8_t)xinLv switchStatus:swtich1.on];
    [models addObject:model1];
    
    JLWearable *w = [JLWearable sharedInstance];

    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
}

#pragma mark 进入心率设置的弹窗
-(void)enterXinLvSettingAlertView{
    xinLvView.hidden = NO;
    if([mXinLv isEqualToString:@"0"]){
        mXinLv = @"120";
    }
    xinLvView.selectMValue = mXinLv;
}

#pragma mark 设置心率上限预警
-(void)settingsXinLvAlert:(UISwitch *)sender{
    swtich1.on = sender.on;
    
    int xinLv = [mXinLv intValue];
    
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    
    JLExerciseHeartRateRemindModel *model1 = [[JLExerciseHeartRateRemindModel alloc] initWithWay:currentType maxRate:(uint8_t)xinLv switchStatus:swtich1.on];
    [models addObject:model1];
    
    JLWearable *w = [JLWearable sharedInstance];

    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
    
    if(sender.on == NO){
        view2.userInteractionEnabled = NO;
        contentView1.userInteractionEnabled = NO;
        contentView2.userInteractionEnabled = NO;
        
        view2.alpha = 0.5;
        contentView1.alpha = 0.5;
        contentView2.alpha = 0.5;
    }
    if(sender.on == YES){
        view2.userInteractionEnabled = YES;
        contentView1.userInteractionEnabled = YES;
        contentView2.userInteractionEnabled = YES;
        
        view2.alpha = 1.0;
        contentView1.alpha = 1.0;
        contentView2.alpha = 1.0;
    }
}

- (IBAction)actionExit:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 运动心率提醒
-(void)jlWatchSetExerciseHeartRateRemind:(JLExerciseHeartRateRemindModel *)model{
    uint8_t mMaxRate = 0;
    
    if(model.maxRate ==0){
        mMaxRate = 120;
    }else{
        mMaxRate = model.maxRate;
    }

    NSMutableAttributedString * tempString;
    labelSport.text = [NSString stringWithFormat:@"%@ %d %@", kJL_TXT("心率高于"),mMaxRate,kJL_TXT("次/分钟时提醒")];
    NSDictionary *dict = [self titleTextAttributesWithTitleColor:kDF_RGBA(128, 91, 235, 1.0) WithTiteleFont:[UIFont fontWithName:@"PingFang SC" size: 12]];
    tempString = [[NSMutableAttributedString alloc] initWithString: labelSport.text];
    NSString *maxRateStr = [NSString stringWithFormat:@"%d",mMaxRate];
    NSRange range = [labelSport.text rangeOfString:maxRateStr];
    [tempString addAttributes:dict range:range];
    
    
    labelSport.attributedText = tempString;
    
    swtich1.on = model.status;
    
    mXinLv = [NSString stringWithFormat:@"%hhu",model.maxRate];
    
    if([kJL_GET hasPrefix:@"zh"]){
        xinLvLabel.frame = CGRectMake(sW-16-22-70,22,100,18);
    }else{
        xinLvLabel.frame = CGRectMake(sW-16-22-90,22,100,18);
    }
    
    if (model.maxRate == 0) {
        xinLvLabel.text =  [NSString stringWithFormat:@"%d %@",120,kJL_TXT("次/分钟")];//kJL_TXT("请填写");
        //xinLvLabel.frame = CGRectMake(sW-16-22-50,22,50,18);
    }else{
        xinLvLabel.text =  [NSString stringWithFormat:@"%hhu %@",model.maxRate,kJL_TXT("次/分钟")];
    }
    
    currentType = model.way;
    if(currentType ==0 ){
        sel1Btn.hidden = NO;
        sel2Btn.hidden = YES;
    }
    if(currentType == 1){
        sel1Btn.hidden = YES;
        sel2Btn.hidden = NO;
    }
    
    if(model.status == NO){
        view2.userInteractionEnabled = NO;
        contentView1.userInteractionEnabled = NO;
        contentView2.userInteractionEnabled = NO;
        
        view2.alpha = 0.5;
        contentView1.alpha = 0.5;
        contentView2.alpha = 0.5;
    }
    if(model.status == YES){
        view2.userInteractionEnabled = YES;
        contentView1.userInteractionEnabled = YES;
        contentView2.userInteractionEnabled = YES;
        
        view2.alpha = 1.0;
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
