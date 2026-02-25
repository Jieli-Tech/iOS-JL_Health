//
//  UpdateVC.m
//  JLWatchDemo
//
//  Created by 杰理科技 on 2022/4/2.
//

#import "UpdateVC.h"
#import "JLHeadFile.h"
#import "TipView.h"

#import "DocumentView.h"

@interface UpdateVC (){
    
    __weak IBOutlet UILabel *lbOtaText;
    __weak IBOutlet UIProgressView *otaProgressView;
    __weak IBOutlet UILabel *lbProgress;
    __weak IBOutlet UILabel *lbVersion;
    __weak IBOutlet UILabel *lbBattery;
    __weak IBOutlet UILabel *lbOtaType;
    
    __weak IBOutlet UIButton *btn_update;
    
    JL_RunSDK       *bleSDK;
    JL_ManagerM     *mCmdManager;
    DocumentView    *myDocumentView;
    JL_Timer        *mTimer;
    
    NSArray         *mWatchList;
    NSString        *mOtaPath;
    
    BOOL            isOtaUpdate;
}

@end

@implementation UpdateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    isOtaUpdate = NO;
    bleSDK = [JL_RunSDK sharedMe];
    mCmdManager = bleSDK.bt_ble.mAssist.mCmdManager;
    mTimer = [[JL_Timer alloc] init];

    [self setupUI];
    
    
    /*--- 设备是否需要OTA ---*/
    BOOL isOTA = [JL_RunSDK isNeedUpdateOTA_1];
    if (isOTA == NO) {
        [self getWatchList];
    }
}

-(void)dealloc{
    [JL_Tools remove:@"kJL_OTA_CONNECT" Own:self];
}

-(void)setupUI{
    [JL_Tools add:@"kJL_OTA_CONNECT" Action:@selector(noteOtaForce:) Own:self];
    
    JLModel_Device *model = [mCmdManager outputDeviceModel];
    lbVersion.text = [NSString stringWithFormat:@"Version %@",model.versionFirmware];
    lbBattery.text = [NSString stringWithFormat:@"电量 %lu%%",(unsigned long)model.battery];
    
    btn_update.layer.cornerRadius = 20.0;
    
    if (model.partitionType == JL_PartitionSingle) lbOtaType.text = @"单备份";
    if (model.partitionType == JL_PartitionDouble) lbOtaType.text = @"双备份";
}




-(void)getWatchList{
    [DialManager listFile:^(DialOperateType type, NSArray * _Nullable array) {
        self->mWatchList = array;
        NSLog(@"Fats List ---> %@",self->mWatchList);
        [TipView setLoadingText:@"获取表盘列表!" Delay:1.0];
    }];
}


- (IBAction)btn_OtaStart:(id)sender {
    
    /*--- BLE是否连接 ---*/
    BOOL isConnect = [JL_RunSDK isConnectDevice];
    if (isConnect == NO) return;
    
    
    if (isOtaUpdate == YES) {
        [DFUITools showText:@"正在升级..." onView:self.view delay:1.0];
        return;
    }
    
    myDocumentView = [[DocumentView alloc] init];
    [self.view addSubview:myDocumentView];
    
    NSString *mPath = [JL_Tools listPath:NSDocumentDirectory MiddlePath:@"" File:@""];
    [myDocumentView showZipWithPath:mPath Result:^(NSString * _Nonnull file) {
        self->mOtaPath = [mPath stringByAppendingPathComponent:file];
        [JL_Tools setUser:self->mOtaPath forKey:@"JL_OTA_PATH"];
        
        /*--- 删掉旧的升级资源文件 ---*/
        NSString *lastZip = [[self->mOtaPath lastPathComponent] stringByReplacingOccurrencesOfString:@".zip" withString:@""];
        NSString *lastPath = [JL_Tools listPath:NSDocumentDirectory MiddlePath:lastZip File:@""];
        [JL_Tools removePath:lastPath];
        
        [self->mTimer threadContinue];
    }];
    
    
    [JL_Tools subTask:^{
        [self->mTimer threadWait];
        
        /*--- 设备只需要OTA ---*/
        BOOL isOTA = [JL_RunSDK isNeedUpdateOTA_1];
        if (isOTA == YES) {
            [JL_Tools mainTask:^{
                
                NSString *lastZip = [[self->mOtaPath lastPathComponent] stringByReplacingOccurrencesOfString:@".zip" withString:@""];
                NSString *lastPath = [JL_Tools listPath:NSDocumentDirectory MiddlePath:lastZip File:@""];
                NSArray *zipArr = [FatfsObject unzipFileAtPath:self->mOtaPath toDestination:lastPath];
                if (zipArr.count == 0) {
                    [DFUITools showText:@"文件解压出错" onView:self.view delay:1.0];
                    return;
                }
                
                [self onUpdateOTA];
            }];
            return;
        }
        
        /*--- 设备需要【资源升级】和【OTA升级】 ---*/
        [self onUpdateResource:^{
            [self onUpdateOTA];
        }];
    }];
}






