//
//  MoreSettingView.m
//  JieliJianKang
//
//  Created by EzioChan on 2022/11/2.
//

#import "MoreSettingView.h"
#import "MoreSettingCell.h"
#import "TaiWanVC.h"
#import "SensorSettingsVC.h"
#import "JLWeatherManager.h"

@interface MoreSettingView()<UITableViewDelegate,UITableViewDataSource,JL_WatchProtocol,SettingSwitchPtl>{
    UITableView *funcTable;
    NSMutableArray *itemArrays;
    NSMutableDictionary *statusDict;
    BOOL disRemindStatus;
}
@end

@implementation MoreSettingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        statusDict = [NSMutableDictionary new];
        [self initData];
        [self initUI];
        [self addWatchObjc];
    }
    return self;
}

-(void)addWatchObjc{
    JLWearable *w = [JLWearable sharedInstance];
    [w w_addDelegate:self];
}


-(void)initData{
    itemArrays = [NSMutableArray new];
    JLDeviceConfigModel *model = [[JLDeviceConfig share] deviceGetConfigWithUUID:kJL_BLE_EntityM.mPeripheral.identifier.UUIDString];
    
    NSMutableArray *syncArray = [NSMutableArray new];
    if(model.exportFunc.spSyncInfo){
        kJLLog(JLLOG_DEBUG, @"与设备通讯交互策略未完善，需要另外定制");
        MoreSettingObjc *objc = [MoreSettingObjc initBasic:kJL_TXT("消息通知") Sec:@""];
        objc.hasSwView = NO;
        //[syncArray addObject:objc];
    }
    
    //天气推送
    if(model.exportFunc.spSyncWeather){
        MoreSettingObjc *objc = [MoreSettingObjc initBasic:kJL_TXT("天气推送") Sec:@""];
        objc.hasSwView = YES;
        objc.swStatus = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BT_WEATHER"] boolValue];
        [syncArray addObject:objc];
    }
    
    [itemArrays addObject:syncArray];
    
    NSMutableArray *bleCtlArray = [NSMutableArray new];
    
    //蓝牙断开提醒
    if(model.systemFunc.spDisconnectReminder){
        MoreSettingObjc *objc = [MoreSettingObjc initBasic:kJL_TXT("蓝牙断开提醒") Sec:@""];
        objc.hasSwView = YES;
        objc.swStatus = disRemindStatus;
        [bleCtlArray addObject:objc];
    }
    
    //抬腕亮屏
    if(model.systemFunc.spScreenSetting){
        MoreSettingObjc *objc = [MoreSettingObjc initBasic:kJL_TXT("抬腕亮屏") Sec:kJL_TXT("抬起手腕将屏幕转向自己即可点亮屏幕")];
        objc.hasSwView = NO;
        objc.vc = [[TaiWanVC alloc] init];
        [bleCtlArray addObject:objc];
    }
    
    [itemArrays addObject:bleCtlArray];
    
    //传感器设置
    if(model.healthFunc.spComprehensive.spSensorSetup){
        MoreSettingObjc *objc = [MoreSettingObjc initBasic:kJL_TXT("传感器设置") Sec:@""];
        objc.hasSwView = NO;
        objc.vc = [[SensorSettingsVC alloc] init];
        [itemArrays addObject:@[objc]];
    }
    
}


-(void)initUI{
    self.backgroundColor = [JLColor colorWithString:@"#F6F7F8"];
    funcTable = [UITableView new];
    funcTable.delegate = self;
    funcTable.dataSource = self;
    funcTable.rowHeight = 62;
    funcTable.backgroundColor = [UIColor clearColor];
    funcTable.tableFooterView = [UIView new];
    funcTable.separatorColor = [JLColor colorWithString:@"#F7F7F7"];
    funcTable.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    [funcTable registerClass:[MoreSettingCell class] forCellReuseIdentifier:@"MoreSettingCell"];
    [self addSubview:funcTable];
    [funcTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}



#pragma mark 蓝牙断开设置
-(void)jlWatchSetDisconnectRemindModel:(JLDisconnectRemindModel *)model{
    disRemindStatus = model.status;
    [self initData];
    [funcTable reloadData];
}

#pragma mark 抬腕监测
-(void)jlWatchSetWristLiftDetectionModel:(JLWristLiftDetectionModel *)model{
    if(model.status == WatchSwitchType_Close){
        [statusDict setValue:kJL_TXT("关闭") forKey:kJL_TXT("抬腕亮屏")];
    }
    if(model.status == WatchSwitchType_AllDay){
        [statusDict setValue:kJL_TXT("全天开启") forKey:kJL_TXT("抬腕亮屏")];
    }
    if(model.status == WatchSwitchType_Customer){
        [statusDict setValue:kJL_TXT("定时开启") forKey:kJL_TXT("抬腕亮屏")];
    }
    [funcTable reloadData];
}


//MARK: - tableview delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return itemArrays.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = itemArrays[section];
    return array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MoreSettingCell *cell = [MoreSettingCell cellWithTable:tableView];
    MoreSettingObjc *item  = itemArrays[indexPath.section][indexPath.row];
    cell.mainLab.text = item.mainStr;
    cell.secLab.text = item.secStr;
    [cell weatherHaveDetail:item.supportSec];
    cell.swView.hidden = !item.hasSwView;
    cell.imgv.hidden = item.hasSwView;
    [cell.swView setOn:item.swStatus];
    cell.delegate = self;
    cell.rightLab.text = [statusDict objectForKey:item.mainStr];
    return  cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    MoreSettingObjc *item  = itemArrays[indexPath.section][indexPath.row];
    if(item.vc){
        [JLApplicationDelegate.navigationController pushViewController:item.vc animated:YES];
    }
}


//MARK: - setting delegate

-(void)settingSwitchBack:(NSString *)mainStr onStatus:(BOOL)status{
    
    if([mainStr isEqualToString:kJL_TXT("天气推送")]){
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",status] forKey:@"BT_WEATHER"];
        if(status){
            [[JLWeatherManager share] syncWeather:kJL_BLE_EntityM];
        }
    }
    
    if([mainStr isEqualToString:kJL_TXT("蓝牙断开提醒")]){
        NSMutableArray <JLwSettingModel *>* models = [NSMutableArray new];
        JLDisconnectRemindModel *model1 = [[JLDisconnectRemindModel alloc] initWithModel:0x00 Status:status];
        [models addObject:model1];
        JLWearable *w = [JLWearable sharedInstance];
        [w w_SettingDeviceFuncWith:models withEntity:kJL_BLE_EntityM result:^(BOOL succeed) {
        }];
    }
}

@end
