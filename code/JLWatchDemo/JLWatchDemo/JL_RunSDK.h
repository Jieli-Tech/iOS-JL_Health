//
//  JL_RunSDK.h
//  JL_BLE_TEST
//
//  Created by DFung on 2018/11/26.
//  Copyright © 2018 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DFUnits/DFUnits.h>
#import "QCY_BLEApple.h"


@interface JL_RunSDK : NSObject
@property(strong,nonatomic)QCY_BLEApple *bt_ble;
@property(strong,nonatomic)NSString *bleAddr;
@property(strong,nonatomic)NSString *csmWatch;

+(id)sharedMe;
+(BOOL)isConnectDevice;
+(BOOL)isNeedUpdateResource;
+(BOOL)isNeedUpdateResource_1;
+(BOOL)isNeedUpdateOTA;
+(BOOL)isNeedUpdateOTA_1;
+(BOOL)isOpenFileSystem;

@end