typedef void(^OTA_VIEW_BK)(void);
-(void)onUpdateResource:(OTA_VIEW_BK __nullable)result{

    self->isOtaUpdate = YES;
    
    /*--- 更新资源标志 ---*/
    [mCmdManager.mFlashManager cmdWatchUpdateResource];
    
    /*--- 展示手表更新资源UI ---*/
    NSLog(@"--->Fats Update UI.(OTA)");
    __block uint8_t m_flag = 0;
    [mCmdManager.mFlashManager cmdUpdateResourceFlashFlag:JL_FlashOperateFlagStart
                                                   Result:^(uint8_t flag) {
        m_flag = flag;
    }];
    if (m_flag != 0) {
        [JL_Tools mainTask:^{
            [DFUITools showText:@"升级请求失败!" onView:self.view delay:1.0];
        }];
        self->isOtaUpdate = NO;
        return;
    }

    [DialManager updateResourcePath:mOtaPath List:mWatchList
                             Result:^(DialUpdateResult updateResult,
                                      NSArray * _Nullable array,
                                      NSInteger index, float progress){
        [JL_Tools mainTask:^{
            if (updateResult == DialUpdateResultReplace) {
                [self otaTimeCheck];//增加超时检测
                
                NSString *fileName = array[index];
                self->lbOtaText.text = [NSString stringWithFormat:@"%@: %@(%d/%lu)...",@"正在更新表盘",
                                       fileName,(int)index+1,(unsigned long)array.count];
                self->lbProgress.text = [NSString stringWithFormat:@"%.1f%%",progress*100.0];
                self->otaProgressView.progress = progress;
                return;
            }
            if (updateResult == DialUpdateResultAdd) {
                [self otaTimeCheck];//增加超时检测
                
                NSString *fileName = array[index];
                self->lbOtaText.text = [NSString stringWithFormat:@"%@: %@(%d/%lu)...",@"正在传输新表盘",
                                       fileName,(int)index+1,(unsigned long)array.count];
                self->lbProgress.text = [NSString stringWithFormat:@"%.1f%%",progress*100.0];
                self->otaProgressView.progress = progress;
                return;
            }
            if (updateResult == DialUpdateResultFinished) self->lbOtaText.text = @"资源更新完成";
            if (updateResult == DialUpdateResultNewest)   self->lbOtaText.text = @"资源已是最新";
            if (updateResult == DialUpdateResultInvalid)  self->lbOtaText.text = @"无效资源文件";
            if (updateResult == DialUpdateResultEmpty)    self->lbOtaText.text = @"资源文件为空";
            if (updateResult == DialUpdateResultNoSpace)  self->lbOtaText.text = @"资源升级空间不足";
            [JL_Tools delay:1.0 Task:^{
                NSLog(@"---->Update result：%@ \n",self->lbOtaText.text);
                if (result) result();
            }];
        }];
    }];
}


-(void)noteOtaForce:(NSNotification*)note{
    if (isOtaUpdate == YES) {
        NSLog(@"--->继续OTA升级");
        self->mOtaPath = [JL_Tools getUserByKey:@"JL_OTA_PATH"];
        [self onUpdateOTA];
    }
}


