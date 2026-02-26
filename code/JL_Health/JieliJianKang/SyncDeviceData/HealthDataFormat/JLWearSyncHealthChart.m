//
//  JLWearSyncHealthChart.m
//  JL_BLEKit
//
//  Created by EzioChan on 2021/10/30.
//  Copyright © 2021 www.zh-jieli.com. All rights reserved.
//

#import "JLWearSyncHealthChart.h"
#import <JL_BLEKit/JL_BLEKit.h>

@implementation JLWearSyncHealthDataModel

@end

@implementation JLWearSyncHealthChart


-(void)createHeadInfo:(NSData *)dt{
    self.type = [dt subf:0 t:1].beUint8;
    int year = [dt subf:1 t:2].beBigendUint16;
    int month = [dt subf:3 t:1].beUint8;
    int day = [dt subf:4 t:1].beUint8;
    
    self.yyyyMMdd = [self createDate:@[@(year),@(month),@(day)]];
//    kJLLog(JLLOG_DEBUG, @"yymmdd:%@",self.yyyyMMdd);
    self.crcCode = [dt subf:5 t:2].beBigendUint16;
    self.version = [dt subf:7 t:1].beUint8;
    self.interval = [dt subf:8 t:1].beUint8;
    self.reserved = [dt subf:9 t:2].beLittleUint16;
    self.sourceData = dt;
    NSMutableArray<JLWearSyncHealthDataModel *> *array = [NSMutableArray new];
    NSInteger seek = 11;
    while (seek<dt.length) {
        JLWearSyncHealthDataModel *model = [JLWearSyncHealthDataModel new];
        int hour = [dt subf:seek t:1].beUint8;
        int min = [dt subf:seek+1 t:1].beUint8;
        model.HHmm = [self createDate:@[@(hour),@(min)]];
//        kJLLog(JLLOG_DEBUG, @"hhmm:%@",model.HHmm);
        int len = [self rePlaceOxFF:[dt subf:seek+2 t:2]].beBigendUint16;
        model.data = [dt subf:seek+4 t:len];
        [array addObject:model];
        seek = seek+4+len;
    }
    self.dataArray = array;

}

-(NSData *)rePlaceOxFF:(NSData *)data{
    NSMutableData *dt = [NSMutableData new];
    NSInteger seek = 0;
    while (seek < data.length) {
        uint8_t v = [data subf:seek t:1].beUint8;
        if (v == 0xff) {
            uint8_t b[1] = {0x00};
            NSData *dt1 = [NSData dataWithBytes:b length:1];
            [dt appendData:dt1];
        }else{
            [dt appendData:[data subf:seek t:1]];
        }
        seek+=1;
    }
    return dt;
}

-(NSString *)createDate:(NSArray *)list{
    NSMutableString *string = [NSMutableString new];
    for (int i = 0; i<list.count; i++) {
        int HH = [list[i] intValue];
        if (HH<10) {
            [string appendFormat:@"0%d",HH];
        }else{
            [string appendFormat:@"%d",HH];
        }
    }
    return string;
}

@end




