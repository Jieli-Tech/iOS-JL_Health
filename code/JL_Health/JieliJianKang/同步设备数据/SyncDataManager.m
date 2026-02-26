//
//  SyncDataManager.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/11/2.
//

#import "SyncDataManager.h"
#import "SyncThreadManager.h"
#import "UserDataSync.h"
#import "JLSqliteSportRunningRecord.h"
#import "JLSqliteStep.h"
#import "JLSqliteHeartRate.h"
#import "JLSqliteOxyhemoglobinSaturation.h"
#import "JLSqliteSleep.h"

@interface SyncDataManager()<SyncThreadDelegate>{
    SyncThreadManager *syncTMgr;
    JL_HeartRateChart_CB  heartRateCb;
    JL_BloodOxyganChart_CB  bloodOxyganCb;
    JL_SleepChart_CB  sleepCb;
    JL_SportRecordData_CB sportRecordDtCb;
    JL_StepCount_CB stepcountCb;
}
@end

@implementation SyncDataManager

+(instancetype)share{
    static SyncDataManager *stm;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stm = [[SyncDataManager alloc] init];
    });
    return stm;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        syncTMgr = [[SyncThreadManager alloc] init];
        [syncTMgr setDelegate:self];
        //[JL_Tools add:kJL_RCSP_SEND Action:@selector(sendData:) Own:self];
        //[JL_Tools add:kJL_RCSP_RECEIVE Action:@selector(recivedData:) Own:self];
    }
    return self;
}

-(void)sendData:(NSNotification *)note{
    NSData *dt = note.object;
    NSLog(@"sendData:%@",dt);
}

-(void)recivedData:(NSNotification *)note{
    NSData *dt = note.object;
    NSLog(@"recivedData:%@",dt);
}

-(void)stopAllTask{
    [syncTMgr removeAllTask];
}


-(void)syncHeartRateData:(JL_EntityM *)entity with:(JL_HeartRateChart_CB)block{
    heartRateCb = block;
    JL_SmallFileManager *ft = [entity.mCmdManager mSmallFileManager];
    SyncObject *objc = [[SyncObject alloc] init];
    objc.type = JL_SmallFileTypeHeartRate;
    objc.smallFileManager = ft;
    [syncTMgr addTask:objc];
}


-(void)syncBloodOxyganData:(JL_EntityM *)entity with:(JL_BloodOxyganChart_CB)block{
    bloodOxyganCb = block;
    JL_SmallFileManager *ft = [entity.mCmdManager mSmallFileManager];
    SyncObject *objc = [[SyncObject alloc] init];
    objc.type = JL_SmallFileTypeSpoData;
    objc.smallFileManager = ft;
    [syncTMgr addTask:objc];
}

-(void)syncSleepData:(JL_EntityM *)entity with:(JL_SleepChart_CB)block{
    sleepCb = block;
    JL_SmallFileManager *ft = [entity.mCmdManager mSmallFileManager];
    SyncObject *objc = [[SyncObject alloc] init];
    objc.type = JL_SmallFileTypeSleepData;
    objc.smallFileManager = ft;
    [syncTMgr addTask:objc];
}

-(void)syncStepCountData:(JL_EntityM *)entity with:(JL_StepCount_CB)block{
    stepcountCb = block;
    JL_SmallFileManager *ft = [entity.mCmdManager mSmallFileManager];
    SyncObject *objc = [[SyncObject alloc] init];
    objc.type = JL_SmallFileTypeStepCount;
    objc.smallFileManager = ft;
    [syncTMgr addTask:objc];
}

-(void)syncSportRecordData:(JL_EntityM *)entity with:(JL_SportRecordData_CB)block{
    sportRecordDtCb = block;
    JL_SmallFileManager *ft = [entity.mCmdManager mSmallFileManager];
    SyncObject *objc = [[SyncObject alloc] init];
    objc.type = JL_SmallFileTypeMotionRecord;
    objc.smallFileManager = ft;
    [syncTMgr addTask:objc];
}


-(void)syncSportRecordData:(JL_EntityM *)entity BySportId:(UInt16)sportId with:(JL_SportRecordData_CB)block {
    sportRecordDtCb = block;
    JL_SmallFileManager *ft = [entity.mCmdManager mSmallFileManager];
    if (ft) {
        [syncTMgr syncById:sportId with:ft];
    }
}



//MARK: -数据回调处理
-(void)syncTaskFinish:(NSData *)data type:(JL_SmallFileType)type{
    //详情参见小文件格式，头部少于11byte，将认为是文件格式内容异常
    switch (type) {
        case JL_SmallFileTypeHeartRate:{
            if (data.length > 11) {
                JLWearSyncHealthHeartRateChart *hr = [[JLWearSyncHealthHeartRateChart alloc] initChart:data];
                heartRateCb(hr);
                [JLSqliteHeartRate s_sync_update:hr];
                [UserDataSync uploadHealthHeartRateData];
            } else {
                if (data) {
                    NSLog(@"小文件内容异常,详情参见小文件格式，头部少于11byte，将认为是文件格式内容异常");
                }
                heartRateCb(nil);
            }
        }break;
        case JL_SmallFileTypeSpoData:{
            if (data.length > 11) {
                JLWearSyncHealthBloodOxyganChart *hr = [[JLWearSyncHealthBloodOxyganChart alloc] initChart:data];
                bloodOxyganCb(hr);
                [JLSqliteOxyhemoglobinSaturation s_sync_update:hr];
                [UserDataSync uploadHealthSpoData];
            } else {
                if (data) {
                    NSLog(@"小文件内容异常,详情参见小文件格式，头部少于11byte，将认为是文件格式内容异常");
                }
                bloodOxyganCb(nil);
            }
        }break;
        case JL_SmallFileTypeSleepData:{
            if (data.length > 11) {
                JLWearSyncHealthSleepChart *sc = [[JLWearSyncHealthSleepChart alloc] initChart:data];
                sleepCb(sc);
                [JLSqliteSleep s_update:sc];
                [UserDataSync uploadHealthSleepData];
            } else {
                if (data) {
                    NSLog(@"小文件内容异常,详情参见小文件格式，头部少于11byte，将认为是文件格式内容异常");
                }
                sleepCb(nil);
            }
        }break;
        case JL_SmallFileTypeMotionRecord:{
            if (data.length > 11) {
                JLSportRecordModel *srm = [[JLSportRecordModel alloc] initWithData:data];
                sportRecordDtCb(srm);
                [JLSqliteSportRunningRecord s_update:srm];
                [UserDataSync uploadSportDataFile];
            } else {
                if (data) {
                    NSLog(@"小文件内容异常,详情参见小文件格式，头部少于11byte，将认为是文件格式内容异常");
                }
                sportRecordDtCb(nil);
            }
        }break;
        case JL_SmallFileTypeStepCount:{
            if (data.length > 11) {
                JLWearSyncHealthStepChart *model = [[JLWearSyncHealthStepChart alloc] initChart:data];
                stepcountCb(model);
                [JLSqliteStep s_update:model];
                [UserDataSync uploadHealthStepCountData];
            } else {
                if (data) {
                    NSLog(@"小文件内容异常,详情参见小文件格式，头部少于11byte，将认为是文件格式内容异常");
                }
                stepcountCb(nil);
            }
        }break;
        default:
            break;
    }
}


@end