-(void)onUpdateOTA{
    [self otaTimeCheck];//增加超时检测
    
    
    NSData *otaData = [self outputDataOfOtaPath:self->mOtaPath];
    
    /*--- 存储BLE地址 ---*/
    JLModel_Device *model = [mCmdManager outputDeviceModel];
    
    /*--- 开始OTA升级 ---*/
    [mCmdManager.mOTAManager cmdOTAData:otaData Result:^(JL_OTAResult result, float progress) {
        [JL_Tools mainTask:^{
            if (result == JL_OTAResultPreparing ||
                result == JL_OTAResultUpgrading)
            {
                self->isOtaUpdate = YES;
                [self otaTimeCheck];//增加超时检测
                
                if (result == JL_OTAResultUpgrading) self->lbOtaText.text = @"正在固件升级";
                if (result == JL_OTAResultPreparing) self->lbOtaText.text = @"检验文件";
                self->lbProgress.text = [NSString stringWithFormat:@"%.1f%%",progress*100.0];
                self->otaProgressView.progress = progress;
            }
            
            if (result == JL_OTAResultPrepared) {
                [self otaTimeCheck];//增加超时检测
                
                self->lbOtaText.text = @"等待升级...";
                self->otaProgressView.progress = 0.0f;
            }
            if (result == JL_OTAResultReconnect) {
                [self otaTimeCheck];//增加超时检测

                NSLog(@"---> OTA正在回连设备...");
                NSString *uuid = [JL_Tools getUserByKey:kUUID_BLE_LAST];
                [self->bleSDK.bt_ble connectPeripheralWithUUID:uuid];
            }
            
            if (result == JL_OTAResultReconnectWithMacAddr) {
                [self otaTimeCheck];//增加超时检测
                
                /*--- 存起model. ---*/
                NSString *bleAddr = model.bleAddr;
                [[JL_RunSDK sharedMe] setBleAddr:bleAddr];
                NSLog(@"---> OTA 保存地址:%@",bleAddr);

                //用BLE地址开启继续搜索回连...
                [[[JL_RunSDK sharedMe] bt_ble] startScanTimer];
            }
            
            if (result == JL_OTAResultSuccess || result == JL_OTAResultReboot) {
                self->otaProgressView.progress = 1.0f;
                self->lbOtaText.text = @"升级成功";
                [self endUpdateUI];
            }
            
            if (result == JL_OTAResultFail) {
                self->lbOtaText.text = @"OTA升级失败";
                [self endUpdateUI];
            }
            if (result == JL_OTAResultDataIsNull) {
                self->lbOtaText.text = @"OTA升级数据为空!";
                [self endUpdateUI];
            }
            if (result == JL_OTAResultCommandFail) {
                self->lbOtaText.text = @"OTA指令失败!";
                [self endUpdateUI];
            }
            if (result == JL_OTAResultSeekFail) {
                self->lbOtaText.text = @"OTA标示偏移查找失败!";
                [self endUpdateUI];
            }
            if (result == JL_OTAResultInfoFail) {
                self->lbOtaText.text = @"OTA升级固件信息错误!";
                [self endUpdateUI];
            }
            if (result == JL_OTAResultLowPower) {
                self->lbOtaText.text = @"OTA升级设备电压低!";
                [self endUpdateUI];
            }
            if (result == JL_OTAResultEnterFail) {
                self->lbOtaText.text = @"未能进入OTA升级模式!";
                [self endUpdateUI];
            }
            if (result == JL_OTAResultUnknown) {
                self->lbOtaText.text = @"OTA未知错误!";
                [self endUpdateUI];
            }
            if (result == JL_OTAResultFailSameVersion) {
                self->lbOtaText.text = @"相同版本!";
                [self endUpdateUI];
            }
            if (result == JL_OTAResultFailTWSDisconnect) {
                self->lbOtaText.text = @"TWS耳机未连接";
                [self endUpdateUI];
            }
            if (result == JL_OTAResultFailNotInBin) {
                self->lbOtaText.text = @"耳机未在充电仓";
                [self endUpdateUI];
            }
        }];
    }];
}


-(NSData*)outputDataOfOtaPath:(NSString*)path{
    
    NSString *zipName = [path lastPathComponent];
    NSString *folderName = [zipName stringByReplacingOccurrencesOfString:@".zip" withString:@""];
    
    NSString *zipPath = [JL_Tools listPath:NSDocumentDirectory MiddlePath:folderName File:@""];
    NSArray  *zipArray  = [JL_Tools subPaths:zipPath];
    
    for (NSString *name in zipArray) {
        if ([name hasSuffix:@".ufw"]) {
            NSString *otaPath = [JL_Tools listPath:NSDocumentDirectory MiddlePath:folderName File:name];
            NSLog(@"---->Start OTA：%@ ",otaPath);            
            NSData   *otaData = [NSData dataWithContentsOfFile:otaPath];
            return otaData;
        }
    }
    return nil;
}


static NSTimer  *otaTimer = nil;
static int      otaTimeout= 0;
-(void)otaTimeCheck{
    otaTimeout = 0;
    if (otaTimer == nil) {
        otaTimer = [JL_Tools timingStart:@selector(otaTimeAdd)
                                  target:self Time:1.0];
    }
}

-(void)otaTimeClose{
    [JL_Tools timingStop:otaTimer];
    otaTimeout = 0;
    otaTimer = nil;
}

-(void)otaTimeAdd{
    otaTimeout++;
    if (otaTimeout == 20) {
        self->isOtaUpdate = NO;
        [self otaTimeClose];
        self->lbOtaText.text = @"OTA升级超时";
        NSLog(@"OTA ---> 超时了！！！");
        [self removeOTAzip];
    }
}


-(void)endUpdateUI{
    isOtaUpdate = NO;
    [self otaTimeClose];
    [self removeOTAzip];
    [JL_Tools subTask:^{
        NSLog(@"--->Fats Update UI END.1");
        [self->mCmdManager.mFlashManager cmdUpdateResourceFlashFlag:JL_FlashOperateFlagFinish
                                                             Result:nil];
    }];
    
    [JL_Tools delay:3.0 Task:^{
        [self btn_Back:nil];
    }];
}


-(void)removeOTAzip{
    if (self->mOtaPath.length>0) {
        NSString *path = [self->mOtaPath stringByReplacingOccurrencesOfString:@".zip" withString:@""];
        [JL_Tools removePath:path];
        NSLog(@"Del ---> %@",path);
    }
}

- (IBAction)btn_Back:(id)sender {
    if (isOtaUpdate == NO) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [DFUITools showText:@"正在升级..." onView:self.view delay:1.0];
    }
    
}


@end
