//
//  OtaView.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/9.
//



#import "OtaView.h"
#import "User_Http.h"


@interface OtaView(){
    
    __weak IBOutlet UIView *subBgView_0;
    __weak IBOutlet UIView *subBgView_1;
    __weak IBOutlet UIView *subBgView_2;
    
    __weak IBOutlet UIButton *btnCancel_0;
    __weak IBOutlet UIButton *btnUpdate_0;
    
    __weak IBOutlet NSLayoutConstraint *subBgView_G_0;
    __weak IBOutlet NSLayoutConstraint *subBgView_G_1;
    __weak IBOutlet NSLayoutConstraint *subBgView_G_2;

    DFHttp1         *http1;
    
    NSString        *pid_str;
    NSString        *vid_str;
}

@end


@implementation OtaView

- (instancetype)initByFrame:(CGRect)frame
{
    self = [DFUITools loadNib:@"OtaView"];
    if (self) {
        [[JL_RunSDK sharedMe] setIsOtaUpgrading:YES];
        
        self.frame = frame;
        subBgView_0.layer.cornerRadius = 15.0;
        subBgView_1.layer.cornerRadius = 15.0;
        subBgView_2.layer.cornerRadius = 15.0;
        
        subBgView_G_0.constant = 25;
        subBgView_G_1.constant = 25;
        subBgView_G_2.constant = 25;
        
        subBgView_0.hidden = YES;
        subBgView_1.hidden = YES;
        subBgView_2.hidden = YES;
        

        
        [self.sureBtn setTitle:kJL_TXT("确定") forState:UIControlStateNormal];
        self.updateLabel.text = kJL_TXT("升级过程中，请保持蓝牙和网络打开状态");
        [btnCancel_0 setTitle:kJL_TXT("取消") forState:UIControlStateNormal];
        [btnUpdate_0 setTitle:kJL_TXT("升级") forState:UIControlStateNormal];
        NSString *titleName = [NSString stringWithFormat:@"%@%@",kJL_TXT("新版本"),@"v1.0"];
        self.otaTitle.text = titleName;
        http1 = [[DFHttp1 alloc] init];
        

        
        JL_EntityM *nowEntity = kJL_BLE_EntityM;
        int vid = (int)[JL_Tools dataToInt:[JL_Tools HexToData:nowEntity.mVID]];
        int pid = (int)[JL_Tools dataToInt:[JL_Tools HexToData:nowEntity.mPID]];
        
        if (nowEntity.mVID == NULL) {
            JLModel_Device *model = [kJL_BLE_CmdManager outputDeviceModel];
            NSData *pidVidData = [JL_Tools HexToData:model.pidvid];
            vid = (int)[JL_Tools dataToInt:[JL_Tools data:pidVidData R:0 L:2]];
            pid = (int)[JL_Tools dataToInt:[JL_Tools data:pidVidData R:2 L:2]];
        }
        
        vid_str = [NSString stringWithFormat:@"%d",vid];
        pid_str = [NSString stringWithFormat:@"%d",pid];
        NSLog(@"OTA_0--->Vid:%@ Pid:%@",vid_str,pid_str);
        
        [self addNote];
    }
    return self;
}

-(void)setSubUiType:(int)subUiType{
    _subUiType = subUiType;
    [self setupUIType:subUiType];
}

-(void)setupUIType:(int)type{
    subBgView_0.hidden = YES;
    subBgView_1.hidden = YES;
    subBgView_2.hidden = YES;
    
    if (type == 0) {//UI:检测升级
        subBgView_0.hidden = NO;
    }
    
    if (type == 1) {//UI:正在更新（无进度）
        subBgView_1.hidden = NO;
        self.progressTxt.hidden = YES;
        self.progressView.hidden= YES;
        self.actView.hidden = NO;
    }
    
    if (type == 2) {//UI:正在升级（有进度）
        subBgView_1.hidden = NO;
        self.progressTxt.hidden = NO;
        self.progressView.hidden= NO;
        self.actView.hidden = YES;
    }
    
    if (type == 3) {//UI:升级结果
        subBgView_2.hidden = NO;
    }
}

- (IBAction)btn_0_Cancel:(id)sender {
    self.hidden = YES;
}

