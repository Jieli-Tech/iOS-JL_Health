//
//  JLWearSyncHealthSleepChart.m
//  JL_BLEKit
//
//  Created by JLee on 2021/11/1.
//  Copyright © 2021 www.zh-jieli.com. All rights reserved.
//

#import "JLWearSyncHealthSleepChart.h"
#import <JL_BLEKit/JL_BLEKit.h>

@implementation JLAnalyzeSleep
@end
@implementation JLWearSleepModel
@end
@implementation SleepData
@end

@implementation JLWearSyncHealthSleepChart

-(instancetype)initChart:(NSData *)sourceData{
    self = [super init];
    if (self) {
        [self createHeadInfo:sourceData];
        
        NSMutableArray *targetArray = [NSMutableArray new];
        int index = -1;
        for (int i = 0; i<self.dataArray.count; i++) {
            JLWearSyncHealthDataModel *model = self.dataArray[i];
            if ([model.HHmm isEqualToString:@"0000"]) {
                index = i;
            }
        }
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyyMMddHHmm";
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        for (int i = 0; i<self.dataArray.count; i++) {
            JLWearSyncHealthDataModel *model = self.dataArray[i];
            NSString *beginTime = [NSString stringWithFormat:@"%@%@",self.yyyyMMdd,model.HHmm];
            if (index > i) {
                NSDate *date = [formatter dateFromString:beginTime];
                NSDate *lastDay = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];
                beginTime = [formatter stringFromDate:lastDay];
            }
            if ([model.HHmm isEqualToString:@"255255"]) {
                self.analyze = [JLAnalyzeSleep new];
                self.analyze.sleepScore = [model.data subf:0 t:1].beUint8;
                self.analyze.deepSleepPresent = [model.data subf:1 t:1].beUint8;
                self.analyze.shallowSleepPresent = [model.data subf:2 t:1].beUint8;
                self.analyze.remSleepPresent = [model.data subf:3 t:1].beUint8;
                uint8_t allLevel = [model.data subf:4 t:1].beUint8;
                self.analyze.allSleepLevel = allLevel & 0x03;
                self.analyze.deepSleepLevel = (allLevel >> 2) & 0x03;
                self.analyze.shallowSleepLevel = (allLevel >> 4) & 0x03;
                self.analyze.remSleepLevel = (allLevel >> 6);
                self.analyze.deepSleepScre = [model.data subf:5 t: 1].beUint8;
                self.analyze.weakupNum = [model.data subf:6 t:1].beUint8;
                continue;
            }
            
            NSMutableArray *newArray = [NSMutableArray new];
            NSInteger seek = 0;
            while (seek < model.data.length-1) {
                NSData *value = [model.data subf:seek t:2];
                JLWearSleepModel *md = [JLWearSleepModel new];
                md.type = value.beUint8;
                md.duration = [value subf:1 t:1].beUint8;
                seek+=2;
                [newArray addObject:md];
            }
            SleepData *spdt = [SleepData new];
            spdt.startDate = [formatter dateFromString:beginTime];
            spdt.sleeps = newArray;
            [targetArray addObject:spdt];
        }
        self.sleepDataArray = targetArray;
    }
    return self;
}


@end



