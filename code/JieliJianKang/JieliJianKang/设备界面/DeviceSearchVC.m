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
#import "WatchLocalVC.h"
#import "CustomWatchVC.h"
#import "WatchLocalView.h"
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
                             LanguagePtl,WatchLocalViewDelegate>
{
    __weak IBOutlet NSLayoutConstraint *lb_0_H;
    __weak IBOutlet NSLayoutConstraint *btn_0_H;
    __weak IBOutlet NSLayoutConstraint *bottom_H;

    __weak IBOutlet UIScrollView *subScrollView;
    __weak IBOutlet UILabel *titleName;
    
    WatchLocalView  *watchLocalView;

//    JL_RunSDK       *mBleSDK;
//    JL_ManagerM     *mCmdManager;
//    DialUICache     *mDialUICache;
    NSString        *bleUUID;
    uint32_t        mRealFreeSize;
    NSArray<NSString *>         *mWatchArray;
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
    [devcSubView refreshUI];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"---> 设备界面");
    self.linkedArray = kJL_BLE_Multiple.bleConnectedArr;
    if (kJL_BLE_EntityM) {
        [self isConnectUI:YES];
    }
    self->mWatchArray = [kJL_DIAL_CACHE getWatchList];
    [self->watchLocalView setDataArray:self->mWatchArray];
}

- (void)isConnectUI:(BOOL)is {
    watchLocalView.hidden = !is;
    functionView.hidden = !is;
    subScrollView.scrollEnabled = is;
    [devcSubView refreshUI];
}

- (void)scrollToTop {
    [subScrollView setContentOffset:CGPointMake(0, 0)];
}

- (void)setupUI {
    lb_0_H.constant  = kJL_HeightStatusBar + 10.0;
    btn_0_H.constant = kJL_HeightStatusBar + 5.0;
    bottom_H.constant= kJL_HeightTabBar;
    
    titleName.text = kJL_TXT("设备");
    
    CGFloat subHeight = 188;
    devcSubView = [[DevicesSubView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, subHeight)];
    
    devcSubView.delegate = self;
    [subScrollView addSubview:devcSubView];

    
    float gap = 52.0;
    float wacthView_H = 220.0;
    float sW = [DFUITools screen_2_W];
    float sH = wacthView_H+20.0+gap*7+20+subHeight;
    subScrollView.contentSize = CGSizeMake(sW, sH);

    CGRect rect = CGRectMake(0, 0, sW, wacthView_H);
    watchLocalView = [[WatchLocalView alloc] initByFrame:rect];
    watchLocalView.delegate = self;
    [watchLocalView setIsEdit:NO];
    [watchLocalView setIsOperate:NO];
    [watchLocalView setIsShowLbSmall:NO];
    [watchLocalView setIsShowLbBig:YES];
    
    [subScrollView addSubview:watchLocalView];
    
    [JL_Tools delay:0.01 Task:^{
        self->watchLocalView.frame = CGRectMake(0, subHeight+10, sW, wacthView_H);
    }];
    
    functionView = [[FunctionView alloc] initWithFrame:CGRectMake(0, wacthView_H+10.0+10+subHeight, sW, 7*52)];
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
            self->watchLocalView.hidden = true;
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


-(void)onWatchLocalViewDidMoreBtn{
    
    WatchLocalVC *vc = [[WatchLocalVC alloc] init];
    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
    [JL_Tools delay:0.05 Task:^{
        [vc loadWatchForPayment:kJL_DIAL_CACHE.isSupportPayment];
    }];
}

-(void)noteForIosReview:(NSNotification*)note{
    
    NSString *mobile = [note object];
    if ([mobile isEqual:kStoreIAP_MOBILE]) {
        [self isConnectUI:YES];
    }
}



- (void)noteDeviceChange:(NSNotification*)note {
    JLDeviceChangeType type = [[note object] integerValue];
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
        [JLUI_Effect startLoadingView:kJL_TXT("读取表盘") OnView:self.view Delay:10.0];
        
        /*--- 读取设备的表盘 ---*/
        [self connectedWatchAction];
        
    }
    if (type == JLDeviceChangeTypeInUseOffline) {
        [self isConnectUI:NO];
        [self scrollToTop];
        [[JLWearSync share] removeProtocol:JLApplicationDelegate.tabBarController];
        [JLUI_Effect removeLoadingView];
        
        /*--- 升级失败也要回连设备 ---*/
        NSString *ancsUuid = [[JL_RunSDK sharedMe] ancsUUID];
        if (ancsUuid.length > 0 && [[JL_RunSDK sharedMe] isOTAFailRelink]) {
            JL_EntityM * otaEntity = [kJL_BLE_Multiple makeEntityWithUUID:ancsUuid];
            NSLog(@"OTA fail will reconnect device --> %@",otaEntity);

            //[[JL_RunSDK sharedMe] setAncsUUID:otaEntity.mPeripheral.identifier.UUIDString];
            [kJL_BLE_Multiple connectEntity:otaEntity Result:^(JL_EntityM_Status status) {
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }];
        }
    }
    if (type == JLDeviceChangeTypeBleOFF) {
        [self isConnectUI:NO];
        [self scrollToTop];
        [[JLWearSync share] removeProtocol:JLApplicationDelegate.tabBarController];
        [JLUI_Effect removeLoadingView];
    }
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
   
}

