//
//  OtaUpdateVC.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/9.
//

#import "OtaUpdateVC.h"
#import "User_Http.h"

@interface OtaUpdateVC (){
    
    __weak IBOutlet NSLayoutConstraint  *subTitleView_H;
    __weak IBOutlet UIButton            *btnUpdate;
    __weak IBOutlet UILabel             *lb_0;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *currentVersionLabel;
    __weak IBOutlet UILabel *fireworkUpdateLabel;
    __weak IBOutlet UIButton *checkUpdateBtn;
    
    OtaView                             *otaView;
    Ota4GView                           *ota4GView;
    
    JL_RunSDK                           *bleSDK;
    JL_ManagerM                         *mCmdManager;
    NSString                            *deviceVersion;
    
    NSString                            *pid_str;
    NSString                            *vid_str;
    
}

@end

@implementation OtaUpdateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    //[self actionToUpdate];
    [self addNote];
 
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)handleOTA4G{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLDeviceConfigModel *config = [[JL_RunSDK sharedMe] configModel];
    if (config) {
        if (config.exportFunc.sp4GModel){
            [[User_Http shareInstance] getNew4GOtaFile:entity.mPID withVid:entity.mVID G4Vendor:[[JL_RunSDK sharedMe] g4ModelVendor] result:^(NSDictionary * _Nonnull info) {
                JLPublic4GModel *model = [[JL_RunSDK sharedMe] g4Model];
                NSLog(@"%@\n current version:%@",info,model.version);
                NSDictionary *targetDict = info[@"data"];
                if ([targetDict isEqual:[NSNull null]]) {
                    [self checkSDKUpdate];
                    return;
                }
                if ([targetDict[@"version"] isEqual:model.version]) {
                    [self checkSDKUpdate];
                    return;
                }
                if (model.version.length == 0){
                    kJLLog(JLLOG_ERROR, @"---> 4G model fail to get version. skip ths step. ");
                    [self checkSDKUpdate];
                    return;
                }
                self->ota4GView.targetDict = targetDict;
                self->ota4GView.nowVersion = model.version;
                self->ota4GView.cmdManager = kJL_BLE_CmdManager;
                NSString * titleStr = [NSString stringWithFormat:@"%@ %@",kJL_TXT("最新版本"),targetDict[@"version"]];
                NSString *contentStr = [NSString stringWithFormat:@"%@",targetDict[@"content"]];
                self->ota4GView.hidden = false;
                [self->ota4GView.otaUpdateTips updateViewWithTitle:titleStr content:contentStr];
            }];
        }else{
            [self checkSDKUpdate];
        }
    }else{
        [self checkSDKUpdate];
    }
}


