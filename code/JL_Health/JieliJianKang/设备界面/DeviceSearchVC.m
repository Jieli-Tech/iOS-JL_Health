//
//  DeviceSearchVC.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/2/18.
//

#import "DeviceSearchVC.h"
#import "JL_RunSDK.h"
#import "JLUI_Effect.h"

#import "AddDeviceVC.h"
#import "CustomWatchVC.h"
#import "FunctionView.h"
#import "MyHealthVC.h"
#import "OtaUpdateVC.h"
#import "AlarmClockVC.h"
#import "DeviceMusicVC.h"
#import "MyContactsVC.h"
#import "DeviceMoreVC.h"
#import "WatchMarket.h"
#import "JLPopMenuView.h"
#import "AddDeviceVC.h"
#import "QRScanVC.h"
#import "JLWeatherManager.h"

#import "JLWeatherHttp.h"
#import "DevicesSubView.h"
#import "DeviceDetailViewController.h"
#import "BtCallViewController.h"

@interface DeviceSearchVC ()<DevSubViewDelegate,
LanguagePtl>
{
    __weak IBOutlet NSLayoutConstraint *lb_0_H;
    __weak IBOutlet NSLayoutConstraint *btn_0_H;
    __weak IBOutlet NSLayoutConstraint *bottom_H;
    
    __weak IBOutlet UIScrollView *subScrollView;
    __weak IBOutlet UILabel *titleName;
    
    DialSubView                 *dialSubView;
    
    NSString        *bleUUID;
    uint32_t        mRealFreeSize;
    DevicesSubView              *devcSubView;
    FunctionView                *functionView;
    JLPopMenuView               *popMenuView;
    JLLogFileMgr                *deviceLogMgr;
}
@property (weak,nonatomic) NSMutableArray *linkedArray;
@end

@implementation DeviceSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LanguageCls share] add:self];
    deviceLogMgr = [[JLLogFileMgr alloc] init];
    
    
    [self setupUI];
    [self addNote];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    kJLLog(JLLOG_DEBUG, @"---> 设备界面");
    self.linkedArray = kJL_BLE_Multiple.bleConnectedArr;
    if (kJL_BLE_EntityM) {
        [self isConnectUI:YES];
    }
    [[dialSubView vm] updateCurrentWatch];
}

- (void)isConnectUI:(BOOL)is {
    dialSubView.hidden = !is;
    functionView.hidden = !is;
    subScrollView.scrollEnabled = is;
}

- (void)scrollToTop {
    [subScrollView setContentOffset:CGPointMake(0, 0)];
}

