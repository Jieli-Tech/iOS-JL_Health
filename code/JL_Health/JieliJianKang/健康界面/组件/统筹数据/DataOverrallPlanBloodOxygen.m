//
//  DataOverrallPlanBloodOxygan.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/11/19.
//

#import "DataOverrallPlanBloodOxygen.h"
#import "JLSqliteOxyhemoglobinSaturation.h"
#import "DataOverRallPlanHeartRate.h"

#define MinNumber  85


@implementation BloodOxygenModel

@end


@implementation DataOverrallPlanBloodOxygen

+(void)bloodOxygenByDate:(NSDate *)date Result:(void(^)(BloodOxygenModel *model))block{
    [JLSqliteOxyhemoglobinSaturation s_checkout:@[date.toStartOfDate] Result:^(NSArray<JL_Chart_OxyhemoglobinSaturation *> * _Nonnull charts) {
        BloodOxygenModel *targetModel = [BloodOxygenModel new];
        if (charts.count>0) {
            JL_Chart_OxyhemoglobinSaturation *chart = charts[0];
            NSInteger k = 0;
            NSMutableArray *tmp = [NSMutableArray new];
            NSMutableArray <UIColor *> *colors = [NSMutableArray new];
            NSTimeInterval runtimer = [date.toStartOfDate timeIntervalSince1970];
            while (1) {
                runtimer+=chart.interval*60;
                for (BloodOxyganData *bod in chart.bloodOxyganlist) {
                    NSTimeInterval hdts = [bod.startDate timeIntervalSince1970];
//                    kJLLog(JLLOG_DEBUG, @"%f - %f \n %f",(runtimer-chart.interval*60),(runtimer+chart.interval*60),hdts);
                    if ((runtimer-chart.interval*60) <= hdts && hdts < (runtimer+chart.interval*60)) {
                        for (NSNumber *number in bod.bloodOxygans){
                            runtimer+=chart.interval*60;
                            ECPoint *point = [ECPoint make:k max:[number intValue] min:MinNumber];
                            point.date = [NSDate dateWithTimeIntervalSince1970:runtimer];
                            if ([number intValue]<70) {
                                [colors addObject:[JLColor colorWithString:@"#8ACA92"]];
                            }
                            if ([number intValue]>=70 && [number intValue]<89) {
                                [colors addObject:[JLColor colorWithString:@"#FFBB2A"]];
                            }
                            if ([number intValue]>=90) {
                                [colors addObject:[JLColor colorWithString:@"#8ACA92"]];
                            }
                            [tmp addObject:point];
                            k++;
                        }
                    }
                }
                ECPoint *point = [ECPoint make:k max:0 min:0];
                point.date = [NSDate dateWithTimeIntervalSince1970:runtimer];
                [colors addObject:[UIColor clearColor]];
                [tmp addObject:point];
                k++;
                if (k >= 60*24/chart.interval-1) {
                    break;;
                }
            }
            targetModel.pointArray = tmp;
            targetModel.colors = colors;
            targetModel.max = chart.maxValue;
            targetModel.min = chart.minValue;
        }else{
            NSInteger k = 0;
            NSMutableArray *tmp = [NSMutableArray new];
            NSMutableArray <UIColor *> *colors = [NSMutableArray new];
            NSTimeInterval runtimer = [date.toStartOfDate timeIntervalSince1970];
            while (1) {
                runtimer+=5*60;
                ECPoint *point = [ECPoint make:k max:0 min:0];
                point.date = [NSDate dateWithTimeIntervalSince1970:runtimer];
                [colors addObject:[UIColor clearColor]];
                [tmp addObject:point];
                k++;
                if (k >= 60*24/5-1) {
                    break;;
                }
            }
            targetModel.pointArray = tmp;
            targetModel.colors = colors;
            targetModel.max = 0;
            targetModel.min = 0;
        }
        block(targetModel);
    }];
}

+(void)bloodOxygenWeekStart:(NSDate *)start to:(NSDate *)end Result:(void(^)(BloodOxygenModel *model))block{
    [self bloodOxygenType:0 StartDate:start to:end Result:block];
}

+(void)bloodOxygenMonthStart:(NSDate *)start to:(NSDate *)end Result:(void(^)(BloodOxygenModel *model))block{
    [self bloodOxygenType:1 StartDate:start to:end Result:block];
}


