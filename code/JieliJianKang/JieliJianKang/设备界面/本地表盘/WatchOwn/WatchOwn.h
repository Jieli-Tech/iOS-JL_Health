//
//  WatchOwn.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2022/5/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *kUI_WATCH_OWN_OPERATION;
//extern NSString *kUI_WATCH_OWN_MORE;

typedef NS_ENUM(UInt8, WatchUIType) {
    //免费表盘
    WatchUITypeFree    = 0,
    //付费表盘
    WatchUITypePay     = 1,
    //设备表盘
    WatchUITypeDevice  = 2,
    //表盘购买记录
    WatchUITypeHistory = 3,
    //旧版API，无购买信息的表盘
    WatchUITypeNoPayment = 4,
};

@interface WatchOwn : UIView
@property(nonatomic,strong)NSString *mSubTitleText;
@property(nonatomic,strong)NSString *mMoreBtnText;
@property(nonatomic,assign)WatchUIType mWatchUiType;
@property(nonatomic,weak)UIViewController *superVC;

- (instancetype)initByFrame:(CGRect)frame;

/*
    加载：服务器免费表盘。
 */
- (NSInteger)reloadMyWatchForFree:(int)count;

/*
    加载：服务器付费表盘。
 */
- (NSInteger)reloadMyWatchForPay:(int)count;

/*
    加载：设备里的所有表盘。
 */
- (NSInteger)reloadMyWatchInDevice;

/*
    加载：购买过的表盘。
 */
- (NSInteger)reloadMyWatchInHistory;

/*
    加载：旧版API，无购买信息的表盘。
 */
- (NSInteger)reloadMyWatchForNoPayment;


@end

NS_ASSUME_NONNULL_END
