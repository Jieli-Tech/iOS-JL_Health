//
//  UserDataSync.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/5/7.
//

#import "UserDataSync.h"
#import "User_Http.h"
#import "AFNetworking.h"
#import "BasicHttp.h"
#import "BasicHttp.h"
#import "JLSqliteHeartRate.h"
#import "JLSqliteOxyhemoglobinSaturation.h"
#import "JLSqliteStep.h"
#import "JLSqliteSleep.h"
#import "JLSqliteSportRunningRecord.h"
#import "JLSqliteSportLocation.h"
#import "JLSqliteWeight.h"
#import <JL_BLEKit/JL_BLEKit.h>
#import "JLUser.h"

#define LastHealthHeartRateUpeateTime             @"LastHealthHeartRateUpeateTime"///上一次心率健康数据下载时间
#define LastHealthStepCountUpdateTime             @"LastHealthStepCountUpdateTime"///上一次步数健康数据下载时间
#define LastHealthSpoDataUpdateTime               @"LastHealthSpoDataUpdateTime"///上一次血氧健康数据下载时间
#define LastHealthSleepDataUpdateTime             @"LastHealthSleepDataUpdateTime"///上一次睡眠健康数据下载时间
#define LastHealthWeightDataUpdateTime            @"LastHealthWeightDataUpdateTime"///上一次体重健康数据下载时间
#define LastSportUpdateTime                       @"LastSportUpdateTime"///上一次运动数据下载时间

#define LastAllDataUpdateTime                     @"LastAllDataUpdateTime"///上一次所有数据下载时间

static NSString *_sportFileDocPath = @"sport";
static NSString *_sportDownloadFileDocPath = @"sport_download";

@implementation UserDataSync

+(AFHTTPSessionManager *)reqMgr{
    NSString *token = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [AFJSONRequestSerializer serializer].cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"jwt-token"];
    
    return manager;
}

#pragma mark - 更新服务器资源相关 - 对外暴露

+ (void)updateHealthAndSportDataFile {
    if ([self notLoggedIn]) {
        return;
    }
    NSDate *lastAllDataUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:[self getUserLastUpeateTimeKeyWithKey:LastAllDataUpdateTime]];
    NSTimeInterval lastAllDataUpdateTimeInterval = [lastAllDataUpdateTime timeIntervalSince1970];
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    if ((currentTimeInterval - lastAllDataUpdateTimeInterval) < 36000) {
//        kJLLog(JLLOG_DEBUG, @"10分钟内不会再次从服务器拉取数据");
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[self getUserLastUpeateTimeKeyWithKey:LastAllDataUpdateTime]];
//    kJLLog(JLLOG_DEBUG, @"从服务器拉取数据...");
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // 同步服务器用户健康数据
        [JLSqliteHeartRate s_checkoutTheLastDataWithResult:^(JLWearSyncHealthHeartRateChart * _Nonnull chart) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:0];
                if (chart.heartRatelist.firstObject.startDate != nil) {
                    startDate = chart.heartRatelist.firstObject.startDate;
                }
                [UserDataSync requestHealthDataBetween:startDate End:[NSDate date] ByTableName:tb_heart_rate result:^(NSArray<UserDataHealth *> * _Nonnull array) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        for (UserDataHealth *data in array) {
                            JLWearSyncHealthHeartRateChart *chart = [[JLWearSyncHealthHeartRateChart alloc] initChart:data.data];
                            [JLSqliteHeartRate s_sync_update:chart];
                        }
                        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[self getUserLastUpeateTimeKeyWithKey:LastHealthHeartRateUpeateTime]];
                    });
                }];
            });
        }];
        [JLSqliteStep s_checkoutTheLastDataWithResult:^(JL_Chart_MoveSteps * _Nonnull chart) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:0];
                if (chart.stepCountlist.firstObject.startDate != nil) {
                    startDate = chart.stepCountlist.firstObject.startDate;
                }
                [UserDataSync requestHealthDataBetween:startDate End:[NSDate date] ByTableName:tb_step result:^(NSArray<UserDataHealth *> * _Nonnull array) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        for (UserDataHealth *data in array) {
                            JL_Chart_MoveSteps *chart = [[JL_Chart_MoveSteps alloc] initChart:data.data];
                            [JLSqliteStep s_update:chart];
                        }
                        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[self getUserLastUpeateTimeKeyWithKey:LastHealthStepCountUpdateTime]];
                    });
                }];
            });
        }];
        [JLSqliteOxyhemoglobinSaturation s_checkoutTheLastDataWithResult:^(JL_Chart_OxyhemoglobinSaturation * _Nonnull chart) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:0];
                if (chart.bloodOxyganlist.firstObject.startDate != nil) {
                    startDate = chart.bloodOxyganlist.firstObject.startDate;
                }
                [UserDataSync requestHealthDataBetween:startDate End:[NSDate date] ByTableName:tb_oxyhemoglobin_saturation result:^(NSArray<UserDataHealth *> * _Nonnull array) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        for (UserDataHealth *data in array) {
                            JL_Chart_OxyhemoglobinSaturation *chart = [[JL_Chart_OxyhemoglobinSaturation alloc] initChart:data.data];
                            [JLSqliteOxyhemoglobinSaturation s_sync_update:chart];
                        }
                        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[self getUserLastUpeateTimeKeyWithKey:LastHealthSpoDataUpdateTime]];
                    });
                }];
            });
        }];
        [JLSqliteSleep s_checkoutTheLastDataWithResult:^(JLWearSyncHealthSleepChart * _Nonnull chart) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:0];
                if (chart.sleepDataArray.firstObject.startDate != nil) {
                    startDate = chart.sleepDataArray.firstObject.startDate;
                }
                [UserDataSync requestHealthDataBetween:startDate End:[NSDate date] ByTableName:tb_sleep result:^(NSArray<UserDataHealth *> * _Nonnull array) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        for (UserDataHealth *data in array) {
                            JLWearSyncHealthSleepChart *chart = [[JLWearSyncHealthSleepChart alloc] initChart:data.data];
                            [JLSqliteSleep s_update:chart];
                        }
                        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[self getUserLastUpeateTimeKeyWithKey:LastHealthSleepDataUpdateTime]];
                    });
                }];
            });
        }];
        [JLSqliteWeight s_checkoutTheLastDataWithResult:^(JL_Chart_Weight * _Nonnull chart) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:0];
                if (chart.date != nil) {
                    startDate = chart.date;
                }
                [UserDataSync requestHealthDataBetween:startDate End:[NSDate date] ByTableName:tb_weight result:^(NSArray<UserDataHealth *> * _Nonnull array) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        for (UserDataHealth *data in array) {
                            JLWearSyncHealthWeightChart *weightChart = [[JLWearSyncHealthWeightChart alloc] initChart:data.data];
                            for (WeightData *weightData in weightChart.weightDataArray) {
                                JLWearWeightModel *model = weightData.weights.firstObject;
                                if (model) {
                                    JL_Chart_Weight *chart_Weight = [JL_Chart_Weight new];
                                    chart_Weight.date = weightData.startDate;
                                    chart_Weight.weight = model.integer + (double)model.decimal / 100;
                                    [JLSqliteWeight s_update:chart_Weight];
                                }
                            }
                        }
                        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[self getUserLastUpeateTimeKeyWithKey:LastHealthWeightDataUpdateTime]];
                    });
                }];
            });
        }];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // 同步服务器用户运动数据
