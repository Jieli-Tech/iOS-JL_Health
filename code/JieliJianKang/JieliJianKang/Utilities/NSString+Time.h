//
//  NSString+Time.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Time)

+ (NSString *)timeFormatted:(NSInteger)totalSeconds;
+ (NSString *)mmssTimeFormatted:(NSInteger)totalSeconds;
+ (NSString *)paceFormatted:(NSInteger)pace;
+ (NSDate *)dateTimeFormatted:(NSInteger)totalSeconds;

@end

NS_ASSUME_NONNULL_END
