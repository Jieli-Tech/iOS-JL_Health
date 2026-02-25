//
//  JLSqliteSleep.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/1.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

typedef void(^SqlSleepBlock)(JLWearSyncHealthSleepChart *chart);
typedef void(^SqlSleepsBlock)(NSArray <JLWearSyncHealthSleepChart *> *charts);


@interface JLSqliteSleep : NSObject

/// 查询一段时间区间的数据
/// @param startDate 开始日期
/// @param endDate 结束日期
/// @param block 图表列表回调
+ (void)s_checkoutWtihStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate Result:(SqlSleepsBlock)block;


/// 查询一个或多个日期的数据
/// @param dateArray 日期数组
/// @param block 图表列表回调
+ (void)s_checkout:(NSArray<NSDate *> *)dateArray Result:(SqlSleepsBlock)block;

/// 查询最新一条的数据
/// @param block 图表列表回调
+ (void)s_checkoutTheLastDataWithResult:(SqlSleepBlock)block;


/// 更新设备回调的数据表
/// @param model JLWearSyncHealthSleepChart 睡眠图表数据模型
+(void)s_update:(JLWearSyncHealthSleepChart *)model;

/// 根据日期删除对应的数据
/// @param date 日期
+ (void)s_delete:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