+(void)bloodOxygenType:(NSInteger) type StartDate:(NSDate *)start to:(NSDate *)end Result:(void(^)(BloodOxygenModel *model))block{
    [JLSqliteOxyhemoglobinSaturation s_checkoutWtihStartDate:start withEndDate:end Result:^(NSArray<JL_Chart_OxyhemoglobinSaturation *> * _Nonnull charts) {
        NSMutableArray *ecp = [NSMutableArray new];
        NSMutableArray <UIColor *> *colors = [NSMutableArray new];
        BloodOxygenModel *bom = [BloodOxygenModel new];
        if (type == 0) {
            for (int i = 1; i<=7; i++) {
                ECPoint *point;
                for (JL_Chart_OxyhemoglobinSaturation *item in charts) {
                    if (item.bloodOxyganlist.firstObject.startDate.witchWeekDay == i) {
                        point = [ECPoint make:i-1 max:item.maxValue min:item.minValue];
                        point.resValue = item.averageValue;
                        point.date = item.bloodOxyganlist[0].startDate;
                        [colors addObject:[JLColor colorWithString:@"#F0AE91"]];
                        [ecp addObject:point];
                    }
                }
                if (point == nil) {
                    point = [ECPoint make:i-1 max:0 min:0];
                    NSDate *date = [NSDate dateWithTimeInterval:24*(i-1)*60*60 sinceDate:start];
                    point.date = date;
                    [colors addObject:[JLColor colorWithString:@"#F0AE91"]];
                    [ecp addObject:point];
                }
                
            }
        }else{
            for (int i = 1; i<=start.monthDayCount; i++) {
                ECPoint *point;
                for (JL_Chart_OxyhemoglobinSaturation *item in charts) {
                    if (item.bloodOxyganlist.firstObject.startDate.witchDay == i) {
                        point = [ECPoint make:i-1 max:item.maxValue min:item.minValue];
                        point.resValue = item.averageValue;
                        point.date = item.bloodOxyganlist[0].startDate;
                        [colors addObject:[JLColor colorWithString:@"#F0AE91"]];
                        [ecp addObject:point];
                    }
                }
                if (point == nil) {
                    point = [ECPoint make:i-1 max:0 min:0];
                    NSDate *date = [NSDate dateWithTimeInterval:24*(i-1)*60*60 sinceDate:start];
                    point.date = date;
                    [colors addObject:[JLColor colorWithString:@"#F0AE91"]];
                    [ecp addObject:point];
                }
                
            }
        }
        
        bom.pointArray = ecp;
        bom.colors = colors;
        block(bom);
    }];
}


+(void)bloodOxygenYearStart:(NSDate *)start toDate:(NSDate *)end result:(void(^)(BloodOxygenModel *model))block{
    [JLSqliteOxyhemoglobinSaturation s_checkoutWtihStartDate:start withEndDate:end Result:^(NSArray<JL_Chart_OxyhemoglobinSaturation *> * _Nonnull charts) {
        BloodOxygenModel *bom = [BloodOxygenModel new];
        NSMutableArray *tgArray = [NSMutableArray new];
        NSMutableArray <UIColor *> *colors = [NSMutableArray new];
        NSDate *tmpDate = start;
        for (int i = 1; i<=12; i++) {
            ECPointMax *point = [[ECPointMax alloc] init];
            point.index = i-1;
            point.maxY = 0;
            point.minY = 0;
            point.date = tmpDate;
            point.resValue = 0;
            [tgArray addObject:point];
            tmpDate = tmpDate.nextMonth_0;
            [colors addObject:[JLColor colorWithString:@"#F0AE91"]];
        }

        for (JL_Chart_OxyhemoglobinSaturation *chart in charts) {
            NSInteger index = chart.bloodOxyganlist.firstObject.startDate.witchMonth;
            ECPointMax *point = tgArray[index-1];
            if (point.minY>chart.minValue || point.minY == 0) {
                point.minY = chart.minValue;
            }
            if (point.maxY<chart.maxValue) {
                point.maxY = chart.maxValue;
            }
            if (chart.averageValue != 0) {
                [point.resArray addObject:@(chart.averageValue)];
            }
        }

        for (ECPointMax *point in tgArray) {
            NSInteger ave = 0;
            for (NSNumber *item in point.resArray) {
                ave+=[item intValue];
            }
            point.resValue = ave/point.resArray.count;
        }
        bom.pointArray = tgArray;
        bom.colors = colors;
        block(bom);
    }];
}







@end
