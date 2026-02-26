//
//  JLDeviceSqliteManager.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/22.
//

#import "JLDeviceSqliteManager.h"
#import <Foundation/Foundation.h>
#import "NSDate+Tools.h"
#import "NSString+Path.h"
#import <FMDB/FMDB.h>
#import "UserDeviceModel.h"
#import "EcTools.h"

NSString *const tableName   = @"UserDevices";
NSString *const devName     = @"devName";
NSString *const identifier  = @"identifier";
NSString *const pid         = @"pid";
NSString *const vid         = @"vid";
NSString *const type        = @"type";
NSString *const mac         = @"mac";
NSString *const uuidStr     = @"uuidStr";
NSString *const userID      = @"userID";
NSString *const deviceID    = @"deviceId";
NSString *const androidCfg  = @"androidCfg";
NSString *const explain     = @"explain";
NSString *const timestamp   = @"timestamp";
NSString *const advData     = @"advData";

@interface JLDeviceSqliteManager(){
    FMDatabaseQueue *fmdbQueue;
}
@end

@implementation JLDeviceSqliteManager

+(instancetype)share{
    static JLDeviceSqliteManager *me;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        me = [[JLDeviceSqliteManager alloc] init];
    });
    return me;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //1.获得数据库文件的路径
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fmdbPath = [doc stringByAppendingPathComponent:@"UserDevices.sqlite"];
        fmdbQueue = [FMDatabaseQueue databaseQueueWithPath:fmdbPath];
        NSString *sql = [NSString stringWithFormat:@"create table %@ (identifier integer primary key autoincrement,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ double,%@ BLOB)",tableName,devName,pid,vid,type,mac,uuidStr,userID,deviceID,androidCfg,explain,timestamp,advData];
        [fmdbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            [db executeStatements:sql];
        }];
        //如果老表中没有那就插入一个新的列
        [fmdbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            if (![db columnExists:timestamp inTableWithName:tableName]) {
                NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ DOUBLE",tableName,timestamp];
                [db executeUpdate:alertStr];
            }
        }];
        //新增广播包内容数据列
        [fmdbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            if (![db columnExists:advData inTableWithName:tableName]) {
                NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ BLOB",tableName,advData];
                BOOL res1 = [db executeUpdate:alertStr];
                NSLog(@"ADD:%d",res1);
            }
        }];
    }
    return self;
}


-(void)update:(UserDeviceModel *)model{
    [self update:model Time:[NSDate new]];
}

-(void)update:(UserDeviceModel *)model Time:(NSDate *)updateDate{
    [fmdbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *cSql = [NSString stringWithFormat:@"select * from %@ where %@ = ? and %@ = ?",tableName,mac,uuidStr];
        FMResultSet *res = [db executeQuery:cSql,model.mac,model.uuidStr];
        int exist = 0;
        while ([res next]) {
            exist++;
        }
        double dateDb = [updateDate timeIntervalSince1970];
        if (exist == 0) {
            NSString *insert = [NSString stringWithFormat:@"insert into %@ (%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@) values (?,?,?,?,?,?,?,?,?,?,%f,?)",tableName,devName,pid,vid,type,mac,uuidStr,userID,deviceID,androidCfg,explain,timestamp,advData,dateDb];
            BOOL res1 = [db executeUpdate:insert,model.devName,model.pid,model.vid,model.type,model.mac,model.uuidStr,model.userID,model.deviceID,model.androidConfig,model.explain,model.advData];
            if (!res1) {
                NSLog(@"user device insert failed");
            }
            NSLog(@"insert user device：\ndevName:%@，\npid:%@，\nvid:%@，\ntype:%@，\nmac:%@，\nuserID:%@，\nuuidStr:%@,\nDeviceID:%@",model.devName,model.pid,model.vid,model.type,model.mac,model.userID,model.uuidStr,model.deviceID);
        }else{
            
            NSString *update = [NSString stringWithFormat:@"update %@ set %@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?, %@ = %f ,%@ = ? where %@ = ? and %@ = ?",tableName,devName,pid,vid,type,mac,userID,deviceID,androidCfg,explain,timestamp,dateDb,advData,mac,uuidStr];
            BOOL result = [db executeUpdate:update,model.devName,model.pid,model.vid,model.type,model.mac,model.userID,model.deviceID,model.androidConfig,model.explain,model.advData,model.mac,model.uuidStr];
            
            if (result) {
                //NSLog(@"update ok");
                //NSLog(@"update user device：\ndevName:%@，\npid:%@，\nvid:%@，\ntype:%@，\nmac:%@，\nuserID:%@，\nuuidStr:%@ \nDeviceID:%@,\n advData:%@",model.devName,model.pid,model.vid,model.type,model.mac,model.userID,model.uuidStr,model.deviceID,model.advData);
            }else{
                NSLog(@"user device update failed!");
            }
        }
    }];
}


