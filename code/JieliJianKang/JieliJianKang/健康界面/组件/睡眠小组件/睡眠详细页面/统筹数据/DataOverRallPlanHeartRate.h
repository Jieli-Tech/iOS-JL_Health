//
//  DataOverRallPlanHeartRate.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/11/15.
//

#import <Foundation/Foundation.h>
#import <CoreDraw/CoreDraw.h>

NS_ASSUME_NONNULL_BEGIN

@interface ECPointMax:ECPoint

@property(nonatomic,strong)NSMutableArray *resArray;

@end

@interface HeartRateModel:NSObject
@property(nonatomic,strong)NSArray *pointArray;
@property(nonatomic,assign)NSInteger max;
@property(nonatomic,assign)NSInteger min;
@property(nonatomic,assign)NSInteger res;
@end

@interface DataOverRallPlanHeartRate : NSObject

+(void)heartRateDate:(NSDate *)date result:(void(^)(HeartRateModel *model))block;

+(void)heartRateWeekStart:(NSDate *)start toDate:(NSDate *)end result:(void(^)(NSArray<ECPoint *> *models))block;

+(void)heartRateMonthStart:(NSDate *)start toDate:(NSDate *)end result:(void(^)(NSArray<ECPoint *> *models))block;

+(void)heartRateYearStart:(NSDate *)start toDate:(NSDate *)end result:(void(^)(NSArray<ECPoint *> *models))block;
@end

NS_ASSUME_NONNULL_END