//        [weakSelf requestSportDataSuccessively];
        [JLSqliteSportRunningRecord s_checkoutTheLastDataWithResult:^(JL_SportRecord_Chart * _Nullable chart) {
            NSTimeInterval sportid = chart.sport_id;
            [UserDataSync requestAndSaveSportDataBetween:[NSDate dateWithTimeIntervalSince1970:sportid] End:[NSDate date] BySportType:[NSString stringWithFormat:@"%d", [weakSelf smallFileTypeFromTableName:tb_sport_running]] withBlock:^{
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[self getUserLastUpeateTimeKeyWithKey:LastSportUpdateTime]];
            }];
        }];
    });
}

#pragma mark - 上传相关 - 对外暴露

/**
 *  上传服务器心率数据
 */
+ (void)uploadHealthHeartRateData {
    if ([self notLoggedIn]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *url = [NSString stringWithFormat:@"%@/health/v1/api/data/health/saveBatch",BaseURL];
        AFHTTPSessionManager *manager = [weakSelf reqMgr];
        NSDate *lastHealthHeartRateUpeateTime = [[NSUserDefaults standardUserDefaults] objectForKey:[self getUserLastUpeateTimeKeyWithKey:LastHealthHeartRateUpeateTime]];
        [[JLSqliteManager sharedInstance] checkoutWithStartDate:lastHealthHeartRateUpeateTime WithEndDate:[NSDate date] DataByName:tb_heart_rate result:^(NSArray * _Nonnull array) {
            if (array.count > 0) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    NSMutableURLRequest *req = [BasicHttp Url:url Body:[self ArrayToBody:array]];
                    [[manager dataTaskWithRequest:req uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                        NSDictionary *dict = responseObject;
                        NSNumber *code = dict[@"code"];
                        if ([code intValue] == 0) {
//                            kJLLog(JLLOG_DEBUG, @"uploadHealthData LastHealthHeartRateUpeateTime success");
//                            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[self getUserLastUpeateTimeKeyWithKey:LastHealthHeartRateUpeateTime]];
                        }
                    }] resume];
                });
            }
        }];
    });
}
/**
 *  上传服务器步数数据
 */
+ (void)uploadHealthStepCountData {
    if ([self notLoggedIn]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *url = [NSString stringWithFormat:@"%@/health/v1/api/data/health/saveBatch",BaseURL];
        AFHTTPSessionManager *manager = [weakSelf reqMgr];
        NSDate *lastHealthStepCountUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:[self getUserLastUpeateTimeKeyWithKey:LastHealthStepCountUpdateTime]];
        [[JLSqliteManager sharedInstance] checkoutWithStartDate:lastHealthStepCountUpdateTime WithEndDate:[NSDate date] DataByName:tb_step result:^(NSArray * _Nonnull array) {
            if (array.count > 0) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    NSMutableURLRequest *req = [BasicHttp Url:url Body:[self ArrayToBody:array]];
                    [[manager dataTaskWithRequest:req uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                        NSDictionary *dict = responseObject;
//                        kJLLog(JLLOG_DEBUG, @"uploadHealthData LastHealthStepCountUpdateTime: %s: dict:%@",__func__,dict);
                        NSNumber *code = dict[@"code"];
                        if ([code intValue] == 0) {
//                            kJLLog(JLLOG_DEBUG, @"uploadHealthData LastHealthStepCountUpdateTime success");
//                            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[self getUserLastUpeateTimeKeyWithKey:LastHealthStepCountUpdateTime]];
                        }
                    }] resume];
                });
            }
        }];
    });
}

