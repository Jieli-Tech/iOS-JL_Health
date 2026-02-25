//
//  DeviceHttp.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/16.
//

#import <Foundation/Foundation.h>

@class JLHttpResponse;
@class DeviceHttpResp;
NS_ASSUME_NONNULL_BEGIN

@interface DeviceHttp : NSObject

/// 绑定当前所连设备
/// @param result 成功回调
+(void)bind:(nullable void (^)(JLHttpResponse * response))result;

/// 解除绑定设备
/// @param device_id 绑定时所返回的BindID
/// @param result 回调
+(void)unBinding:(NSString *)device_id result:(void(^)(JLHttpResponse* response))result;


/// 获取设备列表
/// @param result 返回结果
+(void)checkList:(void(^)(NSArray<DeviceHttpResp*>  * _Nullable array)) result;


/// 修改设备配置信息
/// @param model 模型
/// @param result 返回内容
+(void)updateConfig:(DeviceHttpResp *)model Result:(void(^)(JLHttpResponse * response))result;


/// 更新设备连接时间
/// @param device_id 绑定时所返回的BindID
/// @param result 返回内容
+(void)updateTimeByDeviceID:(NSString *)device_id Result:(void(^)(JLHttpResponse* response))result;

@end

NS_ASSUME_NONNULL_END
