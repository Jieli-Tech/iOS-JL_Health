//
//  JLSqliteHeartRate.m
//  Test
//
//  Created by EzioChan on 2021/4/27.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import "JLSqliteHeartRate.h"
#import "JLSqliteManager.h"
#import "NSString+Path.h"
#import "EcTools.h"



@implementation JLSqliteHeartRate

#pragma mark - 查询

+ (void)s_checkoutWtihStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate Result:(SqlHeartRatesBlock)block {
    NSTimeInterval startDateTimeInterval = [startDate.toStartOfDate timeIntervalSince1970];
    NSTimeInterval endDateTimeInterval = [endDate.toEndOfDate timeIntervalSince1970];
    
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    NSMutableArray<JLWearSyncHealthHeartRateChart *> *modelArray = [NSMutableArray new];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where timestamp >= %f and timestamp <= %f order by timestamp asc", tb_heart_rate, startDateTimeInterval, endDateTimeInterval];
        FMResultSet *resultSet = [db executeQuery:newStr];
        while ([resultSet next]) {
            NSData *bufferData = [resultSet dataForColumn:@"data"];
            JLWearSyncHealthHeartRateChart *model = [[JLWearSyncHealthHeartRateChart alloc] initChart:bufferData];
            [modelArray addObject:model];
        }
        block(modelArray);
    }];
}

+ (void)s_checkoutMinAndMaxTimestampWithResult:(SqlHeartRateTimestampBlock)block {
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    __block NSTimeInterval minDateTimeInterval = [[NSDate date] timeIntervalSince1970];
    __block NSTimeInterval maxDateTimeInterval = [[NSDate date] timeIntervalSince1970];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *minStr = [NSString stringWithFormat:@"select * from %@ where timestamp = (select MIN(timestamp) from %@)", tb_heart_rate, tb_heart_rate];
        FMResultSet *minResultSet = [db executeQuery:minStr];
        while ([minResultSet next]) {
            minDateTimeInterval = [minResultSet doubleForColumn:@"timestamp"];
        }
        NSString *maxStr = [NSString stringWithFormat:@"select * from %@ where timestamp = (select MAX(timestamp) from %@)", tb_heart_rate, tb_heart_rate];
        FMResultSet *maxResultSet = [db executeQuery:maxStr];
        while ([maxResultSet next]) {
            maxDateTimeInterval = [maxResultSet doubleForColumn:@"timestamp"];
        }
        block(minDateTimeInterval, maxDateTimeInterval);
    }];
}

/// 查询最新一条的数据
/// @param block 图表列表回调
+ (void)s_checkoutTheLastDataWithResult:(SqlHeartRateBlock)block {
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    __block JLWearSyncHealthHeartRateChart *model = nil;
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ order by timestamp desc limit 1", tb_heart_rate];
        FMResultSet *resultSet = [db executeQuery:newStr];
        while ([resultSet next]) {
            NSData *bufferData = [resultSet dataForColumn:@"data"];
            model = [[JLWearSyncHealthHeartRateChart alloc] initChart:bufferData];
        }
        block(model);
    }];
}



+ (void)s_checkout:(NSArray<NSDate *> *)dateArray Result:(SqlHeartRatesBlock)block {
    
    NSMutableString *mtStr = [NSMutableString new];
    [mtStr appendString:@"("];
    for (NSDate * item in dateArray) {
        [mtStr appendFormat:@"'%@',", item.toYYYYMMdd];
    }
    [mtStr replaceCharactersInRange:NSMakeRange(mtStr.length - 1, 1) withString:@""];
    [mtStr appendString:@")"];
    
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    NSMutableArray<JLWearSyncHealthHeartRateChart *> *modelArray = [NSMutableArray new];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where date in %@", tb_heart_rate, mtStr];
        FMResultSet *resultSet = [db executeQuery:newStr];
        while ([resultSet next]) {
            NSData *bufferData = [resultSet dataForColumn:@"data"];
            JLWearSyncHealthHeartRateChart *model = [[JLWearSyncHealthHeartRateChart alloc] initChart:bufferData];
            [modelArray addObject:model];
        }
        NSArray<JLWearSyncHealthHeartRateChart *> *models = [[modelArray reverseObjectEnumerator] allObjects];
        block(models);
    }];
}

#pragma mark - 插入/更新

