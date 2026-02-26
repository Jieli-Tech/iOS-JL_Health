//
//  SyncThreadManager.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/11/2.
//

#import "SyncThreadManager.h"
#import "JLSqliteHeartRate.h"
#import "JLSqliteOxyhemoglobinSaturation.h"
#import "JLSqliteSleep.h"
#import "JLSqliteSportRunningRecord.h"
#import "JLSqliteStep.h"

@interface SyncThreadManager(){
    dispatch_semaphore_t semaphore;
    NSThread *requestQueue;
    NSMutableArray <SyncObject*>*requestArray;
    dispatch_queue_t queue;
    dispatch_queue_t queueSpFile;
    NSMutableArray <JLModel_SmallFile* >*smallFileList;
    NSMutableArray <JLWearSyncHealthChart *> *crcFileList;
    NSMutableArray <JL_SportRecord_Chart*> *recordChartList;
}
@end

@implementation SyncObject

@end


@implementation SyncThreadManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        requestArray = [NSMutableArray new];
        semaphore = dispatch_semaphore_create(1);
        queue= dispatch_queue_create("check_and_download_queue", DISPATCH_QUEUE_SERIAL);
        queueSpFile = dispatch_queue_create("check_and_download_SpFile_queue", DISPATCH_QUEUE_SERIAL);
        requestQueue = [[NSThread alloc] initWithTarget:self selector:@selector(requireToDevice) object:nil];
        [requestQueue start];
        smallFileList = [NSMutableArray new];
        crcFileList = [NSMutableArray new];
        recordChartList = [NSMutableArray new];
    }
    return self;
}

-(void)addTask:(SyncObject *)objc{
    if (objc.smallFileManager == nil) {
        kJLLog(JLLOG_DEBUG, @"sync thread 同步文件的句柄为空，请检查是否已连接设备！");
        return;
    }
    kJLLog(JLLOG_DEBUG, @"sync thread SyncObject:%@",[self typeBeString:objc.type]);
    if (requestArray.count == 0) {
        [requestArray addObject:objc];
        dispatch_semaphore_signal(semaphore);
        kJLLog(JLLOG_DEBUG, @"sync thread contiune sync thread %d",__LINE__);
    }else{
        [requestArray addObject:objc];
    }
    
}

-(void)removeAllTask{
    [requestArray removeAllObjects];
}


-(void)requireToDevice{
    while (1) {
        if (requestArray.count!=0){
            [self createTaskAction:requestArray.firstObject];
            kJLLog(JLLOG_DEBUG, @"sync thread output:%@",[self typeBeString:requestArray.firstObject.type]);
        }
        kJLLog(JLLOG_DEBUG, @"sync thread pause sync thread");
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
    }
}




