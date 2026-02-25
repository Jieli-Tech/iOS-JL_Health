//
//  HealthVC.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/2/18.
//

#import "HealthVC.h"
#import "StepPartsView.h"
#import "JL_RunSDK.h"
#import "SportRecordView.h"
#import "HeartBitPartView.h"
#import "SleepPartView.h"
#import "DefaultPartView.h"
#import "StepDetailViewController.h"
#import "TransJump.h"
#import "HeartBeatDetailVC.h"
#import "PresssureVC.h"
#import "SleepDetailViewController.h"
#import "WeightVC.h"
#import "OxygenSaturationVC.h"
#import "JLSportHistoryViewController.h"
#import "JLPopMenuView.h"
#import "AddDeviceVC.h"
#import "QRScanVC.h"
//#import "NFCManager.h"
#import "JLSqliteSportRunningRecord.h"
#import "JLSqliteStep.h"
#import "JLSqliteHeartRate.h"
#import "JLSqliteOxyhemoglobinSaturation.h"
#import "JLSqliteSleep.h"
#import "JLSqliteWeight.h"
#import "SyncDataManager.h"
#import "UserDataSync.h"
#import "DataOverallPlanTools.h"
#import "DataOverRallPlanHeartRate.h"
#import "MJRefresh.h"

@interface HealthVC ()<TransJumpDelegate,LanguagePtl>{
    
    StepPartsView       *stepPartv;
    SportRecordView     *sportPartv;
    HeartBitPartView    *beatPartv;
    SleepPartView       *sleepPartv;
    DefaultPartView     *weightPartv;
    DefaultPartView     *presssurePartv;
    DefaultPartView     *oxygenPartv;
    
    UILabel *titleLab;
    UIButton *addBtn;
    CGFloat targetHeight;
    
    float targetStep;
    NSInteger oxygenMaxValue;
    MJRefreshNormalHeader *header;
    JLPopMenuView *popMenuView;
}

@property(strong, nonatomic) UIScrollView *scrollView;

@end

