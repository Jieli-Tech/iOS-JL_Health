//
//  BridgeHelper.m
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/10.
//

#import "BridgeHelper.h"
#import "JL_RunSDK.h"

@implementation BridgeHelper

+(DialUICache *)dialCache {
    return [[JL_RunSDK sharedMe] mDialUICache];
}

+(JLDialInfoExtentedModel *)dialExtentInfo {
    return [[JL_RunSDK sharedMe] dialInfoExtentedModel];
}

+(JL_ManagerM *_Nullable)getCurrentCmdManager {
    return [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
}

+(JL_BLEMultiple *)getCurrentMultiple {
    return [[JL_RunSDK sharedMe] mBleMultiple];
}

+(JL_EntityM * _Nullable)getCurrentEntity {
    return [[JL_RunSDK sharedMe] mBleEntityM];
}

+(UINavigationController *)getNavigationController {
    return JLApplicationDelegate.navigationController;
}

+(JLDialInfoExtentedModel *)getDialInfoExtentManager {
    return [[JL_RunSDK sharedMe] dialInfoExtentedModel];
}

+(void)connect:(JL_EntityM *)entity {
    [[JL_RunSDK sharedMe] connectDevice:entity callBack:^(BOOL callback) {
        
    }];
}

+(void)connectMac:(NSString *)mac {
    [[JL_RunSDK sharedMe] connectDeviceMac:mac callBack:^(BOOL callback) {
        
    }];
}

+(BOOL)isConnecting{
    return [[JL_RunSDK sharedMe] isConnecting];
}

@end
