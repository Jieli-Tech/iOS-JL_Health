//
//  JLWearSyncHealthWeightChart.m
//  JL_BLEKit
//
//  Created by EzioChan on 2021/11/19.
//  Copyright © 2021 www.zh-jieli.com. All rights reserved.
//

#import "JLWearSyncHealthWeightChart.h"
#import <JL_HashPair/JL_ble_pair.h>
#import <JL_BLEKit/JL_BLEKit.h>

@implementation JLWearWeightModel

@end

@implementation WeightData

@end

@implementation JLWearSyncHealthWeightChart

-(instancetype)initChart:(NSData *)sourceData{
    self = [super init];
    if (self) {
        [self createHeadInfo:sourceData];
        
        NSMutableArray *targetArray = [NSMutableArray new];
        int index = 0;
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
            kJLLog(JLLOG_DEBUG, @"%@",beginTime);
            NSMutableArray *newArray = [NSMutableArray new];
            NSInteger seek = 0;
            while (seek < model.data.length-1) {
                NSData *value = [model.data subf:seek t:2];
                JLWearWeightModel *md = [JLWearWeightModel new];
                md.integer = value.beUint8;
                md.decimal = [value subf:1 t:1].beUint8;
                seek+=2;
                [newArray addObject:md];
            }
            WeightData *spdt = [WeightData new];
            spdt.startDate = [formatter dateFromString:beginTime];
            spdt.weights = newArray;
            [targetArray addObject:spdt];
        }
        self.weightDataArray = targetArray;
    }
    return self;
}


-(NSData *)beData{
    NSMutableData *targetData = [NSMutableData new];
    self.type = 0xff;
    uint8_t k[] = {self.type};
    [targetData appendBytes:k length:1];
    uint16_t year = [[self.yyyyMMdd substringWithRange:NSMakeRange(0, 4)] intValue];
    uint16_t years[] = {htons(year)};
    
    [targetData appendBytes:years length:2];
    uint8_t month = [[self.yyyyMMdd substringWithRange:NSMakeRange(4, 2)] intValue];
    uint8_t day = [[self.yyyyMMdd substringWithRange:NSMakeRange(6, 2)] intValue];
    uint8_t mmdd_crc_version_interval_res[] = {month,day,0xff,0xff,self.version,0xff,0x00,0x00};
    [targetData appendBytes:mmdd_crc_version_interval_res length:8];
    
    NSDateFormatter *fm = [NSDateFormatter new];
    fm.dateFormat = @"hh-mm";
    fm.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSMutableData *tgData = [NSMutableData new];
    for (WeightData *wd in self.weightDataArray) {
        NSMutableData *tmpData = [NSMutableData new];
        NSArray *strs = [[fm stringFromDate:wd.startDate] componentsSeparatedByString:@"-"];
        uint8_t hh = [strs[0] intValue];
        uint8_t mm = [strs[1] intValue];
        uint8_t hhmm_len[] ={hh,mm,0x00,0x02};
        [tmpData appendBytes:hhmm_len length:4];
        for (JLWearWeightModel *md in wd.weights) {
            uint8_t hm[] = {md.integer,md.decimal};
            [tmpData appendBytes:hm length:2];
        }
        [tgData appendData:tmpData];
    }
    uint16_t crc = JL_CRC16((unsigned char *)[tgData bytes], (int)tgData.length, 0);
    uint16_t u16crc[] = {crc};
    [targetData appendData:tgData];
    [targetData replaceBytesInRange:NSMakeRange(5, 2) withBytes:u16crc];
    [self createHeadInfo:targetData];
    return targetData;
}



@end
