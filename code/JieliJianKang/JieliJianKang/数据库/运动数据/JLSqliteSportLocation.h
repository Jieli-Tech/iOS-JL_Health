//
//  JLSqliteSportLocation.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/10/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JLSportLocationType) {
    JLSportLocationTypeStartPacket          = 0,        // 开始包
    JLSportLocationTypeDataPacket           = 1,        // 数据包
};

@interface JL_SportLocation : NSObject

@property (nonatomic, assign) double sport_id;       // 运动ID
@property (nonatomic, assign) JLSportLocationType type; // 0：开始包；1：数据包
@property (nonatomic, assign) double longitude;         // 经度
@property (nonatomic, assign) double latitude;          // 纬度
@property (nonatomic, assign) double speed;             // 速度
@property (nonatomic, strong) NSDate *date;             // 当前时间

- (instancetype)initWithSportID:(double)sport_id withType:(JLSportLocationType)type withLongitude:(double)longitude withLatitude:(double)latitude withSpeed:(double)speed withDate:(NSDate * _Nullable)date;

@end

typedef void(^SqlSportLocationBlock)(NSArray<JL_SportLocation *> *sportLocation);

@interface JLSqliteSportLocation : NSObject

/// 查询运动轨迹
/// @param sport_id 运动ID
/// @param block 运动轨迹模型数组回调
+ (void)s_checkoutWtihSport_id:(double)sport_id Result:(SqlSportLocationBlock)block;

/// 插入开始包
/// @param sport_id 运动ID
+ (void)s_insertStartPacketWithSportID:(double)sport_id;

/// 插入轨迹
/// @param model 数据模型
+ (void)s_insert:(JL_SportLocation *)model;

/// 根据日期删除对应的数据
/// @param sport_id 运动ID
+ (void)s_delete:(double)sport_id;

@end

NS_ASSUME_NONNULL_END
