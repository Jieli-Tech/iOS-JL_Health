//
//  ECDrawTools.h
//  CoreDraw
//
//  Created by EzioChan on 2021/3/2.
//  Copyright © 2021 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreDraw/ECDrawAttribute.h>


typedef NS_ENUM(NSUInteger, ECDrawBgcType) {
    ECDrawBgc_TopLeftToBottomRight,
    ECDrawBgc_TopToBottom,
    ECDrawBgc_LeftToRight
};

NS_ASSUME_NONNULL_BEGIN


@interface ECDrawTools : NSObject

/// 画一条虚线
/// @param start 开始位置
/// @param end 结束位置
/// @param color 颜色
+(void)drawDashLine:(CGPoint)start To:(CGPoint)end with:(UIColor *)color;


/// 画一条直线
/// @param start 开始位置
/// @param end 结束位置
/// @param context 描绘句柄
+(void)drawLine:(CGPoint)start To:(CGPoint)end with:(CGContextRef)context;


/// 画上文字
/// @param text 字体内容
/// @param font 字体格式
/// @param color 字体颜色
/// @param rect 绘画位置
+(void)drawText:(NSString *)text font:(UIFont *)font color:(UIColor *)color rect:(CGRect)rect;

/// 绘制柱状图
/// @param context 描绘句柄
/// @param rect 内容位置
/// @param color 颜色
/// @param radius 圆角设置
+(void)drawCell:(CGContextRef)context rect:(CGRect)rect color:(UIColor *)color radius:(CGFloat )radius;

/// 绘制带圆角矩形
/// @param context 绘制句柄
/// @param rect 内容位置
/// @param color 背景色
/// @param radius 圆角
+(void)drawCell2:(CGContextRef)context rect:(CGRect)rect color:(UIColor *)color radius:(CGFloat)radius;

/// 描边填充色的矩形
/// @param context 句柄
/// @param rect 内容位置
/// @param fColor 填充颜色
/// @param width 边宽
/// @param sColor 描边颜色
+(void)drawRectangle:(CGContextRef)context rect:(CGRect)rect fillColor:(UIColor *)fColor lineWidth:(CGFloat)width StrokeColor:(UIColor *)sColor;

/// 绘制背景渐变色
/// /// 从左上到右下
/// @param scolor 开始
/// @param ecolor 结束
/// @param rect 内容
/// @param ctx 句柄
+(void)drawBackgroundColor:(UIColor *)scolor endColor:(UIColor *)ecolor Rect:(CGRect)rect ctx:(CGContextRef)ctx;

/// 绘制背景渐变色2
/// /// 从上到下
/// @param scolor 开始
/// @param ecolor 结束
/// @param rect 内容
/// @param ctx 句柄
+(void)drawBackgroundColor2:(UIColor *)scolor endColor:(UIColor *)ecolor Rect:(CGRect)rect ctx:(CGContextRef)ctx;

/// 绘制背景渐变色3
/// 从左到右
/// @param scolor 开始
/// @param ecolor 结束
/// @param rect 内容
/// @param ctx 句柄
+(void)drawBackgroundColor3:(UIColor *)scolor endColor:(UIColor *)ecolor Rect:(CGRect)rect ctx:(CGContextRef)ctx;

/// 绘制渐变色的折线全铺满图
/// @param ctx 句柄
/// @param colors 颜色
/// @param locations 颜色的比例
/// @param rect 位置
+(void)drawGradienLine:(CGContextRef)ctx colors:(CFArrayRef)colors locations:(CGFloat [_Nullable])locations rect:(CGRect)rect;

/// 绘制折线
/// @param pointList 折线列表
/// @param width 宽度
/// @param pcolor 颜色
/// @param context 句柄
+(void)drawBrokenLine:(NSArray *)pointList lineWidth:(CGFloat)width pathColor:(UIColor *)pcolor context:(CGContextRef)context;

/// 绘制图片
/// @param ctx 句柄
/// @param img 图片
/// @param rect 大小和位置
+(void)drawImage:(CGContextRef)ctx Image:(UIImage *)img Rect:(CGRect)rect;


/// 绘制圆
/// @param context 句柄
/// @param r 半径
/// @param p 圆心坐标
/// @param color 填充颜色
+(void)drawRoundFill:(CGContextRef)context radius:(CGFloat)r Rect:(CGPoint)p color:(UIColor *)color;

/// 圆形
/// @param radius 半径
/// @param color 颜色
/// @param point 圆心坐标
/// @param width 宽度
+(void)drawRoundStroke:(CGFloat)radius strokeColor:(UIColor *)color Rect:(CGPoint)point width:(CGFloat)width;

/// 绘制三角形
/// @param fillColor 填充颜色
/// @param rect 位置
/// @param oriental 方向
+(void)drawTriangle:(UIColor *)fillColor Rect:(CGRect)rect Oriental:(ECOrientation)oriental;

@end

NS_ASSUME_NONNULL_END