- (IBAction)btn_0_Update:(id)sender {
    
    JLModel_Device *model = [kJL_BLE_CmdManager outputDeviceModel];
    if(model.battery<model.lowBattery){
        [self setupUIErrorText:kJL_TXT("OTA升级设备电压低!")];
        return;
    }

#if IS_OTA_NET
    NSString *version   = self.otaDict[@"version"];
    NSString *updateZip = [NSString stringWithFormat:@"upgrade_%@",version];
    NSString *zipPath   = [JL_Tools findPath:NSDocumentDirectory MiddlePath:updateZip File:@""];
    
    if (zipPath.length > 0) {
        //存在直接升级
        [self actionUpdateResourceAndOTA];
    }else{
        [self setSubUiType:2];
        
        NSString *url = self.otaDict[@"url"];
        
        if (url.length == 0) {
            [[User_Http shareInstance] getNewOTAFile:pid_str WithVid:vid_str Result:^(NSDictionary * _Nonnull info) {
                if (info != nil) {
                    [JL_Tools mainTask:^{
                        self.otaDict = info[@"data"];
                        if (![self.otaDict isEqual:[NSNull null]]) {
                            NSString *aUrl    = self.otaDict[@"url"];
                            NSString *aVersion = self.otaDict[@"version"];
                            NSString *aUpdateZip = [NSString stringWithFormat:@"upgrade_%@.zip",aVersion];
                            [self downloadZipUrl:aUrl ZipName:aUpdateZip];
                        }else{
                            [self setupUIErrorText:kJL_TXT("下载失败!")];
                        }
                    }];
                }else{
                    [JL_Tools mainTask:^{
                        [self setupUIErrorText:kJL_TXT("下载失败!")];
                    }];
                }
            }];
        }else{
            NSString *aUpdateZip = [NSString stringWithFormat:@"upgrade_%@.zip",version];
            [self downloadZipUrl:url ZipName:aUpdateZip];
        }
    }
#else
    //存在直接升级
    [self actionUpdateResourceAndOTA];
#endif
}






-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType type = [[note object] integerValue];
    if (type == JLDeviceChangeTypeInUseOffline ||
        type == JLDeviceChangeTypeBleOFF) {

        
        if (_isOtaRelink == NO) {
            NSLog(@"当前设备已断开，下载任务取消。");
            [[User_Http shareInstance] cancelDownloadTask];
        }
        
    }
}

-(void)noteForceOta:(NSNotification*)note{
    NSLog(@"---> Note Force Ota.");
    [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];
    [self onUpdateOTA];
}


-(void)downloadZipUrl:(NSString*)url ZipName:(NSString*)name{
    NSString *updatePath = [JL_Tools listPath:NSDocumentDirectory MiddlePath:@"" File:name];
    [JL_Tools removePath:updatePath];
    
    [[User_Http shareInstance] downloadUrl:url Path:updatePath Result:^(float progress, JLHTTP_Result result) {
        [JL_Tools mainTask:^{
            self.updateTxt.text = kJL_TXT("下载固件");
            if (result == JLHTTP_ResultDownload) {
                self.progressTxt.text = [NSString stringWithFormat:@"%.1f%%",progress*100.0];
                self.progressView.progress = progress;
            }
            if (result == JLHTTP_ResultSuccess) {
                /*--- 现在完直接升级 ---*/
                [self actionUpdateResourceAndOTA];
            }
            if (result == JLHTTP_ResultFail) {
                [self setupUIErrorText:kJL_TXT("下载失败!")];
            }
        }];
    }];
}



-(void)actionUpdateResourceAndOTA{
    JLModel_Device *model = [kJL_BLE_CmdManager outputDeviceModel];
    
    if (model.otaStatus == JL_OtaStatusForce) {
        /*--- 只需要【OTA升级】 ---*/
        [JL_Tools mainTask:^{
            [self onUpdateOTA];
        }];
    }else{
        /*--- 需要【资源升级】和【OTA升级】 ---*/
        [self setSubUiType:2];
        [self otaTimeCheck];//增加超时检测
        self.updateTxt.text = kJL_TXT("更新资源");
        [self.actView startAnimating];
    
        
        [kJL_BLE_CmdManager.mFlashManager cmdWatchUpdateResourceWith:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
            if(status == JL_CMDStatusSuccess){

                //发命令请求资源更新
                [kJL_BLE_CmdManager.mFlashManager cmdUpdateResourceFlashFlagAsync:JL_FlashOperateFlagStart Result:^(uint8_t flag) {
                    if (flag != 0) {
                        [JL_Tools mainTask:^{
                            [self setupUIErrorText:kJL_TXT("升级请求失败!")];
                        }];
                    }else{
                        [self updateAction];
                    }
                }];
                
            }else{
                [JL_Tools mainTask:^{
                    [self setupUIErrorText:kJL_TXT("设备电量必须在30%以上才能升级")];
                }];
                return;
            }
        }];
       
    }
}