//+ (void)s_update:(JL_SDM_HeartRate *)model {
//    
//    //这里分了两种处理方式，分别处理请求图表数据时回来会包含所有的数据（除了静态心率）
//    if (model.chartModel) {
//        NSInteger maxValue = 0;
//        NSInteger minValue = 0;
//        for (JL_SDM_TimeData *item in model.chartModel.dataArray) {
//            if (item.num > maxValue) {
//                maxValue = item.num;
//            }
//            if (item.num < minValue) {
//                minValue = item.num;
//            }
//        }
//        [self updateData:model.chartModel.sourceData interval:model.chartModel.interval maxHeartRate:[[NSNumber alloc] initWithInteger:maxValue] minHeartRate:[[NSNumber alloc] initWithInteger:minValue] ByDate:model.chartModel.startDate];
//    } else {
//        // 处理实时心率
//        if (model.realTime != 0) {
//            UInt8 hr[] = {model.realTime};
//            NSDate *saveDate = [NSDate new];
//            __block JL_SDM_Chart *chart;
//            [self s_checkout:@[saveDate] Result:^(NSArray<JL_SDM_Chart *> * _Nonnull charts) {
//                if (charts) {
//                    chart = charts.firstObject;
//                }
//            }];
//            int index = 0;
//            for (int i = 0; i < chart.dataArray.count; i++) {
//                JL_SDM_TimeData *td = chart.dataArray[i];
//                if ([saveDate.toHHmmss compareTimeIntervalTo:td.date.toHHmmss]) {
//                    index++;
//                } else {
//                    break;
//                }
//            }
//            NSMutableData *dt0 = [NSMutableData dataWithData:chart.sourceData];
//            JL_SportDataFormat sportDataFormat = [JLWatchEnum sportDataFormatFromSportDataType:JL_SportDataTypeHeartRate];
//            [dt0 replaceBytesInRange:NSMakeRange(index * sportDataFormat, sportDataFormat) withBytes:hr];
//            NSInteger maxValue = 0;
//            NSInteger minValue = 0;
//            for (JL_SDM_TimeData *item in chart.dataArray) {
//                if (item.num > maxValue) {
//                    maxValue = item.num;
//                }
//                if (item.num < minValue) {
//                    minValue = item.num;
//                }
//            }
//            [self updateData:dt0 interval:chart.interval maxHeartRate:[[NSNumber alloc] initWithInteger:maxValue] minHeartRate:[[NSNumber alloc] initWithInteger:minValue] ByDate:chart.startDate];
//        }
//        // 处理静息心率
//        if (model.resting != 0) {
//            [self updateRestingHeartRate:model.resting byDate:[NSDate new]];
//        }
//    }
//}



+ (void)updateData:(NSData *)data interval:(NSInteger)interval maxHeartRate:(NSNumber *)maxHeartRate minHeartRate:(NSNumber *)minHeartRate ByDate:(NSDate *)date {
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    NSString *dt = date.toYYYYMMdd;
    NSString *ds = date.toHHmmss;
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    NSNumber *num = [[NSNumber alloc] initWithInt:(int)interval];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql0 = [NSString stringWithFormat:@"select * from %@ where date = '%@'", tb_heart_rate, dt];
        FMResultSet *resultSet = [db executeQuery:sql0];
        if ([resultSet next]) {
            NSString *sql = [NSString stringWithFormat:@"update %@ set timestamp = ?, time = ?, data = ?, interval = ? ,maxValue = ?, minValue = ? where date = ?", tb_heart_rate];
            BOOL res = [db executeUpdate:sql, [NSNumber numberWithDouble:timestamp], ds, data, num, maxHeartRate, minHeartRate, dt];
            if (!res) {
                kJLLog(JLLOG_DEBUG, @"update failed");
            }
        } else {
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (timestamp, date, time, interval, data, maxValue, minValue) VALUES ( ?,?, ?, ?, ?, ?, ?)", tb_heart_rate];
            BOOL res = [db executeUpdate:sql, [NSNumber numberWithDouble:timestamp], dt, ds, num, data, maxHeartRate, minHeartRate];
            if (!res) {
                kJLLog(JLLOG_DEBUG, @"insert failed");
            }
        }
    }];
}

+(void)s_sync_update:(JLWearSyncHealthHeartRateChart *)model {
    if (model == nil) return;
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (HeartRateData * hrd in model.heartRatelist) {
        for (NSNumber *num in hrd.heartRates){
            [tmpArray addObject:num];
        }
    }
    [EcTools quickArray:tmpArray withLeftIndex:0 AndRightIndex:tmpArray.count-1];
    [self updateData:model.sourceData interval:model.interval maxHeartRate:tmpArray.lastObject minHeartRate:tmpArray.firstObject ByDate:model.heartRatelist.firstObject.startDate];
    [self updateRestingHeartRate:model.restingHeartRate byDate:model.heartRatelist.firstObject.startDate];
}


/**
 *  更新静息心率
 */
+ (void)updateRestingHeartRate:(NSInteger)rate byDate:(NSDate *)date {
    NSString *dt = date.toYYYYMMdd;
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    NSNumber *allNum = [[NSNumber alloc] initWithInt:(int)rate];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql0 = [NSString stringWithFormat:@"select * from %@ where date = '%@'", tb_heart_rate, dt];
        FMResultSet *req = [db executeQuery:sql0];
        if ([req next]) {
            NSString *sql = [NSString stringWithFormat:@"update %@ set restingHeartRate = ?  where date = ?", tb_heart_rate];
            BOOL res = [db executeUpdate:sql, allNum, dt];
            if (!res) {
                kJLLog(JLLOG_DEBUG, @"update failed");
            }
        }
    }];
}

#pragma mark - 删除
+(void)s_delete:(NSDate *)date{
    [[JLSqliteManager sharedInstance] deleteByDate:date InTable:tb_heart_rate];
}

@end