/**
 *  上传服务器血氧数据
 */
+ (void)uploadHealthSpoData {
    if ([self notLoggedIn]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *url = [NSString stringWithFormat:@"%@/health/v1/api/data/health/saveBatch",BaseURL];
        AFHTTPSessionManager *manager = [weakSelf reqMgr];
        NSDate *lastHealthSpoDataUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:[self getUserLastUpeateTimeKeyWithKey:LastHealthSpoDataUpdateTime]];
        [[JLSqliteManager sharedInstance] checkoutWithStartDate:lastHealthSpoDataUpdateTime WithEndDate:[NSDate date] DataByName:tb_oxyhemoglobin_saturation result:^(NSArray * _Nonnull array) {
            if (array.count > 0) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    NSMutableURLRequest *req = [BasicHttp Url:url Body:[self ArrayToBody:array]];
                    [[manager dataTaskWithRequest:req uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                        NSDictionary *dict = responseObject;
//                        kJLLog(JLLOG_DEBUG, @"uploadHealthData LastHealthSpoDataUpdateTime: %s: dict:%@",__func__,dict);
                        NSNumber *code = dict[@"code"];
                        if ([code intValue] == 0) {
//                            kJLLog(JLLOG_DEBUG, @"uploadHealthData LastHealthSpoDataUpdateTime success");
//                            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[self getUserLastUpeateTimeKeyWithKey:LastHealthSpoDataUpdateTime]];
                        }
                    }] resume];
                });
            }
        }];
    });
}
/**
 *  上传服务器睡眠数据
 */
+ (void)uploadHealthSleepData {
    if ([self notLoggedIn]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *url = [NSString stringWithFormat:@"%@/health/v1/api/data/health/saveBatch",BaseURL];
        AFHTTPSessionManager *manager = [weakSelf reqMgr];
        NSDate *lastHealthSleepDataUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:[self getUserLastUpeateTimeKeyWithKey:LastHealthSleepDataUpdateTime]];
        [[JLSqliteManager sharedInstance] checkoutWithStartDate:lastHealthSleepDataUpdateTime WithEndDate:[NSDate date] DataByName:tb_sleep result:^(NSArray * _Nonnull array) {
            if (array.count > 0) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    NSMutableURLRequest *req = [BasicHttp Url:url Body:[self ArrayToBody:array]];
                    [[manager dataTaskWithRequest:req uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                        NSDictionary *dict = responseObject;
//                        kJLLog(JLLOG_DEBUG, @"uploadHealthData LastHealthSleepDataUpdateTime: %s: dict:%@",__func__,dict);
                        NSNumber *code = dict[@"code"];
                        if ([code intValue] == 0) {
//                            kJLLog(JLLOG_DEBUG, @"uploadHealthData LastHealthSleepDataUpdateTime success");
//                            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[self getUserLastUpeateTimeKeyWithKey:LastHealthSleepDataUpdateTime]];
                        }
                    }] resume];
                });
            }
        }];
    });
}
/**
 *  上传服务器体重数据
 */
+ (void)uploadHealthWeightData {
    if ([self notLoggedIn]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *url = [NSString stringWithFormat:@"%@/health/v1/api/data/health/saveBatch",BaseURL];
        AFHTTPSessionManager *manager = [weakSelf reqMgr];
        NSDate *lastHealthWeightDataUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:[self getUserLastUpeateTimeKeyWithKey:LastHealthWeightDataUpdateTime]];
        [JLSqliteWeight s_checkoutWtihStartDate:lastHealthWeightDataUpdateTime withEndDate:[NSDate date] Result:^(NSArray<JL_Chart_Weight *> * _Nonnull charts) {
            if (charts.count > 0) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    NSMutableArray<JLWearSyncHealthWeightChart *> *weightChartArray = [NSMutableArray array];
                    NSString *dateYYYYMMdd = @"";
                    JLWearSyncHealthWeightChart *weightChart = [JLWearSyncHealthWeightChart new];
                    weightChart.weightDataArray = [NSArray array];
                    for (JL_Chart_Weight *chart in charts) {
                        if (![dateYYYYMMdd isEqualToString:chart.date.toYYYYMMdd]) {
                            // 新的一天
                            dateYYYYMMdd = chart.date.toYYYYMMdd;
                            weightChart = [JLWearSyncHealthWeightChart new];
                            weightChart.weightDataArray = [NSArray array];
                            [weightChartArray addObject:weightChart];
                        }
                        JLWearWeightModel *oneModel = [JLWearWeightModel new];
                        oneModel.integer = (int)chart.weight;
                        oneModel.decimal = (int)((int)(chart.weight * 100) % 100);
                        WeightData *weightData = [WeightData new];
                        weightData.startDate = chart.date;
                        weightData.weights = [NSArray arrayWithObject:oneModel];
                        NSMutableArray *weightDataArray = [NSMutableArray arrayWithArray:weightChart.weightDataArray];
                        [weightDataArray addObject:weightData];
                        weightChart.weightDataArray = weightDataArray;
                    }
                    NSMutableArray *dictArray = [NSMutableArray new];
                    for (JLWearSyncHealthWeightChart *weightChart in weightChartArray) {
                        NSDictionary *dict = [JLSqliteManager weightDataToBase64WithResult:weightChart];
                        [dictArray addObject:dict];
                    }
                    NSMutableURLRequest *req = [BasicHttp Url:url Body:[weakSelf ArrayToBody:dictArray]];
                    [[manager dataTaskWithRequest:req uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                        NSDictionary *dict = responseObject;
//                        kJLLog(JLLOG_DEBUG, @"uploadHealthData LastHealthWeightDataUpdateTime: %s: dict:%@",__func__,dict);
                        NSNumber *code = dict[@"code"];
                        if ([code intValue] == 0) {
//                            kJLLog(JLLOG_DEBUG, @"uploadHealthData LastHealthWeightDataUpdateTime success");
//                            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[self getUserLastUpeateTimeKeyWithKey:LastHealthWeightDataUpdateTime]];
                        }
                    }] resume];
                });
            }
        }];
    });
}
/**
 *  上传服务器运动数据
 */
