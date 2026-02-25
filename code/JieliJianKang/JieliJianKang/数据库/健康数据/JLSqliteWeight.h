//
//  JLSqliteWeight.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/10/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JL_Chart_Weight : NSObject

@property (nonatomic, assign) double weight;        // 体重值
@property (nonatomic, strong) NSDate *date;        // 日期

@end

typedef void(^SqlWeightBlock)(JL_Chart_Weight *chart);
typedef void(^SqlWeightsBlock)(NSArray<JL_Chart_Weight *> *charts);
typedef void(^SqlWeightTimestampBlock)(NSTimeInterval minTimeInterval, NSTimeInterval maxTimeInterval);

@interface JLSqliteWeight : NSObject

/// 查询一段时间区间的数据
/// @param startDate 开始日期
/// @param endDate 结束日期
/// @param block 图表列表回调
+ (void)s_checkoutWtihStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate Result:(SqlWeightsBlock)block;

/// 查询数据最小最大时间
/// @param block 最小最大时间回调
+ (void)s_checkoutMinAndMaxTimestampWithResult:(SqlWeightTimestampBlock)block;

/// 查询最新一条的数据
/// @param block 图表列表回调
+ (void)s_checkoutTheLastDataWithResult:(SqlWeightBlock)block;

/// 插入或更新数据
/// @param model 数据模型
+ (void)s_update:(JL_Chart_Weight *)model;

/// 根据日期删除对应的数据
/// @param date 日期
+ (void)s_delete:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
