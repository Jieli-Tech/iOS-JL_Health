//
//  JLSqliteStress.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/10/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JL_Chart_Stress : NSObject//JL_SDM_Chart

@property (nonatomic, assign) NSInteger maxValue;   // 最大值
@property (nonatomic, assign) NSInteger minValue;   // 最小值
@property (nonatomic, assign) NSInteger averageValue;   // 平均值

@end

typedef void(^SqlStressBlock)(NSArray<JL_Chart_Stress *> *charts);
typedef void(^SqlStressTimestampBlock)(NSTimeInterval minTimeInterval, NSTimeInterval maxTimeInterval);

@interface JLSqliteStress : NSObject

/// 查询一段时间区间的数据
/// @param startDate 开始日期
/// @param endDate 结束日期
/// @param block 图表列表回调
+ (void)s_checkoutWtihStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate Result:(SqlStressBlock)block;

/// 查询数据最小最大时间
/// @param block 最小最大时间回调
+ (void)s_checkoutMinAndMaxTimestampWithResult:(SqlStressTimestampBlock)block;

/// 查询一个或多个日期的数据
/// @param dateArray 日期数组
/// @param block 图表列表回调
+ (void)s_checkout:(NSArray<NSDate *> *)dateArray Result:(SqlStressBlock)block;

///// 插入或更新数据
///// @param model 数据模型
//+ (void)s_update:(JL_SDM_Stress *)model;

/// 根据日期删除对应的数据
/// @param date 日期
+ (void)s_delete:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
