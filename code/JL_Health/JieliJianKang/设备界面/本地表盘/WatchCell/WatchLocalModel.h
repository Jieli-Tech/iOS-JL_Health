//
//  WatchLocalModel.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/4/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(UInt8, WatchLocalType) {
    WatchLocalTypeInDevice  = 0,    //手表里的表盘
    WatchLocalTypeUpdate    = 1,    //可更新
    WatchLocalTypeDownload  = 2,    //可下载
    WatchLocalTypePay       = 3,    //需要购买
};
@interface WatchLocalModel : NSObject
@property(nonatomic,strong)NSString         *mName;
@property(nonatomic,strong)NSString         *mVersionStr;
@property(nonatomic,assign)int              mVersionNum;
@property(nonatomic,strong)NSDictionary     *mInfoDict;
@property(nonatomic,assign)WatchLocalType   mWatchType;
@end

NS_ASSUME_NONNULL_END
