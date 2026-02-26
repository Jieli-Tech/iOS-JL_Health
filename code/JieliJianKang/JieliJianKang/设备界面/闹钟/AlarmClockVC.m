//
//  AlarmClockVC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/6/29.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "AlarmClockVC.h"
#import "AlarmClockCell.h"
#import "JL_RunSDK.h"
#import "AlarmSetVC.h"
#import "AlarmObject.h"
#import "RTCAlertView.h"

@interface AlarmClockVC ()<UITableViewDelegate,UITableViewDataSource,AlarmClockCellDelegate>{
    __weak IBOutlet UILabel *titleLab;
    UITableView *alarmTable;
    NSMutableArray *itemArray;
    __weak IBOutlet UIButton *syncDateBtn;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    RTCAlertView *rtcAlert;
    UILabel *watchLabel;
    JL_AlarmClockManager *alarmManager;
}

@end

@implementation AlarmClockVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNote];
}

-(void)initWithData{
    titleHeight.constant = kJL_HeightNavBar+10;
    titleLab.text = kJL_TXT("闹钟");
    alarmManager = kJL_BLE_CmdManager.mAlarmClockManager;
    
    if(self->alarmTable == nil){
        self->alarmTable = [[UITableView alloc] initWithFrame:CGRectMake(0, kJL_HeightNavBar+20, [DFUITools screen_2_W], self->itemArray.count*80)];
    }
    self->alarmTable.delegate = self;
    self->alarmTable.dataSource = self;
    self->alarmTable.rowHeight = 80.0;
    self->alarmTable.separatorColor = kDF_RGBA(247.0, 247.0, 247.0, 1.0);
    self->alarmTable.tableFooterView = [UIView new];
    self->alarmTable.backgroundColor = [UIColor whiteColor];
    [self->alarmTable registerNib:[UINib nibWithNibName:@"AlarmClockCell" bundle:nil] forCellReuseIdentifier:@"AlarmClockCell"];
    self->syncDateBtn.layer.cornerRadius = 25.0;
    self->syncDateBtn.layer.masksToBounds = YES;
    [self.view addSubview:self->alarmTable];
    
    
    [alarmManager cmdRtcGetAlarms:^(NSArray<JLModel_RTC *> * _Nullable alarms, NSError * _Nullable error) {
        if(error){
            NSLog(@"rtc get error:%@",error);
            return;
        }
        [self initUIStatus:alarms];
    }];

}

-(void)initUIStatus:(NSArray *)alarms{
    itemArray = [NSMutableArray new];
    [itemArray setArray:alarms];
    
    alarmTable.frame = CGRectMake(0, kJL_HeightNavBar+20, [DFUITools screen_2_W],itemArray.count*80);
    [alarmTable reloadData];
    
    if(watchLabel == nil){
        watchLabel = [[UILabel alloc] init];
    }
    watchLabel.textAlignment = NSTextAlignmentCenter;
    watchLabel.frame = CGRectMake(15, self->alarmTable.frame.origin.y+self->alarmTable.frame.size.height+30, [DFUITools screen_2_W] - 32, 110);
    watchLabel.numberOfLines = 0;
    watchLabel.adjustsFontSizeToFitWidth = true;
    
    self->watchLabel.font = [UIFont fontWithName:@"PingFangSC" size:14];
    self->watchLabel.textColor = kDF_RGBA(114.0, 114.0, 114.0, 1.0);
    self->watchLabel.text = kJL_TXT("设置好闹钟，同步到手表后，手表将会震动提醒您。您最多可以设置5个闹钟。");
    [self.view addSubview:self->watchLabel];
    
    if(self->itemArray.count==0){
        self->watchLabel.hidden = YES;
    }else{
        self->watchLabel.hidden = NO;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self initWithData];
}

-(void)rtcNote:(NSNotification*)note{
    BOOL isOk = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOk == NO) return;
    itemArray = [NSMutableArray arrayWithArray:alarmManager.rtcAlarms];
    [alarmTable reloadData];
}