@implementation HealthVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDF_RGBA(246, 247, 248, 1);
    __weak typeof(self) weakSelf = self;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width-32;
    
    titleLab = [[UILabel alloc] initWithFrame:CGRectMake(16, kJL_HeightStatusBar+10, 200, 33)];
    titleLab.text = kJL_TXT("健康");
    titleLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24];
    titleLab.textColor = kDF_RGBA(36, 36, 36, 1);
    [self.view addSubview:titleLab];
    addBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-16-40, kJL_HeightStatusBar+10, 40, 40)];
    [addBtn addTarget:self action:@selector(addBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setImage:[UIImage imageNamed:@"icon_more_nol"] forState:UIControlStateNormal];
    [self.view addSubview:addBtn];
    
    [[LanguageCls share] add:self];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kJL_HeightNavBar+10, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-kJL_HeightNavBar-kJL_HeightTabBar)];
    _scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scrollView];
    
    header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 同步服务器数据
        [UserDataSync updateHealthAndSportDataFile];
        
        if (!kJL_BLE_EntityM) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.scrollView.mj_header endRefreshing];
                [weakSelf refreshView];
            });
            return;
        }
        
        JLDeviceConfigModel *configModel = [[JLDeviceConfig share] deviceGetConfigWithUUID:kJL_BLE_EntityM.mPeripheral.identifier.UUIDString];
        //如果支持睡眠检测
        if(configModel.healthFunc.spComprehensive.spSleepMonitor){
            [[SyncDataManager share] syncSleepData:kJL_BLE_EntityM with:^(JLWearSyncHealthSleepChart * _Nullable chart) {
                NSLog(@"同步睡眠数据");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.scrollView.mj_header endRefreshing];
                    [weakSelf refreshView];
                });
            }];
        }
        //如果支持心率功能
        if(configModel.healthFunc.spHeartRate.spExist){
            [[SyncDataManager share] syncHeartRateData:kJL_BLE_EntityM with:^(JLWearSyncHealthHeartRateChart * _Nullable chart) {
                NSLog(@"同步心率数据");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.scrollView.mj_header endRefreshing];
                    [weakSelf refreshView];
                });
            }];
        }
        //如果支持计步Gsensor
        if(configModel.healthFunc.spGSensor.spExist){
            [[SyncDataManager share] syncStepCountData:kJL_BLE_EntityM with:^(JLWearSyncHealthStepChart * _Nullable model) {
                NSLog(@"同步设备步数");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.scrollView.mj_header endRefreshing];
                    [weakSelf refreshView];
                });
            }];
        }
        //如果支持血氧
        if(configModel.healthFunc.spBloodOxygen.spExist){
            [[SyncDataManager share] syncBloodOxyganData:kJL_BLE_EntityM with:^(JLWearSyncHealthBloodOxyganChart * _Nullable chart) {
                NSLog(@"同步设备血氧记录");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.scrollView.mj_header endRefreshing];
                    [weakSelf refreshView];
                });
            }];
        }
        //如果支持运动记录
        if(configModel.healthFunc.spSportModel.spRecord){
            [[SyncDataManager share] syncSportRecordData:kJL_BLE_EntityM with:^(JLSportRecordModel * _Nullable model) {
                NSLog(@"运动记录");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.scrollView.mj_header endRefreshing];
                    [weakSelf refreshView];
                });
            }];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSLog(@"a同步强制结束");
            [weakSelf.scrollView.mj_header endRefreshing];
        });
        [weakSelf refreshMoveStep];
    }];
    
    [header setTitle:kJL_TXT("下拉加载更多...") forState:MJRefreshStateIdle];
    [header setTitle:kJL_TXT("松手开始加载") forState:MJRefreshStatePulling];
    [header setTitle:kJL_TXT("加载中...") forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    _scrollView.mj_header = header;
        
    stepPartv = [[StepPartsView alloc] initWithFrame:CGRectMake(16, 0, [UIScreen mainScreen].bounds.size.width-32,194)];
    stepPartv.delegate = self;
    [_scrollView addSubview:stepPartv];
    
    targetHeight+=194;
    targetHeight+=20;
    sportPartv = [[SportRecordView alloc] initWithFrame:CGRectMake(16, targetHeight, [UIScreen mainScreen].bounds.size.width-32, 90)];
    sportPartv.delegate = self;
    [_scrollView addSubview:sportPartv];
    targetHeight+=90;
    
    targetHeight+=12;
    beatPartv = [[HeartBitPartView alloc] initWithFrame:CGRectMake(16, targetHeight, [UIScreen mainScreen].bounds.size.width-32, 170)];
    beatPartv.delegate = self;
    
    [_scrollView addSubview:beatPartv];
    targetHeight+=170;
    
    targetHeight+=12;
    sleepPartv = [[SleepPartView alloc] initWithFrame:CGRectMake(16, targetHeight, width, 162)];
    sleepPartv.delegate = self;
    [_scrollView addSubview:sleepPartv];
    targetHeight+=162;    
    targetHeight+=12;
    weightPartv = [[DefaultPartView alloc] initWithFrame:CGRectMake(16, targetHeight, width, 90) Type:kJL_TXT("体重") Image:[UIImage imageNamed:@"health_icon_record_nol(5)"]];
    weightPartv.type = WeightRecord;
    weightPartv.delegate = self;
    
    [_scrollView addSubview:weightPartv];
    targetHeight+=90;
    
//    targetHeight+=20;
//    presssurePartv = [[DefaultPartView alloc] initWithFrame:CGRectMake(16, targetHeight, width, 90) Type:kJL_TXT("压力") Image:[UIImage imageNamed:@"health_icon_record_nol(6)"]];
//    presssurePartv.type = presssureRecord;
//    presssurePartv.delegate = self;
//    [presssurePartv setLabValue:@"--" Unit:@"" day:[NSDate new]];
//    [scrollView addSubview:presssurePartv];
//    targetHeight+=90;
    
    targetHeight+=12;
    oxygenPartv = [[DefaultPartView alloc] initWithFrame:CGRectMake(16, targetHeight, width, 90) Type:kJL_TXT("血氧饱和度") Image:[UIImage imageNamed:@"health_icon_record_nol(7)"]];
    oxygenPartv.type = OxygenRecord;
    oxygenPartv.delegate = self;
    [_scrollView addSubview:oxygenPartv];
    targetHeight+=90;
    
    targetHeight+=12;
    [_scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, targetHeight)];
    
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.scrollView.mj_header beginRefreshing];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshView];
    [self refreshMoveStep];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Private Methods

- (void)noteDeviceChange:(NSNotification*)note {
    JLDeviceChangeType type = [[note object] integerValue];
    if (type == JLDeviceChangeTypeSomethingConnected) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.scrollView.mj_header beginRefreshing];
        });
    }
}

