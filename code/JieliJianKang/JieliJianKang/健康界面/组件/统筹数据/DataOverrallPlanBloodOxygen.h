//
//  DataOverrallPlanBloodOxygan.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/11/19.
//

#import <Foundation/Foundation.h>
#import <CoreDraw/CoreDraw.h>

NS_ASSUME_NONNULL_BEGIN
@interface BloodOxygenModel:NSObject
@property(nonatomic,strong)NSArray <ECPoint *>*pointArray;
@property(nonatomic,strong)NSArray <UIColor *>*colors;
@property(nonatomic,assign)NSInteger max;
@property(nonatomic,assign)NSInteger min;
@end
@interface DataOverrallPlanBloodOxygen : NSObject

+(void)bloodOxygenByDate:(NSDate *)date Result:(void(^)(BloodOxygenModel *model))block;

+(void)bloodOxygenWeekStart:(NSDate *)start to:(NSDate *)end Result:(void(^)(BloodOxygenModel *model))block;

+(void)bloodOxygenMonthStart:(NSDate *)start to:(NSDate *)end Result:(void(^)(BloodOxygenModel *model))block;

+(void)bloodOxygenYearStart:(NSDate *)start toDate:(NSDate *)end result:(void(^)(BloodOxygenModel *model))block;

@end

NS_ASSUME_NONNULL_END