+ (void)uploadSportDataFile {
    if ([self notLoggedIn]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSDate *lastSportUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:[self getUserLastUpeateTimeKeyWithKey:LastSportUpdateTime]];
        [weakSelf sportFileFromSportTableWithStartDate:lastSportUpdateTime withEndDate:[NSDate date] Result:^(NSArray<NSString *> * _Nonnull sportFileArray) {
//            kJLLog(JLLOG_DEBUG, @"uploadSportFileWithStartDate: 需要上传的文件数量:%lu", (unsigned long)sportFileArray.count);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                for (int i = 0; i < sportFileArray.count; i++) {
                    NSString *filePath = sportFileArray[i];
                    NSString *lastObject = [filePath componentsSeparatedByString:@"/"].lastObject;
                    NSString *sportidStr = [lastObject componentsSeparatedByString:@"."].firstObject;
                    NSDecimalNumber *decNumber = [NSDecimalNumber decimalNumberWithString:sportidStr];
                    NSTimeInterval sportid = [decNumber doubleValue];
                    [weakSelf uploadSportData:filePath WithDate:[NSDate dateWithTimeIntervalSince1970:sportid] SportType:[NSString stringWithFormat:@"%d", [weakSelf smallFileTypeFromTableName:tb_sport_running]] result:^(NSDictionary * _Nonnull dict) {
//                        kJLLog(JLLOG_DEBUG, @"uploadSportFileWithStartDate: dict:%@", dict);
                        NSNumber *code = dict[@"code"];
                        if ([code intValue] == 0) {
//                            kJLLog(JLLOG_DEBUG, @"uploadSportFileWithStartDate success lastdate:%@", [NSDate dateWithTimeIntervalSince1970:sportid]);
//                            [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSince1970:sportid] forKey:[self getUserLastUpeateTimeKeyWithKey:LastSportUpdateTime]];
                        }
                    }];
                }
            });
        }];
    });
}

#pragma mark - 健康数据相关

/// 请求服务器日期区间内健康数据
/// @param start 开始时间
/// @param end 结束时间
/// @param tbName 类型，用于过滤健康数据类型
/// @param block 回调
+(void)requestHealthDataBetween:(NSDate *)start End:(NSDate *)end ByTableName:(NSString *)tbName result:(HealthDataCbk)block {
    NSString *url = [NSString stringWithFormat:@"%@/health/v1/api/data/health/range",BaseURL];
    UInt8 type = [self smallFileTypeFromTableName:tbName];
    NSDictionary *newDict = @{@"start":start.toAllDate,@"end":end.toAllDate,@"type":[NSNumber numberWithInt:type]};
    AFHTTPSessionManager *manager = [self reqMgr];
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:newDict options:NSJSONWritingPrettyPrinted error:nil];
    NSMutableURLRequest *req = [BasicHttp Url:url Body:bodyData];
//    kJLLog(JLLOG_DEBUG, @"requestHealthDataBetween: start:%@, end:%@, tbName:%@", start, end, tbName);
    [[manager dataTaskWithRequest:req uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        kJLLog(JLLOG_DEBUG, @"requestHealthDataBetween: start:%@, end:%@, tbName:%@, responseObject:%@", start, end, tbName, responseObject);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSDictionary *dict = responseObject;
            if ([dict[@"code"] intValue] == 0) {
                NSArray *array = dict[@"data"];
                NSMutableArray<UserDataHealth *> *newArray = [NSMutableArray new];
                for (NSDictionary *item in array) {
                    [newArray addObject:[UserDataHealth initWithDictionary:item]];
                }
                block(newArray);
            } else {
    //            kJLLog(JLLOG_DEBUG, @"%s:errorBy:%@", __func__, dict);
            }
        });
    }] resume];

}

#pragma mark - 运动数据相关