-(void)deleteBy:(UserDeviceModel *)model{
    [fmdbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *str = [NSString stringWithFormat:@"delete from %@ where %@ = ?",tableName,uuidStr];
        BOOL result = [db executeUpdate:str,model.uuidStr];
        if (result) {
            NSLog(@"delete user device：\ndevName:%@，\npid:%@，\nvid:%@，\ntype:%@，\nmac:%@，\nuserID:%@，\nuuidStr:%@",model.devName,model.pid,model.vid,model.type,model.mac,model.userID,model.uuidStr);
        }
    }];
}

-(void)checkoutBy:(NSString *)checkUserID result:(void(^)(NSArray<UserDeviceModel *> * resultArray))result{
    NSMutableArray *array = [NSMutableArray new];
    //NSLog(@"checkoutByUUID:%@",checkUserID);
    if(checkUserID == nil){
        if (result) {
            result(@[]);
        }
        return;
    }
    [fmdbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ = ?",tableName,userID];
        FMResultSet *res = [db executeQuery:sql,checkUserID];
        while ([res next]) {
            UserDeviceModel *model = [[UserDeviceModel alloc] init];
            model.devName = [res stringForColumn:devName];
            model.pid = [res stringForColumn:pid];
            model.vid = [res stringForColumn:vid];
            model.mac = [res stringForColumn:mac];
            model.type = [res stringForColumn:type];
            model.userID = [res stringForColumn:userID];
            model.uuidStr = [res stringForColumn:uuidStr];
            model.deviceID = [res stringForColumn:deviceID];
            model.androidConfig = [res stringForColumn:androidCfg];
            model.explain = [res stringForColumn:explain];
            model.identifier = [res intForColumn:identifier];
            model.timestamp = [res doubleForColumn:timestamp];
            model.advData = [res dataForColumn:advData];
            [array addObject:model];
        }
        [array sortUsingComparator:^NSComparisonResult(UserDeviceModel*  _Nonnull obj1, UserDeviceModel*  _Nonnull obj2) {
            return obj1.timestamp < obj2.timestamp;
        }];
        
        for (UserDeviceModel *model in array) {
            //NSLog(@"EC %@",[EcTools properties_apsClass:[UserDeviceModel class] object:model]);
            NSLog(@"advData:%@",model.advData);
        }
        if (result) {
            result(array);
        }
    }];
    
 
}

-(void)checkoutAll:(void(^)(NSArray<UserDeviceModel *> *resultArray))result{
    NSMutableArray *array = [NSMutableArray new];
    [fmdbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@",tableName];
        FMResultSet *res = [db executeQuery:sql];
        while ([res next]) {
            UserDeviceModel *model = [[UserDeviceModel alloc] init];
            model.devName = [res stringForColumn:devName];
            model.pid = [res stringForColumn:pid];
            model.vid = [res stringForColumn:vid];
            model.mac = [res stringForColumn:mac];
            model.type = [res stringForColumn:type];
            model.userID = [res stringForColumn:userID];
            model.uuidStr = [res stringForColumn:uuidStr];
            model.deviceID = [res stringForColumn:deviceID];
            model.androidConfig = [res stringForColumn:androidCfg];
            model.explain = [res stringForColumn:explain];
            model.identifier = [res intForColumn:identifier];
            model.timestamp = [res doubleForColumn:timestamp];
            model.advData = [res dataForColumn:advData];
            NSLog(@"%@",[EcTools properties_apsClass:[UserDeviceModel class] object:model]);
            [array addObject:model];
        }
        [array sortUsingComparator:^NSComparisonResult(UserDeviceModel*  _Nonnull obj1, UserDeviceModel*  _Nonnull obj2) {
            return obj1.timestamp < obj2.timestamp;
        }];
        if (result) {
            result(array);
        }
    }];
}




@end
