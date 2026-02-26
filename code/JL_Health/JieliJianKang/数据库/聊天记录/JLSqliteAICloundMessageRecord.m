//
//  JLSqliteAICloundMessageRecord.m
//  JieliJianKang
//
//  Created by 李放 on 2023/8/2.
//

#import "JLSqliteAICloundMessageRecord.h"

@implementation JLSqliteAICloundMessageRecord


//// 聊天数据表
//[self creatTable:tb_chat_record withTableSql:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, role INT, timestamp double, date TEXT, text TEXT, aiCloudState INT);", tb_chat_record]];

/// 查询数据
/// @param date 日期
/// @param block 聊天记录回调
+ (void)s_checkoutWtihDate:(NSDate *)date WithOffset:(int) offset WithResult:(SqlAICloundMessageBlock)block{
    NSTimeInterval dateTimeInterval = [date timeIntervalSince1970];
    NSMutableArray *modelArray = [NSMutableArray new];
    
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where timestamp <= %f order by timestamp asc limit %d,16", tb_chat_record, dateTimeInterval,offset];
//        NSString *newStr = [NSString stringWithFormat:@"select * from %@ where timestamp <= %f order by timestamp", tb_chat_record, dateTimeInterval];
        FMResultSet *req = [db executeQuery:newStr];
        while ([req next]) {
            AICloundMessageModel *model = [[AICloundMessageModel alloc] init];
            model.role = [[req stringForColumn:@"role"] intValue];
            model.aiCloudState = [[req stringForColumn:@"aiCloudState"] intValue];
            model.date = [NSDate dateWithTimeIntervalSince1970:[req doubleForColumn:@"timestamp"]];
            NSString *mText = [req stringForColumn:@"text"];
            model.text = [NSString stringWithFormat:@"%@", mText];
            [modelArray addObject:model];
        }
        block(modelArray);
    }];
}

+ (void)s_update:(AICloundMessageModel *)model{
    if (model == nil) return;
    NSDate *date = model.date;
    if (date == nil) date = [NSDate date];
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    NSString *dt = date.toYYYYMMdd;
    NSString *role = [NSString stringWithFormat:@"%d",model.role];
    NSString *aiCloudState = [NSString stringWithFormat:@"%d",model.aiCloudState];
    NSString *text = model.text;
    
    FMDatabaseQueue *queue = [[JLSqliteManager sharedInstance] fmdbQueue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql0 = [NSString stringWithFormat:@"select * from %@ where timestamp = %f", tb_chat_record, timestamp];
        FMResultSet *resultSet = [db executeQuery:sql0];
        if ([resultSet next]) {
            NSString *sql = [NSString stringWithFormat:@"update %@ set role = ?, date = ?, text = ?, aiCloudState = ? where timestamp = ?", tb_chat_record];
            BOOL res = [db executeUpdate:sql, role, dt,text,aiCloudState, [NSNumber numberWithInteger:(NSInteger)timestamp]];
            if (!res) {
                kJLLog(JLLOG_DEBUG, @"update failed");
            }
        } else {
            kJLLog(JLLOG_DEBUG, @"db:%@",db);
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (role,timestamp,date,text,aiCloudState) VALUES (?,?,?,?,?)", tb_chat_record];
            BOOL res = [db executeUpdate:sql, role, [NSNumber numberWithInteger:(NSInteger)timestamp],dt,text,aiCloudState];
            if (!res) {
                kJLLog(JLLOG_DEBUG, @"insert failed");
            }else{
                kJLLog(JLLOG_DEBUG, @"insert success");
            }
        }
    }];
}

/// 根据日期删除对应的数据
/// @param selectDateArray 删除的日期数据
+ (void)s_delete:(NSArray *) selectDateArray{
    [[JLSqliteManager sharedInstance] deleteBySelectArray:selectDateArray InTable:tb_chat_record];
}

/// 清空所有的数据
+ (void)clean{
    [[JLSqliteManager sharedInstance] clean];
}

@end
