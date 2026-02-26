//
//  JLSqliteSportRunningRecord.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/10/29.
//

#import <Foundation/Foundation.h>
#import "JLSqliteSportLocation.h"

NS_ASSUME_NONNULL_BEGIN

@interface JL_SportRecord_Chart : JLSportRecordModel

///运动id
@property (nonatomic, assign) double sport_id;
@property (nonatomic, strong) NSArray<JL_SportLocation *> *sportLocations;
@property (nonatomic, assign) NSInteger locationCoordsCount;
@property (nonatomic, strong) MAPolyline *polyline;
@property (nonatomic, strong) JL_SportLocation *firstSportLocation;
@property (nonatomic, strong) JL_SportLocation *lastSportLocation;

- (NSString *)getSpeed;

@end

typedef void(^SqlSportRecordBlock)(JL_SportRecord_Chart * _Nullable chart);
typedef void(^SqlSportRecordsBlock)(NSArray <JL_SportRecord_Chart *> *charts);

@interface JLSqliteSportRunningRecord : NSObject

/// 查询一段时间区间的数据
/// @param startDate 开始日期
/// @param endDate 结束日期
/// @param block 图表列表回调
+ (void)s_checkoutWtihStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate Result:(SqlSportRecordsBlock)block;

/// 查询一段区间的数据
/// @param index 开始索引
/// @param needResultCount 结束日期
/// @param block 运动记录数据回调
+ (void)s_checkoutWtihStartIndex:(NSInteger)index needResultCount:(NSInteger)needResultCount withIsASC:(BOOL)isASC Result:(SqlSportRecordsBlock)block;

/// 根据运动id查询数据
/// @param sport_id 运动id
/// @param block 图表列表回调
+ (void)s_checkoutWithSportID:(double)sport_id Result:(SqlSportRecordBlock)block;

/// 查询最新一条的数据
/// @param block 图表列表回调
+ (void)s_checkoutTheLastDataWithResult:(SqlSportRecordBlock)block;

/// 更新设备回调的数据表
/// @param model JLWearSyncHealthSleepChart 睡眠图表数据模型
+(void)s_update:(JLSportRecordModel *)model;

/// 根据运动ID删除对应的数据
/// @param sportId sport_id
+ (void)s_delete:(double)sportId;

@end

NS_ASSUME_NONNULL_END
