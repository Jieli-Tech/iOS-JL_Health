//
//  JLColor.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLColor : NSObject

+ (UIColor *)colorWithString:(NSString *)stringToConvert;

/**
 *    covert the color string(#FFFFFF) to UIColor
 *
 *    @param     stringToConvert     string format(#FFFFFF)
 *    @param     alpha
 *
 *    @return
 */
+ (UIColor *)colorWithString:(NSString *)stringToConvert alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