-(void)noteDeviceChange:(NSNotification *)note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline || tp == JLDeviceChangeTypeBleOFF) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (IBAction)leftBtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addBtnAction:(id)sender {
    if (itemArray.count>=5) {
        [DFUITools showText:kJL_TXT("闹钟数量已满") onView:self.view delay:1.0];
    }else{
        
        NSMutableArray *mArr = [NSMutableArray arrayWithArray:@[@(0),@(1),@(2),@(3),@(4)]];
        
        uint8_t index = 0;
        for (JLModel_RTC *rtcMd in itemArray) {
            uint8_t rtcIndex = rtcMd.rtcIndex;
            if ([mArr containsObject:@(rtcIndex)]) {
                [mArr removeObject:@(rtcIndex)];
            }
        }
        if (mArr.count > 0) {
            index = (uint8_t)[mArr[0] intValue];
        }
        NSLog(@"----> Add RTC Index: %d",index);
        
        JLModel_AlarmSetting *setting = [JLModel_AlarmSetting new];
        setting.index = index;
        setting.isCount = 1;
        setting.count = 1;
        setting.isInterval = 1;
        setting.interval = 1;
        setting.isTime = 1;
        setting.time = 5;
        
        
        AlarmSetVC *vc = [[AlarmSetVC alloc] init];
        vc.createType = YES;
        vc.rtcSettingModel = setting;;
        vc.alarmIndex = index;
        [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
    }
}
- (IBAction)syncDateBtnAction:(id)sender {

    [kJL_BLE_CmdManager.mSystemTime cmdSetSystemTime:[NSDate new]];
}


#pragma mark ///TableViewDelegate
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 8)];
//    view.backgroundColor = [UIColor clearColor];
//    return view;
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 0.0;
//}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return itemArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AlarmClockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmClockCell" forIndexPath:indexPath];
    JLModel_RTC *model = itemArray[indexPath.section];
    if(model.rtcMin<10){
        cell.ClockLab.text = [NSString stringWithFormat:@"%d:0%d",model.rtcHour,model.rtcMin];
    }else{
        cell.ClockLab.text = [NSString stringWithFormat:@"%d:%d",model.rtcHour,model.rtcMin];
    }
    NSString *name = model.rtcName;
    NSString *repeat = [AlarmObject stringMode:model.rtcMode];
    NSString *newStr = [NSString stringWithFormat:@"%@ %@",name,repeat];
    cell.detailLab.text = newStr;
    cell.tag = indexPath.section;
    [cell.select setOn:model.rtcEnable animated:YES];
    [cell.select setOnTintColor:kColor_0000];
    cell.delegate = self;
    
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    cell.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (alarmManager.rtcAlarmType == YES) {
        JLModel_RTC *rtcModel = itemArray[indexPath.section];
        uint8_t bit = 0x01;
        uint8_t bit_index = bit << rtcModel.rtcIndex;
        
        
        [kJL_BLE_CmdManager.mAlarmClockManager cmdRtcOperate:0x00 Index:bit_index Setting:nil
                            Result:^(NSArray<JLModel_AlarmSetting *> * _Nullable array, uint8_t flag) {
            JLModel_AlarmSetting *setting = nil;
            if (array.count > 0) setting = array[0];
            
            if (setting == nil) {
                setting = [JLModel_AlarmSetting new];
                setting.index = rtcModel.rtcIndex;
                setting.isCount = 1;
                setting.count = 1;
                setting.isInterval = 1;
                setting.interval = 5;
                setting.isTime = 1;
                setting.time = 5;
            }
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            AlarmSetVC *vc = [[AlarmSetVC alloc] init];
            vc.rtcSettingModel = setting;
            vc.rtcmodel = rtcModel;
            vc.createType = NO;
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
        }];
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        AlarmSetVC *vc = [[AlarmSetVC alloc] init];
        vc.rtcmodel = itemArray[indexPath.section];
        vc.createType = NO;
        [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kJL_TXT("删除");
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    JLModel_RTC *model = itemArray[indexPath.section];
    [itemArray removeObjectAtIndex:indexPath.section];
    
//    NSMutableArray *delArray = [NSMutableArray new];
//    for (JLModel_RTC *rtcMd in itemArray) {
//        [delArray addObject:@(rtcMd.rtcIndex)];
//    }
//
//    [kJL_BLE_CmdManager.mAlarmClockManager cmdRtcDeleteIndexArray:delArray
//                                                           Result:^(JL_CMDStatus status,
//                                                                    uint8_t sn, NSData * _Nullable data)
//     {
//        JL_CMDStatus state = status;
//        if(state == JL_CMDStatusSuccess){
//            [DFUITools showText:kJL_TXT("删除成功") onView:self.view delay:1.0];
//            [self initWithData];
//        }
//        if(state == JL_CMDStatusFail){
//            [DFUITools showText:kJL_TXT("删除失败") onView:self.view delay:1.0];
//        }
//
//    }];
    

    [kJL_BLE_CmdManager.mAlarmClockManager cmdRtcDeleteIndexArray:@[@(model.rtcIndex)] Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
        JL_CMDStatus state = status;
        if(state == JL_CMDStatusSuccess){
            [DFUITools showText:kJL_TXT("删除成功") onView:self.view delay:1.0];
            [self initWithData];
        }
        if(state == JL_CMDStatusFail){
            [DFUITools showText:kJL_TXT("删除失败") onView:self.view delay:1.0];
        }

    }];
}


#pragma mark ///Cell Delegate
-(void)alarmClockCellDidSelect:(NSInteger)index status:(BOOL)status{
    
    JLModel_RTC *rtcModel = itemArray[index];
    rtcModel.rtcEnable = status;

    [kJL_BLE_CmdManager.mAlarmClockManager cmdRtcSetArray:@[rtcModel] Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
        JL_CMDStatus state = status;
        if(state == JL_CMDStatusSuccess){
            
        }
        if(state == JL_CMDStatusFail){
            [DFUITools showText:kJL_TXT("设置失败") onView:self.view delay:1.0];
            [self initWithData];
        }
    }];
}

-(void)addNote{
    [JL_Tools add:kJL_MANAGER_SYSTEM_INFO Action:@selector(rtcNote:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [JL_Tools remove:nil Own:self];
}

@end
