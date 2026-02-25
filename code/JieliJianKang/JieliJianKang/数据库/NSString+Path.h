//
//  NSString+Path.h
//  Test
//
//  Created by EzioChan on 2021/4/25.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Path)

/// 生成Document下的path
-(NSString *)path;

/// 判断是否存在该文件
-(BOOL)isExist;

/// 加后缀
/// @param str 后缀
-(NSString *)addSuffix:(NSString *)str;

/// 获取最后一段String
-(NSString *)getSuffix;

/// 转成1970到现在的秒
-(NSTimeInterval)toDateInt;

/// 转成时间对象
-(NSDate *)toDateByNormal;

/// 根据沙盒路径获取data
-(NSData *)getData;

/// 比较是否会比当前值大，如果大了就返回NO
/// @param next 字符串“HH:mm:ss”
-(BOOL)compareTimeIntervalTo:(NSString *)next;

#pragma mark - 蓝牙地址转换

/// 蓝牙地址转换
-(NSString *)formatBleEdr;

/// 蓝牙地址转数据地址
-(NSString *)formatBleEdrBeDataStr;

-(NSData *)formatBleEdrBeData;

@end

NS_ASSUME_NONNULL_END
