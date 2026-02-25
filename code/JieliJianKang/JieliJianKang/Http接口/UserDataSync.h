//
//  UserDataSync.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/5/7.
//

#import <Foundation/Foundation.h>
#import "JLSqliteManager.h"
#import "UserDataHealth.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^HealthDataCbk)(NSArray<UserDataHealth *> *array);
typedef void(^SportDataCbk)(NSArray<UserDataSport *> *array);
typedef void(^SportDataUploadCbk)(NSDictionary *dict);
typedef void(^SportAllDataUploadCbk)(void);
typedef void(^SportAllDataUpdateCbk)(void);
typedef void(^SportRecordsFileBlock)(NSArray <NSString *> *sportFileArray);

@interface UserDataSync : NSObject

#pragma mark - 下载相关
/**
 *  下载服务器健康、运动数据
 */
+ (void)updateHealthAndSportDataFile;

#pragma mark - 上传相关

/**
 *  上传服务器心率数据
 */
+ (void)uploadHealthHeartRateData;
/**
 *  上传服务器步数数据
 */
+ (void)uploadHealthStepCountData;
/**
 *  上传服务器血氧数据
 */
+ (void)uploadHealthSpoData;
/**
 *  上传服务器睡眠数据
 */
+ (void)uploadHealthSleepData;
/**
 *  上传服务器体重数据
 */
+ (void)uploadHealthWeightData;
/**
 *  上传服务器运动数据
 */
+ (void)uploadSportDataFile;

#pragma mark - 类型转换相关

+ (JL_SmallFileType)smallFileTypeFromTableName:(NSString *)tableName;

@end

NS_ASSUME_NONNULL_END
