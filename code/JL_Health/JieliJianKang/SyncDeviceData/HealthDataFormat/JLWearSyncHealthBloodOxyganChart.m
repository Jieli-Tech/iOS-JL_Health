//
//  JLWearSyncHealthBloodOxyganChar.m
//  JL_BLEKit
//
//  Created by JLee on 2021/11/1.
//  Copyright © 2021 www.zh-jieli.com. All rights reserved.
//

#import "JLWearSyncHealthBloodOxyganChart.h"
#import <JL_BLEKit/JL_BLEKit.h>

@implementation BloodOxyganData


@end

@implementation JLWearSyncHealthBloodOxyganChart

-(instancetype)initChart:(NSData *)sourceData{
    self = [super init];
    if (self) {
        [self createHeadInfo:sourceData];
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyyMMddHHmm";
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSMutableArray *targetArray = [NSMutableArray new];
        for (JLWearSyncHealthDataModel *model in self.dataArray) {
            NSString *beginTime = [NSString stringWithFormat:@"%@%@",self.yyyyMMdd,model.HHmm];
            NSMutableArray *newArray = [NSMutableArray new];
            NSInteger seek = 0;
            while (seek < model.data.length) {
                int value = [model.data subf:seek t:1].beUint8;
                [newArray addObject:@(value)];
                if (self.maxValue<value) {
                    self.maxValue = value;
                }
                if (self.minValue>value || self.minValue == 0) {
                    self.minValue = value;
                }
                seek+=1;
            }
            BloodOxyganData *hd = [BloodOxyganData new];
            hd.startDate = [formatter dateFromString:beginTime];
            hd.bloodOxygans = newArray;
            [targetArray addObject:hd];
        }
        self.bloodOxyganlist = targetArray;
    }
    return self;
}

@end
