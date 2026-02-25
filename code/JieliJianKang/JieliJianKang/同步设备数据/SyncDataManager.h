//
//  SyncDataManager.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/11/2.
//

#import <Foundation/Foundation.h>
#import "JLSqliteHeartRate.h"


NS_ASSUME_NONNULL_BEGIN

typedef void(^JL_HeartRateChart_CB)(JLWearSyncHealthHeartRateChart *_Nullable chart);

typedef void(^JL_BloodOxyganChart_CB)(JLWearSyncHealthBloodOxyganChart *_Nullable chart);

typedef void(^JL_SleepChart_CB)(JLWearSyncHealthSleepChart *_Nullable chart);

typedef void(^JL_SportRecordData_CB)(JLSportRecordModel *_Nullable model);

typedef void(^JL_StepCount_CB)(JLWearSyncHealthStepChart *_Nullable model);

@interface SyncDataManager : NSObject

+(instancetype)share;

-(void)stopAllTask;

/// 同步心率数据
/// @param entity 设备entity
/// @param block 多次回调
-(void)syncHeartRateData:(JL_EntityM *)entity with:(JL_HeartRateChart_CB)block;

/// 同步血氧饱和度图表
/// @param entity 设备entity
/// @param block 多次回调
-(void)syncBloodOxyganData:(JL_EntityM *)entity with:(JL_BloodOxyganChart_CB)block;

/// 同步睡眠数据
/// @param entity 设备entity
/// @param block 多次回调
-(void)syncSleepData:(JL_EntityM *)entity with:(JL_SleepChart_CB)block;

/// 同步全天步数数据
/// @param entity 设备entity
/// @param block 多次回调
-(void)syncStepCountData:(JL_EntityM *)entity with:(JL_StepCount_CB)block;

///同步运动记录数据
/// @param entity 设备entity
/// @param block 多次回调
-(void)syncSportRecordData:(JL_EntityM *)entity with:(JL_SportRecordData_CB)block;


/// 根据运动文件ID同步内容
/// @param entity 设备entity
/// @param sportId 运动记录文件id
/// @param block 一次回调
-(void)syncSportRecordData:(JL_EntityM *)entity BySportId:(UInt16)sportId with:(JL_SportRecordData_CB)block;

@end

NS_ASSUME_NONNULL_END
