//
//  JLSqliteOxyhemoglobinSaturation.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/10/25.
//

#import "JLSqliteOxyhemoglobinSaturation.h"
#import "JLSqliteManager.h"
#import "EcTools.h"

@implementation JL_Chart_OxyhemoglobinSaturation

@end

@implementation JLSqliteOxyhemoglobinSaturation

#pragma mark - 查询

+ (void)s_checkoutWtihStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate Result:(SqlOxyhemoglobinSaturationsBlock)block {
    NSTimeInterval startDateTimeInterval = [startDate.toStartOfDate timeIntervalSince1970];
    NSTimeInterval endDateTimeInterval = [endDate.toEndOfDate timeIntervalSince1970];
    NSMutableArray<JL_Chart_OxyhemoglobinSaturation *> *modelArray = [NSMutableArray new];
    
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where timestamp >= %f and timestamp <= %f order by timestamp asc", tb_oxyhemoglobin_saturation, startDateTimeInterval, endDateTimeInterval];
        FMResultSet *req = [db executeQuery:newStr];
        while ([req next]) {
            NSData *bufferData = [req dataForColumn:@"data"];
            JL_Chart_OxyhemoglobinSaturation *model = [[JL_Chart_OxyhemoglobinSaturation alloc] initChart:bufferData];
            model.maxValue = [req intForColumn:@"maxValue"];
            model.minValue = [req intForColumn:@"minValue"];
            model.averageValue = [req intForColumn:@"averageValue"];
            [modelArray addObject:model];
        }
        block(modelArray);
    }];
}

+ (void)s_checkoutMinAndMaxTimestampWithResult:(SqlOxyhemoglobinSaturationTimestampBlock)block {
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    __block NSTimeInterval minDateTimeInterval = [[NSDate date] timeIntervalSince1970];
    __block NSTimeInterval maxDateTimeInterval = [[NSDate date] timeIntervalSince1970];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *minStr = [NSString stringWithFormat:@"select * from %@ where timestamp = (select MIN(timestamp) from %@)", tb_oxyhemoglobin_saturation, tb_oxyhemoglobin_saturation];
        FMResultSet *minResultSet = [db executeQuery:minStr];
        while ([minResultSet next]) {
            minDateTimeInterval = [minResultSet doubleForColumn:@"timestamp"];
        }
        NSString *maxStr = [NSString stringWithFormat:@"select * from %@ where timestamp = (select MAX(timestamp) from %@)", tb_oxyhemoglobin_saturation, tb_oxyhemoglobin_saturation];
        FMResultSet *maxResultSet = [db executeQuery:maxStr];
        while ([maxResultSet next]) {
            maxDateTimeInterval = [maxResultSet doubleForColumn:@"timestamp"];
        }
        block(minDateTimeInterval, maxDateTimeInterval);
    }];
}

/// 查询最新一条的数据
/// @param block 图表列表回调
+ (void)s_checkoutTheLastDataWithResult:(SqlOxyhemoglobinSaturationBlock)block {
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    __block JL_Chart_OxyhemoglobinSaturation *model = nil;
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ order by timestamp desc limit 1", tb_oxyhemoglobin_saturation];
        FMResultSet *resultSet = [db executeQuery:newStr];
        while ([resultSet next]) {
            NSData *bufferData = [resultSet dataForColumn:@"data"];
            model = [[JL_Chart_OxyhemoglobinSaturation alloc] initChart:bufferData];
            model.maxValue = [resultSet intForColumn:@"maxValue"];
            model.minValue = [resultSet intForColumn:@"minValue"];
            model.averageValue = [resultSet intForColumn:@"averageValue"];
        }
        block(model);
    }];
}

+ (void)s_checkout:(NSArray<NSDate *> *)dateArray Result:(SqlOxyhemoglobinSaturationsBlock)block {
    
    NSMutableString *mtStr = [NSMutableString new];
    [mtStr appendString:@"("];
    for (NSDate * item in dateArray) {
        [mtStr appendFormat:@"'%@',", item.toYYYYMMdd];
    }
    [mtStr replaceCharactersInRange:NSMakeRange(mtStr.length - 1, 1) withString:@""];
    [mtStr appendString:@")"];
    NSMutableArray<JL_Chart_OxyhemoglobinSaturation *> *modelArray = [NSMutableArray new];
    
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where date in %@", tb_oxyhemoglobin_saturation, mtStr];
        FMResultSet *req = [db executeQuery:newStr];
        while ([req next]) {
            NSData *bufferData = [req dataForColumn:@"data"];
            JL_Chart_OxyhemoglobinSaturation *model = [[JL_Chart_OxyhemoglobinSaturation alloc] initChart:bufferData];
            model.maxValue = [req intForColumn:@"maxValue"];
            model.minValue = [req intForColumn:@"minValue"];
            model.averageValue = [req intForColumn:@"averageValue"];
            [modelArray addObject:model];
        }
        NSArray<JL_Chart_OxyhemoglobinSaturation *> *models = [[modelArray reverseObjectEnumerator] allObjects];
        block(models);
    }];
}

#pragma mark - 插入/更新

