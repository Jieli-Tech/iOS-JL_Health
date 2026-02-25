//
//  StoreIAPManager.h
//  01-内购
//
//  Created by hp on 2022/5/15.
//  Copyright © 2022 itheima. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    SIAPPurchSuccess = 0,               // 购买成功
    SIAPPurchFailed = 1,                // 购买失败
    SIAPPurchCancell = 2,               // 取消购买
    SIAPPurchVerFailed = 3,             // 订单校验失败
    SIAPPurchVerSuccess = 4,            // 订单校验成功
    SIAPPurchNotArrow = 5,              // 不允许内购
    SIAPPurchSellOut  =6,               // 商品已售罄
    SIAPPurchasing    =7,               // 正在购买
    SIAPPurchVerFailedNoReply = 8,      // 订单校验失败
}SIAPPurchType;

typedef void (^IAPCompletionHandle)(SIAPPurchType type,NSString *data);

@interface StoreIAPManager : NSObject

/**
 获取内购业务对象

 @return 内购业务对象
 */
+ (instancetype)shareSIAPManager;


/**
 开始内购

 @param purchID 苹果后台的虚拟商品ID
 @param handle 请求事务回调类型，返回的数据
 */
- (void)startPurchWithID:(NSString *)purchID completeHandle:(IAPCompletionHandle)handle;

@end

NS_ASSUME_NONNULL_END