-(void)setupUI{
    float sW = [UIScreen mainScreen].bounds.size.width;
    float sH = [UIScreen mainScreen].bounds.size.height;
    
    subTitleView_H.constant = kJL_HeightNavBar;
    btnUpdate.layer.cornerRadius = 16.0;
    
    titleLabel.text = kJL_TXT("设备版本更新");
    currentVersionLabel.text = kJL_TXT("当前版本");
    fireworkUpdateLabel.text = kJL_TXT("固件更新");
    [checkUpdateBtn setTitle:kJL_TXT("检查更新") forState:UIControlStateNormal];
    
    
    bleSDK = [JL_RunSDK sharedMe];
    
    [JL_Tools delay:0.2 Task:^{
        CGRect rect = CGRectMake(0, 0, sW, sH);
        self->otaView = [[OtaView alloc] initByFrame:rect];
//        self->otaView.otaEntity = [JL_RunSDK getEntity:self->bleSDK.mBleUUID];
        self->otaView.otaUUID = self->bleSDK.mBleUUID;
        [self.view addSubview:self->otaView];
        self->otaView.hidden = YES;
    }];
    
    [kJL_BLE_CmdManager.mOTAManager logSendData:false];

    JLModel_Device *model = [kJL_BLE_CmdManager getDeviceModel];
    deviceVersion = model.versionFirmware;
    lb_0.text = [NSString stringWithFormat:@"v%@",deviceVersion];
    
    NSData *pidVidData = [JL_Tools HexToData:model.pidvid];
    int vid = [pidVidData subf:0 t:2].beBigendUint16;
    int pid = [pidVidData subf:2 t:2].beBigendUint16;
    NSLog(@"OTA_1--->Vid:%d Pid:%d line:%d data：%@",vid,pid,__LINE__,model.pidvid);
    
    vid_str = [NSString stringWithFormat:@"%d",vid];
    pid_str = [NSString stringWithFormat:@"%d",pid];
    
    if (vid == 0 || pid == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setupUI];
        });
        return;
    }

    ota4GView = [[Ota4GView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:ota4GView];
    
    [ota4GView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [ota4GView setHidden:true];
    
    ota4GView.viewController = self;
    __weak typeof(self) weakSelf = self;
    ota4GView.handleFinish = ^{
        __strong typeof(self) strongSelf = weakSelf;
        JL_EntityM *nowEntity = kJL_BLE_EntityM;
        [[JL4GUpgradeManager share] cmdGetDevice4GInfo:nowEntity.mCmdManager result:^(JL_CMDStatus status, JLPublic4GModel * _Nullable model) {
            [model logProperties];
            [[JL_RunSDK sharedMe] setG4ModelVendor:model.vendor];
            [[JL_RunSDK sharedMe] setG4Model:model];
            [strongSelf handleOTA4G];
        }];
        
    };
    
    ota4GView.handleCancel = ^{
        if ([[JL_RunSDK sharedMe] g4Model].updateStatus == 1){
            [kJL_BLE_Multiple disconnectEntity:kJL_BLE_EntityM Result:^(JL_EntityM_Status status) {
                
            }];
        }
    };
    
    if (self.funcType == 1){
        [self handleOTA4G];
    }
    
}



- (IBAction)btn_back:(id)sender {
    [otaView remoteNote];
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
    [JL_Tools remove:kUI_OTA_IS_OK Own:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btn_check:(id)sender {
    [self handleOTA4G];
}


-(void)checkSDKUpdate{
#if IS_OTA_NET
    [[User_Http shareInstance] getNewOTAFile:pid_str WithVid:vid_str Result:^(NSDictionary * _Nonnull info) {
        NSLog(@"%@",info);
        if (info != nil) {
            NSDictionary *otaDict = info[@"data"];
            [JL_Tools mainTask:^{
                if (![otaDict isEqual:[NSNull null]]) {
                    NSString *serverVersion = info[@"data"][@"version"];
                    NSString *content       = info[@"data"][@"content"];
                    NSString *versionText = [NSString stringWithFormat:@"%@:v%@",kJL_TXT("最新版本"),serverVersion];
                    self->otaView.otaTitle.text = versionText;
                    self->otaView.otaTextView.text = [content stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
                    self->otaView.otaDict = info[@"data"];
                    
                    self->otaView.hidden = NO;
                    [self->otaView setSubUiType:0];
                }else{
                    [DFUITools showText:kJL_TXT("下载失败!") onView:self.view delay:1.0];
                }
            }];
        }else{
            [JL_Tools mainTask:^{
                [DFUITools showText:kJL_TXT("操作失败，请检查网络") onView:self.view delay:1.0];
            }];
        }
    }];
#else
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:kJL_TXT("提示") message:nil
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnCancel = [UIAlertAction actionWithTitle:kJL_TXT("取消") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *btnOTA_0 = [UIAlertAction actionWithTitle:@"升级包00" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {

        self->otaView.otaTitle.text = @"0.0.0.0";
        self->otaView.otaTextView.text = @"测试升级";
        self->otaView.otaDict = @{@"version":@"0.0.0.0"};
        
        self->otaView.hidden = NO;
        [self->otaView setSubUiType:0];
    }];
    UIAlertAction *btnOTA_1 = [UIAlertAction actionWithTitle:@"升级包01" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {

        self->otaView.otaTitle.text = @"0.0.0.1";
        self->otaView.otaTextView.text = @"测试升级";
        self->otaView.otaDict = @{@"version":@"0.0.0.1"};

        self->otaView.hidden = NO;
        [self->otaView setSubUiType:0];
    }];
    UIAlertAction *btnOTA_3 = [UIAlertAction actionWithTitle:@"升级包03" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {

        self->otaView.otaTitle.text = @"0.0.0.3";
        self->otaView.otaTextView.text = @"测试升级";
        self->otaView.otaDict = @{@"version":@"0.0.0.3"};

        self->otaView.hidden = NO;
        [self->otaView setSubUiType:0];
    }];
    [actionSheet addAction:btnCancel];
    [actionSheet addAction:btnOTA_0];
    [actionSheet addAction:btnOTA_1];
    [actionSheet addAction:btnOTA_3];
    [self presentViewController:actionSheet animated:YES completion:nil];
    
#endif

}

-(void)actionToUpdate{
    [JL_Tools delay:0.15 Task:^{
        
#if IS_OTA_NET
        self->otaView.hidden = NO;
        [self->otaView btn_0_Update:@""];
#else
        [DFUITools showText:@"请检查更新." onView:self.view delay:2.0];
#endif
    }];
}



-(BOOL)shouldUpdate:(NSString *)version0 local:(NSString *)version1{
    if ([version0 isEqual:@"0.0.0.0"]) {
        NSLog(@"服务器测试升级");
        return YES;
    }
    if (version0.length==0) {
         NSLog(@"服务器获取到的版本号为空");
         return YES;
     }
    if (version1.length==0 || [version1 isEqual:@""]) {
        NSLog(@"本地升级信息为空：%@",version1);
        return YES;
    }
    NSArray *arr0 = [version0 componentsSeparatedByString:@"."];
    NSArray *arr1 = [version1 componentsSeparatedByString:@"."];

    uint8_t ver0_0 = (uint8_t)[arr0[0] intValue];
    uint8_t ver0_1 = (uint8_t)[arr0[1] intValue];
    uint8_t ver0_2 = (uint8_t)[arr0[2] intValue];
    uint8_t ver0_3 = (uint8_t)[arr0[3] intValue];
    
    uint8_t ver1_0 = (uint8_t)[arr1[0] intValue];
    uint8_t ver1_1 = (uint8_t)[arr1[1] intValue];
    uint8_t ver1_2 = (uint8_t)[arr1[2] intValue];
    uint8_t ver1_3 = (uint8_t)[arr1[3] intValue];
    
    short ver0_h = (ver0_0<<4) + ver0_1;
    short ver0_l = (ver0_2<<4) + ver0_3;
    
    short ver1_h = (ver1_0<<4) + ver1_1;
    short ver1_l = (ver1_2<<4) + ver1_3;
    
    short ver0_short = (ver0_h<<8)+ver0_l;
    short ver1_short = (ver1_h<<8)+ver1_l;

    if (ver0_short > ver1_short) {
        return YES;
    }else{
        return NO;
    }
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [[note object] intValue];
    if (tp == JLDeviceChangeTypeBleOFF ||
        tp == JLDeviceChangeTypeInUseOffline) {
        //普通断开
        if (otaView.isOtaRelink == NO) {
            [otaView showOtaError];
            [JL_Tools delay:1.0 Task:^{
                [self btn_back:nil];
            }];
        }
    }
}
-(void)noteOtaIsOk:(NSNotification*)note{
    [JL_Tools delay:2.0 Task:^{
        [self btn_back:nil];
        NSLog(@"OTA升级回连设备1");
        [JL_Tools post:kUI_RECONNECT_TO_DEVICE Object:nil];
    }];
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JL_Tools add:kUI_OTA_IS_OK Action:@selector(noteOtaIsOk:) Own:self];
}

-(void)viewDidAppear:(BOOL)animated{
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

-(void)dealloc{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
    [JL_Tools remove:kUI_OTA_IS_OK Own:self];
}
@end
