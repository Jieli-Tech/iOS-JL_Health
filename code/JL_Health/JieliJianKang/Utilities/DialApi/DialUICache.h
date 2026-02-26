//
//  DialUICache.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/7/20.
//

#import <Foundation/Foundation.h>
#import <JL_BLEKit/JL_BLEKit.h>
#import <DFUnits/DFUnits.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *JL_WATCH_FACE_LIST = @"JL_WATCH_FACE_LIST";

typedef void(^DialCacheVersionBlock)(NSDictionary * _Nullable dic);

@interface DialUICache : NSObject

@property(nonatomic,assign)BOOL isSupportPayment;

/// 当前选中的手表表盘
@property(nonatomic,strong)NSString *currentWatch;

-(void)setJLCmdManager:(JL_ManagerM * __nullable)cmdManeger;

#pragma mark ---> UI操作
-(void)setCurrrentWatchName:(NSString*)name;
-(NSString*)currentWatchName;

-(NSMutableArray*)getWatchList;
-(NSMutableArray*)newWatchList;
-(NSArray <NSString *>*) getVersionList;
-(void)addWatchListObject:(NSString*)watch;
-(void)removeWatchListObject:(NSString*)watch;
-(void)clearWatchList;

-(NSMutableArray*)getWatchCustomList;
-(NSMutableArray*)newWatchCustomList;
-(void)addWatchCustomListObject:(NSString*)watch;
-(void)removeWatchCustomListObject:(NSString*)watch;

-(NSMutableDictionary*)getWatchVersion:(NSArray*)array;
-(NSString*)getVersionOfWatch:(NSString*)watch;
-(NSString*)getUuidOfWatch:(NSString*)watch;
-(void)setUuidOfWatch:(NSString*)watch uuid:(NSString *)uuid;
-(void)addVersion:(NSString*)version toWatch:(NSString*)watch;
-(void)removeVersionOfWatch:(NSString*)watch;

#pragma mark - 文件管理
+(NSString*)listUpgradeFileName:(NSString*)name Version:(NSString*)version;
+(NSString*)createUpgradeFileName:(NSString*)name Version:(NSString*)version;
+(NSString*)getUpgradeFileName:(NSString*)name Version:(NSString*)version;


@end

NS_ASSUME_NONNULL_END