-(void)updateAction{
    
    
#if IS_OTA_NET
    NSString *version = self.otaDict[@"version"];
    NSString *updateZip = [NSString stringWithFormat:@"upgrade_%@.zip",version];
    NSString *updatePath= [JL_Tools listPath:NSDocumentDirectory MiddlePath:@"" File:updateZip];
#else
    NSString *version = self.otaDict[@"version"];
    NSString *versionPath = [NSString stringWithFormat:@"upgrade_%@.zip",version];
    
    /*--- 删掉旧的升级资源文件 ---*/
    NSString *lastZip = [NSString stringWithFormat:@"upgrade_%@",version];
    NSString *lastPath = [JL_Tools listPath:NSDocumentDirectory MiddlePath:lastZip File:@""];
    [JL_Tools removePath:lastPath];
    
    //NSString *updatePath = [JL_Tools find:versionPath];
    NSString *updatePath = [JL_Tools listPath:NSDocumentDirectory MiddlePath:@"" File:versionPath];
#endif

    
    NSArray *nowList = [kJL_DIAL_CACHE getWatchList];
    [DialManager updateResourcePath:updatePath List:nowList
                             Result:^(DialUpdateResult updateResult, NSArray * _Nullable array,
                                      NSInteger index, float progress){
        [JL_Tools mainTask:^{
            if (updateResult == DialUpdateResultReplace) {
                [self otaTimeCheck];//增加超时检测
                
                NSString *fileName = array[index];
                self.updateTxt.text = [NSString stringWithFormat:@"%@: %@(%d/%lu)...",kJL_TXT("正在更新表盘"),
                                       fileName,(int)index+1,(unsigned long)array.count];
                self.progressTxt.text = [NSString stringWithFormat:@"%.1f%%",progress*100.0];
                self.progressView.progress = progress;
                return;
            }
            if (updateResult == DialUpdateResultAdd) {
                [self otaTimeCheck];//增加超时检测
                
                NSString *fileName = array[index];
                self.updateTxt.text = [NSString stringWithFormat:@"%@: %@(%d/%lu)...",kJL_TXT("正在传输新表盘"),
                                       fileName,(int)index+1,(unsigned long)array.count];
                self.progressTxt.text = [NSString stringWithFormat:@"%.1f%%",progress*100.0];
                self.progressView.progress = progress;
                return;
            }
            if (updateResult == DialUpdateResultFinished) self.updateTxt.text = kJL_TXT("资源更新完成");
            if (updateResult == DialUpdateResultNewest)   self.updateTxt.text = kJL_TXT("资源已是最新");
            if (updateResult == DialUpdateResultInvalid)  self.updateTxt.text = kJL_TXT("无效资源文件");
            if (updateResult == DialUpdateResultEmpty)    self.updateTxt.text = @"等待升级";//kJL_TXT("资源文件为空");
            if (updateResult == DialUpdateResultNoSpace)  self.updateTxt.text = @"等待升级";
            if (updateResult == DialUpdateResultCompareFail)  self.updateTxt.text = @"等待升级";
            [JL_Tools delay:1.0 Task:^{
                NSLog(@"---->Update result：%@ ",self.updateTxt.text);
//                if (result) result();
                [self onUpdateOTA];
            }];
        }];
    }];
}

