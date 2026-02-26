//
//  DataOverallPlanTools.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/11/11.
//

#import "DataOverallPlanTools.h"
#import "JLSqliteSleep.h"


@implementation SleepDetailModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sporadicNaps = [JLWearSleepModel new];
        self.awakeCount = 0;
        self.sporadicNaps.type = WatchSleep_SporadicNaps;
    }
    return self;
}

-(NSInteger)all{
    return self.deep+self.shallow+self.rem+self.awake+self.sporadicNaps.duration;
}

-(NSInteger)nightTime{
    return self.deep+self.shallow+self.rem+self.awake;
}

@end
@implementation SleepDataFormatModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.detail = [SleepDetailModel new];
    }
    return self;
}
@end

@implementation DataOverallPlanTools

//typedef enum : NSUInteger {
//    SleepType_Deep,
//    SleepType_Shallow,
//    SleepType_Awake,
//    SleepType_Rem,
//    SleepType_SporadicNap
//} SleepType;

+(void)sleepDataByDate:(NSDate *)startDate result:(void(^)(SleepDataFormatModel *model)) block{
    [JLSqliteSleep s_checkout:@[startDate] Result:^(NSArray<JLWearSyncHealthSleepChart *> * _Nonnull charts) {
        SleepDataFormatModel *tgModel = [SleepDataFormatModel new];
        if (charts.count>0) {
            NSMutableArray *napsArray = [NSMutableArray new];
            JLWearSyncHealthSleepChart *chart = charts[0];
            NSMutableArray *points = [NSMutableArray new];
            for (SleepData *spD in chart.sleepDataArray) {
                NSTimeInterval dateTimer = [spD.startDate timeIntervalSince1970];
                for (int i = 0; i<spD.sleeps.count; i++) {
                    JLWearSleepModel *tmpModel = spD.sleeps[i];
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateTimer];
                    ECDiagramPoint *point;
                    switch (tmpModel.type) {
                        case WatchSleep_WideAwake:{
                            tgModel.detail.awakeCount+=1;
                            point = [ECDiagramPoint make:date len:tmpModel.duration*60 type:SleepType_Awake];
                            tgModel.detail.awake+=tmpModel.duration;
                        }break;
                        case WatchSleep_Deep:{
                            point = [ECDiagramPoint make:date len:tmpModel.duration*60 type:SleepType_Deep];
                            tgModel.detail.deep+=tmpModel.duration;
                        }break;
                        case WatchSleep_Light:{
                            point = [ECDiagramPoint make:date len:tmpModel.duration*60 type:SleepType_Shallow];
                            tgModel.detail.shallow+=tmpModel.duration;
                        }break;
                        case WatchSleep_SporadicNaps:{
                            tgModel.detail.sporadicNaps.duration += tmpModel.duration;
                            [napsArray addObject:[SleepNapModel makeNap:date with:tmpModel]];
                        }break;
                        case WatchSleep_RapidEyeMovement:{
                            point = [ECDiagramPoint make:date len:tmpModel.duration*60 type:SleepType_Rem];
                            tgModel.detail.rem+=tmpModel.duration;
                        }break;
                    }
                    if (point) {
                        [points addObject:point];
                        dateTimer+=(tmpModel.duration*60);
                    }
                }
            }
            
            tgModel.isHistogram = NO;
            tgModel.pointsArray = points;
            tgModel.detail.arrayNaps = napsArray;
            block(tgModel);
        }else{
            block(tgModel);
        }
    }];
}
+(void)sleepDataWeekFrom:(NSDate *)startDate To:(NSDate *)enddate result:(void(^)(SleepDataFormatModel *model)) block{
    [self sleepDataType:0 From:startDate To:enddate result:block];
}

+(void)sleepDataMonthFrom:(NSDate *)startDate To:(NSDate *)enddate result:(void(^)(SleepDataFormatModel *model)) block{
    [self sleepDataType:1 From:startDate To:enddate result:block];
}