/// 上传运动数据
/// @param paths 数据存储路径
/// @param date 日期
/// @param type 运动类型
/// @param block 回调
+(void)uploadSportData:(NSString *)paths WithDate:(NSDate *)date SportType:(NSString *)type result:(SportDataUploadCbk)block {
    
    NSData *dateData = [date.toAllDate dataUsingEncoding:NSUTF8StringEncoding];
    NSData *typeData = [type dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *url = [NSString stringWithFormat:@"%@/health/v1/api/data/sport/save",BaseURL];
    AFHTTPSessionManager *manager = [self reqMgr];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/html",@"application/json", @"text/json" ,@"text/javascript", nil];
    NSString *token = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    
    NSDictionary *headers = @{
//        @"content-type": @"application/json",
//        @"content-type": @"text/html",
                              @"jwt-token":token?:@"",
                              @"cache-control": @"no-cache"};
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url
       parameters:nil
          headers:headers
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:paths.getData name:@"file" fileName:paths.lastPathComponent mimeType:@"log"];
        [formData appendPartWithFormData:dateData name:@"date"];
        [formData appendPartWithFormData:typeData name:@"type"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

/// 分周拉取运动数据
+ (void)requestSportDataSuccessively {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // 同步服务器用户运动数据
        NSDate *startDate = [[NSUserDefaults standardUserDefaults] objectForKey:[self getUserLastUpeateTimeKeyWithKey:LastSportUpdateTime]];
        if (startDate == nil) {
            // 获取用户注册时间
            startDate = [UserProfile locateProfile].registerTime;
        }
        // 分周拉取
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970] - [startDate timeIntervalSince1970];
        if (timeInterval > (7 * 24 * 3600)) {
            // 时间间隔大于7天
            NSDate *endDate = startDate.nextWeek;
            kJLLog(JLLOG_DEBUG, @"requestSportDataSuccessively1 startDate:%@, endDate:%@", startDate, endDate);
            [UserDataSync requestAndSaveSportDataBetween:startDate End:endDate BySportType:[NSString stringWithFormat:@"%d", [weakSelf smallFileTypeFromTableName:tb_sport_running]] withBlock:^{
                [[NSUserDefaults standardUserDefaults] setObject:endDate forKey:[self getUserLastUpeateTimeKeyWithKey:LastSportUpdateTime]];
                [weakSelf requestSportDataSuccessively];
            }];
        } else {
            kJLLog(JLLOG_DEBUG, @"requestSportDataSuccessively2");
            NSDate *currentDate = [NSDate date];
            [UserDataSync requestAndSaveSportDataBetween:startDate End:currentDate BySportType:[NSString stringWithFormat:@"%d", [weakSelf smallFileTypeFromTableName:tb_sport_running]] withBlock:^{
                [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:[self getUserLastUpeateTimeKeyWithKey:LastSportUpdateTime]];
                kJLLog(JLLOG_DEBUG, @"requestSportDataSuccessively finish!");
            }];
        }
    });
}

/// 请求服务器日期区间内运动数据，并保存到数据表
/// @param start 开始时间
/// @param end 结束时间
/// @param type 运动类型
/// @param block 回调
+(void)requestAndSaveSportDataBetween:(NSDate *)start End:(NSDate *)end BySportType:(NSString *)type withBlock:(SportAllDataUpdateCbk)block {
    NSString *docFileFolderPath = [self initializeSportDownloadDir];
//    kJLLog(JLLOG_DEBUG, @"requestAndSaveSportDataBetween1: start:%@, end:%@, type:%@", start, end, type);
    [self requestSportDataBetween:start End:end BySportType:type result:^(NSArray<UserDataSport *> * _Nonnull array) {
        
//        kJLLog(JLLOG_DEBUG, @"requestAndSaveSportDataBetween1:%ld", (long)array.count);
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (array.count == 0) {
            block();
            return;
        }
            for (int i = 0; i < array.count; i++) {
                UserDataSport *userDataSport = array[i];
                // 下载运动文件
                // 新建文件
                NSString *fileName = [NSString stringWithFormat:@"%f-%d.log", [[NSDate date] timeIntervalSince1970], i];
                NSString *finalFilePath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:docFileFolderPath File:fileName];
                [JL_Tools removePath:finalFilePath];
                NSString *finalFileName = [JL_Tools createOn:NSLibraryDirectory MiddlePath:docFileFolderPath File:fileName];
    //            kJLLog(JLLOG_DEBUG, @"finalFilePath:%@", finalFilePath);
    //            kJLLog(JLLOG_DEBUG, @"finalFileName:%@", finalFileName);
                
                [[[DFHttp1 alloc] init] httpDownload:userDataSport.dataPath Result:^(float progress, NSData * _Nullable data, DF_HTTP1_Result result) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                            /*--- 下载文件中 ---*/
                        if (data.length > 0) {
                            [JL_Tools writeData:data endFile:finalFileName];
                        }
                        /*--- 保存到数据表 ---*/
                        if (result == DF_HTTP1_ResultSuccess) {
//                            kJLLog(JLLOG_DEBUG, @"下载文件:%@ 成功！finalFilePath:%@", userDataSport.dataPath, finalFilePath);
                            [self saveSportFileToSportTableWithFilePath:finalFileName];
                        }
                        if (i == (array.count - 1)) {
                            block();
                        }
                    });
                }];
            }
