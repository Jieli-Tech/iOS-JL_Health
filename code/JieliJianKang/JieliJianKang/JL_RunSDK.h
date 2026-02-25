//
//  JL_RunSDK.h
//  JL_BLE_TEST
//
//  Created by DFung on 2018/11/26.
//  Copyright © 2018 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#import <DFUnits/DFUnits.h>
#import <JL_BLEKit/JL_BLEKit.h>
#import <JL_HashPair/JL_HashPair.h>
#import <JLDialUnit/JLDialUnit.h>
#import <JLBugly/JLBugly-Swift.h>

#import "JLPhoneUISetting.h"
#import "DialUICache.h"

#define kStoreIAP_MOBILE    @"15315274007"
#define BaseURL             @"http://health.jieliapp.com"           //【杰理服务器】测试域名test03.jieliapp.com  上架域名health.jieliapp.com
#define MapApiKey           @"0733d73d9ca8476dc29442f3d22fc4d9"     //【杰理之家】地图SDK的Key
#define PiLinkMapApiKey     @"7dc05b2a0e2fe8b2bdec91acb04d3a6c"     //【PiLink】地图SDK的Key

#define kJL_BLE_Multiple    [[JL_RunSDK sharedMe] mBleMultiple]     //蓝牙控制中心
#define kJL_BLE_EntityM     [[JL_RunSDK sharedMe] mBleEntityM]      //当前蓝牙设备
#define kJL_BLE_CmdManager  kJL_BLE_EntityM.mCmdManager             //命令管理器
#define kJL_BLE_Uuid        [[JL_RunSDK sharedMe] mBleUUID]         //当前蓝牙设备的UUID
#define kJL_DIAL_CACHE      [[JL_RunSDK sharedMe] mDialUICache]     //表盘的UI缓存

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(UInt8, JLUuidType) {
    JLUuidTypeDisconnected              = 0,    //未连接的UUID
    JLUuidTypeConnected                 = 1,    //已连接的UUID
    JLUuidTypeInUse                     = 2,    //正在使用的UUID
    JLUuidTypeNeedOTA                   = 3,    //UUID需要OTA
    JLUuidTypePreparing                 = 4,    //正在准备的UUID
};
typedef NS_ENUM(UInt8, JLDeviceChangeType) {
    JLDeviceChangeTypeConnectedOffline  = 0,    //断开已连接的设备
    JLDeviceChangeTypeInUseOffline      = 1,    //断开正在使用的设备
    JLDeviceChangeTypeSomethingConnected= 2,    //有设备连接上
    JLDeviceChangeTypeManualChange      = 3,    //手动切换设备
    JLDeviceChangeTypeBleOFF            = 4,    //蓝牙已关闭
};
extern NSString *kUI_JL_DEVICE_CHANGE;
extern NSString *kUI_JL_DEVICE_PREPARING;
extern NSString *kUI_JL_DEVICE_OTA;


extern NSString *kUI_JL_BLE_SCAN_OPEN;
extern NSString *kUI_JL_BLE_SCAN_CLOSE;

@interface JL_RunSDK : NSObject
@property(strong,nonatomic)JL_BLEMultiple *mBleMultiple;
@property(weak  ,nonatomic)JL_EntityM     *__nullable mBleEntityM;
@property(strong,nonatomic)NSString       *__nullable mBleUUID;
@property(strong,nonatomic)DialUICache    *__nullable mDialUICache;
@property(strong,nonatomic)NSString       *__nullable ancsUUID;
@property(assign,nonatomic)BOOL           isOtaUpgrading;
@property(assign,nonatomic)BOOL           isOTAFailRelink;

+(id)sharedMe;

/**
  使用UUID切换设备
 */
+(void)setActiveUUID:(NSString*)uuid;

/**
 使用UUID获取已连接的Entity
*/
+(JL_EntityM*)getEntity:(NSString*)uuid;

/**
  获取当前设备状态
        0：未连接的UUID
        1：已连接的UUID
        2：正在使用的UUID
        3：UUID需要OTA
        4：正在准备的UUID
*/
+(JLUuidType)getStatusUUID:(NSString*)uuid;

/**
  获取连接状态对应中文解析
 */
+(NSString *)textEntityStatus:(JL_EntityM_Status)status;

/**
  是否为正在使用的设备发来的命令
 */
+(BOOL)isCurrentDeviceCmd:(NSNotification*)note;

/**
  已连接的UUID
 */
+(NSArray*)getLinkedArray;

/**
  是否连接对应的EDR
 */
+(BOOL)isConnectEdr:(NSString*)edr;

@end
NS_ASSUME_NONNULL_END