+(void)sleepDataType:(NSInteger) type From:(NSDate *)startDate To:(NSDate *)enddate result:(void(^)(SleepDataFormatModel *model)) block{
    [JLSqliteSleep s_checkoutWtihStartDate:startDate withEndDate:enddate Result:^(NSArray<JLWearSyncHealthSleepChart *> * _Nonnull charts) {
        NSDateFormatter *fm = [EcTools cachedFm];
        fm.dateFormat = @"yyyyMMdd";
        NSMutableArray *sleepDays = [NSMutableArray new];
        for (JLWearSyncHealthSleepChart *t in charts) {
            SleepDetailModel *model = [SleepDetailModel new];
            model.date = [fm dateFromString:t.yyyyMMdd];
            for (SleepData *spD in t.sleepDataArray) {
                for (int i = 0; i<spD.sleeps.count; i++) {
                    JLWearSleepModel *tmpModel = spD.sleeps[i];
                    switch (tmpModel.type) {
                        case WatchSleep_WideAwake:{
                            model.awake+=tmpModel.duration;
                        }break;
                        case WatchSleep_Deep:{
                            
                            model.deep+=tmpModel.duration;
                        }break;
                        case WatchSleep_Light:{
                            
                            model.shallow+=tmpModel.duration;
                        }break;
                        case WatchSleep_SporadicNaps:{
                            model.sporadicNaps.duration += tmpModel.duration;
                        }break;
                        case WatchSleep_RapidEyeMovement:{
                            model.rem+=tmpModel.duration;
                        }break;
                    }
                }
            }
            [sleepDays addObject:model];
        }

        SleepDataFormatModel *targetModel = [SleepDataFormatModel new];
        targetModel.isHistogram = true;
        NSMutableArray *esdArray = [NSMutableArray new];
        if (type == 0) {
            for (int i = 1; i<=7; i++) {
                ECSleepDuration *esd;
                for (SleepDetailModel *item in sleepDays) {
                    if (item.date.witchWeekDay == i) {
                        esd = [ECSleepDuration make:(float)item.deep/(float)item.all shallow:(float)item.shallow/(float)item.all awake:(float)item.awake/(float)item.all rem:(float)item.rem/(float)item.all Duration:item.all*60 Date:item.date];
                        break;
                    }
                }
                if (esd == nil) {
                    esd = [ECSleepDuration make:0 shallow:0 awake:0 rem:0 Duration:0 Date:[NSDate dateWithTimeInterval:(i-1)*24*60*60 sinceDate:startDate]];
                }
                [esdArray addObject:esd];
            }
        }else{
            for (int i = 1; i<=startDate.monthDayCount; i++) {
                ECSleepDuration *esd;
                for (SleepDetailModel *item in sleepDays) {
                    if (item.date.witchDay == i) {
                        esd = [ECSleepDuration make:(float)item.deep/(float)item.all shallow:(float)item.shallow/(float)item.all awake:(float)item.awake/(float)item.all rem:(float)item.rem/(float)item.all Duration:item.all*60 Date:item.date];
                        break;
                    }
                }
                if (esd == nil) {
                    esd = [ECSleepDuration make:0 shallow:0 awake:0 rem:0 Duration:0 Date:[NSDate dateWithTimeInterval:(i-1)*24*60*60 sinceDate:startDate]];
                }
                [esdArray addObject:esd];
            }
        }
    
        targetModel.durationArray = esdArray;
        for (SleepDetailModel *item in sleepDays) {
            targetModel.detail.deep+=item.deep;
            targetModel.detail.shallow+=item.shallow;
            targetModel.detail.rem+=item.rem;
            targetModel.detail.awake+=item.awake;
            targetModel.detail.sporadicNaps.duration+=item.sporadicNaps.duration;
        }
        targetModel.detail.deep = targetModel.detail.deep/sleepDays.count;
        targetModel.detail.shallow = targetModel.detail.shallow/sleepDays.count;
        targetModel.detail.rem = targetModel.detail.rem/sleepDays.count;
        targetModel.detail.awake = targetModel.detail.awake/sleepDays.count;
        targetModel.detail.sporadicNaps.duration = targetModel.detail.sporadicNaps.duration/sleepDays.count;
        block(targetModel);
    }];
}



