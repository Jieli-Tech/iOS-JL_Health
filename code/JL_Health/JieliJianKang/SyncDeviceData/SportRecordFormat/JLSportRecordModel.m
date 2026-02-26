//
//  JLSportRecordModel.m
//  JL_BLEKit
//
//  Created by EzioChan on 2021/4/29.
//  Copyright © 2021 www.zh-jieli.com. All rights reserved.
//

#import "JLSportRecordModel.h"

#define DebugLog       0

@implementation JLSportRecordModel

-(instancetype)initWithData:(NSData *)data{
    self = [super init];
    if (self) {
        
    }
    if ((data.length < 13) || (data.length < 1)) {
        log4cplus_error(kModuleName, "initWithData 运动数据异常：%s", [data.beHexStr UTF8String]);
        return self;
    }
    self.modelType = [data subf:0 t:1].beUint8;
    self.version = [data subf:1 t:1].beUint8;
    self.interval = [data subf:2 t:1].beUint8;
    self.reservedBit = [data subf:3 t:10];
    self.dataArray = [self createByData:data];
    //kJLLog(JLLOG_DEBUG, @"%ld",(long)[self getLength:self.dataArray]);
    NSInteger i = data.length-37;
    self.duration = [data subf:i t:2].beLittleUint16;
    i+=2;
    self.reservedBit2 = [data subf:i t:4];
    i+=4;
    self.distance = [data subf:i t:2].beLittleUint16;
    i+=2;
    self.calories = [data subf:i t:2].beLittleUint16;
    i+=2;
    self.step = [data subf:i t:4].beLittleUint32;
    i+=4;
    NSData *recDt = [data subf:i t:2];
    self.recoveryTime = [self coverToString:recDt];
    i+=2;
    self.heartRateType = [data subf:i t:1].beUint8;
    i+=1;
    if ((i + 20) <= data.length) {
        NSData *exData = [data subf:i t:20];
        self.exerciseIntensArray = [self coverToArray:exData];
    } else {
        log4cplus_error(kModuleName, "运动数据exData异常：%s", [data.beHexStr UTF8String]);
    }
    
    self.sourceData = data;
    return self;
}

+(NSDate *)startDate:(NSData *)data{
    if (data.length < 18) {
        log4cplus_error(kModuleName, "头部包信息过短，获取不了信息");
        return [NSDate new];
    }else{
        NSData *dt = [data subf:15 t:4];
        return dt.toDate;
    }
}



-(NSArray<JL_SRM_DataFormat*> *)createByData:(NSData *)data{
    if (data.length < 13) {
        log4cplus_error(kModuleName, "运动数据异常：%s", [data.beHexStr UTF8String]);
        return [NSMutableArray new];
    }
    NSData *dt = [data subf:13 t:data.length-13];
    NSInteger i = 0;
    NSMutableArray<JL_SRM_DataFormat*> *tmpArray = [NSMutableArray new];
    while (1) {
        if ((i+2) > data.length) {
            log4cplus_error(kModuleName, "运动数据flag或者类型异常：%s", [data.beHexStr UTF8String]);
            break;
        }
        JL_SRM_DataFormat *df = [JL_SRM_DataFormat new];
        UInt8 flag = [dt subf:i t:1].beUint8;
        df.type = flag;
        UInt8 length = [dt subf:i+1 t:1].beUint8;
        if ((i+2+length) > data.length) {
            log4cplus_error(kModuleName, "运动数据长度异常：%s", [data.beHexStr UTF8String]);
            break;
        }
#if DebugLog
        kJLLog(JLLOG_DEBUG, @"类型：%d，长度：%d",flag,length);
#endif
        df.length = length+2;
        if (length == 0) {
            log4cplus_fatal(kModuleName, "运动数据长度为0错误！！！");
            break;
        }
        if (flag == JL_SRM_Start) {//开始包
            df.startDate = [dt subf:i+2 t:length].toDate;
#if DebugLog
            NSDateFormatter *format = [NSDateFormatter new];
            format.dateFormat = @"YYYY-MM-dd HH:mm:ss";
            kJLLog(JLLOG_DEBUG, @"SRM_Start类型:开始包，startDate:%@",[format stringFromDate:df.startDate]);
#endif
        }
        if (flag == JL_SRM_Pause) {//暂停包
            df.pauseDate = [dt subf:i+2 t:length].toDate;
#if DebugLog
            kJLLog(JLLOG_DEBUG, @"SRM_Pause类型:暂停包，长度：%d pauseDate:%@",length,df.pauseDate);
#endif
        }
        if (flag == JL_SRM_Basic) {
            
            df.heartRate = [dt subf:i+2 t:1].beUint8;
            df.stride = [dt subf:i+3 t:2].beLittleUint16;
            df.speed = [dt subf:i+5 t:2].beLittleUint16;
#if DebugLog
            kJLLog(JLLOG_DEBUG, @"SRM_Basic类型：基础包 心率:%d,步幅:%d,速度:%d",(int)df.heartRate,(int)df.stride,(int)df.speed);
#endif
        }
        if(flag == JL_SRM_Pace){
            df.pace = [dt subf:i+2 t:2].beLittleUint16;
            df.numKm = [dt subf:i+4 t:1].beUint8;
#if DebugLog
            kJLLog(JLLOG_DEBUG, @"SRM_Basic类型:配速包，配速：%d，第%d公里",(int)df.pace,(int)df.numKm);
#endif
        }
        if (flag == JL_SRM_End){
            df.endDate = [dt subf:i+2 t:length].toDate;
            i = i+2+length;
#if DebugLog
            kJLLog(JLLOG_DEBUG, @"SRM_End类型：结束包 endDate:%@",df.endDate);
#endif
            [tmpArray addObject:df];
            break;
        }
        i = i+2+length;
        [tmpArray addObject:df];
    }
    [tmpArray removeLastObject];
    return tmpArray;
}


-(NSString *)coverToString:(NSData *)data{
    int hour = [data subf:0 t:1].beUint8;
    int mount = [data subf:1 t:1].beUint8;
    return [NSString stringWithFormat:@"%d:%d",hour,mount];
}

-(NSArray *)coverToArray:(NSData *)exerciseData{
    int seek = 0;
    NSMutableArray *targetArray = [NSMutableArray new];
    if (!exerciseData || exerciseData.length <= 0) {
        return targetArray;
    }
#if DebugLog
    if (exerciseData) {
        kJLLog(JLLOG_DEBUG, @"JLWatchExerciseIntens exerciseData:%@", exerciseData);
    }
#endif
    while (seek<exerciseData.length) {
        UInt32 value = [exerciseData subf:seek t:4].beLittleUint32;
        JLWatchExerciseIntens *md = [JLWatchExerciseIntens new];
        md.duration = value;
        UInt8 type = seek/4 + 1;
        md.type = type;
#if DebugLog
        kJLLog(JLLOG_DEBUG, @"JLWatchExerciseIntens类型 seek:%d, duration:%d, type:%d", (unsigned int)seek, (int)value, (int)type);
#endif
        [targetArray addObject:md];
        seek+=4;
    }
    return targetArray;
}

-(NSInteger)getLength:(NSArray<JL_SRM_DataFormat *>*)array{
    NSInteger k = 13;
    for (JL_SRM_DataFormat *item in array) {
        k = k+item.length;
    }
    return k;
}



@end

@implementation JL_SRM_DataFormat

@end