- (void)refreshView {
    [self getUserInfo];
    
    //获取步数当天数据
    
    
    [JLSqliteStep s_checkoutWtihStartDate:[NSDate new].toStartOfDate withEndDate:[NSDate new].toEndOfDate Result:^(NSArray<JL_Chart_MoveSteps *> * _Nonnull charts) {
        
        if(![[JL_RunSDK sharedMe] mBleEntityM]) return;
        for (int i=0; i<charts.count; i++) {
            JL_Chart_MoveSteps *moveSteps = charts[i];

            float currentTotalMileage = [[NSString stringWithFormat:@"%.2f",moveSteps.totalMileage/ 100] floatValue];
            int currentTotalConsumption = [[NSString stringWithFormat:@"%.0f",moveSteps.totalConsumption] intValue];

            NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
            if([unitStr isEqualToString:@("英制")]){
                [self->stepPartv setK:currentTotalMileage*0.621 Kcl:currentTotalConsumption m:0.f];
            }else{
                [self->stepPartv setK:currentTotalMileage Kcl:currentTotalConsumption m:0.f];
            }
        }
        
    }];
    
    // 获取运动记录数据
    [JLSqliteSportRunningRecord s_checkoutTheLastDataWithResult:^(JL_SportRecord_Chart * _Nullable chart) {
        if (chart) {
            NSDate *chartDate = [NSDate dateWithTimeIntervalSince1970:chart.sport_id];
            NSString *type = kJL_TXT("户外跑步");
            switch (chart.modelType) {
                case WatchSportType_InDoor:
                    type = kJL_TXT("室内跑步");
                    break;
                case WatchSportType_OutDoor:
                    type = kJL_TXT("户外跑步");
                    break;
                default:
                    type = @"";
                    break;
            }
            NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
            if([unitStr isEqualToString:@("英制")]){
                [self->sportPartv setTheRecord:kJL_TXT("英里") Record:[NSString stringWithFormat:@"%.2f", (double)((chart.distance / 100)*0.621)] type:type withDay:chartDate.toMMdd3];
            }else{
                [self->sportPartv setTheRecord:kJL_TXT("公里") Record:[NSString stringWithFormat:@"%.2f", (double)(chart.distance / 100)] type:type withDay:chartDate.toMMdd3];
            }
        } else {
            NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
            if([unitStr isEqualToString:@("英制")]){
                [self->sportPartv setTheRecord:kJL_TXT("英里") Record:nil type:nil withDay:nil];
            }else{
                [self->sportPartv setTheRecord:kJL_TXT("公里") Record:nil type:nil withDay:nil];
            }
        }
    }];

    [DataOverRallPlanHeartRate heartRateLastDateResult:^(HeartRateModel * _Nonnull model, NSDate * _Nonnull date) {
        self->beatPartv.dtNumber = model.pointArray.count;
        self->beatPartv.dataArray = model.pointArray;
        [self->beatPartv setHeartBeat:model.lastRate forDay:date];
    }];
    
    //获取睡眠记录
    [sleepPartv setDateLabel:[NSDate new]];
    [DataOverallPlanTools sleepDataCheckLastDayResult:^(SleepDataFormatModel * _Nonnull model) {
        [self->sleepPartv setDuration:model.detail.all*60];
        [self->sleepPartv setDataArray:model.pointsArray];
        [self->sleepPartv setDateLabel:model.detail.date];
    }];
    
    //获取体重
    [JLSqliteWeight s_checkoutTheLastDataWithResult:^(JL_Chart_Weight * _Nonnull chart) {
        NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
        NSString *units = kJL_TXT("公斤");
        
        float mWeight;
        if([unitStr isEqualToString:@("英制")]){
            units = kJL_TXT("磅");
            mWeight = chart.weight*2.205;
        }else{
            mWeight = chart.weight;
            units = kJL_TXT("公斤");
        }
        [self->weightPartv setLabValue:[NSString stringWithFormat:@"%.1f",mWeight] Unit:units day:chart.date];
    }];
    
    //获取血氧饱和度
    [JLSqliteOxyhemoglobinSaturation s_checkoutTheLastDataWithResult:^(JL_Chart_OxyhemoglobinSaturation * _Nonnull chart) {
        JL_Chart_OxyhemoglobinSaturation *oxyHemo = chart;
        NSArray <BloodOxyganData *> *bloodOxyganArray= oxyHemo.bloodOxyganlist;
        BloodOxyganData *bloodOxyganData = bloodOxyganArray[0];
        NSArray *bloodOxygans = bloodOxyganData.bloodOxygans;
        if (bloodOxygans.count>0) {
            float value = [bloodOxygans[0] floatValue];        
            [self->oxygenPartv setLabValue:[NSString stringWithFormat:@"%ld%@",(long)value,@"%"] Unit:@"" day:bloodOxyganData.startDate];
        }else{
            [self->oxygenPartv setLabValue:@"- -" Unit:@"" day:nil];
        }
    }];
 
}