-(void)connectedWatchAction{

    /*--- 设置命令处理中心 ---*/
    [DialManager openDialFileSystemWithCmdManager:kJL_BLE_CmdManager withResult:^(DialOperateType type, float progress) {
        if (type == DialOperateTypeUnnecessary) {
            NSLog(@"无需重复打开表盘文件系统");
            return;
        } else if (type == DialOperateTypeFail) {
            NSLog(@"--->打开表盘文件系统失败!");
            [JLUI_Effect setLoadingText:@"打开表盘文件系统失败!" Delay:1.0];
            return;
        }
        /*--- 读取服务器的表盘 ---*/
        [[WatchMarket sharedMe] searchAllWatchResult:^{
            NSLog(@"--->服务器表盘信息已更新...");
            [DialManager listFile:^(DialOperateType type, NSArray * _Nullable array) {
                /*--- 重置表盘缓存 ---*/
                [kJL_DIAL_CACHE newWatchList];
                [kJL_DIAL_CACHE newWatchCustomList];
                
                /*--- 保留WATCH文件 ---*/
                for (NSString *name in array) {
                    if ([name hasPrefix:@"WATCH"]) [kJL_DIAL_CACHE addWatchListObject:name];
                    if ([name hasPrefix:@"BGP_W"]) [kJL_DIAL_CACHE addWatchCustomListObject:name];
                }
                
                
                self->mWatchArray = [kJL_DIAL_CACHE getWatchList];
                NSLog(@"--->设备表盘信息已获取...WATCH:%ld",(unsigned long)self->mWatchArray.count);
                
                [JL_Tools subTask:^{
                    /*--- 全部表盘的版本 ---*/
                    [kJL_DIAL_CACHE getWatchVersion:self->mWatchArray];
                    
                    [JL_Tools delay:0.1 Task:^{
                        [JLUI_Effect removeLoadingView];//关闭UI转圈
                        [self->watchLocalView setDataArray:self->mWatchArray];
                        [self btn_GetFace:nil];
                        
                        /*--- 读取设备运动 ---*/
                        [JLApplicationDelegate checkCurrentSport];
                        [[JLWearSync share] addProtocol:JLApplicationDelegate.tabBarController];
                        
                        /*--- 同步天气信息 ---*/
                        int v0 = [[[NSUserDefaults standardUserDefaults] valueForKey:@"BT_WEATHER"] intValue];
                        if (v0 == 1) {
                            [JLWeatherHttp syncCurrentLocationWeatherToDevice];
                        }
//                        //读取设备日志
                        [self checkoutDeviceLog];
                        // 读取设备配置
                        [self checkoutDeviceConfigInfo];
                        
                        

                    }];
                }];
               
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
                        NSLog(@"Device log is upload to service");
                    }
                }];
            }break;
            case LogTypeFailed:{
                NSLog(@"get log failed");
            }break;
            default:
                break;
        }
    }];
}

-(void)checkoutDeviceConfigInfo{
    
    [[JLDeviceConfig share] deviceGetConfig:kJL_BLE_CmdManager result:^(JL_CMDStatus status, uint8_t sn, JLDeviceConfigModel * _Nullable config) {
        
        NSLog(@"checkoutDeviceConfigInfo:%d,%@",status,config);
        
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
                [self->watchLocalView reloadViewData];
                
                /*--- 判断是否需要【更新资源】或者【OTA升级】 ---*/
                JLModel_Device *devModel = [kJL_BLE_CmdManager outputDeviceModel];
                if (devModel.otaWatch == JL_OtaWatchYES &&
                    [[JL_RunSDK sharedMe] isOtaUpgrading] == NO) {
                    NSLog(@"---> 需要更新资源.");
                    [self pushUpdateVC];
                }
            }

        }];
    }];
}

-(void)noteReconnectToDevice:(NSNotification*)note{
    [devcSubView reconnecLastDevice];//重连上次的设备
}

-(void)pushUpdateVC{
    [self->devcSubView cutEntityConnecting];//关闭正在连接的设备
    
    OtaUpdateVC *vc = [[OtaUpdateVC alloc] init];
    [vc actionToUpdate];
    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
}




-(void)noteWatchFace:(NSNotification*)note{
    NSDictionary *dict = [note object];
    NSString *text = dict[kJL_MANAGER_KEY_OBJECT];
    NSString *devTxt = [text stringByReplacingOccurrencesOfString:@"/" withString:@""];
    [kJL_DIAL_CACHE setCurrrentWatchName:devTxt];
    [self->watchLocalView reloadViewData];
}

-(void)addNote{
    [JL_Tools add:@"FOR_IOS_REVIEW" Action:@selector(noteForIosReview:) Own:self];
    [JL_Tools add:@"kUI_RECONNECT_TO_DEVICE" Action:@selector(noteReconnectToDevice:) Own:self];
    //[JL_Tools add:@"kUI_WATCH_LOCAL" Action:@selector(notePresentWatchVC:) Own:self];
//    [JL_Tools add:@"kUI_WATCH_LOCAL_EDIT" Action:@selector(notePresentCustomWatchVC:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JL_Tools add:kJL_MANAGER_WATCH_FACE Action:@selector(noteWatchFace:) Own:self];
}

#pragma mark - DMHandlerDelegate

-(void)dmHandleWithItemModelArray:(NSArray<JLModel_File *> *)modelB {
    NSLog(@"更新表盘数据，%@", [NSThread currentThread]);
    NSMutableArray *finalArray = [NSMutableArray array];
    for (JLModel_File *fileModel in modelB) {
        if ([fileModel.fileName hasPrefix:@"WATCH"]) {
            [finalArray addObject:fileModel];
        }
    }
    [self->watchLocalView setDataArray:self->mWatchArray];
    [JLUI_Effect removeLoadingView];//关闭UI转圈
}

//MARK: - handel funcviewHeight
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if([keyPath isEqualToString:@"viewHeight"]){
        CGFloat num = [change[NSKeyValueChangeNewKey] floatValue];
        CGFloat subHeight = 188;
        float wacthView_H = 220.0;
        float sW = [DFUITools screen_2_W];
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
//    [self->devcSubView cutEntityConnecting];//关闭正在连接的设备

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
