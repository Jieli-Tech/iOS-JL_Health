//
//  EcTools.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/11/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EcTools : NSObject
+(void)quickArray:(NSMutableArray *)array withLeftIndex:(NSInteger)leftIndex AndRightIndex:(NSInteger)rightIndex;

+ (NSDictionary *)properties_apsClass:(Class _Nullable)cls object:(id)model;

+ (NSDateFormatter *)cachedFm;

/// 获取一个用户 id / 设备 uuid 的文件夹组合路径
+(NSString *)appUserDevFolder;
@end

NS_ASSUME_NONNULL_END
