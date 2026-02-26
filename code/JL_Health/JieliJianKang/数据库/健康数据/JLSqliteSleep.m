//
//  JLSqliteSleep.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/1.
//

#import "JLSqliteSleep.h"

@implementation JLSqliteSleep

/// 查询一段时间区间的数据
/// @param startDate 开始日期
/// @param endDate 结束日期
/// @param block 图表列表回调
+ (void)s_checkoutWtihStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate Result:(SqlSleepsBlock)block{
    NSTimeInterval startDateTimeInterval = [startDate.toStartOfDate timeIntervalSince1970];
    NSTimeInterval endDateTimeInterval = [endDate.toEndOfDate timeIntervalSince1970];

    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    NSMutableArray<JLWearSyncHealthSleepChart *> *modelArray = [NSMutableArray new];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where timestamp >= %f and timestamp <= %f order by timestamp asc", tb_sleep, startDateTimeInterval, endDateTimeInterval];
        FMResultSet *resultSet = [db executeQuery:newStr];
        while ([resultSet next]) {
            NSData *bufferData = [resultSet dataForColumn:@"data"];
            JLWearSyncHealthSleepChart *model = [[JLWearSyncHealthSleepChart alloc] initChart:bufferData];
            [modelArray addObject:model];
        }
        block(modelArray);
    }];
}


/// 查询一个或多个日期的数据
/// @param dateArray 日期数组
/// @param block 图表列表回调
+ (void)s_checkout:(NSArray<NSDate *> *)dateArray Result:(SqlSleepsBlock)block{
    NSMutableString *mtStr = [NSMutableString new];
    [mtStr appendString:@"("];
    for (NSDate * item in dateArray) {
        [mtStr appendFormat:@"'%@',", item.toYYYYMMdd];
    }
    [mtStr replaceCharactersInRange:NSMakeRange(mtStr.length - 1, 1) withString:@""];
    [mtStr appendString:@")"];
    
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    NSMutableArray<JLWearSyncHealthSleepChart *> *modelArray = [NSMutableArray new];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where date in %@", tb_sleep, mtStr];
        FMResultSet *resultSet = [db executeQuery:newStr];
        while ([resultSet next]) {
            NSData *bufferData = [resultSet dataForColumn:@"data"];
            JLWearSyncHealthSleepChart *model = [[JLWearSyncHealthSleepChart alloc] initChart:bufferData];
            [modelArray addObject:model];
        }
        block(modelArray);
    }];
    
}

/// 查询最新一条的数据
/// @param block 图表列表回调
+ (void)s_checkoutTheLastDataWithResult:(SqlSleepBlock)block {
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    __block JLWearSyncHealthSleepChart *model = nil;
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ order by timestamp desc limit 1", tb_sleep];
        FMResultSet *resultSet = [db executeQuery:newStr];
        while ([resultSet next]) {
            NSData *bufferData = [resultSet dataForColumn:@"data"];
            model = [[JLWearSyncHealthSleepChart alloc] initChart:bufferData];
        }
        block(model);
    }];
}


/// 更新设备回调的数据表
/// @param model JLWearSyncHealthSleepChart 睡眠图表数据模型
+(void)s_update:(JLWearSyncHealthSleepChart *)model{
    if (model == nil) return;
    NSDateFormatter *fm = [EcTools cachedFm];
    fm.dateFormat = @"yyyyMMdd";
    NSDate *dt = [fm dateFromString:model.yyyyMMdd];
    [self updateData:model.sourceData ByDate:dt];
}

+ (void)updateData:(NSData *)data ByDate:(NSDate *)date{
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    NSString *dt = date.toYYYYMMdd;
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql0 = [NSString stringWithFormat:@"select * from %@ where date = '%@'", tb_sleep, dt];
        FMResultSet *resultSet = [db executeQuery:sql0];
        if ([resultSet next]) {
            NSString *sql = [NSString stringWithFormat:@"update %@ set timestamp = ?, data = ? where date = ?", tb_sleep];
            BOOL res = [db executeUpdate:sql, [NSNumber numberWithDouble:timestamp], data,dt];
            if (!res) {
                kJLLog(JLLOG_DEBUG, @"update failed");
            }
        }else{
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (date, data,timestamp) VALUES ( ?, ?, ?)", tb_sleep];
            BOOL res = [db executeUpdate:sql,dt,data,[NSNumber numberWithDouble:timestamp]];
            if (!res) {
                kJLLog(JLLOG_DEBUG, @"insert failed");
            }
        }
    }];
    
}


/// 根据日期删除对应的数据
/// @param date 日期
+ (void)s_delete:(NSDate *)date{
    [[JLSqliteManager sharedInstance] deleteByDate:date InTable:tb_sleep];
}

@end