+(void)sleepDataYearFrom:(NSDate *)startDate To:(NSDate *)enddate result:(void(^)(SleepDataFormatModel *model)) block{
    
    [JLSqliteSleep s_checkoutWtihStartDate:startDate withEndDate:enddate Result:^(NSArray<JLWearSyncHealthSleepChart *> * _Nonnull charts) {
        NSDateFormatter *fm = [EcTools cachedFm];
        fm.dateFormat = @"yyyyMMdd";
        NSMutableDictionary *dict = [NSMutableDictionary new];
        for (JLWearSyncHealthSleepChart *t in charts) {
            SleepDetailModel *model = [SleepDetailModel new];
            model.date = [fm dateFromString:t.yyyyMMdd];
            NSString *key = [[NSString alloc] initWithFormat:@"%d",(int)model.date.witchMonth];
            NSMutableArray *monthArray = dict[key];
            if (monthArray==nil) {
                monthArray = [NSMutableArray new];
            }
            for (SleepData *spD in t.sleepDataArray) {
                for (int i = 0; i<spD.sleeps.count; i++) {
                    JLWearSleepModel *tmpModel = spD.sleeps[i];
                    switch (tmpModel.type) {
                        case WatchSleep_WideAwake:{
                            model.awake+=tmpModel.duration;
                        }break;
                        case WatchSleep_Deep:{
                            model.deep+=tmpModel.duration;
                        }break;
                        case WatchSleep_Light:{
                            
                            model.shallow+=tmpModel.duration;
                        }break;
                        case WatchSleep_SporadicNaps:{
                            model.sporadicNaps.duration += tmpModel.duration;
                        }break;
                        case WatchSleep_RapidEyeMovement:{
                            model.rem+=tmpModel.duration;
                        }break;
                    }
                }
            }
            [monthArray addObject:model];
            [dict setValue:monthArray forKey:key];
        }
        
        SleepDataFormatModel *targetModel = [SleepDataFormatModel new];
        targetModel.isHistogram = true;
        NSMutableArray *esdArray = [NSMutableArray new];
        NSInteger allCount = 0;
        NSDate *month = nil;
        for (int i = 1; i<=12; i++) {
            ECSleepDuration *esd;
            NSString *key = [[NSString alloc] initWithFormat:@"%d",i];
            NSArray *dateArray = dict[key];
            if (month == nil) {
                month = startDate;
            }else{
                month = month.nextMonth;
            }
            if (dateArray == nil || dateArray.count == 0) {
                esd = [ECSleepDuration make:0 shallow:0 awake:0 rem:0 Duration:0 Date:month];
            }else{
                SleepDetailModel *monthModel = [SleepDetailModel new];
                for (SleepDetailModel *item in dateArray) {
                    targetModel.detail.deep+=item.deep;
                    targetModel.detail.shallow+=item.shallow;
                    targetModel.detail.rem+=item.rem;
                    targetModel.detail.awake+=item.awake;
                    targetModel.detail.sporadicNaps.duration+=item.sporadicNaps.duration;
                    
                    monthModel.deep+=item.deep;
                    monthModel.shallow+=item.shallow;
                    monthModel.rem+=item.rem;
                    monthModel.awake+=item.awake;
                    monthModel.sporadicNaps.duration+=item.sporadicNaps.duration;
                    allCount+=1;
                }
                monthModel.deep = monthModel.deep/dateArray.count;
                monthModel.shallow = monthModel.shallow/dateArray.count;
                monthModel.rem = monthModel.rem/dateArray.count;
                monthModel.awake = monthModel.awake/dateArray.count;
                monthModel.sporadicNaps.duration = monthModel.sporadicNaps.duration/dateArray.count;
                esd = [ECSleepDuration make:(float)monthModel.deep/(float)monthModel.all shallow:(float)monthModel.shallow/(float)monthModel.all awake:(float)monthModel.awake/(float)monthModel.all rem:(float)monthModel.rem/(float)monthModel.all Duration:monthModel.all*60 Date:month];
            }
            [esdArray addObject:esd];
//            kJLLog(JLLOG_DEBUG, @"esd.date:%@",esd.date.toYYYYMMdd);
        }
        targetModel.durationArray = esdArray;
        targetModel.detail.deep = targetModel.detail.deep/allCount;
        targetModel.detail.shallow = targetModel.detail.shallow/allCount;
        targetModel.detail.rem = targetModel.detail.rem/allCount;
        targetModel.detail.awake = targetModel.detail.awake/allCount;
        targetModel.detail.sporadicNaps.duration = targetModel.detail.sporadicNaps.duration/allCount;
        block(targetModel);
    }];
}




    





@end
