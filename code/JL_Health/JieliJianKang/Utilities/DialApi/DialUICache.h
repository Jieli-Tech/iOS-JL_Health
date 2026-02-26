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

@interface DialUICache : NSObject
@property(nonatomic,assign)BOOL isSupportPayment;

-(void)setJLCmdManager:(JL_ManagerM * __nullable)cmdManeger;

#pragma mark ---> UI操作
-(void)setCurrrentWatchName:(NSString*)name;
-(NSString*)currentWatchName;

-(NSMutableArray*)getWatchList;
-(NSMutableArray*)newWatchList;
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
-(void)addVersion:(NSString*)version toWatch:(NSString*)watch;
-(void)removeVersionOfWatch:(NSString*)watch;

#pragma mark - 文件管理
+(NSString*)listUpgradeFileName:(NSString*)name Version:(NSString*)version;
+(NSString*)createUpgradeFileName:(NSString*)name Version:(NSString*)version;
+(NSString*)getUpgradeFileName:(NSString*)name Version:(NSString*)version;


@end

NS_ASSUME_NONNULL_END