-(void)onUpdateOTA{
    [self setSubUiType:2];
    self->_isOtaRelink = NO;
    
    [self otaTimeCheck];//增加超时检测
    
    /*--- 获取OTA文件路径 ---*/
    NSString *version = self.otaDict[@"version"];
    NSString *zipFolder = [NSString stringWithFormat:@"upgrade_%@",version];
    NSString *zipFolderPath = [JL_Tools findPath:NSDocumentDirectory MiddlePath:zipFolder File:@""];
    
    /*--- 解压文件为空 ---*/
    if (zipFolderPath == nil) {
        
        NSString *updateZip = [NSString stringWithFormat:@"upgrade_%@.zip",version];
        NSString *updatePath= [JL_Tools listPath:NSDocumentDirectory MiddlePath:@"" File:updateZip];
        
        zipFolderPath = [JL_Tools createOn:NSDocumentDirectory MiddlePath:zipFolder File:@""];
        [FatfsObject unzipFileAtPath:updatePath toDestination:zipFolderPath];
    }
    
    
    NSData   *otaData = nil;
    NSArray *otaPathArray = [JL_Tools subPaths:zipFolderPath];
    NSString *otaPath;
    for (NSString *itemPath in otaPathArray) {
        if ([itemPath hasSuffix:@".ufw"]) {
            otaPath = [zipFolderPath stringByAppendingPathComponent:itemPath];
            otaData = [NSData dataWithContentsOfFile:otaPath];
            NSLog(@"--->OTA升级路径：%@",otaPath);
            break;
        }
    }
    
    /*--- 开始OTA升级 ---*/
    [[JL_RunSDK sharedMe] setIsOTAFailRelink:YES];
    [kJL_BLE_CmdManager.mOTAManager cmdOTAData:otaData Result:^(JL_OTAResult result, float progress) {
        [self handleOtaAction:result progress:progress];
    }];
}