-(void)createTaskAction:(SyncObject *)objc{
    
    switch (objc.type) {
        case JL_SmallFileTypeHeartRate:{
            dispatch_async(queue, ^{
                kJLLog(JLLOG_DEBUG, @"sync thread ----------> request heart rate small file");
                [objc.smallFileManager cmdSmallFileQueryType:objc.type Result:^(NSArray<JLModel_SmallFile *> * _Nullable array) {
                    kJLLog(JLLOG_DEBUG, @"sync thread ----------> response heart rate small file");
                    NSMutableArray *checkout = [NSMutableArray new];
                    NSDate *date = [NSDate new];
                    for (int i = 0; i<array.count; i++) {
                        NSDate *lastDay = [NSDate dateWithTimeInterval:-i*24*60*60 sinceDate:date];
                        [checkout addObject:lastDay];
                    }
                    if (array.count != 0) {
                        [JLSqliteHeartRate s_checkout:checkout Result:^(NSArray<JLWearSyncHealthHeartRateChart *> * _Nonnull charts) {
                            [self->smallFileList removeAllObjects];
                            [self->smallFileList setArray:array];
                            [self->crcFileList removeAllObjects];
                            [self->crcFileList setArray:charts];
                            [self startSyncForCRCListBy:objc];
                        }];
                    }else{
                        if([self->_delegate respondsToSelector:@selector(syncTaskFinish:type:)]){
                            [self->_delegate syncTaskFinish:NULL type:objc.type];
                            kJLLog(JLLOG_DEBUG, @"sync thread 不需要更新文件:%s,%d",__func__,__LINE__);
                        }
                        if (self->requestArray.count>0) {
                            [self->requestArray removeObjectAtIndex:0];
                        }
                        dispatch_semaphore_signal(self->semaphore);
                        kJLLog(JLLOG_DEBUG, @"sync thread contiune thread %d",__LINE__);
                    }
                }];
            });
        }break;
        case JL_SmallFileTypeSpoData:{
            dispatch_async(queue, ^{
                kJLLog(JLLOG_DEBUG, @"sync thread ----------> request SpoData small file");
                [objc.smallFileManager cmdSmallFileQueryType:objc.type Result:^(NSArray<JLModel_SmallFile *> * _Nullable array) {
                    kJLLog(JLLOG_DEBUG, @"sync thread ----------> response SpoData small file");
                    NSMutableArray *checkout = [NSMutableArray new];
                    NSDate *date = [NSDate new];
                    for (int i = 0; i<array.count; i++) {
                        NSDate *lastDay = [NSDate dateWithTimeInterval:-i*24*60*60 sinceDate:date];
                        [checkout addObject:lastDay];
                    }
                    if (array.count != 0) {
                        [JLSqliteOxyhemoglobinSaturation s_checkout:checkout Result:^(NSArray<JL_Chart_OxyhemoglobinSaturation *> * _Nonnull charts) {
                            [self->smallFileList removeAllObjects];
                            [self->smallFileList setArray:array];
                            [self->crcFileList removeAllObjects];
                            [self->crcFileList setArray:charts];
                            [self startSyncForCRCListBy:objc];
                        }];
                    }else{
                        if([self->_delegate respondsToSelector:@selector(syncTaskFinish:type:)]){
                            [self->_delegate syncTaskFinish:NULL type:objc.type];
                            kJLLog(JLLOG_DEBUG, @"sync thread 不需要更新文件:%s,%d",__func__,__LINE__);
                        }
                        if (self->requestArray.count>0) {
                            [self->requestArray removeObjectAtIndex:0];
                        }
                        dispatch_semaphore_signal(self->semaphore);
                        kJLLog(JLLOG_DEBUG, @"sync thread contiune thread %d",__LINE__);
                    }
                }];
            });
        }break;
        case JL_SmallFileTypeSleepData:{
            dispatch_async(queue, ^{
                kJLLog(JLLOG_DEBUG, @"sync thread ----------> request SleepData small file");
                [objc.smallFileManager cmdSmallFileQueryType:objc.type Result:^(NSArray<JLModel_SmallFile *> * _Nullable array) {
                    kJLLog(JLLOG_DEBUG, @"sync thread ----------> response SleepData small file");

                    NSMutableArray *checkout = [NSMutableArray new];
                    NSDate *date = [NSDate new];
                    for (int i = 0; i<array.count; i++) {
                        NSDate *lastDay = [NSDate dateWithTimeInterval:-i*24*60*60 sinceDate:date];
                        [checkout addObject:lastDay];
                    }
                    if (array.count != 0) {
                        [JLSqliteSleep s_checkout:checkout Result:^(NSArray<JLWearSyncHealthSleepChart *> * _Nonnull charts) {
                            [self->smallFileList removeAllObjects];
                            [self->smallFileList setArray:array];
                            [self->crcFileList removeAllObjects];
                            [self->crcFileList setArray:charts];
                            [self startSyncForCRCListBy:objc];
                        }];
                    }else{
                        if([self->_delegate respondsToSelector:@selector(syncTaskFinish:type:)]){
                            [self->_delegate syncTaskFinish:NULL type:objc.type];
                            kJLLog(JLLOG_DEBUG, @"sync thread 不需要更新文件:%s,%d",__func__,__LINE__);
                        }
                        if (self->requestArray.count>0) {
                            [self->requestArray removeObjectAtIndex:0];
                        }
                        dispatch_semaphore_signal(self->semaphore);
                        kJLLog(JLLOG_DEBUG, @"sync thread contiune thread %d",__LINE__);
                    }
                    
                }];
            });
        }break;
        case JL_SmallFileTypeMotionRecord:{
            dispatch_async(queue, ^{
                kJLLog(JLLOG_DEBUG, @"sync thread ----------> request MotionRecord small file");
                [objc.smallFileManager cmdSmallFileQueryType:objc.type Result:^(NSArray<JLModel_SmallFile *> * _Nullable array) {
                    kJLLog(JLLOG_DEBUG, @"sync thread ----------> response MotionRecord small file");

                    NSDate *startdate = [NSDate new];
                    NSDate *endDay = [NSDate dateWithTimeInterval:-5*24*60*60 sinceDate:startdate];
                    if (array.count != 0) {
                        [JLSqliteSportRunningRecord s_checkoutWtihStartDate:startdate withEndDate:endDay Result:^(NSArray<JL_SportRecord_Chart *> * _Nonnull charts) {
                            [self->smallFileList removeAllObjects];
                            [self->smallFileList setArray:array];
                            [self->recordChartList removeAllObjects];
                            [self->recordChartList setArray:charts];
                            [self startSyncForDateListBy:objc];
                        }];
                    }else{
                        if([self->_delegate respondsToSelector:@selector(syncTaskFinish:type:)]){
                            [self->_delegate syncTaskFinish:NULL type:objc.type];
                            kJLLog(JLLOG_DEBUG, @"sync thread 不需要更新文件:%s,%d",__func__,__LINE__);
                        }
                        if (self->requestArray.count>0) {
                            [self->requestArray removeObjectAtIndex:0];
                        }
                        dispatch_semaphore_signal(self->semaphore);
                        kJLLog(JLLOG_DEBUG, @"sync thread contiune thread %d",__LINE__);
                    }
                }];
            });
        }break;
        case JL_SmallFileTypeStepCount:{
            dispatch_async(queue, ^{
                kJLLog(JLLOG_DEBUG, @"sync thread ----------> request StepCount small file");
                [objc.smallFileManager cmdSmallFileQueryType:objc.type Result:^(NSArray<JLModel_SmallFile *> * _Nullable array) {
                    kJLLog(JLLOG_DEBUG, @"sync thread ----------> response StepCount small file");

                    NSMutableArray *checkout = [NSMutableArray new];
                    NSDate *date = [NSDate new];
                    for (int i = 0; i<array.count; i++) {
                        NSDate *lastDay = [NSDate dateWithTimeInterval:-i*24*60*60 sinceDate:date];
                        [checkout addObject:lastDay];
                    }
                    if (array.count != 0) {
                        [JLSqliteStep s_checkout:checkout Result:^(NSArray<JL_Chart_MoveSteps *> * _Nonnull charts) {
                            [self->smallFileList removeAllObjects];
                            [self->smallFileList setArray:array];
                            [self->crcFileList removeAllObjects];
                            [self->crcFileList setArray:charts];
                            [self startSyncForCRCListBy:objc];
                        }];
                    }else{
                        if([self->_delegate respondsToSelector:@selector(syncTaskFinish:type:)]){
                            [self->_delegate syncTaskFinish:NULL type:objc.type];
                            kJLLog(JLLOG_DEBUG, @"sync thread 不需要更新文件:%s,%d",__func__,__LINE__);
                        }
                        if (self->requestArray.count>0) {
                            [self->requestArray removeObjectAtIndex:0];
                        }
                        dispatch_semaphore_signal(self->semaphore);
                        kJLLog(JLLOG_DEBUG, @"sync thread contiune thread %d",__LINE__);
                    }
                }];
            });
        }break;
        default:
            break;
    }
}