//        });
    }];
}

/// 请求服务器日期区间内运动数据
/// @param start 开始时间
/// @param end 结束时间
/// @param type 运动类型
/// @param block 回调
+(void)requestSportDataBetween:(NSDate *)start End:(NSDate *)end BySportType:(NSString *)type result:(SportDataCbk)block{
    NSString *url = [NSString stringWithFormat:@"%@/health/v1/api/data/sport/range",BaseURL];
    NSDictionary *newDict = @{@"start":start.toAllDate,@"end":end.toAllDate,@"type":type};
    AFHTTPSessionManager *manager = [self reqMgr];
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:newDict options:NSJSONWritingPrettyPrinted error:nil];
    NSMutableURLRequest *req = [BasicHttp Url:url Body:bodyData];
    [[manager dataTaskWithRequest:req uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSDictionary *dict = responseObject;
        if ([dict[@"code"] intValue] == 0) {
            NSArray *array = dict[@"data"];
            NSMutableArray<UserDataSport *> *newArray = [NSMutableArray new];
            for (NSDictionary *item in array) {
                [newArray addObject:[UserDataSport initWithDictionary:item]];
            }
            block(newArray);
        }else{
//            kJLLog(JLLOG_DEBUG, @"%s:errorBy:%@",__func__,dict);
        }
    }] resume];

}

#pragma mark - 运动数据表数据与文件互转
/**
 *  转换运动数据为文件
 */
+ (void)sportFileFromSportTableWithStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate Result:(SportRecordsFileBlock)sportRecordsFileBlock {
    NSString *docFileFolderPath = [self initializeSportDir];
    [JLSqliteSportRunningRecord s_checkoutWtihStartDate:startDate withEndDate:endDate Result:^(NSArray<JL_SportRecord_Chart *> * _Nonnull charts) {
        __block NSMutableArray *sportFileArray = [NSMutableArray array];
        if (charts.count > 0) {
            for (JL_SportRecord_Chart *chart in charts) {
                NSString *finalFilePath = [NSString stringWithFormat:@"%@/%f.log", docFileFolderPath, chart.sport_id];
                
                [sportFileArray addObject:finalFilePath];
                if ([[NSFileManager defaultManager] fileExistsAtPath:finalFilePath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:finalFilePath error:nil];
                }
                
                // 文件头
                NSData *fileHeaderData = [JL_Tools HexToData:@"FEDCBA"];
                NSMutableData *mData = [NSMutableData dataWithData:fileHeaderData];
                
                // 版本号
                uint8_t versionBuf[1] = {0x00};
                NSData *versionData = [NSData dataWithBytes:versionBuf length:1];
                [mData appendData:versionData];
                
                // 文件上传端口
                uint8_t portBuf[1] = {0x02};
                NSData *portData = [NSData dataWithBytes:portBuf length:1];
                [mData appendData:portData];
                
                // 文件内容
                NSMutableData *fileContentData = [NSMutableData data];
                
                // 生成GPS文件内容
                NSMutableData *gpsFileContentData = [NSMutableData data];
                for (int i = 0; i< chart.sportLocations.count; i++) {
                    JL_SportLocation *sportLocation = chart.sportLocations[i];
                    if (sportLocation.type == JLSportLocationTypeStartPacket) {
                        // 后续gps数据的开始时间
                        NSTimeInterval timeInterval = [sportLocation.date timeIntervalSince1970] * 1000;
                        NSData *timeData = [JL_Tools uInt64_data:(int64_t)timeInterval Endian:YES];
                        
                        uint8_t typeBuf[1] = {0x01};
                        NSData *typeData = [NSData dataWithBytes:typeBuf length:1];
                        [gpsFileContentData appendData:typeData];
                        [gpsFileContentData appendData:timeData];
                    } else {
                        // gps数据
                        double longitude = sportLocation.longitude;
                        double latitude = sportLocation.latitude;
                        float speed = (float)sportLocation.speed;
                        NSData *longitudeData = [JL_Tools changeBigOrSmall:[NSData dataWithBytes:&longitude length:8]];
                        NSData *latitudeData = [JL_Tools changeBigOrSmall:[NSData dataWithBytes:&latitude length:8]];
                        NSData *speedData = [NSData dataWithBytes:&speed length:4];
                        
                        uint8_t typeBuf[1] = {0x00};
                        NSData *typeData = [NSData dataWithBytes:typeBuf length:1];
                        [gpsFileContentData appendData:typeData];
                        [gpsFileContentData appendData:latitudeData];
                        [gpsFileContentData appendData:longitudeData];
                        [gpsFileContentData appendData:speedData];
                    }
                }
                // 运动文件大小
                NSData *sportSourceFileLengthData = [JL_Tools uInt32_data:(uint32_t)chart.sourceData.length Endian:YES];
                [fileContentData appendData:sportSourceFileLengthData];
                
                // 运动文件内容
                [fileContentData appendData:chart.sourceData];
                
                // GPS文件大小
                NSData *gpsFileLengthData = [JL_Tools uInt32_data:(uint32_t)gpsFileContentData.length Endian:YES];
                [fileContentData appendData:gpsFileLengthData];
                
                // GPS文件内容
                [fileContentData appendData:gpsFileContentData];
                
                // 文件crc
                const void *packageData = fileContentData.bytes;
                uint16_t crc = JL_CRC16((unsigned char *)packageData, (int)fileContentData.length, 0);
                NSData *crcData = [JL_Tools uInt16_data:crc Endian:YES];
                
                [mData appendData:crcData];
                [mData appendData:fileContentData];
                
                // 文件尾
                NSData *fileTailerData = [JL_Tools HexToData:@"EF"];
                [mData appendData:fileTailerData];
                
                // 转换运动数据为文件
                if ([[NSFileManager defaultManager] createFileAtPath:finalFilePath contents:mData attributes:nil]) {
//                    kJLLog(JLLOG_DEBUG, @"运动文件生成 success");
                } else {
//                    kJLLog(JLLOG_DEBUG, @"运动文件生成 fail");
                }
            }
        }
        sportRecordsFileBlock(sportFileArray);
    }];
}

