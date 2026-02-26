//
//  JLWatchHttp.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2022/6/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface JLWatchHttp : NSObject

/**
  根据pid、vid查询表盘产品信息
 */
+(void)requestWatchInfoPid:(int)pid
                       Vid:(int)vid
                    Result:(void(^)(NSDictionary *info))result;

/**
  根据手表ID获取表盘市场里【免费表盘】或【付费表盘】
 */
+(void)requestDialsID:(NSString *)dialID
               IsFree:(BOOL)isFree
                 Page:(int )page Size:(int)size
               Result:(void(^)(NSArray *info))result;


/**
  根据表盘唯一UUID，pid，vid获取表盘信息及图片
 */
+(void)getDialInfoWithUUID:(NSString *)uuid Pid:(int)pid Vid:(int)vid
                     IsPay:(BOOL)isPay Result:(void(^)(NSDictionary *info))result;

/**
   获取表盘的下载url
 */
+(void)getDialDownloadUrlWithID:(NSString *)idstr Result:(void(^)(NSDictionary *info))result;

/**
    校验账单是否成功支付
 */
+(void)verifyReceipt:(NSString *)receipt
           isSandBox:(BOOL)isBox
              ShopID:(NSString*)shopId
              Result:(void(^)(NSDictionary *info))result;
/**
   免费表盘支付
 */
+(void)payForFreeDialShopID:(NSString*)shopId
                     Result:(void(^)(NSDictionary *info))result;


/**
    购买记录
 */
+(void)requestPayRecordPage:(int )page Size:(int)size
                     Result:(void(^)(NSArray *info))result;

/**
     删除付款记录
 */
+(void)deleteHistoryDialRecordID:(NSString*)shopId
                        Result:(void(^)(NSDictionary *info))result;

@end

NS_ASSUME_NONNULL_END
