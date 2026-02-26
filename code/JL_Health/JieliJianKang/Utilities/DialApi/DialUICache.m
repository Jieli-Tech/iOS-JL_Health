//
//  DialUICache.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/7/20.
//

#import "DialUICache.h"
#import "WatchMarket.h"


@interface DialUICache(){
    NSMutableArray  *mListArray;
    NSMutableArray  *mListCustomArray;
    JL_ManagerM     *mCmdManager;
    NSMutableArray  *mListVersion;
    NSMutableArray  *getVersionList;
    DialCacheVersionBlock getVersionBlock;
    NSMutableDictionary *mVersionDictionary;
    NSMutableDictionary *mUUIDDictionary;
    JL_Timer         *timerVersion;
}
@end

@implementation DialUICache

- (instancetype)init
{
    self = [super init];
    if (self) {
        mListArray = [NSMutableArray new];
        mListCustomArray = [NSMutableArray new];
        mListVersion = [NSMutableArray new];
        timerVersion = [[JL_Timer alloc] init];
        timerVersion.subTimeout = 5;
        timerVersion.subScale = 1.0;
    }
    return self;
}

-(void)setJLCmdManager:(JL_ManagerM *)cmdManeger{
    mCmdManager = cmdManeger;
}

#pragma mark - UI操作

-(void)setCurrrentWatchName:(NSString*)name{
    self.currentWatch = name;
}

-(NSString*)currentWatchName{
    return self.currentWatch;
}

-(NSMutableArray*)getWatchList{
    return mListArray;
}
-(NSMutableArray*)newWatchList{
    mListArray = [NSMutableArray new];
    [JL_Tools post:JL_WATCH_FACE_LIST Object:mListArray];
    return mListArray;
}

-(void)addWatchListObject:(NSString*)watch{
    if (![mListArray containsObject:watch]) {
        [mListArray addObject:watch];
        [JL_Tools post:JL_WATCH_FACE_LIST Object:mListArray];
        kJLLog(JLLOG_DEBUG, @"addWatchListObject:%@",watch);
    }else{
        kJLLog(JLLOG_DEBUG, @"addWatchListObject:repeat:%@",watch);
    }
}

-(void)removeWatchListObject:(NSString*)watch{
    [mListArray removeObject:watch];
    [JL_Tools post:JL_WATCH_FACE_LIST Object:mListArray];
    kJLLog(JLLOG_DEBUG, @"removeWatchListObject:%@",watch);
}

-(void)clearWatchList{
    [mListArray removeAllObjects];
    [JL_Tools post:JL_WATCH_FACE_LIST Object:mListArray];
}

-(NSArray <NSString *>*) getVersionList {
    return mListVersion;
}

-(NSMutableArray*)getWatchCustomList{
    return mListCustomArray;
}

-(NSMutableArray*)newWatchCustomList{
    mListCustomArray = [NSMutableArray new];
    return mListCustomArray;
}

-(void)addWatchCustomListObject:(NSString*)watch{
    if (![mListCustomArray containsObject:watch]) {
        [mListCustomArray addObject:watch];
    }
    kJLLog(JLLOG_DEBUG, @"set watch List");
    for (NSString *txt in mListCustomArray) {
        kJLLog(JLLOG_DEBUG, @"--->watch:%@",txt);
    }
}

-(void)removeWatchCustomListObject:(NSString*)watch{
    [mListCustomArray removeObject:watch];
}

