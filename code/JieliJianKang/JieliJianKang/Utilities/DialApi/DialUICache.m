//
//  DialUICache.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/7/20.
//

#import "DialUICache.h"


@interface DialUICache(){
    NSMutableArray  *mListArray;
    NSMutableArray  *mListCustomArray;
    JL_ManagerM     *mCmdManager;
}
@end

@implementation DialUICache

- (instancetype)init
{
    self = [super init];
    if (self) {
        mListArray = [NSMutableArray new];
        mListCustomArray = [NSMutableArray new];
    }
    return self;
}

-(void)setJLCmdManager:(JL_ManagerM *)cmdManeger{
    mCmdManager = cmdManeger;
}

#pragma mark - UI操作
static NSString *currentWatch = nil;
-(void)setCurrrentWatchName:(NSString*)name{
    currentWatch = name;
}

-(NSString*)currentWatchName{
    return currentWatch;
}

-(NSMutableArray*)getWatchList{
    return mListArray;
}
-(NSMutableArray*)newWatchList{
    mListArray = [NSMutableArray new];
    return mListArray;
}

-(void)addWatchListObject:(NSString*)watch{
    if (![mListArray containsObject:watch]) {
        [mListArray addObject:watch];
    }
}

-(void)removeWatchListObject:(NSString*)watch{
    [mListArray removeObject:watch];
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
}

-(void)removeWatchCustomListObject:(NSString*)watch{
    [mListCustomArray removeObject:watch];
}


JL_Timer *timerVersion = nil;
static NSMutableDictionary *mVersionDictionary = nil;
static NSMutableDictionary *mUUIDDictionary = nil;

-(NSMutableDictionary*)getWatchVersion:(NSArray*)array{
    [timerVersion cancelTimeout];
    [timerVersion threadContinue];
    
    timerVersion = [[JL_Timer alloc] init];
    timerVersion.subTimeout = 5;
    timerVersion.subScale = 1.0;
    
    mVersionDictionary = [NSMutableDictionary new];
    mUUIDDictionary = [NSMutableDictionary new];
    
    for (NSString *txt in array) {
        
        NSString *bigTxt = [txt uppercaseString];
        if (![bigTxt hasPrefix:@"WATCH"]) continue;
        
        /*--- 超时处理 ---*/
        [timerVersion waitForTimeoutResult:^{
            NSLog(@"--->Get Watch Version timeout.");
            [mVersionDictionary setObject:@"W001" forKey:bigTxt];
            [mUUIDDictionary setObject:@"" forKey:bigTxt];
            [timerVersion threadContinue];
        }];
        
        /*--- 读取表盘的版本 ---*/
        NSString *name = [NSString stringWithFormat:@"/%@",bigTxt];
        [mCmdManager.mFlashManager cmdWatchFlashPath:name Flag:JL_DialSettingVersion Result:^(uint8_t flag, uint32_t size,
                                                               NSString * _Nullable path,
                                                               NSString * _Nullable describe) {
            [timerVersion cancelTimeout];
            if (path.length > 0) {
                //--->GET WATCH Version:W001,ECF2E7ED-6EC7-4B75-858B-87D2ECE6CA11
                NSLog(@"--->GET %@ Version:%@ describe:%@",bigTxt,path,describe);
                NSArray *arr = [path componentsSeparatedByString:@","];
                NSString *ver = arr[0];
                
                if ([ver hasPrefix:@"W"]) {
                    [mVersionDictionary setObject:ver forKey:bigTxt];
                    
                    if(arr.count >= 2){
                        NSString *uuid = arr[1];
                        [mUUIDDictionary setObject:uuid forKey:bigTxt];
                    }else{
                        [mUUIDDictionary setObject:@"" forKey:bigTxt];
                    }
                    
                }else{
                    [mVersionDictionary setObject:@"W002" forKey:bigTxt];
                    [mUUIDDictionary setObject:@"" forKey:bigTxt];
                }
            } else {
                NSLog(@"--->#GET %@ Version:W001",bigTxt);
                [mVersionDictionary setObject:@"W001" forKey:bigTxt];
                [mUUIDDictionary setObject:@"" forKey:bigTxt];
            }
            [timerVersion threadContinue];
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

-(void)addVersion:(NSString*)version toWatch:(NSString*)watch{
    //NSLog(@"--->2 mVersionDictionary :%@",version);
    [mVersionDictionary setObject:version forKey:watch];
}

-(void)removeVersionOfWatch:(NSString*)watch{
    [mVersionDictionary removeObjectForKey:watch];
    [mUUIDDictionary removeObjectForKey:watch];
}

#pragma mark - 文件管理
+(NSString*)listUpgradeFileName:(NSString*)name Version:(NSString*)version{
    NSString *upgradeFile = [NSString stringWithFormat:@"%@_%@.zip",name,version];
    NSString *path = [JL_Tools findPath:NSLibraryDirectory MiddlePath:@"JL_WATCH_FACE" File:@""];
    if (path == nil) {
        path = [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"JL_WATCH_FACE" File:@""];
    }
    NSString *filePath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"JL_WATCH_FACE" File:upgradeFile];
    [JL_Tools removePath:filePath];
    return filePath;
}

+(NSString*)createUpgradeFileName:(NSString*)name Version:(NSString*)version{
    NSString *upgradeFile = [NSString stringWithFormat:@"%@_%@.zip",name,version];
    NSString *path = [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"JL_WATCH_FACE" File:upgradeFile];
    return path;
}

+(NSString*)getUpgradeFileName:(NSString*)name Version:(NSString*)version{
    NSString *upgradeFile = [NSString stringWithFormat:@"%@_%@.zip",name,version];
    NSString *path = [JL_Tools findPath:NSLibraryDirectory MiddlePath:@"JL_WATCH_FACE" File:upgradeFile];
    NSData *pathData = [NSData dataWithContentsOfFile:path];
    if (pathData.length == 0) path = nil;
    return path;
}

@end
