//
//  JiuZuoVC.m
//  JieliJianKang
//
//  Created by 李放 on 2021/10/26.
//

#import "JiuZuoVC.h"
#import "HourMinutePickerView.h"

@interface JiuZuoVC ()<HourMinutePickerDelegate,JL_WatchProtocol>{
    __weak IBOutlet UIView *headView;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet UIButton *exitBtn;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    
    UIView *view1; //开启久坐提醒的view
    UIView *view2; //开始和结束时间的view
    UIView *view3; //午休免打扰的view
    
    UISwitch *switch1; //久坐提醒的开关
    UISwitch *switch2; //午休免打扰的开关
    
    HourMinutePickerView *jiuZuoHourMinutePickerViewStartTime;
    HourMinutePickerView *jiuZuoHourMinutePickerViewEndTime;
    
    UILabel *startTimeLabel2;
    UILabel *endTimeLabel2;
    
    UInt8 startHour;
    UInt8 startMin;
    UInt8 endHour;
    UInt8 endMin;
    
    UIView *contentView1;
    UIView *contentView2;
    
    float sw;
    float sh;
}

@end

@implementation JiuZuoVC

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
    
    [w w_InquireDeviceFuncWith:JL_WATCH_SETTING_SEDENTARY_REMIND withEntity:kJL_BLE_EntityM];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    titleHeight.constant = kJL_HeightNavBar;
    sw = [DFUITools screen_2_W];
    sh = [DFUITools screen_2_H];

    headView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    exitBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("久坐提醒");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    CGFloat height = kJL_HeightNavBar;
    
    view1 = [[UIView alloc] init];
    view1.frame = CGRectMake(0,height+8,sw,88);
    view1.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [self.view addSubview:view1];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(16,24,sw-16,21);
    label1.numberOfLines = 0;
    [view1 addSubview:label1];
    label1.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label1.text =  kJL_TXT("开启久坐提醒");
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    DFLabel *label2 = [[DFLabel alloc] init];
    label2.frame = CGRectMake(16,47,sw-50-16-10,17);
    label2.numberOfLines = 0;
    label2.labelType = DFLeftRight;
    label2.textAlignment = NSTextAlignmentLeft;
    [view1 addSubview:label2];
    label2.font =  [UIFont fontWithName:@"PingFang SC" size: 12];
    label2.text =  kJL_TXT("久坐超过一小时,设备将震动提醒");
    label2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    
    switch1 = [[UISwitch alloc] initWithFrame:CGRectMake(sw-50-16, view1.frame.size.height/2-15, 50, 30)];
    switch1.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
    [switch1 addTarget:self action:@selector(switchJiuZuo:) forControlEvents:UIControlEventValueChanged];
    [view1 addSubview:switch1];
    
    view2 = [[UIView alloc] init];
    view2.frame = CGRectMake(0,view1.frame.size.height+view1.frame.origin.y+8,sw,120);
    view2.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [self.view addSubview:view2];
    
    contentView1 = [[UIView alloc] init];
    contentView1.frame = CGRectMake(0,0,sw,60);
    contentView1.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [view2 addSubview:contentView1];
    
    UITapGestureRecognizer *startTimeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startTimeClick)];
    [contentView1 addGestureRecognizer:startTimeGestureRecognizer];
    contentView1.userInteractionEnabled=YES;
    
    UILabel *startTimeLabel = [[UILabel alloc] init];
    startTimeLabel.frame = CGRectMake(16,19,sw,21);
    startTimeLabel.numberOfLines = 0;
    [contentView1 addSubview:startTimeLabel];
    startTimeLabel.text = kJL_TXT("开启时间");
    startTimeLabel.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    startTimeLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    startTimeLabel.textAlignment = NSTextAlignmentLeft;
    
    startTimeLabel2 = [[UILabel alloc] init];
    startTimeLabel2.frame = CGRectMake(sw-35-22-16-10,21,50,18);
    startTimeLabel2.numberOfLines = 0;
    [contentView1 addSubview:startTimeLabel2];
    startTimeLabel2.font = [UIFont fontWithName:@"PingFangSC" size: 13];
    startTimeLabel2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    startTimeLabel2.textAlignment = NSTextAlignmentLeft;
    
    UIButton *startTimeBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-16-22,19,22,22)];
    [startTimeBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [contentView1 addSubview:startTimeBtn];
    contentView1.backgroundColor = [UIColor whiteColor];
    
    UIView *viewline3 = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sw-32, 1)];
    [contentView1 addSubview:viewline3];
    viewline3.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    
    contentView2 = [[UIView alloc] init];
    contentView2.frame = CGRectMake(0,60,sw,60);
    contentView2.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [view2 addSubview:contentView2];
    
    UITapGestureRecognizer *endTimeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endTimeClick)];
    [contentView2 addGestureRecognizer:endTimeGestureRecognizer];
    contentView2.userInteractionEnabled=YES;
    
    UILabel *endTimeLabel = [[UILabel alloc] init];
    endTimeLabel.frame = CGRectMake(16,19,sw,21);
    endTimeLabel.numberOfLines = 0;
    [contentView2 addSubview:endTimeLabel];
    endTimeLabel.text = kJL_TXT("结束时间");
    endTimeLabel.font = [UIFont fontWithName:@"PingFangSC" size: 15];
    endTimeLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    endTimeLabel.textAlignment = NSTextAlignmentLeft;
    
    endTimeLabel2 = [[UILabel alloc] init];
    endTimeLabel2.frame = CGRectMake(sw-35-22-16-10,21,50,18);
    endTimeLabel2.numberOfLines = 0;
    [contentView2 addSubview:endTimeLabel2];
    endTimeLabel2.font = [UIFont fontWithName:@"PingFangSC" size: 13];
    endTimeLabel2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    endTimeLabel2.textAlignment = NSTextAlignmentLeft;
    
    UIButton *endTimeBtn = [[UIButton alloc] initWithFrame:CGRectMake(sw-16-22,19,22,22)];
    [endTimeBtn setImage:[UIImage imageNamed:@"icon_next_nol"] forState:UIControlStateNormal];
    [contentView2 addSubview:endTimeBtn];
    contentView2.backgroundColor = [UIColor whiteColor];
    
    view3 = [[UIView alloc] init];
    view3.frame = CGRectMake(0,view2.frame.size.height+view2.frame.origin.y+8,sw,88);
    view3.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    [self.view addSubview:view3];
    
    UILabel *label3 = [[UILabel alloc] init];
    label3.frame = CGRectMake(16,24,sw-16,21);
    label3.numberOfLines = 0;
    [view3 addSubview:label3];
    label3.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
    label3.text =  kJL_TXT("午休免打扰");
    label3.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    UILabel *label4 = [[UILabel alloc] init];
    label4.frame = CGRectMake(16,47,sw-16,17);
    label4.numberOfLines = 0;
    [view3 addSubview:label4];
    label4.font =  [UIFont fontWithName:@"PingFang SC" size: 12];
    label4.text =  kJL_TXT("12:00至14:00不要提醒我");
    label4.textColor = kDF_RGBA(145, 145, 145, 1.0);
    
    switch2 = [[UISwitch alloc] initWithFrame:CGRectMake(sw-50-16, view3.frame.size.height/2-15, 50, 30)];
    switch2.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
    [switch2 addTarget:self action:@selector(switchJiuZuoTwo:) forControlEvents:UIControlEventValueChanged];
    [view3 addSubview:switch2];
    
    jiuZuoHourMinutePickerViewStartTime = [[HourMinutePickerView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self.view addSubview:jiuZuoHourMinutePickerViewStartTime];
    jiuZuoHourMinutePickerViewStartTime.delegate = self;
    jiuZuoHourMinutePickerViewStartTime.hidden = YES;
    jiuZuoHourMinutePickerViewStartTime.type = 0;
    
    jiuZuoHourMinutePickerViewEndTime = [[HourMinutePickerView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self.view addSubview:jiuZuoHourMinutePickerViewEndTime];
    jiuZuoHourMinutePickerViewEndTime.delegate = self;
    jiuZuoHourMinutePickerViewEndTime.hidden = YES;
    jiuZuoHourMinutePickerViewEndTime.type = 1;
}

-(void)startTimeClick{
    jiuZuoHourMinutePickerViewStartTime.hidden = NO;
}

-(void)endTimeClick{
    jiuZuoHourMinutePickerViewEndTime.hidden = NO;
}

#pragma mark 久坐提醒
-(void)jlWatchSetSedentaryRmd:(JLSedentaryRmdModel *)model{
    switch1.on = model.status;
    switch2.on = model.doNotDisturb;
    
    startHour = model.begin.hour;
    startMin  = model.begin.min;
    
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
        if(endMin == 10){
            endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%d%@%d",dayStr,0,endHour,@":",endMin];
        }else{
            endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%d%@%d%d",dayStr,0,endHour,@":",0,endMin];
        }
    }if(endHour>=10&&endMin>=10){
        endTimeLabel2.text = [NSString stringWithFormat:@"%@%d%@%d",dayStr,endHour,@":",endMin];
    }
    
    jiuZuoHourMinutePickerViewStartTime.startTimeselectIndexs = @[@(startHour),@(startMin)];
    jiuZuoHourMinutePickerViewEndTime.endTimeselectIndexs = @[@(endHour),@(endMin)];
    
    if(model.status == NO){
        contentView1.userInteractionEnabled = NO;
        contentView2.userInteractionEnabled = NO;
        view3.userInteractionEnabled = NO;
        
        contentView1.alpha = 0.5;
        contentView2.alpha = 0.5;
        view3.alpha = 0.5;
    }
    if(model.status == YES){
        contentView1.userInteractionEnabled = YES;
        contentView2.userInteractionEnabled = YES;
        view3.userInteractionEnabled = YES;
        
        contentView1.alpha = 1.0;
        contentView2.alpha = 1.0;
        view3.alpha = 1.0;
    }
}


