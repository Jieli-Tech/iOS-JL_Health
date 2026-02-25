//
//  JLSqliteManager.m
//  Test
//
//  Created by EzioChan on 2021/4/25.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import "JLSqliteManager.h"

#define ECMethod(...) NSLog(@"%s%@", __func__,__VA_ARGS__)

@interface JLSqliteManager()

@property (strong, nonatomic) FMDatabaseQueue *fmdbQueue;
@property (nonatomic, strong) NSString *identify;

@end

@implementation JLSqliteManager

+ (instancetype)sharedInstance {
    static JLSqliteManager *mgr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[JLSqliteManager alloc] init];
    });
    return mgr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (FMDatabaseQueue *)fmdbQueue {
    return _fmdbQueue;
}

#pragma mark - 数据库/数据表创建

- (void)checkfmDbPath:(NSString *)dbName {
    _fmdbQueue  = [FMDatabaseQueue databaseQueueWithPath:dbName.path];
}

//#pragma mark - 健康类数据表名
//#define tb_heart_rate           @"tb_heart_rate"///心率
//#define tb_step                 @"tb_step"///运动步数
//#define tb_stress               @"tb_stress"///压力测试
//#define tb_oxyhemoglobin        @"tb_oxyhemoglobin"///血氧饱和度
//#pragma mark - 运动类数据表名
//#define tb_exercise_running     @"tb_exercise_running"///跑步运动信息
//#define tb_exercise_location    @"tb_exercise_location"///运动定位信息
- (void)initializeDatabaseWithUserIdentify:(NSString *)identify {
    
    _identify = identify;
    [self checkfmDbPath:[identify addSuffix:@"db"]];
    
    // MARK: - 健康类数据表
    // 心率图表数据表
    [self creatTable:tb_heart_rate withTableSql:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, timestamp double, date TEXT, time TEXT, interval INT, data BLOB, restingHeartRate INT, maxValue INT, minValue INT);", tb_heart_rate]];
    // 步数图表数据表
    [self creatTable:tb_step withTableSql:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, timestamp double, date TEXT, time TEXT, interval INT, data BLOB, allStep INT, totalMileage double, totalConsumption INT);", tb_step]];
    // 压力图表数据表
//    [self creatTable:tb_stress withTableSql:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, timestamp double, date TEXT, time TEXT, interval INT, data BLOB, maxValue INT, minValue INT, averageValue INT);", tb_stress]];
    // 血氧饱和度图表数据表
    [self creatTable:tb_oxyhemoglobin_saturation withTableSql:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, timestamp double, date TEXT, time TEXT, interval INT, data BLOB, maxValue INT, minValue INT, averageValue INT);", tb_oxyhemoglobin_saturation]];
    // 体重
    [self creatTable:tb_weight withTableSql:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, timestamp double, date TEXT, weight double);", tb_weight]];
    //睡眠
    [self creatTable:tb_sleep withTableSql:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, data BLOB, timestamp DOUBLE);", tb_sleep]];
    // MARK: - 运动类数据表
    // 跑步运动信息
    [self creatTable:tb_sport_running withTableSql:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, sport_id DOUBLE, type INT, startTimestamp DOUBLE, data BLOB);", tb_sport_running]];
    // 轨迹表
    [self creatTable:tb_sport_location withTableSql:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, sport_id DOUBLE, type INT, longitude DOUBLE, latitude DOUBLE, speed DOUBLE, timestamp DOUBLE);", tb_sport_location]];
    // 每公里配速表
    [self creatTable:tb_sport_speed_per_km withTableSql:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, sport_id DOUBLE, speed DOUBLE, distance DOUBLE, startTimestamp DOUBLE, endTimestamp DOUBLE);", tb_sport_speed_per_km]];
    
    NSLog(@"initializeDatabaseWithUserIdentify");
}

- (void)creatTable:(NSString *)tbName withTableSql:(NSString *)sqlStr {
    [_fmdbQueue inDatabase:^(FMDatabase * _Nonnull db) {
//        FMResultSet *req = [db executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) count FROM sqlite_master where type='table' and name='%@'", tbName]];
//        if ([req next]) {
//            NSString *count = [req stringForColumn:@"count"];
//            if (count.intValue == 0) {
                [db executeUpdate:sqlStr];
//            }
//        }
    }];
}

#pragma mark - 数据表删除

- (void)deleteByDate:(NSDate *)date InTable:(NSString *)tableName {

    NSString *dt = date.toYYYYMMdd;
    [_fmdbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL ret = [db executeUpdate:@"delete from ? where date = ?", tableName, dt];
        if (!ret) {
            ECMethod(@"delete failed");
        }
    }];
}

