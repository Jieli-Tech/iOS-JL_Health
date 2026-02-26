//
//  DataOVerRallPlanHeartRate.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/11/15.
//

#import "DataOverRallPlanHeartRate.h"
#import "JLSqliteHeartRate.h"


@implementation ECPointMax

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.resArray = [NSMutableArray new];
    }
    return self;
}

@end


@implementation HeartRateModel

@end

@implementation DataOverRallPlanHeartRate

+(void)heartRateLastDateResult:(void(^)(HeartRateModel *model,NSDate *date))block{
    [JLSqliteHeartRate s_checkoutTheLastDataWithResult:^(JLWearSyncHealthHeartRateChart * _Nonnull chart) {
        NSDateFormatter *fm = [EcTools cachedFm];
        [fm setDateFormat:@"yyyyMMdd"];
        NSDate *date = [fm dateFromString:chart.yyyyMMdd];
        HeartRateModel *targetModel = [HeartRateModel new];
        if (chart) {
            NSInteger k = 0;
            NSMutableArray *tmp = [NSMutableArray new];
            NSTimeInterval runtimer = [date timeIntervalSince1970];
            while (1) {
                runtimer+=chart.interval*60;
                for (HeartRateData *hdt in chart.heartRatelist) {
                    NSTimeInterval hdts = [hdt.startDate timeIntervalSince1970];
                    //                    kJLLog(JLLOG_DEBUG, @"%f - %f \n %f",(runtimer-chart.interval*60),(runtimer+chart.interval*60),hdts);
                    if ((runtimer-chart.interval*60) <= hdts && hdts < (runtimer+chart.interval*60)) {
                        for (NSNumber *number in hdt.heartRates){
                            runtimer+=chart.interval*60;
                            NSValue *v = [NSValue valueWithCGPoint:CGPointMake(k, [number intValue])];
                            [tmp addObject:v];
                            targetModel.lastRate = [number intValue];
                            k++;
                        }
                    }
                }
                NSValue *v = [NSValue valueWithCGPoint:CGPointMake(k, 0)];
                [tmp addObject:v];
                k++;
                if (k >= 60*24/chart.interval-1) {
                    break;;
                }
            }
            targetModel.pointArray = tmp;
            targetModel.max = chart.maxHeartRate;
            targetModel.min = chart.minHeartRate;
            targetModel.res = chart.restingHeartRate;
            block(targetModel,date);
        }else{
            block(targetModel,date);
        }
    }];
}



+(void)heartRateDate:(NSDate *)date result:(void(^)(HeartRateModel *model))block{
    [JLSqliteHeartRate s_checkout:@[date] Result:^(NSArray<JLWearSyncHealthHeartRateChart *> * _Nonnull charts) {
        HeartRateModel *targetModel = [HeartRateModel new];
        if (charts.count>0) {
            JLWearSyncHealthHeartRateChart *chart = charts[0];
            NSInteger k = 0;
            NSMutableArray *tmp = [NSMutableArray new];
            NSTimeInterval runtimer = [date timeIntervalSince1970];
            while (1) {
                runtimer+=chart.interval*60;
                for (HeartRateData *hdt in chart.heartRatelist) {
                    NSTimeInterval hdts = [hdt.startDate timeIntervalSince1970];
//                    kJLLog(JLLOG_DEBUG, @"%f - %f \n %f",(runtimer-chart.interval*60),(runtimer+chart.interval*60),hdts);
                    if ((runtimer-chart.interval*60) <= hdts && hdts < (runtimer+chart.interval*60)) {
                        for (NSNumber *number in hdt.heartRates){
                            runtimer+=chart.interval*60;
                            NSValue *v = [NSValue valueWithCGPoint:CGPointMake(k, [number intValue])];
                            [tmp addObject:v];
                            k++;
                        }
                    }
                }
                NSValue *v = [NSValue valueWithCGPoint:CGPointMake(k, 0)];
                [tmp addObject:v];
                k++;
                if (k >= 60*24/chart.interval-1) {
                    break;;
                }
            }
            targetModel.pointArray = tmp;
            targetModel.max = chart.maxHeartRate;
            targetModel.min = chart.minHeartRate;
            targetModel.res = chart.restingHeartRate;
        }
        block(targetModel);
    }];
}


