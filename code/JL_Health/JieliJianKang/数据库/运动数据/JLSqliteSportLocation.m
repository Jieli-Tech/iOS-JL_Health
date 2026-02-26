//
//  JLSqliteSportLocation.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/10/25.
//

#import "JLSqliteSportLocation.h"

@implementation JL_SportLocation

- (instancetype)initWithSportID:(double)sport_id withType:(JLSportLocationType)type withLongitude:(double)longitude withLatitude:(double)latitude withSpeed:(double)speed withDate:(NSDate * _Nullable)date {
    self = [super init];
    if (self) {
        self.sport_id = sport_id;
        self.type = type;
        self.longitude = longitude;
        self.latitude = latitude;
        self.speed = speed;
        self.date = date;
    }
    return self;
}

@end

@implementation JLSqliteSportLocation

#pragma mark - 查询

/// 查询运动轨迹
/// @param sport_id 运动ID
/// @param block 运动轨迹模型数组回调
+ (void)s_checkoutWtihSport_id:(double)sport_id Result:(SqlSportLocationBlock)block {
    NSMutableArray<JL_SportLocation *> *modelArray = [NSMutableArray new];
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where sport_id = %ld order by timestamp asc", tb_sport_location, (long)sport_id];
        FMResultSet *req = [db executeQuery:newStr];
        while ([req next]) {
            JL_SportLocation *model = [[JL_SportLocation alloc] init];
            model.sport_id = [req doubleForColumn:@"sport_id"];
            model.type = [req intForColumn:@"type"];
            model.longitude = [req doubleForColumn:@"longitude"];
            model.latitude = [req doubleForColumn:@"latitude"];
            model.speed = [req doubleForColumn:@"speed"];
            model.date = [NSDate dateWithTimeIntervalSince1970:[req doubleForColumn:@"timestamp"]];
            [modelArray addObject:model];
        }
        block(modelArray);
    }];
}

#pragma mark - 插入

/// 插入开始包
/// @param sport_id 运动ID
+ (void)s_insertStartPacketWithSportID:(double)sport_id {
    if (sport_id < 1) return;
    JL_SportLocation *model = [[JL_SportLocation alloc] initWithSportID:sport_id withType:JLSportLocationTypeStartPacket withLongitude:0 withLatitude:0 withSpeed:0 withDate:[NSDate date]];
    [self s_insert:model];
}

/// 插入轨迹
/// @param model 数据模型
+ (void)s_insert:(JL_SportLocation *)model {
    if (model == nil) return;
    NSNumber *sport_id = [NSNumber numberWithDouble:model.sport_id];
    NSNumber *type = [NSNumber numberWithInteger:model.type];
    NSNumber *longitude = [NSNumber numberWithDouble:model.longitude];
    NSNumber *latitude = [NSNumber numberWithDouble:model.latitude];
    NSNumber *speed = [NSNumber numberWithDouble:model.speed];
    NSTimeInterval timestamp = [model.date timeIntervalSince1970];
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (sport_id, type, longitude, latitude, speed, timestamp) VALUES (?, ?, ?, ?, ?, ?)", tb_sport_location];
        BOOL res = [db executeUpdate:sql, sport_id, type, longitude, latitude, speed, [NSNumber numberWithDouble:timestamp]];
        if (!res) {
            NSLog(@"insert failed");
        }
    }];
}

#pragma mark - 删除

/// 根据日期删除对应的数据
/// @param sport_id 运动ID
+ (void)s_delete:(double)sport_id {
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where sport_id = ?", tb_sport_location];
        BOOL ret = [db executeUpdate:sql, [NSNumber numberWithDouble:sport_id]];
        if (!ret) {
            NSLog(@"delete failed");
        }
    }];
}

@end
