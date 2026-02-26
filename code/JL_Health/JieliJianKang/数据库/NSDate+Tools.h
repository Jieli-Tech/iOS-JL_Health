//
//  NSDate+Tools.h
//  Test
//
//  Created by EzioChan on 2021/4/26.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StartAndEndDate:NSObject

@property(nonatomic,strong)NSDate *start;

@property(nonatomic,strong)NSDate *end;

@end

@interface NSDate (Tools)

- (NSString *)toYYYY;

- (NSString *)toYYYYMM;

- (NSString *)toYYYYMMdd;

- (NSString *)toYYYYMMdd2;

-(NSString *)toMM;

- (NSString *)toMMdd;

- (NSString *)toMMdd2;

- (NSString *)toMMdd3;

- (NSString *)toHHmmss;

- (NSString *)toHHmm;

- (NSString *)tommss;

- (NSString *)toAllDate;

- (NSData *)toBit32Data;

/**
 *  获取当天零时
 */
- (NSDate *)toStartOfDate;

/**
 *  获取当天23时59分59秒
 */
- (NSDate *)toEndOfDate;

/**
 *  字符串转NSDate
 *  @prama dateFormatterString @"2015-06-15 16:01:03"
 *  @return NSDate对象
 */
+ (NSDate *)dateWtihString:(NSString *)dateFormatterString;

/**
 *  字符串转NSDate
 *  @prama dateFormatterString @"2015-06-15 16:01:03"
 *  @prama dateFormat @"yyyy-MM-dd HH:mm:ss"
 *  @return NSDate对象
 */
+ (NSDate *)dateWtihString:(NSString *)dateFormatterString withDateFormat:(NSString *)dateFormat;

/// 下一天
-(NSDate *)next;

/// 上一天
-(NSDate *)before;

/// 下一周
-(NSDate *)nextWeek;

/// 上一周
-(NSDate *)beforeWeek;

/// 下个月
-(NSDate *)nextMonth;

/// 下个月 （允许超过当前时间）
-(NSDate *)nextMonth_0;

/// 上个月
-(NSDate *)beforeMonth;

///下一年
-(NSDate *)nextYear;

///上一年
-(NSDate *)beforeYear;

/// 当前是否在某个区间之间
- (BOOL)isBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

/// 在今天之前
-(BOOL)beforeNow;
/// 在这周之前
-(BOOL)beforeThisWeek;
/// 在这个月之前
-(BOOL)beforeThisMonth;
/// 在今年之前
-(BOOL)beforeThisYear;
/// 在今天之前(不含当前）
-(BOOL)beforeNow_0;
/// 在这周之前(不含当前）
-(BOOL)beforeThisWeek_0;
/// 在这个月之前(不含当前）
-(BOOL)beforeThisMonth_0;
/// 在今年之前(不含当前）
-(BOOL)beforeThisYear_0;

/// 当前这一天的一周始末
-(StartAndEndDate *)thisWeek;

/// 当前这个月的始末
-(StartAndEndDate *)thisMonth;

/// 当前这个年的始末
-(StartAndEndDate *)thisYear;

/// 判断是周几：1~7
-(NSInteger)witchWeekDay;

/// 当前时间对应几号
-(NSInteger)witchDay;

/// 当前时间是几月
-(NSInteger)witchMonth;

/// 当前时间对应的月有多少天
-(NSInteger)monthDayCount;

/// 当前时间对应的年有多少天
-(NSInteger)yearDayCount;

/// 获取当前时间的周格式
-(NSString *)standardDate;

/// 获取当前时间整月的列表
-(NSArray *)thisMonthDays;

-(NSArray *)thisYearMonths;

@end

NS_ASSUME_NONNULL_END