#pragma mark - 数据表查询

//#define tb_heart_rate                       @"tb_heart_rate"///心率
//#define tb_step                             @"tb_step"///运动步数
//#define tb_oxyhemoglobin_saturation         @"tb_oxyhemoglobin_saturation"///血氧饱和度
//#define tb_weight                           @"tb_weight"///体重
//#define tb_sleep                            @"tb_sleep"//睡眠
- (void)checkOutAllByDate:(NSDate *)date result:(checkDayAllBlock)block {
    NSString *dateStr = date.toYYYYMMdd;
    NSArray *reqArray = @[tb_step, tb_heart_rate, tb_oxyhemoglobin_saturation, tb_weight, tb_sleep];
    [_fmdbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSMutableArray *newArray = [NSMutableArray new];
        for (NSString *tbName in reqArray) {
            FMResultSet *req = [db executeQuery:@"select * from ? where date = ?", tbName, dateStr];
            while ([req next]) {
                [newArray addObject:[self dataToBase64:tbName WithResult:req]];
            }
        }
        block(newArray);
    }];
}

- (void)checkoutDate:(NSDate *)date DataByName:(NSString *)name result:(checkDayAllBlock)block {
    NSString *dateStr = date.toYYYYMMdd;
    NSArray *reqArray = @[name];
    [_fmdbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSMutableArray *newArray = [NSMutableArray new];
        for (NSString *tbName in reqArray) {
            FMResultSet *req = [db executeQuery:@"select * from ? where date = ?", tbName, dateStr];
            while ([req next]) {
                [newArray addObject:[self dataToBase64:tbName WithResult:req]];
            }
        }
        block(newArray);
    }];
}

- (void)checkoutWithStartDate:(NSDate *)startDate WithEndDate:(NSDate *)endDate  DataByName:(NSString *)tbName result:(checkDayAllBlock)block {
    NSTimeInterval startDateTimeInterval = [startDate.toStartOfDate timeIntervalSince1970];
    NSTimeInterval endDateTimeInterval = [endDate.toEndOfDate timeIntervalSince1970];
    [_fmdbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSMutableArray *newArray = [NSMutableArray new];
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where timestamp >= %f and timestamp <= %f order by timestamp desc", tbName, startDateTimeInterval, endDateTimeInterval];
        FMResultSet *req = [db executeQuery:newStr];
        while ([req next]) {
            [newArray addObject:[self dataToBase64:tbName WithResult:req]];
        }
        block(newArray);
    }];
}

#pragma mark - Private Methods

- (NSDate *)toDate:(NSString *)dt Time:(NSString *)ds {
    NSDateFormatter *fm = [EcTools cachedFm];
    [fm setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *newStr = [NSString stringWithFormat:@"%@ %@", dt, ds];
    return [fm dateFromString:newStr];
}

//MARK: - base64
//#define tb_heart_rate                       @"tb_heart_rate"///心率
//#define tb_step                             @"tb_step"///运动步数
//#define tb_oxyhemoglobin_saturation         @"tb_oxyhemoglobin_saturation"///血氧饱和度
//#define tb_sleep                            @"tb_sleep"//睡眠
- (NSDictionary *)dataToBase64:(NSString *)tableName WithResult:(FMResultSet *)result {
    NSData *data = [result dataForColumn:@"data"];
    NSString *base64Str = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSTimeInterval timestamp = [result doubleForColumn:@"timestamp"];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    UInt8 type = [UserDataSync smallFileTypeFromTableName:tableName];
    if (base64Str == nil) {
        base64Str = @"";
    }
    NSDictionary *dict = @{@"type":[NSNumber numberWithInt:type], @"data":base64Str, @"date":startDate.toAllDate};
    return dict;
}

//#define tb_weight                           @"tb_weight"///体重
+ (NSDictionary *)weightDataToBase64WithResult:(JLWearSyncHealthWeightChart *)chart {
    NSString *base64Str = [chart.beData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSDate *startDate = chart.weightDataArray.firstObject.startDate;
    if (startDate == nil) {
        startDate = [NSDate date];
    }
    NSString *allDate = startDate.toAllDate;
    UInt8 type = [UserDataSync smallFileTypeFromTableName:tb_weight];
    if (base64Str == nil) {
        base64Str = @"";
    }
    NSDictionary *dict = @{@"type":[NSNumber numberWithInt:type], @"data":base64Str, @"date":allDate};
    return dict;
}

@end
