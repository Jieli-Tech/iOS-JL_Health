//
//  JLSqliteSportSpeedPerKm.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/5.
//

#import "JLSqliteSportSpeedPerKm.h"

@implementation JL_SportSpeedPerKm

- (instancetype)initWithSportID:(double)sport_id withDistance:(double)distance withStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate {
    self = [super init];
    if (self) {
        self.sport_id = sport_id;
        self.distance = distance;
        self.startDate = startDate;
        self.endDate = endDate;
    }
    return self;
}

@end

@implementation JLSqliteSportSpeedPerKm

/// 查询运动每公里配速信息
/// @param sport_id 运动ID
/// @param block 每公里配速模型数组回调
+ (void)s_checkoutWtihSport_id:(double)sport_id Result:(SqlSportSpeedPerKmBlock)block {
    NSMutableArray<JL_SportSpeedPerKm *> *modelArray = [NSMutableArray new];
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where sport_id = %ld order by startTimestamp asc", tb_sport_speed_per_km, (long)sport_id];
        FMResultSet *req = [db executeQuery:newStr];
        while ([req next]) {
            JL_SportSpeedPerKm *model = [[JL_SportSpeedPerKm alloc] init];
            model.sport_id = [req doubleForColumn:@"sport_id"];
            model.speed = [req doubleForColumn:@"speed"];
            model.distance = [req doubleForColumn:@"distance"];
            model.startDate = [NSDate dateWithTimeIntervalSince1970:[req doubleForColumn:@"startTimestamp"]];
            model.endDate = [NSDate dateWithTimeIntervalSince1970:[req doubleForColumn:@"endTimestamp"]];
            [modelArray addObject:model];
        }
        block(modelArray);
    }];
}

#pragma mark - 插入

/// 插入轨迹
/// @param model 数据模型
+ (void)s_insert:(JL_SportSpeedPerKm *)model {
    if (model == nil) return;
    NSNumber *sport_id = [NSNumber numberWithDouble:model.sport_id];
    double speed = 0;
    NSNumber *distance = [NSNumber numberWithDouble:model.distance];
    NSTimeInterval startTimestamp = [model.startDate timeIntervalSince1970];
    NSTimeInterval endTimestamp = [model.endDate timeIntervalSince1970];
    if (startTimestamp == endTimestamp) endTimestamp++;
    speed = 1000 * (endTimestamp - startTimestamp) / model.distance; // (配速 = 秒/公里)
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (sport_id, speed, distance, startTimestamp, endTimestamp) VALUES (?, ?, ?, ?, ?)", tb_sport_speed_per_km];
        BOOL res = [db executeUpdate:sql, sport_id, [NSNumber numberWithDouble:speed], distance, [NSNumber numberWithDouble:startTimestamp], [NSNumber numberWithDouble:endTimestamp]];
        if (!res) {
            kJLLog(JLLOG_DEBUG, @"insert failed");
        }
    }];
}

#pragma mark - 删除

/// 根据日期删除对应的数据
/// @param sport_id 运动ID
+ (void)s_delete:(double)sport_id {
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL ret = [db executeUpdate:@"delete from ? where sport_id = ?", tb_sport_speed_per_km, sport_id];
        if (!ret) {
            kJLLog(JLLOG_DEBUG, @"delete failed");
        }
    }];
}

@end
