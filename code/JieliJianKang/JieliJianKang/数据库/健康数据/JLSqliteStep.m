//
//  JLSqliteStep.m
//  Test
//
//  Created by EzioChan on 2021/4/25.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import "JLSqliteStep.h"

@implementation JL_Chart_MoveSteps

@end

@implementation JLSqliteStep

#pragma mark - Simulation

+ (void)s_checkoutSimulationDataWtihStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate Result:(SqlStepsBlock)block {
    NSTimeInterval startDateTimeInterval = [startDate.toStartOfDate timeIntervalSince1970];
    NSTimeInterval endDateTimeInterval = [endDate.toEndOfDate timeIntervalSince1970];
    NSMutableArray<JL_Chart_MoveSteps *> *modelArray = [NSMutableArray new];
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where timestamp >= %f and timestamp <= %f order by timestamp asc", tb_step, startDateTimeInterval, endDateTimeInterval];
        FMResultSet *req = [db executeQuery:newStr];
        while ([req next]) {
            NSData *bufferData = [req dataForColumn:@"data"];
            JL_Chart_MoveSteps *model = [[JL_Chart_MoveSteps alloc] initChart:bufferData];
            model.allStep = [req intForColumn:@"allStep"];
            model.totalMileage = [req intForColumn:@"totalMileage"];
            model.totalConsumption = [req intForColumn:@"totalConsumption"];
            [modelArray addObject:model];
        }
        block(modelArray);
    }];
}

/**
 *  iOS获取两个日期之间的所有日期数组，精确到天
 */
+ (NSArray<NSDate *> *)getDatesWithStartDate:(NSString *)startDate endDate:(NSString *)endDate {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    //字符串转时间
    NSDateFormatter *matter = [EcTools cachedFm];
    matter.dateFormat = @"yyyy-MM-dd";
    NSDate *start = [matter dateFromString:startDate];
    NSDate *end = [matter dateFromString:endDate];
    
    NSMutableArray<NSDate *> *componentAarray = [NSMutableArray array];
    NSComparisonResult result = [start compare:end];
    NSDateComponents *comps;
    while (result != NSOrderedDescending) {
        comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |  NSCalendarUnitWeekday fromDate:start];
        [componentAarray addObject:start];
        
        //后一天
        [comps setDay:([comps day]+1)];
        start = [calendar dateFromComponents:comps];
        
        //对比日期大小
        result = [start compare:end];
    }
    return componentAarray;
}

#pragma mark - 查询

+ (void)s_checkoutWtihStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate Result:(SqlStepsBlock)block  {
    NSTimeInterval startDateTimeInterval = [startDate.toStartOfDate timeIntervalSince1970];
    NSTimeInterval endDateTimeInterval = [endDate.toEndOfDate timeIntervalSince1970];
    NSMutableArray<JL_Chart_MoveSteps *> *modelArray = [NSMutableArray new];
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where timestamp > %f and timestamp < %f order by timestamp asc", tb_step, startDateTimeInterval, endDateTimeInterval];
        FMResultSet *req = [db executeQuery:newStr];
        while ([req next]) {
            NSData *bufferData = [req dataForColumn:@"data"];
            JL_Chart_MoveSteps *model = [[JL_Chart_MoveSteps alloc] initChart:bufferData];
            model.allStep = [req intForColumn:@"allStep"];
            model.totalMileage = [req intForColumn:@"totalMileage"];
            model.totalConsumption = [req intForColumn:@"totalConsumption"];
            [modelArray addObject:model];
        }
        block(modelArray);
    }];
}

+ (void)s_checkoutMinAndMaxTimestampWithResult:(SqlStepTimestampBlock)block {
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    __block NSTimeInterval minDateTimeInterval = [[NSDate date] timeIntervalSince1970];
    __block NSTimeInterval maxDateTimeInterval = [[NSDate date] timeIntervalSince1970];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *minStr = [NSString stringWithFormat:@"select * from %@ where timestamp = (select MIN(timestamp) from %@)", tb_step, tb_step];
        FMResultSet *minResultSet = [db executeQuery:minStr];
        while ([minResultSet next]) {
            minDateTimeInterval = [minResultSet doubleForColumn:@"timestamp"];
        }
        NSString *maxStr = [NSString stringWithFormat:@"select * from %@ where timestamp = (select MAX(timestamp) from %@)", tb_step, tb_step];
        FMResultSet *maxResultSet = [db executeQuery:maxStr];
        while ([maxResultSet next]) {
            maxDateTimeInterval = [maxResultSet doubleForColumn:@"timestamp"];
        }
        block(minDateTimeInterval, maxDateTimeInterval);
    }];
}

+ (void)s_checkout:(NSArray<NSDate *> *)dateArray Result:(SqlStepsBlock)block {
    NSMutableString *mtStr = [NSMutableString new];
    [mtStr appendString:@"("];
    for (NSDate * item in dateArray) {
        [mtStr appendFormat:@"'%@',", item.toYYYYMMdd];
    }
    [mtStr replaceCharactersInRange:NSMakeRange(mtStr.length - 1, 1) withString:@""];
    [mtStr appendString:@")"];
    NSMutableArray<JL_Chart_MoveSteps *> *modelArray = [NSMutableArray new];
    
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where date in %@", tb_step, mtStr];
        FMResultSet *req = [db executeQuery:newStr];
        while ([req next]) {
            NSData *bufferData = [req dataForColumn:@"data"];
            JL_Chart_MoveSteps *model = [[JL_Chart_MoveSteps alloc] initChart:bufferData];
            model.allStep = [req intForColumn:@"allStep"];
            model.totalMileage = [req intForColumn:@"totalMileage"];
            model.totalConsumption = [req intForColumn:@"totalConsumption"];
            [modelArray addObject:model];
        }
        block(modelArray);
    }];
}