-(void)startSyncSmallFile:(SyncObject *)objc{
    
    if (smallFileList.count == 0) {
        dispatch_semaphore_signal(self->semaphore);
        kJLLog(JLLOG_DEBUG, @"sync thread contiune thread %d",__LINE__);
        return;
    }
    NSMutableData *reciveData = [NSMutableData new];
    
    [objc.smallFileManager cmdSmallFileRead:smallFileList.lastObject Result:^(JL_SmallFileOperate status, float progress, NSData * _Nullable data) {
        [reciveData appendData:data];
        if (status == JL_SmallFileOperateSuceess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self->_delegate respondsToSelector:@selector(syncTaskFinish:type:)]){
                    [self->_delegate syncTaskFinish:reciveData type:objc.type];
                    kJLLog(JLLOG_DEBUG, @"sync thread 收到完整文件:%s,%d",__func__,__LINE__);
                }
            });
            [self->smallFileList removeLastObject];
            if (self->smallFileList.count>0){
                [self startSyncSmallFile:objc];
            }else{
                if([self->_delegate respondsToSelector:@selector(syncTaskFinish:type:)]){
                    [self->_delegate syncTaskFinish:NULL type:objc.type];
                    kJLLog(JLLOG_DEBUG, @"sync thread 不需要更新文件:%s,%d",__func__,__LINE__);
                }
                if (self->requestArray.count>0) {
                    [self->requestArray removeObjectAtIndex:0];
                }
                dispatch_semaphore_signal(self->semaphore);
                kJLLog(JLLOG_DEBUG, @"sync thread contiune thread %d",__LINE__);
            }
        }else if (status == JL_SmallFileOperateFail || status == JL_SmallFileOperateCrcError){
            kJLLog(JLLOG_DEBUG, @"sync thread 小文件读取发生错误：%d,%d",status,__LINE__);
        }
    }];
}



