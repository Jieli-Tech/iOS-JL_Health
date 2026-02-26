//
//  JLWearSyncHealthHeartRateChart.m
//  JL_BLEKit
//
//  Created by JLee on 2021/11/1.
//  Copyright © 2021 www.zh-jieli.com. All rights reserved.
//

#import "JLWearSyncHealthHeartRateChart.h"
#import <JL_BLEKit/JL_BLEKit.h>

@implementation HeartRateData
@end

@implementation JLWearSyncHealthHeartRateChart

-(instancetype)initChart:(NSData *)sourceData{
    self = [super init];
    if (self) {
        [self createHeadInfo:sourceData];
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyyMMddHHmm";
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSMutableArray *targetArray = [NSMutableArray new];
        self.maxHeartRate = 0;
        self.minHeartRate = 0;
        for (JLWearSyncHealthDataModel *model in self.dataArray) {
            NSString *beginTime = [NSString stringWithFormat:@"%@%@",self.yyyyMMdd,model.HHmm];
            NSMutableArray *newArray = [NSMutableArray new];
            NSInteger seek = 0;
            while (seek < model.data.length) {
                int value = [model.data subf:seek t:1].beUint8;
                if (value == 255) {
                    value = 0;
                }
                if (self.maxHeartRate<value) {
                    self.maxHeartRate = value;
                }
                if (self.minHeartRate>value || self.minHeartRate == 0) {
                    self.minHeartRate = value;
                }
                [newArray addObject:@(value)];
                seek+=1;
            }
            HeartRateData *hd = [HeartRateData new];
            hd.startDate = [formatter dateFromString:beginTime];
            hd.heartRates = newArray;
            [targetArray addObject:hd];
        }
        self.restingHeartRate = self.reserved >> 8;
        self.heartRatelist = targetArray;
    }
    return self;
}

@end