-(void)handleOtaAction:(JL_OTAResult) result progress:(float)progress{
    [JL_Tools mainTask:^{
        switch (result){
            case JL_OTAResultReboot:
            case JL_OTAResultSuccess:{
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
                self.progressView.progress = 1.0f;
                [self removeOTAPath];
                
                [JL_Tools delay:0.5 Task:^{
                    [self setupUISuccess];
                    if (result == JL_OTAResultSuccess)  [JL_Tools post:kUI_OTA_IS_OK Object:nil];
                }];
            }break;
            case JL_OTAResultFail:{
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:YES];
                [self setupUIErrorText:kJL_TXT("OTA升级失败")];
            }break;
            case JL_OTAResultDataIsNull:{
                [self setupUIErrorText:kJL_TXT("OTA升级数据为空!")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            case JL_OTAResultCommandFail:{
                [self setupUIErrorText:kJL_TXT("OTA指令失败!")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            case JL_OTAResultSeekFail:{
                [self setupUIErrorText:kJL_TXT("读取数据偏移出错")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            case JL_OTAResultInfoFail:{
                [self setupUIErrorText:kJL_TXT("升级文件信息错误")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            case JL_OTAResultLowPower:{
                [self setupUIErrorText:kJL_TXT("设备电量必须在30%以上才能升级")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            case JL_OTAResultEnterFail:{
                [self setupUIErrorText:kJL_TXT("设备返回失败的状态")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            
            case JL_OTAResultReconnect:{
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
                [self otaTimeCheck];//增加超时检测
                self->_isOtaRelink = YES;
                
                NSLog(@"---> OTA回连设备... %@",self.otaUUID);
                
                JL_BLEMultiple *mp = [[JL_RunSDK sharedMe] mBleMultiple];
                JL_EntityM * otaEntity = [mp makeEntityWithUUID:self.otaUUID];
                

                [kJL_BLE_Multiple connectEntity:otaEntity Result:^(JL_EntityM_Status status) {
                    self->_isOtaRelink = NO;
                    if (status != JL_EntityM_StatusPaired) {
                        [self setupUIErrorText:kJL_TXT("OTA升级失败")];
                    }
                    if (status == JL_EntityM_StatusPaired){
                        [[JL_RunSDK sharedMe] setMBleEntityM:otaEntity];
                    }
                }];
            }break;
            case JL_OTAResultUpgrading:
            case JL_OTAResultPreparing:{
                [self otaTimeCheck];//增加超时检测

                if (result == JL_OTAResultUpgrading) {
                    self.updateTxt.text = kJL_TXT("正在升级");
                }
                if (result == JL_OTAResultPreparing) {
                    self.updateTxt.text = kJL_TXT("检验文件");
                }
                self.progressTxt.text = [NSString stringWithFormat:@"%.1f%%",progress*100.0];
                self.progressView.progress = progress;
            }break;
            case JL_OTAResultPrepared:{
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
                
                self->_isOtaRelink = YES;
                [self otaTimeCheck];//增加超时检测
                
                self.updateTxt.text = kJL_TXT("等待升级");
                self.progressView.progress = 0.0f;
            }break;
            case JL_OTAResultFailVerification:{
                [self setupUIErrorText:kJL_TXT("升级数据校验出错")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            case JL_OTAResultFailCompletely:{
                [self setupUIErrorText:kJL_TXT("升级失败")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            case JL_OTAResultFailKey:{
                [self setupUIErrorText:kJL_TXT("密钥不匹配")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            case JL_OTAResultFailErrorFile:{
                [self setupUIErrorText:kJL_TXT("升级文件信息错误")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            case JL_OTAResultFailUboot:{
                [self setupUIErrorText:kJL_TXT("UBoot不匹配")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            case JL_OTAResultFailLenght:{
                [self setupUIErrorText:kJL_TXT("升级过程出现长度错误")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            case JL_OTAResultFailFlash:{
                [self setupUIErrorText:kJL_TXT("出现Flash读写错误")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            case JL_OTAResultFailCmdTimeout:{
                    [self setupUIErrorText:kJL_TXT("命令超时")];
                    [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            case JL_OTAResultFailSameVersion:{
                [self setupUIErrorText:kJL_TXT("升级文件版本相同")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            case JL_OTAResultFailTWSDisconnect:{
                [self setupUIErrorText:kJL_TXT("设备未处于配对连接状态")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            case JL_OTAResultFailNotInBin:{
                [self setupUIErrorText:kJL_TXT("耳机未在充电仓")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            }break;
            case JL_OTAResultReconnectWithMacAddr:{
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
                [self otaTimeCheck];//增加超时检测
                self->_isOtaRelink = YES;
                NSLog(@"---> OTA 设备当前UUID... %@",self.otaUUID);
                //[[JL_RunSDK sharedMe] setAncsUUID:self.otaUUID];
                [JL_Tools post:kUI_JL_BLE_SCAN_OPEN Object:nil];
            }break;
            case JL_OTAResultUnknown:{
                [self setupUIErrorText:kJL_TXT("未知的升级错误")];
                [[JL_RunSDK sharedMe] setIsOTAFailRelink:NO];
            } break;
        }
    }];
}



-(void)removeOTAPath{
    NSString *version   = self.otaDict[@"version"];
    NSString *updateZip = [NSString stringWithFormat:@"upgrade_%@",version];
    NSString *otaPath = [JL_Tools listPath:NSDocumentDirectory MiddlePath:updateZip File:@""];
    //NSString *updateZipPath = [NSString stringWithFormat:@"upgrade_%@.zip",version];
    //NSString *otaPath2 = [JL_Tools listPath:NSDocumentDirectory MiddlePath:@"" File:updateZipPath];
    //[JL_Tools removePath:otaPath2];
    [JL_Tools removePath:otaPath];
}


- (IBAction)btn_2_Confirm:(id)sender {
    self.hidden = YES;
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
    if (otaTimeout == 30) {
        [self otaTimeClose];
        [self setupUIErrorText:kJL_TXT("OTA升级超时")];
        NSLog(@"OTA ---> 超时了！！！");
    }
}

-(void)setupUIErrorText:(NSString*)text{
    [self setupUIType:3];
    self.resultImage.image = [UIImage imageNamed:@"icon_fail_nol"];
    self.resultTxt.text = text;
    [self otaTimeClose];
    
    [self endUpdateUI];//关闭手表的更新UI
}

-(void)setupUISuccess{
    [self setupUIType:3];
    self.resultImage.image = [UIImage imageNamed:@"icon_success_nol"];
    self.resultTxt.text = kJL_TXT("升级完成");
    [self otaTimeClose];
    
    [self endUpdateUI];//关闭手表的更新UI
}

-(void)endUpdateUI{
    [JL_Tools subTask:^{
        NSLog(@"--->Fats Update UI END.1");
        [kJL_BLE_CmdManager.mFlashManager cmdUpdateResourceFlashFlag:JL_FlashOperateFlagFinish Result:nil];
    }];
}

-(void)showOtaError{
    [self setupUIType:3];
    self.resultImage.image = [UIImage imageNamed:@"icon_fail_nol"];
    self.resultTxt.text = kJL_TXT("蓝牙断开");
    [self otaTimeClose];
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_OTA Action:@selector(noteForceOta:) Own:self];
}

-(void)remoteNote{
    [[JL_RunSDK sharedMe] setIsOtaUpgrading:NO];
    [JL_Tools remove:kUI_JL_DEVICE_OTA Own:self];
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}


-(void)dealloc{
    [[JL_RunSDK sharedMe] setIsOtaUpgrading:NO];
    [self remoteNote];
}

@end
