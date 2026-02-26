//
//  DataOverallPlanTools.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/11/11.
//

#import <Foundation/Foundation.h>
#import "SyncDataManager.h"
#import "JLSqliteHeartRate.h"
#import <CoreDraw/CoreDraw.h>
#import "ContrastNapView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SleepDetailModel : NSObject

@property(nonatomic,assign)NSInteger deep;
@property(nonatomic,assign)NSInteger shallow;
@property(nonatomic,assign)NSInteger rem;
@property(nonatomic,assign)NSInteger awake;
@property(nonatomic,assign)NSInteger all;
@property(nonatomic,assign)NSInteger nightTime;
@property(nonatomic,assign)NSInteger awakeCount;
@property(nonatomic,strong)JLWearSleepModel *sporadicNaps;
@property(nonatomic,strong)JLAnalyzeSleep *sleepAnalyze;
@property(nonatomic,strong)NSDate *date;
/// 当前只有为日的时候才有意义
@property(nonatomic,strong)NSArray <SleepNapModel *> *arrayNaps;
@end

@interface SleepDataFormatModel:NSObject

@property(nonatomic,assign)BOOL isHistogram;

@property(nonatomic,strong)NSArray<ECDiagramPoint *> *pointsArray;

@property(nonatomic,strong)NSArray<ECSleepDuration *> *durationArray;

@property(nonatomic,strong)SleepDetailModel *detail;

@end
@interface DataOverallPlanTools : NSObject


+(void)sleepDataCheckLastDayResult:(void(^)(SleepDataFormatModel *model)) block;
/// 天
/// @param startDate 日期
/// @param block 回调
+(void)sleepDataByDate:(NSDate *)startDate result:(void(^)(SleepDataFormatModel *model)) block;

/// 周
/// @param startDate 开始
/// @param enddate 结束
/// @param block 回调
+(void)sleepDataWeekFrom:(NSDate *)startDate To:(NSDate *)enddate result:(void(^)(SleepDataFormatModel *model)) block;

/// 月
/// @param startDate 开始
/// @param enddate 结束
/// @param block 回调
+(void)sleepDataMonthFrom:(NSDate *)startDate To:(NSDate *)enddate result:(void(^)(SleepDataFormatModel *model)) block;

/// 年
/// @param startDate 开始
/// @param enddate 结束
/// @param block 回调
+(void)sleepDataYearFrom:(NSDate *)startDate To:(NSDate *)enddate result:(void(^)(SleepDataFormatModel *model)) block;


@end

NS_ASSUME_NONNULL_END
