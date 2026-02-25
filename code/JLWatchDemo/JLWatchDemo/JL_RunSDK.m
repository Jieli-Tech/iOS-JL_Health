//
//  JL_RunSDK.m
//  JL_BLE_TEST
//
//  Created by DFung on 2018/11/26.
//  Copyright © 2018 www.zh-jieli.com. All rights reserved.
//

#import "JL_RunSDK.h"


@interface JL_RunSDK(){
    
}
@end

@implementation JL_RunSDK

static JL_RunSDK *SDK = nil;
+(id)sharedMe{
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        SDK = [[self alloc] init];
    });
    return SDK;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bt_ble = [QCY_BLEApple new];
    }
    return self;
}

+(BOOL)isConnectDevice{
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    QCY_BLEApple *bt_ble = bleSDK.bt_ble;
    
    /*--- 判断是否已连接设备 ---*/
    if (bt_ble.mBlePeripheral == nil) {
        UIWindow *win = [DFUITools getWindow];
        [DFUITools showText:@"请先连设备!" onView:win delay:1.0];
        return NO;
    }
    return YES;
}


+(BOOL)isNeedUpdateResource{
    
    /*--- 设备信息 ---*/
    JL_ManagerM *mCmdManager = SDK.bt_ble.mAssist.mCmdManager;
    JLModel_Device *model = [mCmdManager outputDeviceModel];
    
    /*--- BLE是否需要更新资源 ---*/
    if (model.otaWatch == JL_OtaWatchYES) {
        UIWindow *win = [DFUITools getWindow];
        [DFUITools showText:@"需要升级手表！" onView:win delay:1.0];
        return YES;
    }
    return NO;
}

+(BOOL)isNeedUpdateResource_1{
    
    /*--- 设备信息 ---*/
    JL_ManagerM *mCmdManager = SDK.bt_ble.mAssist.mCmdManager;
    JLModel_Device *model = [mCmdManager outputDeviceModel];
    
    /*--- BLE是否需要更新资源 ---*/
    if (model.otaWatch == JL_OtaWatchYES) {
        return YES;
    }
    return NO;
}

+(BOOL)isNeedUpdateOTA{
    /*--- 设备信息 ---*/
    JL_ManagerM *mCmdManager = SDK.bt_ble.mAssist.mCmdManager;
    JLModel_Device *model = [mCmdManager outputDeviceModel];
    
    /*--- BLE是否需要OTA升级 ---*/
    if (model.otaStatus == JL_OtaStatusForce) {
        UIWindow *win = [DFUITools getWindow];
        [DFUITools showText:@"需要升级手表！" onView:win delay:1.0];
        return YES;
    }
    return NO;
}

+(BOOL) isNeedUpdateOTA_1{
    /*--- 设备信息 ---*/
    JL_ManagerM *mCmdManager = SDK.bt_ble.mAssist.mCmdManager;
    JLModel_Device *model = [mCmdManager outputDeviceModel];
    
    /*--- BLE是否需要OTA升级 ---*/
    if (model.otaStatus == JL_OtaStatusForce) {
        return YES;
    }
    return NO;
}


+(BOOL)isOpenFileSystem{
    JL_ManagerM *mCmdManager = SDK.bt_ble.mAssist.mCmdManager;
    JLModel_Device *model = [mCmdManager outputDeviceModel];
    uint32_t flashSize = model.flashInfo.mFlashSize;
    uint32_t fatsSize  = model.flashInfo.mFatfsSize;
    
    if (!(flashSize == 0 || fatsSize == 0)) {
        return YES;
    }
    UIWindow *win = [DFUITools getWindow];
    [DFUITools showText:@"需要打开表盘文件系统！" onView:win delay:1.0];
    return NO;
}


@end
