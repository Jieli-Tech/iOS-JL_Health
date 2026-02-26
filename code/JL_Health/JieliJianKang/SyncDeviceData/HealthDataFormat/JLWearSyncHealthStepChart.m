//
//  JLWearSyncHealthStepChart.m
//  JL_BLEKit
//
//  Created by EzioChan on 2021/11/5.
//  Copyright © 2021 www.zh-jieli.com. All rights reserved.
//

#import "JLWearSyncHealthStepChart.h"
#import <JL_BLEKit/JL_BLEKit.h>

@implementation StepCountData
@end

@implementation JLWearStepCountModel
@end

@implementation JLWearSyncHealthStepChart

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
            NSMutableArray <JLWearStepCountModel *>*newArray = [NSMutableArray new];
            NSInteger seek = 0;
            while (seek < model.data.length) {
                JLWearStepCountModel *mdl = [JLWearStepCountModel new];
                mdl.count = [model.data subf:seek t:2].beBigendUint16;
                mdl.duration = [model.data subf:seek+2 t:2].beBigendUint16;
                mdl.Calories = [model.data subf:seek+4 t:2].beBigendUint16;
                [newArray addObject:mdl];
                seek+=6;
            }
            StepCountData *hd = [StepCountData new];
            hd.startDate = [formatter dateFromString:beginTime];
            hd.stepCounts = newArray;
            [targetArray addObject:hd];
        }
        self.stepCountlist = targetArray;
    }
    return self;
}

@end
