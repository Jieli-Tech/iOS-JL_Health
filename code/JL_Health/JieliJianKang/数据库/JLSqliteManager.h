//
//  JLSqliteManager.h
//  Test
//
//  Created by EzioChan on 2021/4/25.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+Tools.h"
#import "NSString+Path.h"
#import <FMDB/FMDB.h>
#import <JL_BLEKit/JL_BLEKit.h>
#import "JLSqliteWeight.h"
NS_ASSUME_NONNULL_BEGIN

#pragma mark - 健康类数据表名
#define tb_heart_rate                       @"tb_heart_rate"///心率
#define tb_step                             @"tb_step"///运动步数
#define tb_stress                           @"tb_stress"///压力测试
#define tb_oxyhemoglobin_saturation         @"tb_oxyhemoglobin_saturation"///血氧饱和度
#define tb_weight                           @"tb_weight"///体重
#define tb_sleep                            @"tb_sleep"//睡眠
#pragma mark - 运动类数据表名
#define tb_sport_running                    @"tb_sport_running"///跑步运动记录表
#define tb_sport_location                   @"tb_sport_location"///运动定位记录表
#define tb_sport_speed_per_km               @"tb_sport_speed_per_km"///每公里配速记录表
#pragma mark - 聊天类数据表名
#define tb_chat_record                      @"tb_chat_record"///聊天数据表

typedef void(^checkDayAllBlock)(NSArray *array);

@interface JLSqliteManager : NSObject

+ (instancetype)sharedInstance;

- (FMDatabaseQueue *)fmdbQueue;

/**
 * 初始化数据表
 * @param identify 用户identify
 */
- (void)initializeDatabaseWithUserIdentify:(NSString *)identify;

#pragma mark - 数据表删除
/**
 *  删除表数据
 *  @param date 日期
 *  @param tableName 表名
*/
- (void)deleteByDate:(NSDate *)date InTable:(NSString *)tableName;

/**
 *  删除选中的时间数据
 *  @param selectArray 日期
 *  @param tableName 表名
*/
- (void)deleteBySelectArray:(NSArray *)selectArray InTable:(NSString *)tableName;

#pragma mark - 清空数据
/**
 *  删除全部的数据
*/
- (void)clean;

#pragma mark - 数据表查询
/**
 *  获取某天所有的健康数据
 *  @param date 日期
 *  @param block 回调 （返回结果仅用于上传服务器）
*/
- (void)checkOutAllByDate:(NSDate *)date result:(checkDayAllBlock)block;

/**
 *  获取某天某个健康表的数据
 *  @param date 日期
 *  @param name 表名
 *  @param block 回调（返回结果仅用于上传服务器）
*/
- (void)checkoutDate:(NSDate *)date DataByName:(NSString *)name result:(checkDayAllBlock)block;

/**
 *  获取某个时间间隔某个健康表的数据
 *  @param startDate 开始日期
 *  @param endDate 结束日期
 *  @param tbName 表名
 *  @param block 回调（返回结果仅用于上传服务器）
*/
- (void)checkoutWithStartDate:(NSDate *)startDate WithEndDate:(NSDate *)endDate DataByName:(NSString *)tbName result:(checkDayAllBlock)block;

+ (NSDictionary *)weightDataToBase64WithResult:(JLWearSyncHealthWeightChart *)chart;

@end

NS_ASSUME_NONNULL_END