//+ (void)s_update:(JL_SDM_OxSaturation *)model {
//     if (model.chartModel) {
//         NSInteger totalValue = 0;
//         NSInteger maxValue = 0;
//         NSInteger minValue = 0;
//         for (JL_SDM_TimeData *item in model.chartModel.dataArray) {
//             totalValue += item.num;
//             if (item.num > maxValue) {
//                 maxValue = item.num;
//             }
//             if (item.num < minValue) {
//                 minValue = item.num;
//             }
//         }
//         NSInteger count = model.chartModel.dataArray.count > 0 ? model.chartModel.dataArray.count : 1;
//         NSInteger averageValue = totalValue / count;
//         [self updateData:model.chartModel.sourceData interval:model.chartModel.interval maxValue:[[NSNumber alloc] initWithInteger:maxValue] minValue:[[NSNumber alloc] initWithInteger:minValue] averageValue:[[NSNumber alloc] initWithInteger:averageValue] ByDate:model.chartModel.startDate];
//     } else {
//         // 这里是处理实回来的记录到数据库中
//         if (model.staturation != 0) {
//             UInt8 hr[] = {model.staturation};
//             NSDate *saveDate = [NSDate new];
//             __block JL_SDM_Chart *chart;
//             [self s_checkout:@[saveDate] Result:^(NSArray<JL_SDM_Chart *> * _Nonnull charts) {
//                 if (charts) {
//                     chart = charts.firstObject;
//                 }
//             }];
//             int index = 0;
//             for (int i = 0; i < chart.dataArray.count; i++) {
//                 JL_SDM_TimeData *td = chart.dataArray[i];
//                 if ([saveDate.toHHmmss compareTimeIntervalTo:td.date.toHHmmss]) {
//                     index++;
//                 } else {
//                     break;
//                 }
//             }
//             NSMutableData *dt0 = [NSMutableData dataWithData:chart.sourceData];
//             JL_SportDataFormat sportDataFormat = [JLWatchEnum sportDataFormatFromSportDataType:JL_SportDataTypeOxygenSaturation];
//             [dt0 replaceBytesInRange:NSMakeRange(index * sportDataFormat, sportDataFormat) withBytes:hr];
//             NSInteger totalValue = 0;
//             NSInteger maxValue = 0;
//             NSInteger minValue = 0;
//             for (JL_SDM_TimeData *item in chart.dataArray) {
//                 totalValue += item.num;
//                 if (item.num > maxValue) {
//                     maxValue = item.num;
//                 }
//                 if (item.num < minValue) {
//                     minValue = item.num;
//                 }
//             }
//             NSInteger count = chart.dataArray.count > 0 ? chart.dataArray.count : 1;
//             NSInteger averageValue = totalValue / count;
//             [self updateData:model.chartModel.sourceData interval:model.chartModel.interval maxValue:[[NSNumber alloc] initWithInteger:maxValue] minValue:[[NSNumber alloc] initWithInteger:minValue] averageValue:[[NSNumber alloc] initWithInteger:averageValue] ByDate:model.chartModel.startDate];
//         }
//     }
//}


+(void)s_sync_update:(JLWearSyncHealthBloodOxyganChart *)model {
    if (model == nil) return;
    NSMutableArray *tmpArray = [NSMutableArray new];
    NSInteger totalValue = 0;
    for (BloodOxyganData * hrd in model.bloodOxyganlist) {
        for (NSNumber *num in hrd.bloodOxygans){
            totalValue+=[num intValue];
            [tmpArray addObject:num];
        }
    }
    [EcTools quickArray:tmpArray withLeftIndex:0 AndRightIndex:tmpArray.count-1];
    NSInteger averageValue = totalValue / tmpArray.count;
    [self updateData:model.sourceData interval:model.interval maxValue:tmpArray.lastObject minValue:tmpArray.firstObject averageValue:[[NSNumber alloc] initWithInteger:averageValue] ByDate:model.bloodOxyganlist.firstObject.startDate];
}


+ (void)updateData:(NSData *)data interval:(NSInteger)interval maxValue:(NSNumber *)maxValue minValue:(NSNumber *)minValue averageValue:(NSNumber *)averageValue ByDate:(NSDate *)date {
    NSString *dt = date.toYYYYMMdd;
    NSString *ds = date.toHHmmss;
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    NSNumber *num = [[NSNumber alloc] initWithInt:(int)interval];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql0 = [NSString stringWithFormat:@"select * from %@ where date = '%@'", tb_oxyhemoglobin_saturation, dt];
        FMResultSet *req = [db executeQuery:sql0];
        if ([req next]) {
            NSString *sql = [NSString stringWithFormat:@"update %@ set timestamp = ?, time = ?, data = ?, interval = ?, maxValue = ?, minValue = ?, averageValue = ? where date = ?", tb_oxyhemoglobin_saturation];
           BOOL res = [db executeUpdate:sql, [NSNumber numberWithDouble:timestamp], ds, data, num, maxValue, minValue, averageValue, dt];
            if (!res) {
                kJLLog(JLLOG_DEBUG, @"update failed");
            }
        } else {
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (timestamp, date, time, interval, data, maxValue, minValue, averageValue) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", tb_oxyhemoglobin_saturation];
            BOOL res = [db executeUpdate:sql, [NSNumber numberWithDouble:timestamp], dt, ds, num, data, maxValue, minValue, averageValue];
            if (!res) {
                kJLLog(JLLOG_DEBUG, @"insert failed");
            }
        }
    }];
}

#pragma mark - 删除

/// 根据日期删除对应的数据
/// @param date 日期
+ (void)s_delete:(NSDate *)date {
    [[JLSqliteManager sharedInstance] deleteByDate:date InTable:tb_oxyhemoglobin_saturation];
}

@end
