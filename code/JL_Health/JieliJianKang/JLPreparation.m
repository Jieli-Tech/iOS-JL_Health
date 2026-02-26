//
//  JLPreparation.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/9/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "JLPreparation.h"
#import "SyncDataManager.h"
#import "OtaUpdateVC.h"
//#import "JLUI_Cache.h"

//#import "SqliteManager.h"
//#import "MapLocationRequest.h"
//#import "EQDefaultCache.h"
//#import "CorePlayer.h"

NSString *kUI_JL_UUID_PREPARATE_OK = @"UI_JL_UUID_PREPARATE_OK";


@interface JLPreparation(){
    int     timeout;
    NSTimer *actionTimer;
    int     preparateTimce;
}

@end

@implementation JLPreparation

- (instancetype)init
{
    self = [super init];
    if (self) {
        timeout = 0;
        preparateTimce = 0;
        self.isPreparateOK = 0;
        [SyncDataManager share];
        
    }
    return self;
}

-(void)actionPreparation{
    __weak typeof(self) wSelf = self;
    
    self.isPreparateOK = 1;
    [self startTimeout];
 
    /*--- 关闭耳机信息推送 ---*/
    NSLog(@"--->(1) TURN OFF headset push.");
    [self.mBleEntityM.mCmdManager.mTwsManager cmdHeadsetAdvEnable:NO];
    
    /*--- 同步时间戳 ----*/
    NSLog(@"--->(2) SET Device time.");
    NSDate *date = [NSDate new];
    JL_SystemTime *systemTime = self.mBleEntityM.mCmdManager.mSystemTime;
    
    NSDateFormatter *forMatter = [EcTools cachedFm];
    [forMatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *dateStr = [forMatter stringFromDate:date];
    NSArray *time_Set = [dateStr componentsSeparatedByString:@"-"];
    
    uint16_t year = (uint16_t)[time_Set[0] intValue];
    uint8_t  month= (uint8_t)[time_Set[1] intValue];
    uint8_t  day  = (uint8_t)[time_Set[2] intValue];
    uint8_t  hour = (uint8_t)[time_Set[3] intValue];
    uint8_t  min  = (uint8_t)[time_Set[4] intValue];
    uint8_t  sec  = (uint8_t)[time_Set[5] intValue];
    [systemTime cmdSetSystemYear:year Month:month Day:day Hour:hour Minute:min Second:sec];

    /*--- 清除设备音乐缓存 ---*/
    [self.mBleEntityM.mCmdManager.mFileManager cmdCleanCacheType:JL_CardTypeUSB];
    [self.mBleEntityM.mCmdManager.mFileManager cmdCleanCacheType:JL_CardTypeSD_0];
    [self.mBleEntityM.mCmdManager.mFileManager cmdCleanCacheType:JL_CardTypeSD_1];
    
    /*--- 获取设备信息 ---*/
    NSLog(@"--->(3) GET Device infomation.");
    [self.mBleEntityM.mCmdManager cmdTargetFeatureResult:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
        JL_CMDStatus st = status;
        if (st == JL_CMDStatusSuccess) {
            [wSelf startTimeout];//超时续费
            
            JLModel_Device *model = [wSelf.mBleEntityM.mCmdManager outputDeviceModel];
            
            JL_OtaStatus upSt = model.otaStatus;
            if (upSt == JL_OtaStatusForce) {
                NSLog(@"---> 进入强制升级.");
                [self actionFinishedForOTA];
  
                return;
            }else{
                if (model.otaHeadset == JL_OtaHeadsetYES) {
                    NSLog(@"---> 进入强制升级: OTA另一只耳机.");
                    [self actionFinishedForOTA];
                    
                    return;
                }
            }
            wSelf.mBleEntityM.mBLE_NEED_OTA = NO;
            
        
            /*---- 共有信息 ---*/
            NSLog(@"---> run task 1");
            [wSelf.mBleEntityM.mCmdManager cmdGetSystemInfo:JL_FunctionCodeCOMMON
                                                     Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                [wSelf startTimeout];//超时续费
            
                NSLog(@"complete task 1");
                                    
                /*---- 蓝牙信息 ---*/
                NSLog(@"---> run task 2");
                //[[JLCacheBox cacheUuid:wSelf.mBleUUID] setIsID3_FIRST:NO];
                [wSelf.mBleEntityM.mCmdManager cmdGetSystemInfo:JL_FunctionCodeBT
                                                         Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                    [wSelf startTimeout];//超时续费
                                        
                    NSLog(@"---> Preparation finished (xxxx).");
                    
                    [wSelf checkDeviceInfo:wSelf.mBleEntityM];
                    
                    [wSelf actionFinished];
                }];
            }];
        }
    }];
}