-(void)startSyncForCRCListBy:(SyncObject *)objc {
    
    if (crcFileList.count == 0) {
        [self startSyncSmallFile:objc];
        return;
    }
    JLWearSyncHealthChart *chart = crcFileList.lastObject;
    JLModel_SmallFile  *sf = smallFileList.lastObject;
    JLModel_SmallFile *reqSf = [JLModel_SmallFile new];
    reqSf.file_type = sf.file_type;
    reqSf.file_ver = sf.file_ver;
    reqSf.file_id = sf.file_id;
    reqSf.file_size = 8;
    NSMutableData *reciveData = [NSMutableData new];
    [objc.smallFileManager cmdSmallFileRead:reqSf Result:^(JL_SmallFileOperate status, float progress, NSData * _Nullable data) {
        
        if (status == JL_SmallFileOperateSuceess) {
            [reciveData appendData:data];
            uint16_t crc = [reciveData subf:5 t:2].beBigendUint16;
            if (crc == chart.crcCode && chart.crcCode != 0xFFFF) {
                if (self->requestArray.count>0) {
                    [self->requestArray removeObjectAtIndex:0];
                }
                dispatch_semaphore_signal(self->semaphore);
                kJLLog(JLLOG_DEBUG, @"sync thread contiune thread %d",__LINE__);
            }else{
                NSMutableData *recData = [NSMutableData new];
                [objc.smallFileManager cmdSmallFileRead:sf Result:^(JL_SmallFileOperate status, float progress, NSData * _Nullable data) {
                    [recData appendData:data];
                    if (status == JL_SmallFileOperateSuceess) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if([self->_delegate respondsToSelector:@selector(syncTaskFinish:type:)]){
                                [self->_delegate syncTaskFinish:recData type:objc.type];
                                kJLLog(JLLOG_DEBUG, @"sync thread 收到完整文件:%s,%d",__func__,__LINE__);
                            }
                        });
                        [self->crcFileList removeLastObject];
                        [self->smallFileList removeLastObject];
                        
                        if (self->crcFileList.count>0 && self->smallFileList.count>0){
                            [self startSyncForCRCListBy:objc];
                        }else if (self->smallFileList>0 && self->crcFileList.count == 0){
                            [self startSyncSmallFile:objc];
                        }else{
                            if (self->requestArray.count>0) {
                                [self->requestArray removeObjectAtIndex:0];
                            }
                            dispatch_semaphore_signal(self->semaphore);
                            kJLLog(JLLOG_DEBUG, @"sync thread contiune thread %d",__LINE__);
                        }
                    }else if (status == JL_SmallFileOperateFail || status == JL_SmallFileOperateCrcError){
                        kJLLog(JLLOG_DEBUG, @"sync thread 小文件读取发生错误：%d,%d",status,__LINE__);
                    }
                }];
            }
        }else if (status == JL_SmallFileOperateFail || status == JL_SmallFileOperateCrcError){
            kJLLog(JLLOG_DEBUG, @"sync thread 小文件读取发生错误：%d,%d",status,__LINE__);
        }else{
            [reciveData appendData:data];
        }
    }];
}