/**
 *  保存运动文件数据到数据表
 */
+ (void)saveSportFileToSportTableWithFilePath:(NSString *)filePath {
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
//    kJLLog(JLLOG_DEBUG, @"saveSportFileToSportTableWithFilePath, filePath : %@", filePath);
    
    if (fileData == nil || fileData.length < 1) {
        kJLLog(JLLOG_DEBUG, @"saveSportFileToSportTableWithFilePath, fileData nothing!");
        return;
    }
    
    // 解析服务器下载的运动文件内容，并保存到数据表
    // 文件上传端口
//    NSData *portData = [fileData subdataWithRange:NSMakeRange(4, 1)];
//    int port = [portData beUint8];
//    kJLLog(JLLOG_DEBUG, @"运动数据文件上传端口: %ld", (long)port);
    
    // 文件内容crc
    NSData *crcData = [fileData subdataWithRange:NSMakeRange(5, 2)];
    UInt16 web_crc = [crcData beBigendUint16];
    NSData *totalFileData = [fileData subdataWithRange:NSMakeRange(7, fileData.length - 7 - 1)];
    const void *packageData = totalFileData.bytes;
    uint16_t local_crc = JL_CRC16((unsigned char *)packageData, (int)totalFileData.length, 0);
//    kJLLog(JLLOG_DEBUG, @"web_crc : %hu, local_crc : %hu", web_crc, local_crc);
    if (web_crc == local_crc) {
//        kJLLog(JLLOG_DEBUG, @"crc 匹配成功");
    } else {
//        kJLLog(JLLOG_DEBUG, @"crc 匹配失败");
        return;
    }
    
    // 运动文件大小
    NSData *sportFileLengthData = [fileData subdataWithRange:NSMakeRange(7, 4)];
    UInt32 sportFileLength = [sportFileLengthData beBigendUint32];
    
    // 运动文件内容，这个就是和固件的sourceData一模一样
    NSData *sportFileData = [fileData subdataWithRange:NSMakeRange(11, sportFileLength)];
    JLSportRecordModel *sportRecordModel = [[JLSportRecordModel alloc] initWithData:sportFileData];
    [JLSqliteSportRunningRecord s_update:sportRecordModel];
    
    // GPS文件大小
    NSData *gpsFileLengthData = [fileData subdataWithRange:NSMakeRange(11 + sportFileLength, 4)];
    UInt32 gpsFileLength = [gpsFileLengthData beBigendUint32];
    
    // GPS文件内容
    if (gpsFileLength > 0) {
        NSData *gpsFileData = [fileData subdataWithRange:NSMakeRange(15 + sportFileLength, gpsFileLength)];
        NSInteger index = 0;
        double sport_id = [sportRecordModel.dataArray.firstObject.startDate timeIntervalSince1970];
        [JLSqliteSportLocation s_delete:sport_id];
        while(1) {
            if (index >= gpsFileLength) {
//                kJLLog(JLLOG_DEBUG, @"gpsFileLength finish!");
                break;
            }
            // 截取类型，1 byte
            NSData *gpsDataTypeData = [gpsFileData subdataWithRange:NSMakeRange(index, 1)];
            UInt8 gpsDataType = [JL_Tools dataToInt:gpsDataTypeData];
            index += 1;
            if (gpsDataType == 0X01) {
                // 开始包
                NSData *startDataTypeData = [gpsFileData subdataWithRange:NSMakeRange(index, 8)];
                NSInteger startTime = [JL_Tools dataToInt:startDataTypeData];
                NSTimeInterval startTimeInterval = (double)(startTime / 1000);
                
                index += 8;
//                kJLLog(JLLOG_DEBUG, @"1=============JLSportLocationTypeStartPacket sport_id:%f, startTime:%u, startTimeInterval:%f, %@", sport_id, (unsigned int)startTime, startTimeInterval, [NSDate dateWithTimeIntervalSince1970:startTimeInterval]);
                JL_SportLocation *model = [[JL_SportLocation alloc] initWithSportID:sport_id withType:JLSportLocationTypeStartPacket withLongitude:0 withLatitude:0 withSpeed:0 withDate:[NSDate dateWithTimeIntervalSince1970:startTimeInterval]];
                [JLSqliteSportLocation s_insert:model];
            } else if (gpsDataType == 0X00) {
                // gps数据
                NSData *latitudeData = [JL_Tools changeBigOrSmall:[gpsFileData subdataWithRange:NSMakeRange(index, 8)]];
                double *latitude = (double *)latitudeData.bytes;
                index += 8;
                NSData *longitudeData = [JL_Tools changeBigOrSmall:[gpsFileData subdataWithRange:NSMakeRange(index, 8)]];
                double *longitude = (double *)longitudeData.bytes;
                index += 8;
                NSData *speedData = [JL_Tools changeBigOrSmall:[gpsFileData subdataWithRange:NSMakeRange(index, 4)]];
                float *speedTemp = (float *)speedData.bytes;
                double speed = (double)speedTemp[0];
                
                index += 4;
//                kJLLog(JLLOG_DEBUG, @"2=============JLSportLocationTypeStartPacket sport_id:%f, longitude:%f, latitude:%f, speed:%f", sport_id, longitude[0], latitude[0], speed);
                JL_SportLocation *model = [[JL_SportLocation alloc] initWithSportID:sport_id withType:JLSportLocationTypeDataPacket withLongitude:longitude[0] withLatitude:latitude[0] withSpeed:speed withDate:nil];
                [JLSqliteSportLocation s_insert:model];
            }
        }
    }
}

