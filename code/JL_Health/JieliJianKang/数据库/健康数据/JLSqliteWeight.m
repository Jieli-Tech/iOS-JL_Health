//
//  JLSqliteWeight.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/10/28.
//

#import "JLSqliteWeight.h"

@implementation JL_Chart_Weight

@end

@implementation JLSqliteWeight

#pragma mark - 查询

/// 查询一段时间区间的数据
/// @param startDate 开始日期
/// @param endDate 结束日期
/// @param block 图表列表回调
+ (void)s_checkoutWtihStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate Result:(SqlWeightsBlock)block {
    NSTimeInterval startDateTimeInterval = [startDate.toStartOfDate timeIntervalSince1970];
    NSTimeInterval endDateTimeInterval = [endDate.toEndOfDate timeIntervalSince1970];
    NSMutableArray<JL_Chart_Weight *> *modelArray = [NSMutableArray new];
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where timestamp >= %f and timestamp <= %f order by timestamp asc", tb_weight, startDateTimeInterval, endDateTimeInterval];
        FMResultSet *req = [db executeQuery:newStr];
        while ([req next]) {
            JL_Chart_Weight *model = [[JL_Chart_Weight alloc] init];
            model.weight = [req doubleForColumn:@"weight"];
            model.date = [NSDate dateWithTimeIntervalSince1970:[req doubleForColumn:@"timestamp"]];
            [modelArray addObject:model];
        }
        block(modelArray);
    }];
}

/// 查询数据最小最大时间
/// @param block 最小最大时间回调
+ (void)s_checkoutMinAndMaxTimestampWithResult:(SqlWeightTimestampBlock)block {
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    __block NSTimeInterval minDateTimeInterval = [[NSDate date] timeIntervalSince1970];
    __block NSTimeInterval maxDateTimeInterval = [[NSDate date] timeIntervalSince1970];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *minStr = [NSString stringWithFormat:@"select * from %@ where timestamp = (select MIN(timestamp) from %@)", tb_weight, tb_weight];
        FMResultSet *minResultSet = [db executeQuery:minStr];
        while ([minResultSet next]) {
            minDateTimeInterval = [minResultSet doubleForColumn:@"timestamp"];
        }
        NSString *maxStr = [NSString stringWithFormat:@"select * from %@ where timestamp = (select MAX(timestamp) from %@)", tb_weight, tb_weight];
        FMResultSet *maxResultSet = [db executeQuery:maxStr];
        while ([maxResultSet next]) {
            maxDateTimeInterval = [maxResultSet doubleForColumn:@"timestamp"];
        }
        block(minDateTimeInterval, maxDateTimeInterval);
    }];
}

/// 查询最新一条的数据
/// @param block 图表列表回调
+ (void)s_checkoutTheLastDataWithResult:(SqlWeightBlock)block{
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    __block JL_Chart_Weight *model = nil;
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ order by timestamp desc limit 1", tb_weight];
        FMResultSet *req = [db executeQuery:newStr];
        while ([req next]) {
            model = [[JL_Chart_Weight alloc] init];
            model.weight = [req doubleForColumn:@"weight"];
            model.date = [NSDate dateWithTimeIntervalSince1970:[req doubleForColumn:@"timestamp"]];
        }
        block(model);
    }];
}

#pragma mark - 插入/更新

/// 插入或更新数据
/// @param model 数据模型
+ (void)s_update:(JL_Chart_Weight *)model {
    if (model == nil) return;
    NSDate *date = model.date;
    if (date == nil) date = [NSDate date];
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    NSNumber *weight = [NSNumber numberWithDouble:model.weight];
    NSString *dt = date.toYYYYMMdd;
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql0 = [NSString stringWithFormat:@"select * from %@ where timestamp = %f", tb_weight, timestamp];
        FMResultSet *resultSet = [db executeQuery:sql0];
        if ([resultSet next]) {
            NSString *sql = [NSString stringWithFormat:@"update %@ set weight = ?, date = ? where timestamp = ?", tb_weight];
            BOOL res = [db executeUpdate:sql, weight, dt, [NSNumber numberWithInteger:(NSInteger)timestamp]];
            if (!res) {
                NSLog(@"update failed");
            }
        } else {
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (timestamp, weight, date) VALUES (?, ?, ?)", tb_weight];
            BOOL res = [db executeUpdate:sql, [NSNumber numberWithInteger:(NSInteger)timestamp], weight, dt];
            if (!res) {
                NSLog(@"insert failed");
            }
        }
    }];
}

#pragma mark - 删除

/// 根据日期删除对应的数据
/// @param date 日期
+ (void)s_delete:(NSDate *)date {
    [[JLSqliteManager sharedInstance] deleteByDate:date InTable:tb_weight];
}

@end
