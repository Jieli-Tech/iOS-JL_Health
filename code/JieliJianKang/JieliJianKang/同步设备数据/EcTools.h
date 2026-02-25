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

@end

NS_ASSUME_NONNULL_END