#pragma mark 发送数据给设备端
-(void)sendDataToDevice{
    NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
    
    WatchTimer *startTimer = [[WatchTimer alloc] initWith:startHour Min:startMin];
    WatchTimer *endTimer = [[WatchTimer alloc] initWith:endHour Min:endMin];

    JLSedentaryRmdModel *model1 = [[JLSedentaryRmdModel alloc] initWithModel:WatchRemind_BrightScreen Status:switch1.on DoNotDisturb:switch2.on Begin:startTimer End:endTimer];
    [models addObject:model1];
    
    JLWearable *w = [JLWearable sharedInstance];
    [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
    }];
}

#pragma mark 开启久坐提醒的开关
-(void)switchJiuZuo:(UISwitch *)sender{
    switch1.on = sender.on;
    
    if(sender.on == NO){
        contentView1.userInteractionEnabled = NO;
        contentView2.userInteractionEnabled = NO;
        view3.userInteractionEnabled = NO;
        
        contentView1.alpha = 0.5;
        contentView2.alpha = 0.5;
        view3.alpha = 0.5;
        
        switch2.on = NO;
    }
    if(sender.on == YES){
        contentView1.userInteractionEnabled = YES;
        contentView2.userInteractionEnabled = YES;
        view3.userInteractionEnabled = YES;
        
        contentView1.alpha = 1.0;
        contentView2.alpha = 1.0;
        view3.alpha = 1.0;
    }
    
    [self sendDataToDevice];
}

#pragma mark 开启午休免打扰的开关
-(void)switchJiuZuoTwo:(UISwitch *)sender{
    switch2.on = sender.on;
    
    [self sendDataToDevice];
}

- (IBAction)exitBtn:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    jiuZuoHourMinutePickerViewEndTime.endTimeselectIndexs = @[@(endHour),@(endMin)];
    
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
    
    jiuZuoHourMinutePickerViewStartTime.startTimeselectIndexs = @[@(startHour),@(startMin)];
    
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
