//
//  JLSqliteSportSpeedPerKm.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JL_SportSpeedPerKm : NSObject

@property (nonatomic, assign) double sport_id;       // 运动ID
@property (nonatomic, assign) double speed;         // 配速 = 秒/公里，即速度的倒数
@property (nonatomic, assign) double distance;      // 纬度
@property (nonatomic, strong) NSDate *startDate;    // 当前时间
@property (nonatomic, strong) NSDate *endDate;      // 当前时间

- (instancetype)initWithSportID:(double)sport_id withDistance:(double)distance withStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate;

@end

typedef void(^SqlSportSpeedPerKmBlock)(NSArray<JL_SportSpeedPerKm *> *sportSpeedPerKm);

@interface JLSqliteSportSpeedPerKm : NSObject

/// 查询运动每公里配速信息
/// @param sport_id 运动ID
/// @param block 每公里配速模型数组回调
+ (void)s_checkoutWtihSport_id:(double)sport_id Result:(SqlSportSpeedPerKmBlock)block;

/// 插入轨迹
/// @param model 数据模型
+ (void)s_insert:(JL_SportSpeedPerKm *)model;

/// 根据日期删除对应的数据
/// @param sport_id 运动ID
+ (void)s_delete:(double)sport_id;

@end

NS_ASSUME_NONNULL_END
