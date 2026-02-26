//
//  JLVoicePackageManager.h
//  JL_BLEKit
//
//  Created by EzioChan on 2024/1/16.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JL_BLEKit/JL_BLEKit.h>

NS_ASSUME_NONNULL_BEGIN
@class JLToneCfgModel;
@class JLVoiceReplaceInfo;

typedef void(^JLTipsVoiceBlock)(JL_CMDStatus,JLVoiceReplaceInfo *_Nullable info);

/// 提示音替换类
@interface JLVoicePackageManager : NSObject

/// 打包多个 .wts 文件成 tone.cfg 数据
/// - Parameters:
///   - paths: 文件存放路径
///   - names: 文件在设备端使用时的名称
///   - info: 设备限制的信息
+(NSData *)makePks:(NSArray *)paths FileNames:(NSArray *)names Info:(JLVoiceReplaceInfo*)info;

/// 解包 tone.cfg 数据
/// - Parameter data: tone.cfg 数据
+(NSArray<JLToneCfgModel*> *)parsePks:(NSData *)data; 

/// 当前 SDK 版本
+(NSString *)getVersion;

/// 单例
+(instancetype)share;

/// 是否处于替换中
-(BOOL)isReplacing;

/// 是否支持提示音替换查询
/// - Parameters:
///   - manager: 设备
///   - result: 回调结果
-(void)isSupportTipsVoiceReplace:(JL_ManagerM *)manager result:(JLConfigTwsRsp)result;

/// 获取设备端提示音的信息
/// - Parameters:
///   - manager: 设备
///   - result: 回调
-(void)voicesReplaceGetVoiceInfo:(JL_ManagerM *)manager Result:(JLTipsVoiceBlock)result;

/// 推送提示音数据到设备
/// - Parameters:
///   - mgr: 设备
///   - devhandle: 设备句柄，当前句柄需要通过获取设备存储信息获得，可参考 JLModel_Device 类的 cardInfo 属性，当设备不作要求时，此值填 0xffffffff
///   - path: 提示音本地存放路径
///   - isReborn: 完成后是否重启设备
///   - result: 回调结果
-(void)voicesReplacePushDataRequest:(JL_ManagerM *)mgr DevHandle:(NSData *)devhandle TonePath:(NSString *)path IsReborn:(BOOL)isReborn Result:(JL_BIGFILE_RT __nullable)result;

@end

NS_ASSUME_NONNULL_END
