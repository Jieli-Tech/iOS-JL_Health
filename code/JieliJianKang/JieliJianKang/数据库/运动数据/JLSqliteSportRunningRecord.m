//
//  JLSqliteSportRunningRecord.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/10/29.
//

#import "JLSqliteSportRunningRecord.h"
#import "NSString+Time.h"

@implementation JL_SportRecord_Chart

- (NSString *)getSpeed {
    double pace = self.distance * 100 * self.duration / 3600;
    return [NSString paceFormatted:pace];
}

@end


@implementation JLSqliteSportRunningRecord

#pragma mark - 查询

/// 查询一段时间区间的数据
/// @param startDate 开始日期
/// @param endDate 结束日期
/// @param block 图表列表回调
+ (void)s_checkoutWtihStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate Result:(SqlSportRecordsBlock)block {
    NSTimeInterval startDateTimeInterval = [startDate.toStartOfDate timeIntervalSince1970];
    NSTimeInterval endDateTimeInterval = [endDate.toEndOfDate timeIntervalSince1970];
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    NSMutableArray<JL_SportRecord_Chart *> *modelArray = [NSMutableArray new];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where sport_id >= %f and sport_id <= %f order by sport_id asc", tb_sport_running, startDateTimeInterval, endDateTimeInterval];
        FMResultSet *resultSet = [db executeQuery:newStr];
        while ([resultSet next]) {
            NSData *bufferData = [resultSet dataForColumn:@"data"];
            JL_SportRecord_Chart *model = [[JL_SportRecord_Chart alloc] initWithData:bufferData];
            model.sport_id = [model.dataArray.firstObject.startDate timeIntervalSince1970];
            [modelArray addObject:model];
        }
        
        for (JL_SportRecord_Chart *chart in modelArray) {
            [self s_checkoutSportLocationsInDatabase:db withChart:chart];
        }
        
        block(modelArray);
    }];
}

/// 查询一段区间的数据
/// @param index 开始索引
/// @param needResultCount 结束日期
/// @param block 运动记录数据回调
+ (void)s_checkoutWtihStartIndex:(NSInteger)index needResultCount:(NSInteger)needResultCount withIsASC:(BOOL)isASC Result:(SqlSportRecordsBlock)block {
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    NSMutableArray<JL_SportRecord_Chart *> *modelArray = [NSMutableArray new];
    NSString *sortStr = isASC ? @"asc" : @"desc";
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"select count(*) from %@", tb_sport_running];
        int count = [db intForQuery:sql];
        NSInteger startIndex = count - index;
        NSInteger endIndex = count - index - needResultCount + 1;
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where ID <= %ld and ID >= %ld order by sport_id %@, ID %@", tb_sport_running, startIndex, endIndex, sortStr, sortStr];
        FMResultSet *resultSet = [db executeQuery:newStr];
        while ([resultSet next]) {
            NSData *bufferData = [resultSet dataForColumn:@"data"];
            if (bufferData.length > 0) {
                JL_SportRecord_Chart *chart = [[JL_SportRecord_Chart alloc] initWithData:bufferData];
                chart.sport_id = [chart.dataArray.firstObject.startDate timeIntervalSince1970];
                [modelArray addObject:chart];
            }
        }
        
        for (JL_SportRecord_Chart *chart in modelArray) {
            [self s_checkoutSportLocationsInDatabase:db withChart:chart];
        }
        
        block(modelArray);
    }];
}

/// 根据运动id查询数据
/// @param sport_id 运动id
/// @param block 图表列表回调
+ (void)s_checkoutWithSportID:(double)sport_id Result:(SqlSportRecordBlock)block {
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    __block JL_SportRecord_Chart *chart = nil;
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where sport_id = %f", tb_sport_running, sport_id];
        FMResultSet *resultSet = [db executeQuery:newStr];
        while ([resultSet next]) {
            NSData *bufferData = [resultSet dataForColumn:@"data"];
            chart = [[JL_SportRecord_Chart alloc] initWithData:bufferData];
            chart.sport_id = [chart.dataArray.firstObject.startDate timeIntervalSince1970];
            [self s_checkoutSportLocationsInDatabase:db withChart:chart];
        }
        block(chart);
    }];
}

