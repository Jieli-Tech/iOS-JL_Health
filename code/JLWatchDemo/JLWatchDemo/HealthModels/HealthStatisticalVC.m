//
//  HealthStatisticalVC.m
//  JLWatchDemo
//
//  Created by EzioChan on 2022/4/14.
//



#import "HealthStatisticalVC.h"

@interface HealthStatisticalVC ()



@end

@implementation HealthStatisticalVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (IBAction)backBtnAction:(id)sender {
    
    [self dismissViewControllerAnimated:true completion:nil];
    
}


///去查询设备的文件列表
-(void)checkFileList{
    /**
     这里的示例是先去读取全天心跳记录的
     因为有可能设备已经好几天没同步心率数据到手机了，所以有可能出现多个列表
     但多个列表必然是按时间顺序排放的，最后的必定是最新的记录文件
     */
    [self.manager.mSmallFileManager cmdSmallFileQueryType:JL_SmallFileTypeHeartRate Result:^(NSArray<JLModel_SmallFile *> * _Nullable array) {
        //这里可能需要对这个数组进行保存，因为有可能是多天未同步，需要一并同步数据
        //当下假设只获取最后一个记录数据
        //首先这里需要去获取一下文件的头部数据（排除本地已存在的状况）
        
        JLModel_SmallFile *smFile = array.lastObject;
        //获取文件头
        [self.manager.mSmallFileManager cmdSmallFileReadType:smFile.file_type FileID:smFile.file_id Offset:0x00 FileSize:0x07 Flag:0x01 Result:^(uint8_t flag, uint16_t fileID, NSData * _Nullable data) {
            //根据已有的格式
            /**
             | 文件类型（1Byte）| 日期(年月日)（4Byte） | 文件校验码crc（2Byte）
             */
            NSDate *fileDate = [data subf:1 t:4].toDate;//这里可用SDK提供的方法进行吧4Byte的时间戳转换成时间
            //判断是否今天的数据，这里可以考虑匹配本地的数据的当天内容的CRC，如果CRC一致，则说明是同一份数据，不需要更新
            if ([self isSameDay:fileDate date2:[NSDate new]]) {
                //这里假设从本地读到了一个crc数据
                NSData *localCRC = [NSData new];
                NSData *devCrc = [data subf:5 t:2];
                if ([self isEqualToData:localCRC :devCrc]) {
                    //去下载当前文件的全部的数据
                    [self toDownloadAllData:smFile];
                    
                }
            }else{//如果不是当天的日期也去读取，或者做一下本地的数据查询再去决定是否下载
                [self toDownloadAllData:smFile];
            }
        }];
    
        
    }];

}



/// 去下载某个健康数据的文件
/// @param smFile 文件模型
-(void)toDownloadAllData:(JLModel_SmallFile *)smFile{
    NSMutableData *targetData = [NSMutableData new];
    [self.manager.mSmallFileManager cmdSmallFileRead:smFile Result:^(JL_SmallFileOperate status, float progress, NSData * _Nullable data) {
        if (data) {
            [targetData appendData:data];
        }
        switch (status) {
            case JL_SmallFileOperateFail:
                NSLog(@"传输失败了");
                break;
            case JL_SmallFileOperateDoing:
                //传输进度
                NSLog(@"传输中...%.2f",progress);
                break;
            case JL_SmallFileOperateSuceess:{
                NSLog(@"传输完成");
                JLWearSyncHealthChart *chart = [[JLWearSyncHealthChart alloc] init];
                [chart createHeadInfo:targetData];
                NSLog(@"把数据解析成图表");
            }break;
            case JL_SmallFileOperateUnknown:
                NSLog(@"传输失败了，未知错误，需要查看固件打印");
                break;
            case JL_SmallFileOperateExcess:
                NSLog(@"传输失败了，数据溢出，需要查看固件打印");
                break;
            case JL_SmallFileOperateCrcError:
                NSLog(@"传输失败了，crc校验错误，需要查看固件打印");
                break;
            case JL_SmallFileOperateTimeout:
                NSLog(@"传输失败了，传输超时，需要查看固件打印");
                break;
        }
    }];
    
}

///判断两个NSDate是否是同一天
- (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2 {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlag = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comp1 = [calendar components:unitFlag fromDate:date1];
    NSDateComponents *comp2 = [calendar components:unitFlag fromDate:date2];
    return [comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year] == [comp2 year];
}
///判断nsdata 是否相等
- (BOOL)isEqualToData:(NSData *)data1 :(NSData *)data2{
    if (data1.length != data2.length) {
        return false;
    }
    const char *bytes1 = data1.bytes;
    const char *bytes2 = data2.bytes;
    for (int i = 0; i<data1.length; i++) {
        if (bytes1[i] != bytes2[i]) {
            return false;
        }
    }
    return true;
}





@end