+(void)heartRateWeekStart:(NSDate *)start toDate:(NSDate *)end result:(void(^)(NSArray<ECPoint *> *models))block{
    [self heartRateType:0 WAHStart:start toDate:end result:block];
}

+(void)heartRateMonthStart:(NSDate *)start toDate:(NSDate *)end result:(void(^)(NSArray<ECPoint *> *models))block{
    [self heartRateType:1 WAHStart:start toDate:end result:block];
}

+(void)heartRateType:(NSInteger)type WAHStart:(NSDate *)start toDate:(NSDate *)end result:(void(^)(NSArray<ECPoint *> *models))block{
    [JLSqliteHeartRate s_checkoutWtihStartDate:start withEndDate:end Result:^(NSArray<JLWearSyncHealthHeartRateChart *> * _Nonnull charts) {
        NSMutableArray *ecp = [NSMutableArray new];
        if (type == 0) {
            for (int i = 1; i<=7; i++) {
                ECPoint *point;
                for (JLWearSyncHealthHeartRateChart *item in charts) {
                    if (item.heartRatelist.firstObject.startDate.witchWeekDay == i) {
                        point = [ECPoint make:i-1 max:item.maxHeartRate min:item.minHeartRate];
                        point.resValue = item.restingHeartRate;
                        point.date = item.heartRatelist[0].startDate;
                        [ecp addObject:point];
                    }
                }
                if (point == nil) {
                    point = [ECPoint make:i-1 max:0 min:0];
                    NSDate *date = [NSDate dateWithTimeInterval:24*(i-1)*60*60 sinceDate:start];
                    point.date = date;
                    [ecp addObject:point];
                }
                
            }
        }else{
            for (int i = 1; i<=start.monthDayCount; i++) {
                ECPoint *point;
                for (JLWearSyncHealthHeartRateChart *item in charts) {
                    if (item.heartRatelist.firstObject.startDate.witchDay == i) {
                        point = [ECPoint make:i-1 max:item.maxHeartRate min:item.minHeartRate];
                        point.resValue = item.restingHeartRate;
                        point.date = item.heartRatelist[0].startDate;
                        [ecp addObject:point];
                    }
                }
                if (point == nil) {
                    point = [ECPoint make:i-1 max:0 min:0];
                    NSDate *date = [NSDate dateWithTimeInterval:24*(i-1)*60*60 sinceDate:start];
                    point.date = date;
                    [ecp addObject:point];
                }
                
            }
        }
        block(ecp);
    }];
}


+(void)heartRateYearStart:(NSDate *)start toDate:(NSDate *)end result:(void(^)(NSArray<ECPoint *> *models))block{
    [JLSqliteHeartRate s_checkoutWtihStartDate:start withEndDate:end Result:^(NSArray<JLWearSyncHealthHeartRateChart *> * _Nonnull charts) {
        NSMutableArray *tgArray = [NSMutableArray new];
        NSDate *tmpDate = start;
        for (int i = 1; i<=12; i++) {
            ECPointMax *point = [[ECPointMax alloc] init];
            point.index = i-1;
            point.maxY = 0;
            point.minY = 0;
            point.date = tmpDate;
            point.resValue = 0;
            [tgArray addObject:point];
            tmpDate = tmpDate.nextMonth;
        }

        for (JLWearSyncHealthHeartRateChart *chart in charts) {
            NSInteger index = chart.heartRatelist.firstObject.startDate.witchMonth;
            ECPointMax *point = tgArray[index-1];
            if (point.minY>chart.minHeartRate || point.minY == 0) {
                point.minY = chart.minHeartRate;
            }
            if (point.maxY<chart.maxHeartRate) {
                point.maxY = chart.maxHeartRate;
            }
            if (chart.restingHeartRate != 0) {
                [point.resArray addObject:@(chart.restingHeartRate)];
            }
        }

        for (ECPointMax *point in tgArray) {
            NSInteger ave = 0;
            for (NSNumber *item in point.resArray) {
                ave+=[item intValue];
            }
            point.resValue = ave/point.resArray.count;
        }
        block(tgArray);
    }];
}




@end