-(void)startSyncForDateListBy:(SyncObject *)objc{
    
    if (recordChartList.count == 0) {
        [self startSyncSmallFile:objc];
        return;
    }

    JL_SportRecord_Chart *chart = recordChartList.lastObject;
    JLModel_SmallFile  *sf = smallFileList.lastObject;
    JLModel_SmallFile *reqSf = [JLModel_SmallFile new];
    reqSf.file_type = sf.file_type;
    reqSf.file_ver = sf.file_ver;
    reqSf.file_id = sf.file_id;
    reqSf.file_size = 30;
    NSMutableData *reciveData = [NSMutableData new];
    [objc.smallFileManager cmdSmallFileRead:reqSf Result:^(JL_SmallFileOperate status, float progress, NSData * _Nullable data) {
        [reciveData appendData:data];
        if (status == JL_SmallFileOperateSuceess) {
            NSDate *dt0 = [JLSportRecordModel startDate:data];
            NSTimeInterval t1 = [dt0 timeIntervalSince1970];
            NSTimeInterval t2 = [chart.dataArray.firstObject.startDate timeIntervalSince1970];
            if (t1 == t2) {
                if (self->requestArray.count>0) {
                    [self->requestArray removeObjectAtIndex:0];
                }
                dispatch_semaphore_signal(self->semaphore);
                kJLLog(JLLOG_DEBUG, @"sync thread contiune thread %d",__LINE__);
            }else{
                NSMutableData *recData = [NSMutableData new];
                [objc.smallFileManager cmdSmallFileRead:sf Result:^(JL_SmallFileOperate status, float progress, NSData * _Nullable data) {
                    [recData appendData:data];
                    if (status == JL_SmallFileOperateSuceess) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if([self->_delegate respondsToSelector:@selector(syncTaskFinish:type:)]){
                                [self->_delegate syncTaskFinish:recData type:objc.type];
                                kJLLog(JLLOG_DEBUG, @"sync thread 收到完整文件:%s,%d",__func__,__LINE__);
                            }
                        });
                        [self->recordChartList removeLastObject];
                        [self->smallFileList removeLastObject];
                        if (self->recordChartList.count>0 && self->smallFileList.count>0){
                            [self startSyncForDateListBy:objc];
                        }else if (self->smallFileList.count>0 && self->recordChartList.count == 0){
                            [self startSyncSmallFile:objc];
                        }else{
                            if (self->requestArray.count>0) {
                                [self->requestArray removeObjectAtIndex:0];
                            }
                            dispatch_semaphore_signal(self->semaphore);
                            kJLLog(JLLOG_DEBUG, @"sync thread contiune thread %d",__LINE__);
                        }
                    }else if (status == JL_SmallFileOperateFail || status == JL_SmallFileOperateCrcError){
                        kJLLog(JLLOG_DEBUG, @"sync thread 小文件读取发生错误：%d,%d",status,__LINE__);
                    }
                }];
            }
        }else if (status == JL_SmallFileOperateFail || status == JL_SmallFileOperateCrcError){
            kJLLog(JLLOG_DEBUG, @"sync thread 小文件读取发生错误：%d,%d",status,__LINE__);
        }
    }];
}

-(void)syncById:(UInt16 )spid with:(JL_SmallFileManager *)ft{
    dispatch_async(queueSpFile, ^{
        [ft cmdSmallFileQueryType:JL_SmallFileTypeMotionRecord Result:^(NSArray<JLModel_SmallFile *> * _Nullable array) {
            JLModel_SmallFile *targetSf;
            for (JLModel_SmallFile *sf in array) {
                if (sf.file_id == spid) {
                    targetSf = sf;
                    break;
                }
            }
            if (targetSf) {
                NSMutableData *reciveData = [NSMutableData new];
                [ft cmdSmallFileRead:targetSf Result:^(JL_SmallFileOperate status, float progress, NSData * _Nullable data) {
                    [reciveData appendData:data];
                    if (status == JL_SmallFileOperateSuceess) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if([self->_delegate respondsToSelector:@selector(syncTaskFinish:type:)]){
                                [self->_delegate syncTaskFinish:reciveData type:JL_SmallFileTypeMotionRecord];
                                kJLLog(JLLOG_DEBUG, @"sync thread 收到完整文件:%s,%d",__func__,__LINE__);
                            }
                        });
                    }else if (status == JL_SmallFileOperateFail || status == JL_SmallFileOperateCrcError){
                        kJLLog(JLLOG_DEBUG, @"sync thread 小文件读取发生错误：%d,%d",status,__LINE__);
                    }
                }];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([self->_delegate respondsToSelector:@selector(syncTaskFinish:type:)]){
                        [self->_delegate syncTaskFinish:nil type:JL_SmallFileTypeMotionRecord];
                        kJLLog(JLLOG_DEBUG, @"sync thread 未找到对应运动ID:%s,%d",__func__,__LINE__);
                    }
                });
            }
        }];
        
        
    });
}



-(NSString *)typeBeString:(JL_SmallFileType)type{
    switch (type) {
        case JL_SmallFileTypeContacts:
            return @"通讯录";
            break;
        case JL_SmallFileTypeMotionRecord:
            return @"运动记录";
            break;
        case JL_SmallFileTypeHeartRate:
            return @"心率";
            break;
        case JL_SmallFileTypeSpoData:
            return @"血氧";
            break;
        case JL_SmallFileTypeSleepData:
            return @"睡眠";
            break;
        case JL_SmallFileTypeMassage:
            return @"消息信息";
            break;
        case JL_SmallFileTypeWeather:
            return @"天气信息";
            break;
        case JL_SmallFileTypeCallLog:
            return @"通话记录";
            break;
        case JL_SmallFileTypeStepCount:
            return @"步数";
            break;
        case JL_SmallFileTypeWeight:
            return @"体重";
            break;
    }
}


@end