+ (NSString *)initializeSportDownloadDir {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *docFileFolderPath = [NSString stringWithFormat:@"%@/%@", docDir, _sportDownloadFileDocPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:docFileFolderPath]) {
        NSError *error = nil;
        BOOL isSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:docFileFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
//        kJLLog(JLLOG_DEBUG, @"initializeSportDownloadDir %@, error = %@", docFileFolderPath, error);
//        kJLLog(JLLOG_DEBUG, @"initializeSportDownloadDir %@, isSuccess = %d", docFileFolderPath, isSuccess);
    }
    return docFileFolderPath;
}

+ (NSString *)initializeSportDir {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *docFileFolderPath = [NSString stringWithFormat:@"%@/%@", docDir, _sportFileDocPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:docFileFolderPath]) {
        NSError *error = nil;
        BOOL isSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:docFileFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
//        kJLLog(JLLOG_DEBUG, @"initializeSportDir %@, error = %@", docFileFolderPath, error);
//        kJLLog(JLLOG_DEBUG, @"initializeSportDir %@, isSuccess = %d", docFileFolderPath, isSuccess);
    }
    return docFileFolderPath;
}

#pragma mark - 类型转换相关

+ (JL_SmallFileType)smallFileTypeFromTableName:(NSString *)tableName {
    UInt8 type = JL_SmallFileTypeHeartRate;
    if ([tableName isEqualToString:tb_heart_rate]) {
        type = JL_SmallFileTypeHeartRate;
    } else if ([tableName isEqualToString:tb_step]) {
        type = JL_SmallFileTypeStepCount;
    } else if ([tableName isEqualToString:tb_oxyhemoglobin_saturation]) {
        type = JL_SmallFileTypeSpoData;
    } else if ([tableName isEqualToString:tb_sleep]) {
        type = JL_SmallFileTypeSleepData;
    } else if ([tableName isEqualToString:tb_sport_running]) {
        type = JL_SmallFileTypeMotionRecord;
    } else if ([tableName isEqualToString:tb_weight]) {
        type = JL_SmallFileTypeWeight;
    }
    return type;
}

+ (NSString *)tableNameFromSmallFileType:(JL_SmallFileType)type {
    if (type == JL_SmallFileTypeHeartRate) {
        return tb_heart_rate;
    } else if (type == JL_SmallFileTypeStepCount) {
        return tb_step;
    } else if (type == JL_SmallFileTypeSpoData) {
        return tb_oxyhemoglobin_saturation;
    } else if (type == JL_SmallFileTypeSleepData) {
        return tb_sleep;
    } else if (type == JL_SmallFileTypeMotionRecord) {
        return tb_sport_running;
    } else if (type == JL_SmallFileTypeWeight) {
        return tb_weight;
    }
    return tb_heart_rate;
}

#pragma mark - Private Methods

+ (BOOL)notLoggedIn {
    NSString *accessToken = [JL_Tools getUserByKey:kUI_ACCESS_TOKEN];
    if ((accessToken.length < 1) || ([User_Http shareInstance].userPfInfo.identify.length < 1)) {
        return YES;
    }
    return NO;
}

+(NSData *)ArrayToBody:(NSArray *)array{
    NSString *str = [NSString new];
    str = [str stringByAppendingString:@"["];
    for (NSDictionary *dict in array) {
        NSString *tmpStr = [NSString stringWithFormat:@"{\"type\":\"%@\",\"data\": \"%@\",\"date\": \"%@\"}",dict[@"type"],dict[@"data"],dict[@"date"]];
        str = [str stringByAppendingString:tmpStr];
    }
    str = [str stringByAppendingString:@"]"];
    
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - 获取各用户时间戳key
+ (NSString *)getUserLastUpeateTimeKeyWithKey:(NSString * _Nonnull)key {
    UserProfile *userProfile = [UserProfile locateProfile];
    if (userProfile.identify != nil) {
        return [NSString stringWithFormat:@"%@_%@", key, userProfile.identify];
    }
    return key;
}

@end