///刷新实时的步数
-(void)refreshMoveStep{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    if(!entity)return;
    JLWearable *w = [JLWearable sharedInstance];
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:[JL_SDM_MoveSteps require:YES distance:YES calories:YES]];
    w.moveStep = ^(JL_SDM_MoveSteps *ms) {
        [self->stepPartv setWalkStep:ms.rtStep];
        [self->stepPartv setTargetStepAction:self->targetStep];
        [self->stepPartv setK:(float)ms.distance/100.0 Kcl:ms.calories m:0.f];
    };
    [w w_requestSportData:array withEntity:entity];
}

- (void)addBtnAction:(UIButton *)sender {
    //__weak typeof(self) weakSelf = self;
    NSArray<JLPopMenuViewItemObject *> *arr = @[
        [[JLPopMenuViewItemObject alloc] initWithName:kJL_TXT("扫一扫") withImageName:@"icon_scan_nol" withTapBlock:^{
            QRScanVC *vc = [[QRScanVC alloc] init];
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
        }],
        [[JLPopMenuViewItemObject alloc] initWithName:kJL_TXT("添加设备") withImageName:@"icon_add_nol-1" withTapBlock:^{
            AddDeviceVC *vc = [[AddDeviceVC alloc] init];
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
        }],
//        [[JLPopMenuViewItemObject alloc] initWithName:@"NFC是否可读写" withImageName:@"icon_add_nol-1" withTapBlock:^{
//            if (@available(iOS 11.0, *)) {
//                [NFCManager isSupportsNFCReading];
//                [NFCManager isSupportsNFCWrite];
//            }
//        }],
//        [[JLPopMenuViewItemObject alloc] initWithName:@"NFC读卡操作" withImageName:@"icon_scan_nol" withTapBlock:^{
//            if (@available(iOS 11.0, *)) {
//                [[NFCManager sharedInstance] scanTagWithSuccessBlock:^(NFCNDEFMessage * _Nonnull message) {
//                    NSLog(@"scanTag success: %@", message);
//                } andErrorBlock:^(NSError * _Nonnull error) {
//                    NSLog(@"scanTag error: %@", error);
//                }];
//            }
//        }],
    ];
    popMenuView = [[JLPopMenuView alloc] initWithStartPoint:CGPointMake(sender.x + sender.width - 150, sender.y + sender.height - 10) withItemObjectArray:arr];
    [self.view addSubview:popMenuView];
    popMenuView.hidden = NO;
}

-(void)jumpByObject:(JumpType)type{    
    switch (type) {
        case HeartBeat:{
            HeartBeatDetailVC *vc = [[HeartBeatDetailVC alloc] init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
        }break;
        case StepCount:{
            StepDetailViewController *vc = [[StepDetailViewController alloc] init];
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
        }break;
        case SportRecord:{
            JLSportHistoryViewController *vc = [[JLSportHistoryViewController alloc] init];
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
        }break;
        case SleepTime:{
            SleepDetailViewController *vc = [[SleepDetailViewController alloc] init];
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
        }break;
        case WeightRecord:{
            WeightVC *vc = [[WeightVC alloc] init];
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
            break;
        }
        case presssureRecord:{
            PresssureVC *vc = [[PresssureVC alloc] init];
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
            break;
        }
        case OxygenRecord:{
            OxygenSaturationVC *vc = [[OxygenSaturationVC alloc] init];
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}

-(void)getUserInfo{
    [[User_Http shareInstance] requestGetUserConfigInfo:^(JLUser * _Nonnull userInfo) {
        [JL_Tools mainTask:^{
            if(userInfo != nil){
                self->targetStep = [[NSString stringWithFormat:@"%d",userInfo.step] integerValue];
            }
        }];
    }];
}

- (void)languageChange {
    titleLab.text = kJL_TXT("健康");
    [header setTitle:kJL_TXT("下拉加载更多...") forState:MJRefreshStateIdle];
    [header setTitle:kJL_TXT("松手开始加载") forState:MJRefreshStatePulling];
    [header setTitle:kJL_TXT("加载中...") forState:MJRefreshStateRefreshing];
    [weightPartv setTitle:kJL_TXT("体重")];
    [presssurePartv setTitle:kJL_TXT("压力")];
    [oxygenPartv setTitle:kJL_TXT("血氧饱和度")];
    [popMenuView setTitleName:@[kJL_TXT("扫一扫"),kJL_TXT("添加设备")]];
    
}

@end
