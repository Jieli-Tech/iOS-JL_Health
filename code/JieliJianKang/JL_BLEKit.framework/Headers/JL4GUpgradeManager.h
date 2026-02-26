//
//  JL4GUpgradeManager.h
//  JL_BLEKit
//
//  Created by EzioChan on 2023/12/18.
//  Copyright © 2023 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLPublicSettingBlocks.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(uint8_t, JL4GUpgradeStatus) {
    JL4GUpgradeStatusFinish = 0x00,
    JL4GUpgradeStatusStart = 0x01,
    JL4GUpgradeStatusTransporting = 0x02,
};

@class JL4GUpgradeManager;
@protocol JL4GUpgradeDelegate  <NSObject>

/// 升级结果
/// - Parameters:
///   - mgr:4G升级管理对象
///   - status: 升级状态
///   - progress: 升级进度
///   - code: 结果码
///     0x00 升级成功
///     0x01 升级失败
///     0x02 升级超时
///   - error: 错误信息
-(void)jl4GUpgradeResult:(JL4GUpgradeManager *)mgr Status:(JL4GUpgradeStatus) status Progress:(float)progress Code:(uint8_t)code error:(NSError * _Nullable)error;

@end

@class JL_ManagerM;

/// 4G模块升级管理对象
@interface JL4GUpgradeManager : NSObject

/// 4G升级代理回调
@property(nonatomic,weak) id<JL4GUpgradeDelegate> delegate;

/// 获取4G模块信息
/// - Parameters:
///   - manager: 设备
///   - result: 回调结果
-(void)cmdGetDevice4GInfo:(JL_ManagerM *)manager result:(JLPSSource4GCbk)result;


/// 开始4G升级
/// - Parameters:
///   - manager: 设备
///   - data: 升级数据
-(void)cmdStartUpgrade4G:(JL_ManagerM *)manager Data:(NSData *)data;

/// 取消4G升级
/// - Parameter manager: 设备
-(void)cmdCancel4GUpgrade:(JL_ManagerM *)manager;

@end

NS_ASSUME_NONNULL_END
