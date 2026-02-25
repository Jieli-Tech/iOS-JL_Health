//
//  WatchMarket.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/4/1.
//

#import <Foundation/Foundation.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

#define kJL_WATCH_FACE  @"JL_WATCH_FACE"

@interface WatchMarket : NSObject
@property(strong,nonatomic)NSMutableArray *watchList;
@property(strong,nonatomic)NSMutableArray *watchListFree;
@property(strong,nonatomic)NSMutableArray *watchListPay;

+(id)sharedMe;
-(void)searchAllWatchResult:(void(^)(void))result;
+(NSData *)getDataOfWatchIcon:(NSString*)name;
@end

NS_ASSUME_NONNULL_END
