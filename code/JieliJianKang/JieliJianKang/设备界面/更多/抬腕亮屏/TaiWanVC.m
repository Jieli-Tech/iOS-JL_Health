//
//  TaiWanVC.m
//  JieliJianKang
//
//  Created by 李放 on 2021/10/25.
//

#import "TaiWanVC.h"
#import "HourMinutePickerView.h"

@interface TaiWanVC ()<JL_WatchProtocol,HourMinutePickerDelegate>{
    __weak IBOutlet UIView *headView;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet UIButton *leftBtn;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    
    UIView *area1; //开启状态的view
    UIView *area2; //开启时间和结束时间的view
    
    UIButton *sel1Btn; //关闭
    UIButton *sel2Btn; //全天开启
    UIButton *sel3Btn; //定时开启
    HourMinutePickerView *hourMinutePickerViewStartTime;
    HourMinutePickerView *hourMinutePickerViewEndTime;
    
    UILabel *startTimeLabel2;
    UILabel *endTimeLabel2;
    
    int currentType;
    
    UInt8 startHour;
    UInt8 startMin;
    UInt8 endHour;
    UInt8 endMin;
    
    UIView *contentView4;
    UIView *contentView5;
    
    float sw;
    float sh;
}

@end

@implementation TaiWanVC

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
    
    [w w_InquireDeviceFuncWith:JL_WATCH_SETTING_LIFTWRIST_DETECTION withEntity:kJL_BLE_EntityM];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    titleHeight.constant = kJL_HeightNavBar;
    currentType = -1;
    
    sw = [DFUITools screen_2_W];
    sh = [DFUITools screen_2_H];

    headView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    leftBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("抬腕亮屏");
    
    CGFloat height = kJL_HeightNavBar;
    
    UILabel *openStateLabel = [[UILabel alloc] init];
    openStateLabel.frame = CGRectMake(16,height+15,sw-16,20);
    openStateLabel.numberOfLines = 0;
    [self.view addSubview:openStateLabel];
    openStateLabel.font =  [UIFont fontWithName:@"PingFang SC" size: 14];
    openStateLabel.text =  kJL_TXT("开启状态");
    openStateLabel.textColor = kDF_RGBA(145, 145, 145, 1.0);
    
    area1 = [[UIView alloc] init];
    area1.frame = CGRectMake(0,openStateLabel.frame.origin.y+openStateLabel.frame.size.height+15,sw,180);
    area1.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [self.view addSubview:area1];
    area1.alpha = 1.0;
    
    UIView *contentView1 = [[UIView alloc] init];
    contentView1.frame = CGRectMake(0,0,sw,60);
    contentView1.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [area1 addSubview:contentView1];
    
    UITapGestureRecognizer *stateCloseClickGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stateCloseClick)];
    [contentView1 addGestureRecognizer:stateCloseClickGestureRecognizer];
    contentView1.userInteractionEnabled=YES;
    
    UILabel *closeLabel = [[UILabel alloc] init];
    closeLabel.frame = CGRectMake(16,19,sw-16,21);
    closeLabel.numberOfLines = 0;
    [contentView1 addSubview:closeLabel];
    closeLabel.text = kJL_TXT("关闭");
    closeLabel.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    closeLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    closeLabel.textAlignment = NSTextAlignmentLeft;
    
    sel1Btn = [[UIButton alloc] initWithFrame:CGRectMake(sw-40,18,24,24)];
    [sel1Btn setImage:[UIImage imageNamed:@"icon_choose_nol"] forState:UIControlStateNormal];
    [contentView1 addSubview:sel1Btn];
    sel1Btn.hidden = YES;
    
    UIView *viewline1 = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sw-32, 1)];
    [contentView1 addSubview:viewline1];
    viewline1.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    UIView *contentView2 = [[UIView alloc] init];
    contentView2.frame = CGRectMake(0,60,sw,60);
    contentView2.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [area1 addSubview:contentView2];
    
    UITapGestureRecognizer *stateTimeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stateFullTimeClick)];
    [contentView2 addGestureRecognizer:stateTimeGestureRecognizer];
    contentView2.userInteractionEnabled=YES;
    
    UILabel *stateTimeLabel = [[UILabel alloc] init];
    stateTimeLabel.frame = CGRectMake(16,19,sw-16,21);
    stateTimeLabel.numberOfLines = 0;
    [contentView2 addSubview:stateTimeLabel];
    stateTimeLabel.text = kJL_TXT("全天开启");
    stateTimeLabel.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    stateTimeLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    stateTimeLabel.textAlignment = NSTextAlignmentLeft;
    
    sel2Btn = [[UIButton alloc] initWithFrame:CGRectMake(sw-40,18,24,24)];
    [sel2Btn setImage:[UIImage imageNamed:@"icon_choose_nol"] forState:UIControlStateNormal];
    [contentView2 addSubview:sel2Btn];
    sel2Btn.hidden = YES;
    
    UIView *viewline2 = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sw-32, 1)];
    [contentView2 addSubview:viewline2];
    viewline2.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    UIView *contentView3 = [[UIView alloc] init];
    contentView3.frame = CGRectMake(0,120,sw,60);
    contentView3.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [area1 addSubview:contentView3];
    
    UITapGestureRecognizer *fullTimeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stateTimeClick)];
    [contentView3 addGestureRecognizer:fullTimeGestureRecognizer];
    contentView3.userInteractionEnabled=YES;
    
    UILabel *fullTimeLabel = [[UILabel alloc] init];
    fullTimeLabel.frame = CGRectMake(16,19,sw-16,21);
    fullTimeLabel.numberOfLines = 0;
    [contentView3 addSubview:fullTimeLabel];
    fullTimeLabel.text = kJL_TXT("定时开启");
    fullTimeLabel.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    fullTimeLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    fullTimeLabel.textAlignment = NSTextAlignmentLeft;
    
    sel3Btn = [[UIButton alloc] initWithFrame:CGRectMake(sw-40,18,24,24)];
    [sel3Btn setImage:[UIImage imageNamed:@"icon_choose_nol"] forState:UIControlStateNormal];
    [contentView3 addSubview:sel3Btn];
    sel3Btn.hidden = YES;
    
    area2 = [[UIView alloc] init];
    area2.frame = CGRectMake(0,area1.frame.origin.y+area1.frame.size.height+8,sw,120);
    area2.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [self.view addSubview:area2];
    area2.alpha = 1.0;
    
    contentView4 = [[UIView alloc] init];
    contentView4.frame = CGRectMake(0,0,sw,60);
    contentView4.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [area2 addSubview:contentView4];
    
    UITapGestureRecognizer *startTimeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startTimeClick)];
    [contentView4 addGestureRecognizer:startTimeGestureRecognizer];
    contentView4.userInteractionEnabled=YES;
    
    UILabel *startTimeLabel = [[UILabel alloc] init];
    startTimeLabel.frame = CGRectMake(16,19,sw-16,21);
    startTimeLabel.numberOfLines = 0;
    [contentView4 addSubview:startTimeLabel];
    startTimeLabel.text = kJL_TXT("开启时间");
    startTimeLabel.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    startTimeLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    startTimeLabel.textAlignment = NSTextAlignmentLeft;
    
    startTimeLabel2 = [[UILabel alloc] init];
    startTimeLabel2.frame = CGRectMake(sw-35-22-16-10,21,50,18);
    startTimeLabel2.numberOfLines = 0;
    [contentView4 addSubview:startTimeLabel2];
    startTimeLabel2.font = [UIFont fontWithName:@"PingFangSC" size: 13];
    startTimeLabel2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    startTimeLabel2.textAlignment = NSTextAlignmentLeft;
    
    UIButton *startTimeBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-16-22,19,22,22)];
    [startTimeBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [contentView4 addSubview:startTimeBtn];
    contentView4.backgroundColor = [UIColor whiteColor];
    
    UIView *viewline3 = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sw-32, 1)];
    [contentView4 addSubview:viewline3];
    viewline3.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    contentView5 = [[UIView alloc] init];
    contentView5.frame = CGRectMake(0,60,sw,60);
    contentView5.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [area2 addSubview:contentView5];
    
    UITapGestureRecognizer *endTimeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endTimeClick)];
    [contentView5 addGestureRecognizer:endTimeGestureRecognizer];
    contentView5.userInteractionEnabled=YES;
    
    UILabel *endTimeLabel = [[UILabel alloc] init];
    endTimeLabel.frame = CGRectMake(16,19,sw-16,21);
    endTimeLabel.numberOfLines = 0;
    [contentView5 addSubview:endTimeLabel];
    endTimeLabel.text = kJL_TXT("结束时间");
    endTimeLabel.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    endTimeLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    endTimeLabel.textAlignment = NSTextAlignmentLeft;
    
    endTimeLabel2 = [[UILabel alloc] init];
    endTimeLabel2.frame = CGRectMake(sw-35-22-16-10,21,50,18);
    endTimeLabel2.numberOfLines = 0;
    [contentView5 addSubview:endTimeLabel2];
    endTimeLabel2.font = [UIFont fontWithName:@"PingFangSC" size: 13];
    endTimeLabel2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    endTimeLabel2.textAlignment = NSTextAlignmentLeft;
    
    UIButton *endTimeBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-16-22,19,22,22)];
    [endTimeBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [contentView5 addSubview:endTimeBtn];
    contentView5.backgroundColor = [UIColor whiteColor];
    
    hourMinutePickerViewStartTime = [[HourMinutePickerView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self.view addSubview:hourMinutePickerViewStartTime];
    hourMinutePickerViewStartTime.delegate = self;
    hourMinutePickerViewStartTime.hidden = YES;
    hourMinutePickerViewStartTime.type = 0;
    
    hourMinutePickerViewEndTime = [[HourMinutePickerView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self.view addSubview:hourMinutePickerViewEndTime];
    hourMinutePickerViewEndTime.delegate = self;
    hourMinutePickerViewEndTime.hidden = YES;
    hourMinutePickerViewEndTime.type = 1;
}

-(void)HourMinutePickerActionStartTime:(NSMutableArray *) selectArray{
    startHour = (UInt8)[selectArray[0] intValue];
    startMin = (UInt8)[selectArray[1] intValue];
    
    if((endHour*60+endMin)==(startHour*60+startMin)){
        if(endHour == 23){
            endHour = 0;
        }else{
            endHour = endHour+1;
        }
    }
    
    hourMinutePickerViewEndTime.endTimeselectIndexs = @[@(endHour),@(endMin)];
    
    NSString *dayStr;
    if((endHour*60+endMin)<(startHour*60+startMin)){
        dayStr = kJL_TXT("次日");
        if([kJL_GET hasPrefix:@"zh"]){
            endTimeLabel2.frame = CGRectMake(sw-35-22-16-10-36,21,100,18);
        }else{
            endTimeLabel2.frame = CGRectMake(sw-35-22-16-10-66,21,130,18);
        }
    }else{
        dayStr = @"";
        endTimeLabel2.frame = CGRectMake(sw-35-22-16-10,21,50,18);
    }
    
    if(endHour<10&&endMin>10){
        endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%d%@%d",dayStr,0,endHour,@":",endMin];
    }if(endHour>=10&&endMin<10){
        endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%@%d%d",dayStr,endHour,@":",0,endMin];
    }if(endHour<10&&endMin<=10){
        if(endMin == 10){
            endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%d%@%d",dayStr,0,endHour,@":",endMin];
        }else{
            endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%d%@%d%d",dayStr,0,endHour,@":",0,endMin];
        }
    }if(endHour>=10&&endMin>=10){
        endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%@%d",dayStr,endHour,@":",endMin];
    }
    
    if(startHour<10&&startMin>10){
        startTimeLabel2.text = [NSString stringWithFormat:@"%d%d%@%d",0,startHour,@":",startMin];
    }if(startHour>=10&&startMin<10){
        startTimeLabel2.text = [NSString stringWithFormat:@"%d%@%d%d",startHour,@":",0,startMin];
    }if(startHour<10&&startMin<=10){
        if(startMin == 10){
            startTimeLabel2.text = [NSString stringWithFormat:@"%d%d%@%d",0,startHour,@":",startMin];
        }else{
            startTimeLabel2.text = [NSString stringWithFormat:@"%d%d%@%d%d",0,startHour,@":",0,startMin];
        }
    }if(startHour>=10&&startMin>=10){
        startTimeLabel2.text = [NSString stringWithFormat:@"%d%@%d",startHour,@":",startMin];
    }
    
    [self sendDataToDevice];
}

-(void)HourMinutePickerActionEndTime:(NSMutableArray *) selectArray{
    endHour = (UInt8)[selectArray[0] intValue];
    endMin  =  (UInt8)[selectArray[1] intValue];
    
    
    if((endHour*60+endMin)==(startHour*60+startMin)){
        if(startHour==0){
            startHour = 23;
        }else{
            startHour = startHour-1;
        }
    }
    
    hourMinutePickerViewStartTime.startTimeselectIndexs = @[@(startHour),@(startMin)];

    if(startHour<10&&startMin>10){
        startTimeLabel2.text = [NSString stringWithFormat:@"%d%d%@%d",0,startHour,@":",startMin];
    }if(startHour>=10&startMin<10){
        startTimeLabel2.text = [NSString stringWithFormat:@"%d%@%d%d",startHour,@":",0,startMin];
    }if(startHour<10&&startMin<=10){
        if(startMin == 10){
            startTimeLabel2.text = [NSString stringWithFormat:@"%d%d%@%d",0,startHour,@":",startMin];
        }else{
            startTimeLabel2.text = [NSString stringWithFormat:@"%d%d%@%d%d",0,startHour,@":",0,startMin];
        }
    }if(startHour>=10&&startMin>=10){
        startTimeLabel2.text = [NSString stringWithFormat:@"%d%@%d",startHour,@":",startMin];
    }
    
    NSString *dayStr;
    if((endHour*60+endMin)<(startHour*60+startMin)){
        dayStr = kJL_TXT("次日");
        if([kJL_GET hasPrefix:@"zh"]){
            endTimeLabel2.frame = CGRectMake(sw-35-22-16-10-36,21,100,18);
        }else{
            endTimeLabel2.frame = CGRectMake(sw-35-22-16-10-66,21,130,18);
        }
    }else{
        dayStr = @"";
        endTimeLabel2.frame = CGRectMake(sw-35-22-16-10,21,50,18);
    }
    
    if(endHour<10&&endMin>10){
        endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%d%@%d",dayStr,0,endHour,@":",endMin];
    }if(endHour>=10&&endMin<10){
        endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%@%d%d",dayStr,endHour,@":",0,endMin];
    }if(endHour<10&&endMin<=10){
        if(endMin == 10){
            endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%d%@%d",dayStr,0,endHour,@":",endMin];
        }else{
            endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%d%@%d%d",dayStr,0,endHour,@":",0,endMin];
        }
    }if(endHour>=10&&endMin>=10){
        endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%@%d",dayStr,endHour,@":",endMin];
    }
    
    [self sendDataToDevice];
}

-(void)stateCloseClick{
    currentType = 0;
    
    sel1Btn.hidden = NO;
    sel2Btn.hidden = YES;
    sel3Btn.hidden = YES;
    
    contentView4.userInteractionEnabled = NO;
    contentView4.alpha = 0.5;
    
    contentView5.userInteractionEnabled = NO;
    contentView5.alpha = 0.5;
    
    [self sendDataToDevice];
}

-(void)stateFullTimeClick{
    currentType = 1;

    sel1Btn.hidden = YES;
    sel2Btn.hidden = NO;
    sel3Btn.hidden = YES;
    
    contentView4.userInteractionEnabled = NO;
    contentView4.alpha = 0.5;
    
    contentView5.userInteractionEnabled = NO;
    contentView5.alpha = 0.5;
    
    [self sendDataToDevice];
}

-(void)stateTimeClick{
    currentType = 2;

    sel1Btn.hidden = YES;
    sel2Btn.hidden = YES;
    sel3Btn.hidden = NO;
    
    contentView4.userInteractionEnabled = YES;
    contentView4.alpha = 1.0;
    
    contentView5.userInteractionEnabled = YES;
    contentView5.alpha = 1.0;
    
    [self sendDataToDevice];
}

-(void)startTimeClick{
    hourMinutePickerViewStartTime.hidden = NO;
}

-(void)endTimeClick{
    hourMinutePickerViewEndTime.hidden = NO;
}

- (IBAction)backExit:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 抬腕检测
-(void)jlWatchSetWristLiftDetectionModel:(JLWristLiftDetectionModel *)model{
    currentType = model.status;
    
    if(currentType == WatchSwitchType_Close){
        contentView4.userInteractionEnabled = NO;
        contentView4.alpha = 0.5;
        
        contentView5.userInteractionEnabled = NO;
        contentView5.alpha = 0.5;
        
        sel1Btn.hidden = NO;
        sel2Btn.hidden = YES;
        sel3Btn.hidden = YES;
    }
    if(currentType == WatchSwitchType_AllDay){
        contentView4.userInteractionEnabled = NO;
        contentView4.alpha = 0.5;
        
        contentView5.userInteractionEnabled = NO;
        contentView5.alpha = 0.5;
        
        sel1Btn.hidden = YES;
        sel2Btn.hidden = NO;
        sel3Btn.hidden = YES;
    }
    if(currentType == WatchSwitchType_Customer){
        contentView4.userInteractionEnabled = YES;
        contentView4.alpha = 1.0;
        
        contentView5.userInteractionEnabled = YES;
        contentView5.alpha = 1.0;
        
        sel1Btn.hidden = YES;
        sel2Btn.hidden = YES;
        sel3Btn.hidden = NO;
    }
    
    startHour = model.start.hour;
    startMin  = model.start.min;
    
    if(startHour<10&&startMin>10){
        startTimeLabel2.text = [NSString stringWithFormat:@"%d%d%@%d",0,startHour,@":",startMin];
    }if(startHour>=10&&startMin<10){
        startTimeLabel2.text = [NSString stringWithFormat:@"%d%@%d%d",startHour,@":",0,startMin];
    }if(startHour<10&&startMin<=10){
        if(startMin == 10){
            startTimeLabel2.text = [NSString stringWithFormat:@"%d%d%@%d",0,startHour,@":",startMin];
        }else{
            startTimeLabel2.text = [NSString stringWithFormat:@"%d%d%@%d%d",0,startHour,@":",0,startMin];
        }
    }if(startHour>=10&&startMin>=10){
        startTimeLabel2.text = [NSString stringWithFormat:@"%d%@%d",startHour,@":",startMin];
    }
    
    endHour = model.end.hour;
    endMin  = model.end.min;
    
    NSString *dayStr;
    if((endHour*60+endMin)<(startHour*60+startMin)){
        dayStr = kJL_TXT("次日");
        if([kJL_GET hasPrefix:@"zh"]){
            endTimeLabel2.frame = CGRectMake(sw-35-22-16-10-36,21,100,18);
        }else{
            endTimeLabel2.frame = CGRectMake(sw-35-22-16-10-66,21,130,18);
        }
    }else{
        dayStr = @"";
        endTimeLabel2.frame = CGRectMake(sw-35-22-16-10,21,50,18);
    }
    
    if(endHour<10&&endMin>10){
        endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%d%@%d",dayStr,0,endHour,@":",endMin];
    }if(endHour>=10&&endMin<10){
        endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%@%d%d",dayStr,endHour,@":",0,endMin];
    }if(endHour<10&&endMin<=10){
        if(endMin ==10){
            endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%d%@%d",dayStr,0,endHour,@":",endMin];
        }else{
            endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%d%@%d%d",dayStr,0,endHour,@":",0,endMin];
        }
    }if(endHour>=10&&endHour>=10){
        endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%@%d",dayStr,endHour,@":",endMin];
    }
    
    hourMinutePickerViewStartTime.startTimeselectIndexs = @[@(startHour),@(startMin)];
    hourMinutePickerViewEndTime.endTimeselectIndexs = @[@(endHour),@(endMin)];
}

#pragma mark 发送数据给设备端
-(void)sendDataToDevice{
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    
    WatchTimer *startTimer = [[WatchTimer alloc] initWith:startHour Min:startMin];
    WatchTimer *endTimer = [[WatchTimer alloc] initWith:endHour Min:endMin];

    JLWristLiftDetectionModel *model1 = [[JLWristLiftDetectionModel alloc] initWithModel:WatchRemind_BrightScreen Status:currentType Begin:startTimer End:endTimer];
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