/// 查询最新一条的数据
/// @param block 图表列表回调
+ (void)s_checkoutTheLastDataWithResult:(SqlStepBlock)block {
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    __block JL_Chart_MoveSteps *model = nil;
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ order by timestamp desc limit 1", tb_step];
        FMResultSet *resultSet = [db executeQuery:newStr];
        while ([resultSet next]) {
            NSData *bufferData = [resultSet dataForColumn:@"data"];
            model = [[JL_Chart_MoveSteps alloc] initChart:bufferData];
            model.allStep = [resultSet intForColumn:@"allStep"];
            model.totalMileage = [resultSet intForColumn:@"totalMileage"];
            model.totalConsumption = [resultSet intForColumn:@"totalConsumption"];
        }
        block(model);
    }];
}

#pragma mark - 插入/更新

//+ (void)s_update:(JL_SDM_MoveSteps *)model {
//    if (model.chartModel) {
//        NSInteger count = 0;
//        for (JL_SDM_TimeData *item in model.chartModel.dataArray) {
//            count += item.num;
//            // TODO: 计算总里程、总消耗
//        }
//        [self updateData:model.chartModel.sourceData interval:model.chartModel.interval allStep:[[NSNumber alloc] initWithInteger:count] totalMileage:[NSNumber numberWithDouble:0] totalConsumption:[NSNumber numberWithDouble:0] ByDate:model.chartModel.startDate];
//    } else {
//        // 这里是处理实时回来的记录到数据库中
//        if (model.rtStep != 0) {
//            UInt8 hr[] = {model.rtStep};
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
//            JL_SportDataFormat sportDataFormat = [JLWatchEnum sportDataFormatFromSportDataType:JL_SportDataTypeMovementSteps];
//            [dt0 replaceBytesInRange:NSMakeRange(index * sportDataFormat, sportDataFormat) withBytes:hr];
//            NSInteger count = 0;
//            for (JL_SDM_TimeData *item in chart.dataArray) {
//                count += item.num;
//                // TODO: 计算总里程、总消耗
//            }
//            [self updateData:dt0 interval:chart.interval allStep:[[NSNumber alloc] initWithInteger:count] totalMileage:[NSNumber numberWithDouble:0] totalConsumption:[NSNumber numberWithDouble:0] ByDate:chart.startDate];
//        }
////        if (model.allStep != 0) {
////            [self updateAllStep:model.allStep byDate:[NSDate new]];
////        }
//    }
//}

+(void)s_update:(JLWearSyncHealthStepChart *)model{
    if (model == nil) return;
    int allStep = 0;
    int allMileage = 0;
    int totoal = 0;
    for (StepCountData *item in model.stepCountlist) {
        for (JLWearStepCountModel *md in item.stepCounts) {
            allStep+=md.count;
            allMileage+=md.Calories;
            totoal+=md.duration;
        }
    }
    [self updateData:model.sourceData interval:model.interval allStep:[NSNumber numberWithInt:allStep] totalMileage:[NSNumber numberWithInt:allMileage] totalConsumption:[NSNumber numberWithInt:totoal] ByDate:model.stepCountlist.firstObject.startDate];
}

+ (void)updateData:(NSData *)data interval:(NSInteger)interval allStep:(NSNumber *)allStep totalMileage:(NSNumber *)totalMileage totalConsumption:(NSNumber *)totalConsumption ByDate:(NSDate *)date {
    NSString *dt = date.toYYYYMMdd;
    NSString *ds = date.toHHmmss;
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    NSNumber *num = [[NSNumber alloc] initWithInt:(int)interval];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql0 = [NSString stringWithFormat:@"select * from %@ where date = '%@'", tb_step, dt];
        FMResultSet *req = [db executeQuery:sql0];
        if ([req next]) {
            NSString *sql = [NSString stringWithFormat:@"update %@ set timestamp = ?, time = ?, data = ?, interval = ?, allStep = ?, totalMileage = ?, totalConsumption = ? where date = ?", tb_step];
           BOOL res = [db executeUpdate:sql, [NSNumber numberWithDouble:timestamp], ds, data, num, allStep, totalMileage, totalConsumption, dt];
            if (!res) {
                NSLog(@"update failed");
            }
        } else {
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (timestamp, date, time, interval, data, allStep, totalMileage, totalConsumption) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", tb_step];
            BOOL res = [db executeUpdate:sql, [NSNumber numberWithDouble:timestamp], dt, ds, num, data, allStep, totalMileage, totalConsumption];
            if (!res) {
                NSLog(@"insert failed");
            }
        }
    }];
}

/**
 *  更新总步数
 */
//+ (void)updateAllStep:(NSInteger)allstep byDate:(NSDate *)date {
//
//    NSString *dt = date.toYYYYMMdd;
//    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
//    NSNumber *allNum = [[NSNumber alloc] initWithLongLong:(long long)allstep];
//    [queue inDatabase:^(FMDatabase * _Nonnull db) {
//        NSString *sql0 = [NSString stringWithFormat:@"select * from %@ where date = '%@'",tb_step,dt];
//        FMResultSet *req = [db executeQuery:sql0];
//        if ([req next]) {
//            NSString *sql = [NSString stringWithFormat:@"update %@ set allStep = ?  where date = ?",tb_step];
//           BOOL res = [db executeUpdate:sql,allNum,dt];
//            if (!res) {
//                NSLog(@"update failed");
//            }
//        }
//    }];
//}

#pragma mark - 删除

+ (void)s_delete:(NSDate *)date {
    [[JLSqliteManager sharedInstance] deleteByDate:date InTable:tb_step];
}

@end
