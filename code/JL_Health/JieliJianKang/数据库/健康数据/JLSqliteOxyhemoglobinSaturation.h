//
//  JLSqliteOxyhemoglobinSaturation.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/10/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JL_Chart_OxyhemoglobinSaturation : JLWearSyncHealthBloodOxyganChart

@property (nonatomic, assign) NSInteger maxValue;   // 最大值
@property (nonatomic, assign) NSInteger minValue;   // 最小值
@property (nonatomic, assign) NSInteger averageValue;   // 平均值

@end

typedef void(^SqlOxyhemoglobinSaturationBlock)(JL_Chart_OxyhemoglobinSaturation *chart);
typedef void(^SqlOxyhemoglobinSaturationsBlock)(NSArray<JL_Chart_OxyhemoglobinSaturation *> *charts);
typedef void(^SqlOxyhemoglobinSaturationTimestampBlock)(NSTimeInterval minTimeInterval, NSTimeInterval maxTimeInterval);

@interface JLSqliteOxyhemoglobinSaturation : NSObject

/// 查询一段时间区间的数据
/// @param startDate 开始日期
/// @param endDate 结束日期
/// @param block 图表列表回调
+ (void)s_checkoutWtihStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate Result:(SqlOxyhemoglobinSaturationsBlock)block;

/// 查询数据最小最大时间
/// @param block 最小最大时间回调
+ (void)s_checkoutMinAndMaxTimestampWithResult:(SqlOxyhemoglobinSaturationTimestampBlock)block;

/// 查询一个或多个日期的数据
/// @param dateArray 日期数组
/// @param block 图表列表回调
+ (void)s_checkout:(NSArray<NSDate *> *)dateArray Result:(SqlOxyhemoglobinSaturationsBlock)block;

/// 查询最新一条的数据
/// @param block 图表列表回调
+ (void)s_checkoutTheLastDataWithResult:(SqlOxyhemoglobinSaturationBlock)block;

/// 插入或更新数据
/// @param model 数据模型
//+ (void)s_update:(JL_SDM_OxSaturation *)model;

/// 更新图表（全天）
/// @param model 数据类型
+(void)s_sync_update:(JLWearSyncHealthBloodOxyganChart *)model;

/// 根据日期删除对应的数据
/// @param date 日期
+ (void)s_delete:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