//MARK: - 扩展信息检查更新
-(void)checkDeviceInfo:(JL_EntityM *)entity{
    [[JLDeviceConfig share] deviceGetConfig:entity.mCmdManager result:^(JL_CMDStatus status, uint8_t sn, JLDeviceConfigModel * _Nullable config) {
        [[JL_RunSDK sharedMe] setConfigModel:config];

        /// 4G 模块检查更新
        if (config.exportFunc.sp4GModel){
            [[JL4GUpgradeManager share] cmdGetDevice4GInfo:entity.mCmdManager result:^(JL_CMDStatus status, JLPublic4GModel * _Nullable model) {
                [model logProperties];
                [[JL_RunSDK sharedMe] setG4ModelVendor:model.vendor];
                [[JL_RunSDK sharedMe] setG4Model:model];
                if (status == JL_CMDStatusSuccess) {
                    if(model.version.length == 0){
                        kJLLog(JLLOG_ERROR, @"---> 4G model fail to get version. skip ths step.");
                        return;
                    }
                    if (model.updateStatus == 0x01) {
                        //TODO: 强制升级 4G 模块
                        OtaUpdateVC *vc = [OtaUpdateVC new];
                        vc.funcType = 1;
                        [JLApplicationDelegate.navigationController pushViewController:vc animated:true];
                    }
                }
            }];
        }
        
        JLDeviceExportFuncModel *model = config.exportFunc;
        // 表盘参数扩展内容获取
        if (model.spDialInfoExtend){
            [[JLDialInfoExtentManager share] getDialInfoExtented: entity.mCmdManager result:^(JL_CMDStatus status, JLDialInfoExtentedModel * _Nullable op) {
                if (status == JL_CMDStatusSuccess) {
                    [[JL_RunSDK sharedMe] setDialInfoExtentedModel:op];
                }else{
                    NSLog(@"getDialInfoExtented fail :%d",status);
                }
            }];
        }
    }];
}


-(void)actionFinished{
    [self stopTimeout];//停止超时
    
    NSLog(@"-----> 处理完成:%@",self.mBleEntityM.mItem);
    self.mBleEntityM.isCMD_PREPARED= YES;
    self.isPreparateOK = 2;

    NSString *uuid = [self.mBleUUID copy];
    [JL_Tools post:kUI_JL_UUID_PREPARATE_OK Object:uuid];
}

-(void)actionFinishedForOTA{
    [self stopTimeout];
    
    NSLog(@"-----> 处理完成:%@",self.mBleEntityM.mItem);
    self.mBleEntityM.isCMD_PREPARED= YES;
    self.mBleEntityM.mBLE_NEED_OTA = YES;
    self.isPreparateOK = 2;

    NSString *uuid = [self.mBleUUID copy];
    [JL_Tools post:kUI_JL_UUID_PREPARATE_OK Object:uuid];
}



#pragma mark - 连接超时管理
-(void)startTimeout{
    //NSLog(@"--->【%@】Preparation Timeout【Start】",self.mBleEntityM.mItem);
    timeout = 0;
    if (actionTimer) {
        [JL_Tools timingContinue:actionTimer];
    }else{
        actionTimer = [JL_Tools timingStart:@selector(timeoutAction)
                                   target:self Time:1.0];
    }
}

-(void)stopTimeout{
    //NSLog(@"--->【%@】Preparation Timeout【Stop】",self.mBleEntityM.mItem);
    timeout = 0;
    [JL_Tools timingPause:actionTimer];
}

-(void)timeoutAction{
    //NSLog(@"--->【%@】Preparation Timeout:%d",self.mBleEntityM.mItem,timeout);
    if (timeout == 8) {
        [self stopTimeout];

        if (preparateTimce == 2) {
            NSLog(@"-----> 处理失败，断开吧~【%@】",self.mBleEntityM.mItem);

            self.isPreparateOK = 1;
            [kJL_BLE_Multiple disconnectEntity:self.mBleEntityM Result:^(JL_EntityM_Status status) {
                if (status == JL_EntityM_StatusDisconnectOk) {
                    self.isPreparateOK = 2;
                }
            }];
        }else{
            self.isPreparateOK = 0;
            NSLog(@"-----> 重新处理:%@",self.mBleEntityM.mItem);
        }
        preparateTimce++;
    }
    timeout++;
}

-(void)actionDismiss{
    NSLog(@"---> Preparation Action Dismiss.");
    
    [self stopTimeout];
    [JL_Tools timingStop:actionTimer];
    actionTimer = nil;
    
    self.mBleEntityM.isCMD_PREPARED= NO;
    self.isPreparateOK = 2;
}

-(void)dealloc{
    [JL_Tools timingStop:actionTimer];
    actionTimer = nil;
}

@end