-(NSMutableDictionary*)getWatchVersion:(NSArray*)array{
    [timerVersion cancelTimeout];
    mVersionDictionary = [NSMutableDictionary new];
    mUUIDDictionary = [NSMutableDictionary new];
    __weak DialUICache *weakSelf = self;
    
    for (NSString *txt in array) {
        
        NSString *bigTxt = [txt uppercaseString];
        if (![bigTxt hasPrefix:@"WATCH"]) continue;
        
        /*--- 超时处理 ---*/
        [timerVersion waitForTimeoutResult:^{
            __strong DialUICache *strongSelf = weakSelf;
            kJLLog(JLLOG_DEBUG, @"--->Get Watch Version timeout.");
            [strongSelf->mVersionDictionary setObject:@"W001" forKey:bigTxt];
            [strongSelf->mUUIDDictionary setObject:@"" forKey:bigTxt];
            [strongSelf->timerVersion threadContinue];
        }];
        
        /*--- 读取表盘的版本 ---*/
        NSString *name = [NSString stringWithFormat:@"/%@",bigTxt];
        [mCmdManager.mFlashManager cmdWatchFlashPath:name Flag:JL_DialSettingVersion Result:^(uint8_t flag, uint32_t size,
                                                               NSString * _Nullable path,
                                                               NSString * _Nullable describe) {
            __strong DialUICache *strongSelf = weakSelf;
            [strongSelf->timerVersion cancelTimeout];
            if (path.length > 0) {
                //--->GET WATCH Version:W001,ECF2E7ED-6EC7-4B75-858B-87D2ECE6CA11
                kJLLog(JLLOG_DEBUG, @"--->GET %@ Version:%@ describe:%@",bigTxt,path,describe);
                NSArray *arr = [path componentsSeparatedByString:@","];
                NSString *ver = arr[0];
                if (![self->mListVersion containsObject:ver]){
                    [self->mListVersion addObject:ver];
                }
                if ([ver hasPrefix:@"W"]) {
                    [strongSelf->mVersionDictionary setObject:ver forKey:bigTxt];
                    
                    if(arr.count >= 2){
                        NSString *uuid = arr[1];
                        [strongSelf->mUUIDDictionary setObject:uuid forKey:bigTxt];
                    }else{
                        [strongSelf->mUUIDDictionary setObject:@"" forKey:bigTxt];
                    }
                    
                }else{
                    [strongSelf->mVersionDictionary setObject:@"W002" forKey:bigTxt];
                    [strongSelf->mUUIDDictionary setObject:@"" forKey:bigTxt];
                }
            } else {
                kJLLog(JLLOG_DEBUG, @"--->#GET %@ Version:W001",bigTxt);
                [strongSelf->mVersionDictionary setObject:@"W001" forKey:bigTxt];
                [strongSelf->mUUIDDictionary setObject:@"" forKey:bigTxt];
            }
            [strongSelf->timerVersion threadContinue];
        }];
        [timerVersion threadWait];
    }
    return mVersionDictionary;
}

-(NSString*)getVersionOfWatch:(NSString*)watch{
    NSString *ver = mVersionDictionary[watch];
    if (ver.length == 0) ver = @"W001";
    return ver;
}

-(NSString*)getUuidOfWatch:(NSString*)watch{
    NSString *uuid = mUUIDDictionary[watch];
    if (uuid.length == 0) uuid = @"";
    return uuid;
}

-(void)setUuidOfWatch:(NSString*)watch uuid:(NSString *)uuid{
    [mUUIDDictionary setValue:uuid forKey:watch];
}

-(void)addVersion:(NSString*)version toWatch:(NSString*)watch{
    //kJLLog(JLLOG_DEBUG, @"--->2 mVersionDictionary :%@",version);
    [mVersionDictionary setObject:version forKey:watch];
}

-(void)removeVersionOfWatch:(NSString*)watch{
    [mVersionDictionary removeObjectForKey:watch];
    [mUUIDDictionary removeObjectForKey:watch];
}

#pragma mark - 文件管理
+(NSString*)listUpgradeFileName:(NSString*)name Version:(NSString*)version{
    NSString *upgradeFile = [NSString stringWithFormat:@"%@_%@.zip",name,version];
    NSString *middle = [NSString stringWithFormat:@"%@/%@",[EcTools appUserDevFolder],kJL_WATCH_FACE];
    NSString *path = [JL_Tools findPath:NSLibraryDirectory MiddlePath:middle File:@""];
    if (path == nil) {
        path = [JL_Tools createOn:NSLibraryDirectory MiddlePath:middle File:@""];
    }
    NSString *filePath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:middle File:upgradeFile];
    [JL_Tools removePath:filePath];
    return filePath;
}

+(NSString*)createUpgradeFileName:(NSString*)name Version:(NSString*)version{
    NSString *upgradeFile = [NSString stringWithFormat:@"%@_%@.zip",name,version];
    NSString *middle = [NSString stringWithFormat:@"%@/%@",[EcTools appUserDevFolder],kJL_WATCH_FACE];
    NSString *path = [JL_Tools createOn:NSLibraryDirectory MiddlePath:middle File:upgradeFile];
    return path;
}

+(NSString*)getUpgradeFileName:(NSString*)name Version:(NSString*)version{
    NSString *upgradeFile = [NSString stringWithFormat:@"%@_%@.zip",name,version];
    NSString *middle = [NSString stringWithFormat:@"%@/%@",[EcTools appUserDevFolder],kJL_WATCH_FACE];
    NSString *path = [JL_Tools findPath:NSLibraryDirectory MiddlePath:middle File:upgradeFile];
    NSData *pathData = [NSData dataWithContentsOfFile:path];
    if (pathData.length == 0) path = nil;
    return path;
}

@end