- (void)setupUI {
    lb_0_H.constant  = kJL_HeightStatusBar + 10.0;
    btn_0_H.constant = kJL_HeightStatusBar + 5.0;
    bottom_H.constant= kJL_HeightTabBar;
    
    titleName.text = kJL_TXT("设备");
    
    CGFloat subHeight = 220;
    devcSubView = [[DevicesSubView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, subHeight)];
    
    devcSubView.delegate = self;
    [subScrollView addSubview:devcSubView];
    
    
    float gap = 52.0;
    float wacthView_H = 230.0;
    float sW = [UIScreen mainScreen].bounds.size.width;
    float sH = wacthView_H+20.0+gap*7+20+subHeight;
    subScrollView.contentSize = CGSizeMake(sW, sH);
    
    dialSubView = [[DialSubView alloc] initWithFrame:CGRectMake(0, subHeight, sW, wacthView_H)];
    dialSubView.hidden = true;
    __weak DeviceSearchVC *weakSelf = self;
    dialSubView.gotoMore = ^{
        __strong DeviceSearchVC *strongSelf = weakSelf;
        JLModel_Device *dev = [[BridgeHelper getCurrentCmdManager] outputDeviceModel];
        NSData *dt = [JL_Tools HexToData:dev.pidvid];
        NSString *vid = [NSString stringWithFormat:@"%d",(int)[JL_Tools dataToInt:[dt subf:0 t:2]]];
        NSString *pid = [NSString stringWithFormat:@"%d",(int)[JL_Tools dataToInt:[dt subf:2 t:2]]];
        [[DialBaseViewModel shared] getProductInfoWithPid:pid vid:vid completion:^(ProductInfoModel * _Nullable info) {
            if (!info) {
                [DFUITools showText:kJL_TXT("未找到该表盘") onView:strongSelf.view delay:1.0];
                return ;
            }
            if (info.configData.supportDialPayment){
                DialMarketViewController *vc = [[DialMarketViewController alloc] init];
                [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
            }else{
                DialViewController *vc = [[DialViewController alloc] init];
                [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
            }
        }];
    };
    dialSubView.gotoEdit = ^(NSString * _Nonnull watchName) {
        CustomWatchVC *vc = [[CustomWatchVC alloc] init];
        vc.watchName = watchName;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [weakSelf presentViewController:vc animated:YES completion:nil];
    };
    [subScrollView addSubview:dialSubView];
    
    functionView = [[FunctionView alloc] initWithFrame:CGRectMake(0, wacthView_H+10+subHeight, sW, 7*52)];
    functionView.subView = devcSubView;
    [functionView addObserver:self forKeyPath:@"viewHeight" options:NSKeyValueObservingOptionNew context:nil];
    [subScrollView addSubview:functionView];
    
    
    [JL_Tools delay:1.0 Task:^{
        /*--- 审核测试 ---*/
        UserProfile *pf = [[User_Http shareInstance] userPfInfo];
        if ([pf.mobile isEqual:kStoreIAP_MOBILE]||
            [pf.email isEqual:kStoreIAP_MOBILE]) {
            /*--- 读取服务器的表盘 ---*/
            [[WatchMarket sharedMe] searchAllWatchResult:^{
                [self isConnectUI:YES];
            }];
        }else{
            self->dialSubView.hidden = true;
        }
    }];
    
    
    functionView.hidden = true;
    subScrollView.scrollEnabled = false;
}

- (IBAction)btn_addMenu:(UIButton *)sender {
    
    NSArray<JLPopMenuViewItemObject *> *arr = @[
        [[JLPopMenuViewItemObject alloc] initWithName:kJL_TXT("扫一扫") withImageName:@"icon_scan_nol" withTapBlock:^{
            [self->devcSubView cutEntityConnecting];//关闭正在连接的设备
            
            QRScanVC *vc = [[QRScanVC alloc] init];
            vc.formRoot = 0;
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
        }],
        [[JLPopMenuViewItemObject alloc] initWithName:kJL_TXT("添加设备") withImageName:@"icon_add_nol-1" withTapBlock:^{
            [self->devcSubView cutEntityConnecting];//关闭正在连接的设备
            
            AddDeviceVC *vc = [[AddDeviceVC alloc] init];
            [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
        }],
    ];
    popMenuView = [[JLPopMenuView alloc] initWithStartPoint:CGPointMake(sender.x + sender.width - 150, sender.y + sender.height - 10) withItemObjectArray:arr];
    [self.view addSubview:popMenuView];
    popMenuView.hidden = NO;
}


-(void)noteForIosReview:(NSNotification*)note{
    
    NSString *mobile = [note object];
    if ([mobile isEqual:kStoreIAP_MOBILE]) {
        [self isConnectUI:YES];
    }
}



- (void)noteDeviceChange:(NSNotification*)note {
    JLDeviceChangeType type = [[note object] intValue];
    if (type == JLDeviceChangeTypeSomethingConnected) {
        [self isConnectUI:YES];
        [self scrollToTop];
        
        
        /*--- 检查是否处于强制升级 ---*/
        if (kJL_BLE_EntityM.mBLE_NEED_OTA == YES)
            {
            if ([[JL_RunSDK sharedMe] isOtaUpgrading] == NO) {
                /*--- OTA界面需要弹出来 ---*/
                [JL_Tools delay:0.5 Task:^{
                    [self pushUpdateVC];
                }];
            }else{
                /*--- OTA界面已经存在，无需弹出来 ---*/
                [JL_Tools post:kUI_JL_DEVICE_OTA Object:nil];
            }
            return;
            }
        
        /*--- 获取Flash信息 ---*/
        [AlertViewOnWindows showConnectingWithTips:kJL_TXT("读取表盘") timeout:10];
        /*--- 读取设备的表盘 ---*/
        [self connectedWatchAction];
        
    }
    if (type == JLDeviceChangeTypeInUseOffline) {
        [self isConnectUI:NO];
        [self scrollToTop];
        [[JLWearSync share] removeProtocol:JLApplicationDelegate.tabBarController];
        
        /*--- 升级失败也要回连设备 ---*/
        NSString *ancsUuid = [[JL_RunSDK sharedMe] ancsUUID];
        if (ancsUuid.length > 0 && [[JL_RunSDK sharedMe] isOTAFailRelink]) {
            JL_EntityM * otaEntity = [kJL_BLE_Multiple makeEntityWithUUID:ancsUuid];
            kJLLog(JLLOG_DEBUG, @"OTA fail will reconnect device --> %@",otaEntity);
            
            //[[JL_RunSDK sharedMe] setAncsUUID:otaEntity.mPeripheral.identifier.UUIDString];
            [[JL_RunSDK sharedMe] connectDevice:otaEntity callBack:^(BOOL status) {
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }];
        }
    }
    if (type == JLDeviceChangeTypeBleOFF) {
        [self isConnectUI:NO];
        [self scrollToTop];
        [[JLWearSync share] removeProtocol:JLApplicationDelegate.tabBarController];
    }
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
    
}

-(void)connectedWatchAction{
    /*--- 设置命令处理中心 ---*/
    [DialManager openDialFileSystemWithCmdManager:kJL_BLE_CmdManager withResult:^(DialOperateType type, float progress) {
        if (type == DialOperateTypeUnnecessary) {
            kJLLog(JLLOG_DEBUG, @"无需重复打开表盘文件系统");
            return;
        } else if (type == DialOperateTypeFail) {
            kJLLog(JLLOG_DEBUG, @"--->打开表盘文件系统失败!");
            [JLUI_Effect setLoadingText:@"打开表盘文件系统失败!" Delay:1.0];
            return;
        }
        
        [DialManager listFile:^(DialOperateType type, NSArray * _Nullable array) {
            /*--- 重置表盘缓存 ---*/
            [kJL_DIAL_CACHE newWatchList];
            [kJL_DIAL_CACHE newWatchCustomList];
            
            /*--- 保留WATCH文件 ---*/
            for (NSString *name in array) {
                if ([name hasPrefix:@"WATCH"]) [kJL_DIAL_CACHE addWatchListObject:name];
                if ([name hasPrefix:@"BGP_W"]) [kJL_DIAL_CACHE addWatchCustomListObject:name];
            }
            
            
            NSArray *watchArray = [kJL_DIAL_CACHE getWatchList];
            kJLLog(JLLOG_DEBUG, @"--->设备表盘信息已获取...WATCH:%ld",(unsigned long)watchArray.count);
            
            [[WatchMarket sharedMe] searchAllWatchResult:^{
            }];
            
            [JL_Tools subTask:^{
                /*--- 全部表盘的版本 ---*/
                [kJL_DIAL_CACHE getWatchVersion:watchArray];
                
                [JL_Tools mainTask:^{
                    [AlertViewOnWindows removeConnecting];
                    kJLLog(JLLOG_DEBUG, @"--->设备表盘信息已获取,开始准备显示表盘图片...");
                    [[self->dialSubView vm] requireDialsInfo];
                    [self btn_GetFace:nil];
                    
                }];
                
                // 读取设备运动
                [JLApplicationDelegate checkCurrentSport];
                [[JLWearSync share] addProtocol:JLApplicationDelegate.tabBarController];
                
                // 同步天气信息
                int v0 = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BT_WEATHER"] intValue];
                if (v0 == 1) {
                    [JLWeatherHttp syncCurrentLocationWeatherToDevice];
                }
                //读取设备日志
                [self checkoutDeviceLog];
                // 读取设备配置
                [self checkoutDeviceConfigInfo];
                
            }];
        }];
    }];
    
}

-(void)checkoutDeviceLog{
    [kJL_BLE_CmdManager.mDeviceLogs deviceLogDownload:^(DeviceLogType type, float progress, NSString * _Nullable tempSavePath) {
        switch (type) {
            case LogTypeSucceed:{
                JLModel_Device *model =  [kJL_BLE_CmdManager outputDeviceModel];
                self->deviceLogMgr.filePath = tempSavePath;
                self->deviceLogMgr.filename = [tempSavePath lastPathComponent];
                self->deviceLogMgr.platform = PlatformTypeDevice;
                self->deviceLogMgr.brand = @"jieli";
                self->deviceLogMgr.name = @"手表类型";
                self->deviceLogMgr.version = model.versionFirmware;
                self->deviceLogMgr.uuid = kJL_BLE_CmdManager.mEntity.mEdr;
                self->deviceLogMgr.keycode = @"PNJYELFFFBDITNKY";
                [self->deviceLogMgr sendToServiceWithBlock:^(ResponseModel * _Nonnull model) {
                    if (model.code == 0) {
                        [DFFile removePath:tempSavePath];
                        kJLLog(JLLOG_DEBUG, @"Device log is upload to service");
                    }
                }];
            }break;
            case LogTypeFailed:{
                kJLLog(JLLOG_DEBUG, @"get log failed");
            }break;
            default:
                break;
        }
    }];
}

-(void)checkoutDeviceConfigInfo{
    
    [[JLDeviceConfig share] deviceGetConfig:kJL_BLE_CmdManager result:^(JL_CMDStatus status, uint8_t sn, JLDeviceConfigModel * _Nullable config) {
        
        kJLLog(JLLOG_DEBUG, @"checkoutDeviceConfigInfo:%d,%@",status,config);
        
    }];
    // 同步天气
    [DFAction delay:10 Task:^{
        [[JLWeatherManager share] syncWeather:kJL_BLE_EntityM];
    }];
}

- (void)btn_GetFace:(id)sender {
    
    [kJL_BLE_CmdManager.mFlashManager cmdWatchFlashPath:nil Flag:JL_DialSettingReadCurrentDial
                                                 Result:^(uint8_t flag, uint32_t size,
                                                          NSString * _Nullable path,
                                                          NSString * _Nullable describe) {
        [JL_Tools mainTask:^{
            if (flag == 0) {
                NSString *mCurrentWacth = [path stringByReplacingOccurrencesOfString:@"/" withString:@""];
                [kJL_DIAL_CACHE setCurrrentWatchName:mCurrentWacth];
                [[self->dialSubView vm] updateCurrentWatch];
                
                /*--- 判断是否需要【更新资源】或者【OTA升级】 ---*/
                JLModel_Device *devModel = [kJL_BLE_CmdManager outputDeviceModel];
                if (devModel.otaWatch == JL_OtaWatchYES &&
                    [[JL_RunSDK sharedMe] isOtaUpgrading] == NO) {
                    kJLLog(JLLOG_DEBUG, @"---> 需要更新资源.");
                    [self pushUpdateVC];
                }
            }
            
        }];
    }];
}

-(void)pushUpdateVC{
    [self->devcSubView cutEntityConnecting];//关闭正在连接的设备
    
    OtaUpdateVC *vc = [[OtaUpdateVC alloc] init];
    [vc actionToUpdate];
    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
}




-(void)addNote{
    [JL_Tools add:kUI_FOR_IOS_REVIEW Action:@selector(noteForIosReview:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)removeNote{
    [JL_Tools remove:kUI_FOR_IOS_REVIEW Own:self];
    [JL_Tools remove:kUI_RECONNECT_TO_DEVICE Own:self];
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

#pragma mark - DMHandlerDelegate

-(void)dmHandleWithItemModelArray:(NSArray<JLModel_File *> *)modelB {
    kJLLog(JLLOG_DEBUG, @"更新表盘数据，%@", [NSThread currentThread]);
    NSMutableArray *finalArray = [NSMutableArray array];
    for (JLModel_File *fileModel in modelB) {
        if ([fileModel.fileName hasPrefix:@"WATCH"]) {
            [finalArray addObject:fileModel];
        }
    }
    [[dialSubView vm] requireDialsInfo];
}

//MARK: - handel funcviewHeight
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if([keyPath isEqualToString:@"viewHeight"]){
        CGFloat num = [change[NSKeyValueChangeNewKey] floatValue];
        CGFloat subHeight = 188;
        float wacthView_H = 220.0;
        float sW = [UIScreen mainScreen].bounds.size.width;
        float sH = wacthView_H+20.0+num+20+subHeight;
        subScrollView.contentSize = CGSizeMake(sW, sH);
    }
}


//MARK:- delegate devSubView
-(void)devSubViewAddBtnAction{
    
    if (kJL_BLE_Multiple.bleManagerState == CBManagerStatePoweredOff) {
        [DFUITools showText:kJL_TXT("蓝牙没有打开") onView:self.view delay:1.0];
        return;
    }
    [self->devcSubView cutEntityConnecting];//关闭正在连接的设备
    
    AddDeviceVC *vc = [[AddDeviceVC alloc] init];
    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
    
}
- (void)devSubViewscrollToSomeModel:(UserDeviceModel *)model{
    DeviceDetailViewController *vc = [[DeviceDetailViewController alloc] init];
    vc.mainModel = model;
    [JLApplicationDelegate.navigationController pushViewController:vc animated:true];
}


-(void)languageChange {
    titleName.text = kJL_TXT("设备");
    [functionView initByArray];
    [popMenuView setTitleName:@[kJL_TXT("扫一扫"),kJL_TXT("添加设备")]];
}

@end
