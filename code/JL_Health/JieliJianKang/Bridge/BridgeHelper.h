//
//  BridgeHelper.h
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class DialUICache;
@class JLDialInfoExtentedModel;
@class JL_ManagerM;
@class JL_EntityM;

@interface BridgeHelper : NSObject

+(DialUICache *)dialCache;

+(JLDialInfoExtentedModel *)dialExtentInfo;

+(JL_ManagerM *_Nullable)getCurrentCmdManager;

+(JL_BLEMultiple *)getCurrentMultiple;

+(JL_EntityM * _Nullable)getCurrentEntity;

+(UINavigationController *)getNavigationController;

+(JLDialInfoExtentedModel *)getDialInfoExtentManager;

+(void)connect:(JL_EntityM *)entity;

+(void)connectMac:(NSString *)mac;

+(BOOL)isConnecting;
@end

NS_ASSUME_NONNULL_END
