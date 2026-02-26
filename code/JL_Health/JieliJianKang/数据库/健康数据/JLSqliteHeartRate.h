//
//  JLSqliteHeartRate.h
//  Test
//
//  Created by EzioChan on 2021/4/27.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLSqliteManager.h"
#import "JLWearSyncHealthHeartRateChart.h"


NS_ASSUME_NONNULL_BEGIN

typedef void(^SqlHeartRateBlock)(JLWearSyncHealthHeartRateChart *chart);
typedef void(^SqlHeartRatesBlock)(NSArray<JLWearSyncHealthHeartRateChart *> *charts);
typedef void(^SqlHeartRateTimestampBlock)(NSTimeInterval minTimeInterval, NSTimeInterval maxTimeInterval);

@interface JLSqliteHeartRate : NSObject

/// 查询一段时间区间的数据
/// @param startDate 开始日期
/// @param endDate 结束日期
/// @param block 图表列表回调
+ (void)s_checkoutWtihStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate Result:(SqlHeartRatesBlock)block;

/// 查询数据最小最大时间
/// @param block 最小最大时间回调
+ (void)s_checkoutMinAndMaxTimestampWithResult:(SqlHeartRateTimestampBlock)block;

/// 查询最新一条的数据
/// @param block 图表列表回调
+ (void)s_checkoutTheLastDataWithResult:(SqlHeartRateBlock)block;

/// 查询一个或多个日期的数据
/// @param dateArray 日期数组
/// @param block 图表列表回调
+ (void)s_checkout:(NSArray<NSDate *> *)dateArray Result:(SqlHeartRatesBlock)block;

///// 插入或更新数据
///// @param model 数据模型
//+ (void)s_update:(JL_SDM_HeartRate *)model;

/// 更新设备回调的数据表
/// @param model JLWearSyncHealthHeartRateChart 心率图表数据模型
+(void)s_sync_update:(JLWearSyncHealthHeartRateChart *)model;

/// 根据日期删除对应的数据
/// @param date 日期
+ (void)s_delete:(NSDate *)date;

@end



NS_ASSUME_NONNULL_END
