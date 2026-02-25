//
//  JLSqliteStep.h
//  Test
//
//  Created by EzioChan on 2021/4/25.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLSqliteManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface JL_Chart_MoveSteps : JLWearSyncHealthStepChart

@property (nonatomic, assign) NSInteger allStep;   // 总步数
@property (nonatomic, assign) double totalMileage;   // 总里程
@property (nonatomic, assign) double totalConsumption;   // 总消耗

@end

typedef void(^SqlStepBlock)(JL_Chart_MoveSteps *chart);
typedef void(^SqlStepsBlock)(NSArray<JL_Chart_MoveSteps *> *charts);
typedef void(^SqlStepTimestampBlock)(NSTimeInterval minTimeInterval, NSTimeInterval maxTimeInterval);

@interface JLSqliteStep : NSObject

/// 查询一段时间区间的模拟数据
/// @param startDate 开始日期
/// @param endDate 结束日期
/// @param block 图表列表回调
+ (void)s_checkoutSimulationDataWtihStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate Result:(SqlStepsBlock)block;

/// 查询一段时间区间的数据
/// @param startDate 开始日期
/// @param endDate 结束日期
/// @param block 图表列表回调
+ (void)s_checkoutWtihStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate Result:(SqlStepsBlock)block;

/// 查询数据最小最大时间
/// @param block 最小最大时间回调
+ (void)s_checkoutMinAndMaxTimestampWithResult:(SqlStepTimestampBlock)block;

/// 查询最新一条的数据
/// @param block 图表列表回调
+ (void)s_checkoutTheLastDataWithResult:(SqlStepBlock)block;

/// 查询一个或多个日期的数据
/// @param dateArray 日期数组
/// @param block 图表列表回调
+ (void)s_checkout:(NSArray<NSDate *> *)dateArray Result:(SqlStepsBlock)block;

/// 插入或更新数据
/// @param model 数据模型
+(void)s_update:(JLWearSyncHealthStepChart *)model;

/// 根据日期删除对应的数据
/// @param date 日期
+ (void)s_delete:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