/// 查询最新一条的数据
/// @param block 图表列表回调
+ (void)s_checkoutTheLastDataWithResult:(SqlSportRecordBlock)block {
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    __block JL_SportRecord_Chart *model = nil;
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ order by sport_id desc limit 1", tb_sport_running];
        FMResultSet *resultSet = [db executeQuery:newStr];
        while ([resultSet next]) {
            NSData *bufferData = [resultSet dataForColumn:@"data"];
            model = [[JL_SportRecord_Chart alloc] initWithData:bufferData];
            model.sport_id = [model.dataArray.firstObject.startDate timeIntervalSince1970];
        }
        block(model);
    }];
}

+ (void)s_checkoutSportLocationsInDatabase:(FMDatabase * _Nonnull )db withChart:(JL_SportRecord_Chart *)chart {
    if (chart.modelType != 0x01) {
        return;
    }
    NSMutableArray<JL_SportLocation *> *locationsArray = [NSMutableArray new];
    NSString *newStr = [NSString stringWithFormat:@"select * from %@ where sport_id = %ld order by timestamp desc", tb_sport_location, (long)chart.sport_id];
    FMResultSet *req = [db executeQuery:newStr];
    while ([req next]) {
        JL_SportLocation *locationModel = [[JL_SportLocation alloc] init];
        locationModel.sport_id = [req doubleForColumn:@"sport_id"];
        locationModel.type = [req intForColumn:@"type"];
        locationModel.longitude = [req doubleForColumn:@"longitude"];
        locationModel.latitude = [req doubleForColumn:@"latitude"];
        locationModel.speed = [req doubleForColumn:@"speed"];
        locationModel.date = [NSDate dateWithTimeIntervalSince1970:[req doubleForColumn:@"timestamp"]];
        [locationsArray addObject:locationModel];
    }
    chart.sportLocations = locationsArray;
    chart.locationCoordsCount = 0;
    for (JL_SportLocation *sportLocation in locationsArray) {
        if (sportLocation.type == JLSportLocationTypeDataPacket) chart.locationCoordsCount++;
    }
    if (chart.locationCoordsCount > 2) {
        CLLocationCoordinate2D coords[chart.locationCoordsCount];
        chart.firstSportLocation = chart.sportLocations.firstObject;
        chart.lastSportLocation = chart.sportLocations.lastObject;
        int index = 0;
        for (int i  = 0; i < chart.sportLocations.count; i++) {
            JL_SportLocation *sportLocation = chart.sportLocations[i];
            if (sportLocation.type == JLSportLocationTypeDataPacket) {
                if (index == 0) {
                    chart.firstSportLocation = sportLocation;
                }
                coords[index].latitude = sportLocation.latitude;
                coords[index].longitude = sportLocation.longitude;
                chart.lastSportLocation = sportLocation;
                index++;
            }
        }
        chart.polyline = [MAPolyline polylineWithCoordinates:coords count:chart.locationCoordsCount];
    }
}

#pragma mark - 插入/更新

/// 更新设备回调的数据表
/// @param model JLWearSyncHealthSleepChart 睡眠图表数据模型
+ (void)s_update:(JLSportRecordModel *)model {
    if (model == nil) return;
    [self updateData:model.sourceData type:model.modelType ByDate:model.dataArray.firstObject.startDate];
}

+ (void)updateData:(NSData *)data type:(int)type ByDate:(NSDate *)date {
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql0 = [NSString stringWithFormat:@"select * from %@ where sport_id = %f", tb_sport_running, timestamp];
        FMResultSet *resultSet = [db executeQuery:sql0];
        if ([resultSet next]) {
            NSString *sql = [NSString stringWithFormat:@"update %@ set type = ?, startTimestamp = ?, data = ? where sport_id = ?", tb_sport_running];
            BOOL res = [db executeUpdate:sql, [NSNumber numberWithInt:type], [NSNumber numberWithDouble:timestamp], data, [NSNumber numberWithDouble:timestamp]];
            if (!res) {
                NSLog(@"update failed");
            }
        } else {
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (sport_id, type, startTimestamp, data) VALUES (?, ?, ?, ?)", tb_sport_running];
            BOOL res = [db executeUpdate:sql, [NSNumber numberWithDouble:timestamp], [NSNumber numberWithInt:type], [NSNumber numberWithDouble:timestamp], data];
            if (!res) {
                NSLog(@"insert failed");
            }
        }
    }];
    
}

#pragma mark - 删除

/// 根据运动ID删除对应的数据
/// @param sportId sport_id
+ (void)s_delete:(double)sportId {
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL ret = [db executeUpdate:@"delete from ? where sport_id = ?", tb_sport_running, [NSNumber numberWithDouble:sportId]];
        if (!ret) {
            NSLog(@"delete failed");
        }
    }];
}

@end
