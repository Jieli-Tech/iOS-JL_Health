//
//  NSString+Path.m
//  Test
//
//  Created by EzioChan on 2021/4/25.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import "NSString+Path.h"

@implementation NSString (Path)


-(NSString *)path{
    NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fmdbPath=[doc stringByAppendingPathComponent:self];
    return fmdbPath;
}

-(BOOL)isExist{
    NSFileManager *fm = [[NSFileManager alloc] init];
    if ([fm fileExistsAtPath:self]) {
        return YES;
    }else{
        return NO;
    }
}


-(NSString *)addSuffix:(NSString *)str{
    return [NSString stringWithFormat:@"%@.%@",self,str];
}

-(NSString *)getSuffix{
    NSArray *array = [self componentsSeparatedByString:@"_"];
    return array.lastObject;
}

-(NSTimeInterval)toDateInt{
    NSArray *strArray = [self componentsSeparatedByString:@":"];
    NSTimeInterval t0 = [strArray[0] intValue]*60*60 +[strArray[1] intValue]*60+[strArray[2] intValue];
    return t0;
}

-(NSDate *)toDateByNormal{
    NSDateFormatter *fm = [EcTools cachedFm];
    [fm setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
    return [fm dateFromString:self];
}

-(NSData *)getData{
    NSData *data = [NSData dataWithContentsOfFile:self];
    return data;
}


- (BOOL)compareTimeIntervalTo:(NSString *)next{
    if (self.toDateInt < next.toDateInt) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Private Methods
/// 蓝牙地址转换
-(NSString *)formatBleEdr{
    NSString *target = [NSMutableString new];
    NSData *data = [JL_Tools HexToData:self];
    for (int i = 0; i<6; i++) {
        NSData *newData = [data subf:i t:1];
        NSString *str = [NSString stringWithFormat:@"%@",[JL_Tools dataChangeToString:newData]];
        target = [target stringByAppendingString:str];
        if (i!=5) {
            target = [target stringByAppendingString:@":"];
        }
    }
    return [target uppercaseString];
}

-(NSData *)formatBleEdrBeData{

    NSArray *array = [self componentsSeparatedByString:@":"];
    NSMutableData *data = [NSMutableData new];
    for (NSString *item in array) {
        NSData *dt = [JL_Tools HexToData:item];
        [data appendData:dt];
    }
    return data;
}


-(NSString *)formatBleEdrBeDataStr{
    NSArray *array = [self componentsSeparatedByString:@":"];
    NSMutableData *data = [NSMutableData new];
    for (NSString *item in array) {
//        NSData *dt = [JL_Tools uInt8_data:[item intValue]];
        NSData *dt = [JL_Tools HexToData:item];
        [data appendData:dt];
    }
    return [JL_Tools dataChangeToString:data];
}


@end
